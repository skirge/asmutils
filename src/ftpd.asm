;Copyright (C) 2002 Attila Monoses <ata@email.ro>
;
;$Id: ftpd.asm,v 1.2 2002/06/11 08:45:10 konst Exp $
;
;hackers' ftpd
;
;syntax :       ftpd root_directory port
;
;example:       ftpd /home/ftpd 12345
;
;in root_directory must exist bin/ls
;(ftpd uses it for LIST request)
;
;works with console client,
;and also with mc & wincommander if root_directory/bin/ls = /bin/ls
;(the asmutils ls' output is different then the one distributed with linux
;and the visual clients like mc,wc can't parse it.
;the console client only outputs it for human view)
;
;user may be anything, no password requested
;
;most important insufficiency is that ABOR is not yet implemented
;if user client interrupts data transmition, its server process
;will end thus user must reconnect if has more stuff to do
;
;does not support default data port (tcp20)
;tested clients don't use it but some might
;
;must execute as root or made setuid (uses chroot)
;otherwise everything is shared

%include "system.inc"

CODESEG

%define req_len 1024
%define buff_size 8192

%define LF 10
%define EOL 13,10

%define rep_150 1
%define rep_200 2
%define rep_215 3
%define rep_220 4
%define rep_221 5
%define rep_226 6
%define rep_230 7
%define rep_250 8
%define rep_257 9
%define rep_421 10
%define rep_502 11
%define rep_550 12
%define rep_LF 13
%define rep_CRLF 14

setsockoptvals	dd 1

ls		db '/bin/ls',0
lsarg		db '-la',0
parent_dir	db '..',0

;___________________________________________________________________________________________
;               responses messages
;-------------------------------------------------------------------------------------------

rep_l db 15,23,16,19,34,24,20,20,20,5,31,30,35,1,2
;first byte is length of table

rep_1	db '150 Transfer starting',EOL
rep_2	db '200 Command ok',EOL
rep_3	db '215 UNIX Type: L8',EOL
rep_4	db '220 Asmutils FTP server ready...',EOL
rep_5	db '221 Closing connection',EOL
rep_6	db '226 File action ok',EOL
rep_7	db '230 User logged in',EOL
rep_8	db '250 File action ok',EOL
rep_9	db '257 "'
rep_10	db '421 Error, closing connection',EOL
rep_11	db '502 Command not implemented.',EOL
rep_12	db '550 Request file action not taken',EOL
rep_13	db 10
rep_14	db 13,10

;___________________________________________________________________________________________

START:

    pop ebp
    cmp ebp,byte 3                              ;at least 2 args

    jb .false_exit

    pop esi                                     ;skip program name
    pop dword[root]                             ;document root

    pop esi                                     ;port number

    sys_signal SIGCHLD,SIG_IGN                  ;avoid zombi

    xor eax,eax
    xor ebx,ebx

.n1:
    lodsb                                       ;bx <- port
    sub al,'0'
    jb .n2
    imul ebx,byte 10
    add ebx,eax
    jmps .n1

.n2:
    xchg bh,bl                                  ;bindsockstruct <- portl,porth,0,AF_INET
    shl ebx,16
    mov bl,AF_INET
    mov edi,bindctrl                            ;opt2
    mov [edi],ebx
    mov dword[edi+4],0                          ;INADDR_ANY

.begin:
    sys_socket PF_INET,SOCK_STREAM,IPPROTO_TCP  ;and let there be a socket...
    test eax,eax
    js .false_exit
    mov ebp,eax                                 ;ebp <- meet socket descriptor

    sys_setsockopt ebp,SOL_SOCKET,SO_REUSEADDR,setsockoptvals,4
    or eax,eax
    jz .do_bind

.false_exit:                                    ;exit_stuff
    xor ebx,ebx
    inc ebx
.real_exit:
    sys_exit

.do_bind:
    sys_bind ebp,bindctrl,16                    ;bind_ctrl
    or eax,eax
    jnz .false_exit

    sys_listen ebp,5                            ;at most five clients
    or eax,eax
    jnz .false_exit

    sys_fork                                    ;into background
    or eax,eax
    jz .acceptloop

