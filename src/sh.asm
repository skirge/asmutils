;
;Copyright (C) 2000,2001	Alexandr Gorlov <alexandr@fssrf.spb.ru>, <ct@mail.ru>
;				Karsten Scheibler <karsten.scheibler@bigfoot.de>
;$Id: sh.asm,v 1.3 2001/08/28 06:31:55 konst Exp $
;
;small shell
;
;syntax: sh
;
;example: sh
;
;0.01: 07-Oct-2000	initial release (AG + KS)
;0.02  26-Jul-2001      Added char-oriented commandline, tab-filename filling
;			partial export support 
;			partial CTRL+C handling (RM)

%include "system.inc"
;%ifdef __LINUX__
;%include "os_linux.inc"
;%endif




;****************************************************************************
;****************************************************************************
;*
;* PART 1: assign's
;*
;****************************************************************************
;****************************************************************************





%assign CMDLINE_BUFFER1_SIZE		001000h
%assign CMDLINE_BUFFER2_SIZE		010000h
%assign CMDLINE_PROGRAM_PATH_SIZE	001000h
%assign CMDLINE_MAX_ARGUMENTS		(CMDLINE_BUFFER1_SIZE / 2)
%assign CMDLINE_MAX_ENVIRONMENT		20


%assign ENTER 0ah
%assign BACKSPACE 08h
%assign DEL 7fh
%assign TABULATOR 9h

%assign ESC 01bh
%assign file_buff_size 0512


;%define DATAOFF(addr)           byte ebp + ((addr) - score)

CODESEG





;****************************************************************************
;****************************************************************************
;*
;* PART 2: start code
;*
;****************************************************************************
;****************************************************************************






START:



;stack layout:
			;argument counter
			;null terminated list with pointers to arguments
			;null terminated list with pointers to environment variables
			pop esi ;dont want argc

			;-------------------
			;initialize terminal
			;-------------------
			call tty_initialize
			
			;Experimental error handling 
			sys_signal 02,break_hndl
			
			pop 	edi ;prg name
			call    environ_initialize
			;---------------------
			;write welcome message
			;---------------------

			sys_write  STDOUT, text.welcome, text.welcome_length

			;------------------------------
			;get UID and select prompt type
			;------------------------------

select_prompt:		sys_getuid
			mov	dword ebx, text.prompt_user
			test	dword eax, eax
			jnz	.not_root
			mov	dword ebx, text.prompt_root
.not_root:		mov	dword [cmdline.prompt], ebx

			;----------------------------
			;set values for cmdline_parse
			;----------------------------

			xor	dword eax, eax
			mov	dword [cmdline.flags], eax
			mov	dword [cmdline.argument_count], eax
			mov	dword [cmdline.buffer2_offset], eax
			mov	dword [cmdline.arguments_offset], eax

			;---------------------------------
			;output shell prompt and read line
			;---------------------------------

get_cmdline:		sys_write  STDOUT, [cmdline.prompt], text.prompt_length
			jmp	short .normal_prompt
.incomplete_prompt:	sys_write  STDOUT, text.prompt_incomplete, text.prompt_length
.normal_prompt:		call	cmdline_get
			test	dword eax, eax
			jz	get_cmdline

			;-------------
			;parse cmdline
			;-------------

			call	cmdline_parse
			test	dword eax, eax
			jz	get_cmdline
			js	get_cmdline.incomplete_prompt ;this is somewhat broken

			;---------------
			;execute cmdline
			;---------------

			call	cmdline_execute

			;----------------
			;get next cmdline
			;----------------

			jmp	get_cmdline




;****************************************************************************
;****************************************************************************
;*
;* PART 3: sub routines
;*
;****************************************************************************
;****************************************************************************
;SHELL="
;enviroment setup

environ_initialize:
			sys_brk 0
			mov 	[cmdline.environment],eax
			mov 	dword [environ_count],1
			mov 	edx,eax
			xchg 	ebx,eax
			mov 	esi,edi
			call string_length
			add 	ebx,ecx
			add 	ebx,08 ;better more
			sys_brk EMPTY
			xchg 	edx,edi
			mov 	dword [edi],'SHEL'
			mov 	dword [edi+4],'L=" '
			add 	edi,7
