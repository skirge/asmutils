;Copyright (C) 1999 Cecchinel Stephan <inter.zone@free.fr>
;
;$Id: nc.asm,v 1.3 2000/09/03 16:13:54 konst Exp $
;
;hackers' netcat
;
;syntax:	nc -l [port] ip port	get input from port , output to ip port
;		nc -l |port]		get input from port, output to STDOUT
;		nc ip port		get input from STDIN, output to ip port
;
;			ip is in form xxx.xxx.xxx.xxx  only numeric (no DNS lookup)


[bits 32]
%include "system.inc"

	CODESEG

;--------------------------------------------------------
; inet_aton:  convert ascii xxx.xxx.xxx.xxx ip notation
;		to network oriented 32 bit number
; input: esi:   ascii string
; ouput: edi:	to store 32 bit number
;
%macro	inet_aton 0
	_mov ecx,4
.conv:	call StrToLong
	mov al,dl
	stosb
	loop .conv
%endmacro


START:
	_mov ebp,STDIN
	_mov edi,STDOUT
	pop ebx
	pop ebx
        pop esi
	test esi,esi
	jz near .read
	mov ax,[esi]
        cmp ax,'-l'
        jnz near .writesock

.readsock:
	pop esi			; next arg, port to listen
	call StrToLong		; convert ascii to int
	push edx

; first we create a socket
	call createsock
; then we bind to port
	lea esi,[buff2]
        mov [esi],eax
	pop eax
        mov byte[esi+(2+32)],ah
	mov byte[esi+(3+32)],al
        mov byte[esi+32],2
        lea eax,[esi+32]
        mov [esi+4],eax
        _mov eax,16
        mov [esi+8],eax
        sys_socketcall SYS_BIND,esi
        test eax,eax
        jnz near .exit
; listen
	xor eax,eax
        inc eax
        mov [esi+4],eax
        sys_socketcall SYS_LISTEN,esi
; accept incoming connection
	lea eax,[arg1]
	mov dword[esi+4],eax
	add eax,0x100
        mov dword[esi+8],eax
	_mov ebx,16
        mov [eax],ebx
        sys_socketcall SYS_ACCEPT,esi
	mov ebp,eax
;
	pop esi
	test esi,esi
	jz short .read
;
.writesock:
	lea edi,[consockaddr+4]
; convert xx.xx.xx.xx  to  network notation
	inet_aton
	sub edi,byte 8
;
	mov word[edi],AF_INET
	pop esi				; take next arg (port)
	call StrToLong			; convert to int
	mov byte[edi+2],dh	; store port in network order
	mov byte[edi+3],dl	; 
;
	call createsock		; create socket
	lea esi,[edi+16]	; esi=connargs
	mov dword[esi],eax
	mov dword[esi+4],edi
	mov edi,eax
	_mov eax,16
	mov dword[esi+8],eax
	sys_socketcall SYS_CONNECT,esi		; connect
;
.read:	lea esi,[buff]
	sys_read ebp,esi,1024
	test eax,eax
        js short .exit
	jz short .exit
	mov edx,eax
	sys_write edi, esi ,EMPTY
	jmp short .read

.exit:	sys_exit

;-----------------------------------------------------------
; StrToLong:  convert ascii decimal string to 32 bit number
; input:  esi   point on ascii
; return: edx=32 bit number
;
StrToLong:
	xor eax,eax
	xor edx,edx
.next:	lodsb
	sub al,'0'
	jb short exit2
	add edx,edx
	lea edx,[edx+edx*4]
	add edx,eax
	jmp short .next

;---------------------------------------
; create a socket with standard args
;
createsock:
	sys_socketcall SYS_SOCKET,socketargs
exit2:	ret

socketargs:	dd PF_INET, SOCK_STREAM, IPPROTO_TCP	; socket creation standard args

	UDATASEG

buff:	resb 1024
buff2:	resb 32
bindsockstruct:		resb 16
;
consockaddr:		resb 16
conargs:		resb 16
;
arg1:	resb 0x100
arg2:	resb 0x100

	END