.true_exit:                                     ;exit_stuff
    xor ebx,ebx
    jmps .real_exit

.acceptloop:                                    ;start looping for connections
    mov [arg2],byte 16
    sys_accept ebp,arg1,arg2
    test eax,eax
    js .acceptloop

    mov edi,eax                                 ;edi <- ctrl socket descriptor
    sys_fork                                    ;new child
    or eax,eax
    jz .child
    jmps .acceptloop                             ;next pliz

;___________________________________________________________________________________________
;               CHILD   ebp(ctrl)       edi(data)
;-------------------------------------------------------------------------------------------
.child:
    mov ebp,edi                                 ;ebp <- ctrl socket

    mov ecx,rep_220                             ;send wellcome message
    call .reply

.get_command:                                   ;start looping for commands
    sys_read ebp,req,req_len                    ;recv
    dec eax
    js .get_command                             ;while request

    mov eax,[req]                               ;identify command for processing

    ;a series of jumps from command to command to verify which was requested...

;___________________________________________________________________________________________
;               RETR & STOR command
;-------------------------------------------------------------------------------------------
.retr:
    push edi                                    ;save data socket
    mov edi,operation
    mov byte[edi],1                             ;operation is RETR

    cmp eax,'RETR'                              ;is command RETR ?
    je .transfer
.stor:
    inc byte[edi]                               ;operation is STOR
    cmp eax,'STOR'                              ;is command STOR ?
    jne near .list                              ;if not try LIST
.transfer:

    call .req2asciiz

    pop edi                                     ;load data socket
    push edi                                    ;for close on error

    mov eax,O_RDWR
    test byte[operation],2                      ;if STOR
    jz .open_file
    or eax,O_CREAT|O_TRUNC

.open_file:
    sys_open esi,eax,S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP|S_IROTH            ;open file
    or eax, byte 0
    js .transfer_error

    mov esi,eax                                 ;file descriptor
    mov ecx,rep_150                             ;send start of transfer
    call .reply


    test byte[operation],2
    jz .transfer_file
    xchg esi,edi                                ;in case of STOR

.transfer_file:
    sys_read esi,buff,buff_size                 ;read a bunch
    or eax,byte 0
    je .end_transfer

    cmp byte[ftpd_TYPE],'A'                     ;is TYPE ASCII or binary?
    jne .binary_transfer
    call .ascii
    jmps .transfer_file                         ;and again
.binary_transfer:
    sys_write edi,buff,eax                      ;...and write that bunch
    jmps .transfer_file                         ;and again

.end_transfer:
    sys_close esi                               ;close file
    sys_close edi                               ;close data connection = EOF
    mov ecx,rep_226                             ;send ok
    call .reply_get_command

.transfer_error:
    pop edi
    sys_close edi                               ;close data connection = EOF
    mov ecx,rep_550                             ;send error
    call .reply_get_command
;___________________________________________________________________________________________



;___________________________________________________________________________________________
;               LIST command
;-------------------------------------------------------------------------------------------
.list:
    mov byte[edi],3                             ;operation is LIST
    pop edi                                     ;redo stack and data socket

    cmp ax,'LI'                                 ;is command LIST?
    jne near .port                              ;if not try PORT

    mov ecx,rep_150                             ;send start of transmition
    call .reply


    sys_fork                                    ;for ctrl & data
    or eax,eax
    jne near .list_ctrl

    sys_pipe pipein                             ;pipe between ls & filter

    sys_fork                                    ;for execute & filter
    or eax,eax
    je near .execute_ls

    sys_close [pipeout]                         ;filter process doesn't write into the pipe

.filter:
    sys_read [pipein],buff,buff_size            ;read a bunch for filtering
    cmp eax,byte 0                              ;if none read
    jz .end_filter                              ;it means its all done

    call .ascii
    jmps .filter

.end_filter:
    jmp .true_exit