.next_char:
			lodsb 
			stosb
			or 	al,al
			jnz .next_char
			dec 	edi
			mov 	al,'"'
			stosb 
			xor 	al,al
			stosb 
			ret


;****************************************************************************
;****************************************************************************
;*
;* PART 3.1: string sub routines
;*
;****************************************************************************
;****************************************************************************





;****************************************************************************
;* string_length ************************************************************
;****************************************************************************
;* edi=>  pointer to string
;* <=ecx  string length (including trailing \0)
;* <=edi  pointer to string + string length
;****************************************************************************
string_length:
			push	dword eax
			xor	dword ecx, ecx
			xor	dword eax, eax
			dec	dword ecx
			cld
			repne scasb
			neg	dword ecx
			pop	dword eax
			ret



;****************************************************************************
;* string_compare ***********************************************************
;****************************************************************************
;* esi=>  pointer to string 1
;* edi=>  pointer to string 2
;* <=ecx  == 0 (string are equal), != 0 (strings are not equal)
;* <=esi  pointer to string 1 + position of first nonequal character
;* <=edi  pointer to string 2 + position of first nonequal character
;****************************************************************************
string_compare:
			push	dword edx
			push	dword edi
			call	string_length
			mov	dword edx, ecx
			mov	dword edi, esi
			call	string_length
			cmp	dword ecx, edx
			jae	.length_ok
			mov	dword ecx, edx
.length_ok:		pop	dword edi
			cld
			repe cmpsb
			pop	dword edx
			ret





;****************************************************************************
;****************************************************************************
;*
;* PART 3.2: sub routines terminal handling
;*
;****************************************************************************
;****************************************************************************





;****************************************************************************
;* tty_initialize ***********************************************************
;****************************************************************************
tty_initialize:

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;TODO: set STDIN options (blocking, echo, icanon etc ...) only on linux ?
;      set signal handlers
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%ifdef __LINUX__
			mov	edx, termattrs
			sys_ioctl STDIN, TCGETS
			mov	eax,[termattrs.c_lflag]
			push 	eax
			and	eax, byte ~(ICANON|ECHO)
			mov	[termattrs.c_lflag], eax
			sys_ioctl STDIN, TCSETS
			pop	dword [termattrs.c_lflag]
%else
			sys_fcntl  STDIN, F_GETFL
			and	dword eax, ~(O_NONBLOCK) ;dont work
			sys_fcntl  STDIN, F_SETFL, eax
%endif
			ret



;****************************************************************************
;* tty_restore **************************************************************
;****************************************************************************

tty_restore:
%ifdef __LINUX__
 	    sys_ioctl STDIN, TCSETS,termattrs
%endif	    
	ret





;****************************************************************************
;****************************************************************************
;*
;* PART 3.3: sub routines for parsing command line
;*
;****************************************************************************
;****************************************************************************



;****************************************************************************
;* cmdline_get **************************************************************
;****************************************************************************
;* <=eax  characters read (including trailing \n)
;****************************************************************************
; This code is xterm & linux console compatible. It means VT100 and DEC 
; maybe.
%ifdef __LINUX__
;>AL out
get_char:
		        sys_read STDIN,getchar,1
			mov 	al,[ecx]
			ret

;IN EDI buffer 
;OUT filled with null term str with\n
cmdline_get:
			mov 	edi,cmdline.buffer1 
			mov 	word [edi],0
.do_nothing_loop:
			call 	get_char
			cmp 	al,TABULATOR
			jz  near .tab_pressed 
			cmp 	al,ESC
			jz  near .esc_seq_start
			cmp     al,BACKSPACE
			jz    .back_space
			cmp     al,DEL
			jz    .back_space
			sys_write STDOUT,getchar,1
			mov 	al,[getchar]
			cmp 	al,ENTER
			jz 	.enter
			xor 	ah,ah		;write in on console
			cmp 	byte [edi],ah
			jz 	.ok_have_end    ;test if insert or append
			push edi      		;insert
.loop:			xchg 	al,[edi]
			inc 	edi
			or 	al,al
			jnz .loop
			mov 	byte [edi],ah
			pop 	edi
			inc 	edi
			sys_write EMPTY,insert_char,4
			sys_write EMPTY,edi,1
			sys_write EMPTY,backspace,EMPTY ;we filled edx with 1 in last case
.big_fat_jump:
			jmp near .do_nothing_loop
.ok_have_end:
 			mov 	[edi],ax
			inc 	edi	
			jmp short .big_fat_jump
.enter: 
			cmp 	byte [edi],0 ;go at the end of str and put \n
			jz .append
			inc 	edi
			jmp short .enter
.append:
			mov	word [edi],0x000a
			xchg 	edi,eax
			sub 	eax,cmdline.buffer1-1 
			ret				;bye bye ...
.back_space:	
			cmp 	edi,cmdline.buffer1    ;check outer limits
 			jz   near .beep
			cmp 	byte [edi],0	       
			jz .at_the_end			;simple case we if are at the end
			push 	edi     
.loop1:			mov 	al,[edi]		;no ...
			inc 	edi			
			mov 	[edi-2],al
			or 	al,al
			jnz .loop1
			pop 	edi	
			sys_write STDOUT,delete_one_char,5
			dec 	edi
			mov 	al,[edi]
			mov 	byte [cur_move_tmp+1],al
			sys_write EMPTY,cur_move_tmp+1,2
.big_fat_jump2:
			jmp near .do_nothing_loop		
.at_the_end:
			dec 	edi
			mov    	byte [edi],0
			mov 	byte [cur_move_tmp+1],' '
			sys_write EMPTY,cur_move_tmp,3
			jmp short .big_fat_jump2	
.esc_seq_start:
			sys_read STDIN,getchar+1,2 ;have control code in buffer 
			cmp 	word [ecx],'[D'
			jz  .cursor_left	
			cmp 	word [ecx],'[C'
			jz  .cursor_right
			jmp short .big_fat_jump2		
.cursor_right:
			cmp 	byte [edi],0		;check outer limits
			jz .beep
			sys_write STDOUT,edi,1  	;reprint the charter
			inc 	edi 
			jmp  short .big_fat_jump2
.beep:	
			sys_write STDOUT,beep,1 	;beeeeeeeeeep
			jmp short .big_fat_jump2
.cursor_left:
			cmp 	edi,cmdline.buffer1 	;check outer limits
			jz .beep
			dec 	edi
			sys_write STDOUT,backspace,1    ;cursor one left
			jmp    short .big_fat_jump2

;

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;TODO: append same part of filenames from a list 
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

.last_slash:
			or 	edx,edx
			jnz 	.got_last
			mov 	edx,edi
			jmp short .got_last
.tab_pressed: 					;we want hint which file to write
			push 	edi
			xchg 	esi,edi
			mov 	edi,cmdline.buffer1
			mov 	eax,edi
		
			mov 	byte [file_name],0
			mov 	byte [first_time],0
			mov 	[write_after_slash],edi ;here we start ...
			call string_length
			mov 	ebx,cur_dir
			xor 	edx,edx
			;Please note: following lines could be written more clearly
			;this seems as more reg magic move around and it is so.
			;If you have a better solution to cover all cases
			;here's your chance!
.find_space:
			dec 	edi 		;now we are at the end of str
			cmp 	edi,eax		;we will find from end of str till
			jz .not_found 		;start the first space
			cmp 	byte [edi],'/'  ;and fist slash
			jz .last_slash
.got_last:
			cmp 	byte [edi],' '
			jnz  .find_space
			inc 	edi
			mov 	ebx,edi
			;edi points to a start of the possible directory
			;edx  -----------last slash
			or 	edx,edx
			jnz .have_slash    
.not_found:
			cmp byte [eax],'/'   ;is the first slash ?
			jnz .really_not_found
			
			or 	edx,edx
			jnz .have_more_slash
			mov 	edx,eax
.have_more_slash:
			mov 	ebx,eax
			jmps .have_slash
.really_not_found:	cmp 	byte [eax],'.'
			jnz .last_chance_failed
			or 	edx,edx
			jz .last_chance_failed
			jmps .have_slash
.last_chance_failed:
			mov 	ebx,cur_dir
			mov 	edx,ebx
			inc 	edx
			mov 	[write_after_slash],edi
			jmp short .lets_rock 