.execute_ls:
    sys_close [pipein]
    sys_dup2 [pipeout],STDOUT                   ;redirecting output of ls_process
    push edi                                    ;opt3
    mov edi,lsargs
    mov esi,ls                                  ;preparing for execution
    mov dword[edi],esi
    mov esi,lsarg
    mov dword[edi+4],esi

    mov ecx,8                                   ;mov dword[edi+8],0
    xor eax,eax                                 ;mov dword[edi+12],0
    repne lodsb

    cmp byte[req+4],13                          ;if CR is after LIST
    je .no_params                               ;then no arguments to LIST

    call .req2asciiz

    cmp byte[esi],'-'                           ;mc's syntax:  LIST -la /...
    jne .no_mc
    add esi,byte 4                              ;if mc jump over -la_
.no_mc:
    mov dword[lsargs+8],esi                     ;load path for real ls
.no_params:
    pop edi
    sys_execve ls,lsargs,0                      ;executing ls
.list_ctrl:
    sys_close edi
    mov ecx,rep_250                             ;transfer successful
    call .reply_get_command

;___________________________________________________________________________________________



;___________________________________________________________________________________________
;               PORT command
;-------------------------------------------------------------------------------------------
.port:

    cmp ax,'PO'                                 ;is command PORT?
    jne near .type                              ;if not try TYPE

    mov esi,req
    add esi,byte 5

    xor ebx,ebx                                 ;preparing ebx for IP
    mov ecx,4

.p1:
    shl ebx,8
    call .str2int
    loop .p1                                    ;4 bytes in IP

    push ebx                                    ;changing endiannes
    pop bx
    xchg bh,bl
    shl ebx,16
    pop bx
    xchg bh,bl
    mov edi,binddata                            ;opt1
    mov dword[edi+4],ebx                        ;done with IP

    xor ebx,ebx                                 ;ebx for PORT & AF_INET
    call .str2int
    shl ebx,8
    call .str2int
    xchg bh,bl                                  ;changing endiannes
    shl ebx,16
    mov bl,AF_INET
    mov dword[edi],ebx                          ;done with PORT & AF_INET

    sys_socket PF_INET,SOCK_STREAM,IPPROTO_TCP  ;and let there be a socket...
    cmp eax,byte 0
    js .err_port
    push eax                                    ;save data socket
    sys_connect eax, edi,16                     ;make data connection
    cmp eax,byte 0
    js .err_port
    pop edi                                     ;edi <- data socket
    mov ecx,rep_200                             ;send ok
    call .reply_get_command

.err_port:
    mov ecx,rep_421                             ;send error message
    call .reply

    sys_shutdown ebp,2
    sys_close ebp
    jmp .false_exit
;___________________________________________________________________________________________



;___________________________________________________________________________________________
;               TYPE MODE STRU commands
;-------------------------------------------------------------------------------------------
.type:
    push edi                                    ;save in case it contains data socket
                                                ;these three commands may arise between
                                                ;PORT and transfere; must save data socket
    mov edi,ftpd_TYPE                           ;set destination to ftpd_TYPE
    cmp ax,'TY'                                 ;is command TYPE?
    je .tms_common

    inc edi                                     ;set destination to ftpd_MODE
    cmp ax,'MO'                                 ;is command MODE?
    je .tms_common

    inc edi                                     ;set destination to ftpd_STRU
    cmp eax,'STRU'                              ;is command STRU?
    jne .misc                                   ;if not try the rest

.tms_common:

    mov al,byte[req+5]                          ;requested transfer param
    mov esi,TMS_params                          ;supported 4 params
    mov ecx,4
.tms_check_param:
    cmp al,byte[esi]                            ;verify if supported
    je .tms_param_match
    inc esi
    loop .tms_check_param

    mov ecx,rep_502                             ;unknown parameter
    jmps .tms_reply_get_command

.tms_param_match:
    mov byte[edi],al                            ;set parameter
    mov ecx,rep_200                             ;reply ok

.tms_reply_get_command:
    pop edi                                     ;redo stack
    call .reply_get_command
;___________________________________________________________________________________________



.misc:
    cmp ax,'CD'
    je .cdup

    push eax                                    ;save command
    call .req2asciiz
    mov ebx,esi                                 ;zero ended parameter
    pop eax                                     ;load command

    cmp ax,'MK'
    je .mkd
    cmp ax,'RM'
    je .rmd
    cmp ax,'DE'
    je .dele
    cmp ax,'CW'
    je .cwd
    jmps .small


;___________________________________________________________________________________________
;               CWD CDUP command
;-------------------------------------------------------------------------------------------
.cdup:
    mov ebx,parent_dir                          ;cdup = cd ..
.cwd:
    sys_chdir                                   ;try to chdir
    jmps .misc_common
;___________________________________________________________________________________________



;___________________________________________________________________________________________
;               MKD command
;-------------------------------------------------------------------------------------------
.mkd:
    mov ecx,S_IRWXU|S_IRWXG|S_IRWXO
    sys_mkdir                                   ;try to mkdir
    jmps .misc_common
;___________________________________________________________________________________________



;___________________________________________________________________________________________
;               RMD command
;-------------------------------------------------------------------------------------------
.rmd:
    sys_rmdir                                   ;try to rmdir
    jmps .misc_common
;___________________________________________________________________________________________



;___________________________________________________________________________________________
;               DELE command
;-------------------------------------------------------------------------------------------
.dele:
    sys_unlink                                  ;try to unlink

.misc_common:
    or eax, byte 0
    jnz .misc_error

    mov ecx,rep_250                             ;success
    jmps .misc_reply_get_command

.misc_error:
    mov ecx,rep_550                             ;or not
.misc_reply_get_command:
    call .reply_get_command
;___________________________________________________________________________________________



;___________________________________________________________________________________________
;               USER command
;-------------------------------------------------------------------------------------------
.user:
    sys_chroot [root]
    mov ecx,rep_230
    jmps .misc_reply_get_command
;___________________________________________________________________________________________



;___________________________________________________________________________________________
;               SYST command
;-------------------------------------------------------------------------------------------
.syst:
    mov ecx,rep_215
    jmps .misc_reply_get_command
;___________________________________________________________________________________________



;___________________________________________________________________________________________
;               NOOP command
;-------------------------------------------------------------------------------------------
.noop:
    mov ecx,rep_200
    jmps .misc_reply_get_command
;___________________________________________________________________________________________


.small:
    pop edi                                     ;restore data socket if there was any

    cmp ax,'US'
    je .user
    cmp ax,'SY'
    je near .syst
    cmp ax,'NO'
    je .noop
    cmp ax,'QU'
    je .quit
    cmp ax,'PW'
    je .pwd



;___________________________________________________________________________________________
;               unknown command
;-------------------------------------------------------------------------------------------

    mov ecx,rep_502
    call .reply_get_command
;___________________________________________________________________________________________



;___________________________________________________________________________________________
;               QUIT command
;-------------------------------------------------------------------------------------------
.quit:
    mov ecx,rep_221
    call .reply

    jmp .true_exit
;___________________________________________________________________________________________



;___________________________________________________________________________________________
;               PWD command
;-------------------------------------------------------------------------------------------
.pwd:
    mov ecx,rep_257                     ;start reply
    call .reply

    sys_getcwd buff,buff_size

    mov esi,buff
    xor ecx,ecx

.pwd_getend:
    lodsb
    inc ecx
    test al,al
    jnz .pwd_getend                     ;replace trailing 0

    dec esi                             ;with
    mov dword[esi],658722               ; \"\r\n
    inc ecx
    inc ecx
    sys_write ebp,buff,ecx              ;end reply

    jmp .get_command
;___________________________________________________________________________________________



;___________________________________________________________________________________________
;               function string to int
;-------------------------------------------------------------------------------------------
.str2int:
    xor eax,eax
    lodsb
    sub al,'0'
    jb .l2

    mov dh,bh
    xor bh,bh
    imul bx,byte 10
    or bh,dh

    add ebx,eax
    jmp .str2int