.have_slash:
			inc 	edx
			mov 	[write_after_slash],edx
			dec 	edx
.lets_rock:
			xor 	al,al
			xchg 	byte [edx],al
			xchg 	ebp,eax
			
.try_again:
			;have_a_look if posible to open another directory
			;in write_after_slash is right piece of filename
			;int 3
			cmp 	ebx,edx ;we have a cd /bi 
			jnz .havent
			mov 	ebx,cur_dir
			inc 	ebx
.havent:		
			
			sys_open EMPTY,O_DIRECTORY|O_RDONLY
			or 	eax,eax
			jns .ok
			mov 	ebx,cur_dir 
			jmp short .try_again
.ok:
			xchg 	ebp,eax
			xchg 	byte [edx],al
			xchg 	esi,edi
.find_next:
			sys_getdents ebp,file_buff,file_buff_size ;get dir entries
			or 	eax,eax
			jz near .finish_lookup		;no entries left
			add 	eax,ecx 		;set the buffer limit {offset] 	    
			xor 	edx,edx    
			push dword 0 			;mark last entry
.compare_next:
			add 	ecx,edx
			mov 	edx,ecx
			mov 	esi,[write_after_slash]
			cmp 	eax,ecx
			;jb .print_what_find
			;jz .print_what_find
			jna .print_what_found
			add 	edx,0ah ;offset in struct for file name - stupid
			push 	edx	;put candidate on the list
			push 	ecx
			xchg 	edx,edi
			call  string_compare ;cmp fm last slash!  
					    ;look if he have parcial match
			dec 	esi
			pop 	ecx
			cmp 	edx,esi     
			xchg 	edx,edi
			jz .same	   ;yes we have
			pop edx 	   ;throw this filename away 
.same:
			movzx 	edx,word [ecx+8] ;get the size of this entry
			jmp short .compare_next
.print_what_found:	
	
			pop 	esi		;look at the last and second last
			or 	esi,esi		;if 1st 0 -nothing found
			jz 	.find_next      ;if 2nd 0 only one found in buffer
			pop 	edx
			or 	edx,edx
			jnz near .have_more
			;here we can have only one but dont know about the rest
			;not yet processed
			;copy this filename to some_buffer
			cmp 	byte [file_name],0
			jnz near .have_more
			xchg 	ebx,edi
			mov 	edi,file_name
.copy_loop3:		lodsb
			stosb
			or 	al,al
			jnz .copy_loop3 
			xchg 	ebx,edi
			jmps .find_next

.we_have_really_one:	mov esi,file_name
.we_have_really_one2:				
			;we have one suitable candidate in buffer ESI
			sys_write STDOUT,erase_line,5
			mov 	edi,[write_after_slash]
				
.next_char:		;append the string back to commandline
			lodsb
			stosb
			or 	al,al
			jnz .next_char
			;linux dep part
			%ifdef __LINUX__
			mov 	esi,edi
			;int 3
			std
.find_space2:
			lodsb
			cmp esi,cmdline.buffer1
			jz .try_it
			cmp al,' '
			jnz .find_space2
			inc esi
			inc esi
.try_it:		
			cld
			sys_stat esi,stat_buf
			test    eax,eax
			js  	.is_not_dir	
			movzx   eax,word [stat_buf.st_mode]
			mov     ebx,40000q
			and     eax,ebx   
			cmp     eax,ebx
			jnz .is_not_dir
			dec 	edi			
			mov 	word [edi],0x002f
			inc 	edi
			inc 	edi
			%endif
.is_not_dir:      
			pop 	eax
			dec 	edi
			push 	edi
			jmps .skip
.finish_lookup:		;restore promt
			cmp 	byte [first_time],0
			jz  .we_have_really_one
			mov 	esi,file_equal
			cmp 	byte [esi],0
			jnz .we_have_really_one2	
			;we have something same for all files...
.skip:			sys_write STDOUT,erase_line,5
			sys_write STDOUT, [cmdline.prompt], text.prompt_length			
			mov 	edi,cmdline.buffer1
			call string_length
			dec 	ecx
			xchg 	edx,ecx
			sys_write  EMPTY, cmdline.buffer1, EMPTY
			sys_close ebp
			pop 	edi
			jmp near .do_nothing_loop