.l2 :
    ret
;___________________________________________________________________________________________



;___________________________________________________________________________________________
;               function ASCII  ( edi buff eax )
;in case of incoming data cuts out the CR just before LF
;in case of outgoing data inserts a CR before every LF
;-------------------------------------------------------------------------------------------
.ascii:
    pusha

    mov ebp,edi                                 ;destination
    mov edi,buff                                ;source for scan
    mov ecx,eax                                 ;length of string to scan

.scan:
    cld
    mov al,LF                                   ;looking for LF
    mov esi,edi                                 ;scanned the string from ...
    repne scasb                                 ;scan
    sub edi,esi                                 ;scanned length

    cmp byte[edi+esi-1],LF                      ;even if its a trailing LF
    je .found_LF

    call .send_ascii                            ;write it all forward to the client

.return_ascii:
    popa
    ret

.found_LF:
    xor eax,eax
    inc eax
    push ecx                                    ;these were for outgoing
    mov ecx,rep_CRLF
    cmp byte[operation],2                       ;is it STOR (incoming) ?
    jne .no_stor

    inc eax                                     ;diffs of incoming ascii
    mov ecx,rep_LF                              ;from outgoing ascii

.no_stor:
    sub edi,eax                                 ;if found go back to point to it

    call .send_ascii                            ;send the line
    call .reply                                 ;and LF or CRLF
    pop ecx
    cmp ecx, byte 0
    je .return_ascii                            ;in case of trailing LF

    add edi,eax
    add edi,esi                                 ;go back to found LF
    jmp .scan                                   ;next line from same bunch
;___________________________________________________________________________________________



;___________________________________________________________________________________________
;               function req2asciiz
;put end of string after request
;and return first parameter in esi
;-------------------------------------------------------------------------------------------
.req2asciiz:
    mov ecx,req_len                             ;cover the request
    mov edi,req                                 ;take request
    mov al,32                                   ;find first argument
    repne scasb
    push edi                                    ;save argument
    mov al, 13                                  ;look for CR
    repne scasb                                 ;lookin'...
    dec edi
    mov byte[edi],0                             ;replace CR with EOStr
    pop esi                                     ;load argument
    ret
;___________________________________________________________________________________________



;___________________________________________________________________________________________
;               function reply
;replacement for all kinds of sys_write
;-------------------------------------------------------------------------------------------
.send_ascii:
    pusha
    mov ecx,esi
    mov edx,edi
    jmps .common_sys_write
.reply_get_command:
    inc byte[rgc]
.reply:
    pusha

    xor eax,eax

    mov esi,rep_l                               ;reply-length table
    mov edx,esi                                 ;0th reply offset

.reply_select:                                  ;to get the offset
    lodsb                                       ;of required reply
    add edx,eax                                 ;add the length of each reply
    loop .reply_select                          ;placed before it

    mov cl,byte[esi]                            ;rep_len
    xchg ecx,edx                                ;prepare for sys_write
.common_sys_write:
    mov ebx,ebp
    sys_write

    popa
    dec byte[rgc]
    jz .and_get_command

    inc byte[rgc]
    ret
.and_get_command:
    pop eax
    pop eax
    jmp .get_command
;___________________________________________________________________________________________



DATASEG

    ftpd_DPORT dw 20                            ;data port ; default 20
    ftpd_TYPE db 'I'                            ;image type
    ftpd_MODE db 'S'                            ;stream mode
    ftpd_STRU db 'F'                            ;file structure

    TMS_params db 'A','I','S','F'               ;transmition parameters implemented
                                                ;ascii, image, stream, file

UDATASEG
    rgc resb 1                                  ;ReplayGetCommand

    arg1 resb 0xff
    arg2 resb 0xff

    bindctrl resd 2
    binddata resd 2

    lsargs resd 6

    pipein resd 1
    pipeout resd 1

    root resd 1

    operation resb 1                            ;RETR | STOR | LIST

    buff resb buff_size
    req resb 1024
END