.have_more:
    			cmp 	byte [first_time],0
			jnz .dont_need_cr
			mov 	ecx,esi
			mov 	eax,file_name
			cmp 	byte [eax],0
			jz .ok_file_name_not_used
			or 	edx,edx
			jnz .is_not_zero
			mov 	edx,eax
			xor 	eax,eax
.is_not_zero:		push 	eax
			mov 	esi,edx ;fill [file_name] to [equal_file]
.ok_file_name_not_used:
		
			;** ;write equal filename... to this will will compare
			xchg 	ebx,edi
			mov 	edi,file_equal

.copy_next:		lodsb 
			stosb
			or 	al,al
			jnz .copy_next
			xchg 	ecx,esi
			xchg 	ebx,edi
			;**
			
;quick & dirty hack to begin on new line
			dec 	esi
			mov 	byte [esi],0xa
		
.dont_need_cr:
			inc 	byte [first_time]
			push 	edx
			push 	esi
.pop_next:				;we print a list of candidates here
			pop 	edx
			or 	edx,edx
			jz near .find_next
			;**ESI can be used
			mov 	esi,file_equal
			mov 	ebx,edx
			cmp 	byte [ebx],0xa
			jz .compare_next2
			dec 	ebx
.compare_next2:
			inc 	ebx
			lodsb
			cmp 	al,[ebx]
			jz .compare_next2
			dec 	esi
			mov 	byte [esi],0
			;**
			
			xchg 	edi,esi
			mov 	edi,edx
			call string_length
			dec 	edi
			dec 	ecx
			mov 	byte [edi],0xa ;append a newline
			xchg 	edi,esi
			xchg 	edx,ecx
			sys_write STDOUT,EMPTY,EMPTY
			jmp short .pop_next 
 %else
 			sys_read  STDIN, cmdline.buffer1, (CMDLINE_BUFFER1_SIZE - 1)
			test	dword eax, eax
			jns	.end
			xor	dword eax, eax
.end:			mov	byte  [cmdline.buffer1 + eax], 0
			ret
 %endif


;****************************************************************************
;* cmdline_parse ************************************************************
;****************************************************************************
;* eax=>  number of characters in cmdline
;* <=eax  number of parameters (0 = none, 0ffffffffh = line incomplete)
;****************************************************************************
;!!!!!!!!!!!!!!!!!!!!!!
;TODO: ' \ < > 2> * ` $
;!!!!!!!!!!!!!!!!!!!!!!

cmdline_parse_flags:
.seperator:		equ	001h
.quota1:		equ	002h
.quota2:		equ	004h
			

cmdline_parse:
			mov	dword ebx, [cmdline.flags]
			mov	dword ecx, eax
			mov	dword edx, [cmdline.argument_count]
			mov	dword esi, cmdline.buffer1
			mov	dword edi, cmdline.buffer2
			mov	dword ebp, [cmdline.arguments_offset]
			add	dword edi, [cmdline.buffer2_offset]

.next_character:	lodsb
			test	byte  al, al
			jz	.end
			test	dword ebx, cmdline_parse_flags.seperator
			jnz	.check_seperator
			cmp	byte  al, 0x09
			je	.skip_character
			cmp	byte  al, 0x0a
			je	.end
			cmp	byte  al, 0x20
			je	.skip_character
			mov	dword [cmdline.arguments + 4 * ebp], edi
			inc	dword ebp
			inc	dword edx
			or	dword ebx, cmdline_parse_flags.seperator

.check_seperator:	cmp	byte  al, '"'
			jne	.not_quota1
			xor	dword ebx, cmdline_parse_flags.quota1
			jmp	.skip_character
.not_quota1:		test	dword ebx, cmdline_parse_flags.quota1
			jnz	.copy_character
			cmp	byte  al, 0x09
			je	.seperate
			cmp	byte  al, 0x0a
			je	.end
			cmp	byte  al, 0x20
			jne	.copy_character
.seperate:		xor	dword eax, eax
			and	dword ebx, ~cmdline_parse_flags.seperator
.copy_character:	stosb
.skip_character:	dec	dword ecx
			jnz	.next_character

.end:			test	dword ebx, cmdline_parse_flags.quota1
			jnz	.incomplete
			xor	dword eax, eax
			mov	dword [cmdline.arguments + 4 * ebp], eax
			stosb
			mov	dword [cmdline.flags], eax
			mov	dword [cmdline.argument_count], eax
			mov	dword [cmdline.buffer2_offset], eax
			mov	dword [cmdline.arguments_offset], eax
			mov	dword eax, edx
			ret

.incomplete:		xor	dword eax, eax
			dec	dword eax
			mov	dword [cmdline.flags], ebx
			sub	dword edi, cmdline.buffer2
			mov	dword [cmdline.argument_count], edx
			mov	dword [cmdline.buffer2_offset], edi
			mov	dword [cmdline.arguments_offset], ebp
			ret



;****************************************************************************
;* cmdline_execute **********************************************************
;****************************************************************************
cmdline_execute:
execute_builtin:
			xor	dword ebx, ebx
			dec	dword ebx
.next:			inc	dword ebx
			mov	dword edi, [cmdline.arguments]
			mov	dword esi, [builtin_cmds.table + 8 * ebx]
			test	dword esi, esi
			jz	.end
			call	string_compare
			test	dword ecx, ecx
			jnz	.next
			jmp	dword [builtin_cmds.table + 8 * ebx + 4]
.end:

			;---------------
			;set environment
			;---------------


.set_environment:
;			xor	dword eax, eax
			
			;mov 	eax, [environ_count]
			;mov	dword [cmdline.environment], eax
			;mov	dword [cmdline.environment+4], eax

			;----
			;fork
			;----
;***
			call  tty_restore
			sys_fork
			test	dword eax, eax
			jnz	near  .wait

			;--------------------------------------------------
			;try to execute directly if the name contains a '/'
			;--------------------------------------------------

.execute_extern:	mov	dword edi, [cmdline.arguments]
			call	string_length
			mov	dword edi, [cmdline.arguments]
			mov	byte  al, '/'
			repne scasb
			test	dword ecx, ecx
			jz	.scan_paths
			
			sys_execve  [cmdline.arguments], cmdline.arguments, cmdline.environment
			jmp	.error

			;-------------------------------------
			;walk through paths and try to execute
			;-------------------------------------

.scan_paths:		mov	dword ebp, 4
			mov	dword esi, builtin_cmds.paths
.next_path:		mov	dword edi, cmdline.program_path
.copy_loop1:		lodsb
			stosb
			test	byte  al, al
			jnz	.copy_loop1
			dec	dword edi
			mov	byte  al, '/'
			push	dword esi
			stosb
			mov	dword esi, [cmdline.arguments]
.copy_loop2:		lodsb
			stosb
			test	byte  al, al
			jnz	.copy_loop2
			pop	dword esi
			sys_execve  cmdline.program_path, cmdline.arguments, cmdline.environment
			dec	dword ebp
			jnz	.next_path

			;--------------------------------------------------
			;if all tries to execute the command failed, output
			;this message and exit
			;--------------------------------------------------

.error:			sys_write  STDERR, text.cmd_not_found, text.cmd_not_found_length
			sys_exit  1

.wait:			mov [pid],eax
			sys_wait4  0xffffffff, NULL, NULL, NULL
			jmp	tty_initialize




;****************************************************************************
;****************************************************************************
;*
;* PART 4: built in commands
;*
;****************************************************************************
;****************************************************************************



;****************************************************************************
;* cmd_export ***************************************************************
;****************************************************************************
;TODO
cmd_export:
		mov 	edx,[environ_count]
		mov	dword edi, [cmdline.arguments + 4]
		or 	edi,edi
		jz .export_print
		mov ebp,edi
		call string_length
		;ecx size of str
		;dec ecx
		sys_brk 0
		mov esi,eax
		add eax,ecx
		xchg eax,ebx
		sys_brk EMPTY
		xchg ebp,edi
		xchg esi,edi
		;edi the ptr
		mov [cmdline.environment+edx*4],edi
		inc edx
		cmp edx,CMDLINE_MAX_ENVIRONMENT
		mov [environ_count],edx
		jnz .write_var
		int 3
.write_var:
		lodsb
		stosb
		or al,al
		jnz .write_var
.done:
		ret
;stolen from env.asm
.export_print:
		xor 	ebp,ebp
		dec 	ebp
.env:
		inc 	ebp
		mov	esi,[cmdline.environment + ebp * 4]
		test	esi,esi
		jz	.done
		mov	ecx,esi
		xor	edx,edx
		dec	edx
.slen:
		inc	edx
		lodsb
		or	al,al
		jnz	.slen
		dec 	esi
		mov 	al,0xa
		xchg 	[esi],al
		xchg 	eax,edi
		inc 	edx
		sys_write STDOUT
		xchg 	eax,edi
		xchg 	[esi],al
		jmps	.env




;****************************************************************************
;* cmd_exit *****************************************************************
;****************************************************************************
cmd_exit:
			call	tty_restore
			sys_write  STDOUT, text.logout, text.logout_length
			sys_exit  0



;****************************************************************************
;* cmd_cd *******************************************************************
;****************************************************************************
cmd_cd:
			mov	dword ebx, [cmdline.arguments + 4]
			sys_chdir
			test	dword eax, eax
			jns	.end
			sys_write  STDERR, text.cd_failed, text.cd_failed_length
.end:			ret



break_hndl:
sys_write STDOUT,text.break,text.break_length
sys_kill [pid],15
ret


;****************************************************************************
;****************************************************************************
;*
;* PART 5: read only data
;*
;****************************************************************************
;****************************************************************************




text:
.welcome:			db	"asmutils shell", 10
.welcome_length:		equ	$ - .welcome
.prompt_user:			db	"$ "
.prompt_root:			db	"# "
.prompt_incomplete:		db	"> "
.prompt_length			equ	2
.cmd_not_found:			db	"command not found", 10
.cmd_not_found_length:		equ	$ - .cmd_not_found
.break:			db	">>SIGINT received<<,sending SIGTERM", 10
.break_length:		equ	$ - .break

.cd_failed:			db	"couldn't change directory", 10
.cd_failed_length:		equ	$ - .cd_failed
.logout:			db	"logout", 10
.logout_length:			equ	$ - .logout

builtin_cmds:
				align	4
.table:				dd	.exit, cmd_exit
				dd	.logout, cmd_exit
				dd	.cd, cmd_cd
				dd      .export, cmd_export
				dd	0, 0
.exit:				db	"exit", 0
.logout:			db	"logout", 0
.cd:				db	"cd", 0
.export				db      "export",0
.paths:				db	"/bin", 0
				db	"/sbin", 0
				db	"/usr/bin", 0
				db	"/usr/sbin", 0


erase_line      db     0x1b,"[2K",0xd
insert_char 	db     0x1b,"[1@]"
delete_one_char db 0x8,0x1b,"[1P"
backspace:
cur_move_tmp 	db 08h,' ',08h
beep   		db 07h
cur_dir db "./",0

;try_hook db 0
;tabulator_str db 09,00

;****************************************************************************
;****************************************************************************
;*
;* PART 6: uninitialized data
;*
;****************************************************************************
;****************************************************************************


;DATASEG

UDATASEG
cmdline:
.buffer1:			CHAR	CMDLINE_BUFFER1_SIZE
.buffer2:			CHAR	CMDLINE_BUFFER2_SIZE
.program_path:			CHAR	CMDLINE_PROGRAM_PATH_SIZE
				alignb	4
.prompt:			ULONG	1
.arguments:			ULONG	CMDLINE_MAX_ARGUMENTS
.environment:			ULONG	CMDLINE_MAX_ENVIRONMENT
.flags:				ULONG	1
.argument_count:		ULONG	1
.buffer2_offset:		ULONG	1
.arguments_offset:		ULONG	1
;fdset: 				resb fd_set_size
;timer: B_STRUC itimerval
%ifdef __LINUX__
termattrs B_STRUC termios,.c_lflag
getchar_buff: resb 3
getchar resb 3
file_buff resb file_buff_size
write_after_slash resd 1 
environ_count resd 1
first_chance resb 1
file_name resb 255
file_equal resb 255
first_time  resb 1 ;stupid
stat_buf B_STRUC stat,.st_mode
%endif
pid resd 1
END
;****************************************************************** AG + KS *

