;Copyright (C) 2000-2002 Alexandr Gorlov <ct@mail.ru>
;			 Karsten Scheibler <karsten.scheibler@bigfoot.de>
;			 Rudolf Marek <marekr2@fel.cvut.cz>
;
;$Id: sh.asm,v 1.9 2002/02/14 13:38:15 konst Exp $
;
;hackers' shell
;
;syntax: sh
;
; Command syntax:
;	[[relative]/path/to/]program [argument ...]
;
; Conditional syntax:
;	command
;	{and|or} command
;	...
; Now you can enjoy basic redirection support !
;
;  ls|grep asm|grep s>>list 
;  
;or just:
;
;  ls|sort
;  cat<my_input
;  cat sh.asm > my_output
;  cat sh.asm>>my_appended_output  (spaces between > | < aren't mandatory)
;
; Comment (may not be in conditional):
;	: text without shell special characters
;
;example: sh
;
;0.01: 07-Oct-2000	initial release (AG,KS)
;0.02: 26-Jul-2001      Added char-oriented commandline, tab-filename filling,
;			partial export support, 
;			partial CTRL+C handling (RM)
;0.03: 16-Sep-2001      Added history handling (runtime hist), 
;			improved signal handling (RM)
;0.04: 30-Jan-2002	Added and/or internals and scripting (JH)
;0.05: 10-Feb-2002      Added pipe mania & redir support, 
;			shell inherits parent's env if any (RM)

%include "system.inc"

%ifdef __LINUX__ 
%define HISTORY 
%endif

;%undef HISTORY save 192 bytes + dynamic memory for cmdlines
;All your base are belong to us !

;****************************************************************************
;****************************************************************************
;*
;* PART 1: assign's
;*
;****************************************************************************
;****************************************************************************





%assign CMDLINE_BUFFER1_SIZE		001000h
%assign CMDLINE_BUFFER2_SIZE		010000h  ;so much ?
%assign CMDLINE_PROGRAM_PATH_SIZE	001000h
%assign CMDLINE_MAX_ARGUMENTS		(CMDLINE_BUFFER1_SIZE / 2)
%assign CMDLINE_MAX_ENVIRONMENT		50


%assign ENTER 		0ah
%assign BACKSPACE 	08h
%assign DEL 		7fh
%assign TABULATOR 	09h
%assign ESC 		01bh
%assign file_buff_size 	0512


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

			
			pop 	edi ;prg name
			call    environ_initialize
			pop	ebp			; shell_script
			call	environ_inherit		; copy parent's env to our struc			
			mov 	edi,ebp
			or	edi, edi
			jz	.interactive_shell
	
			;-----------------
			;open shell script
			;-----------------

			sys_open	edi, O_RDONLY
			or	eax, eax
			jnz	.script_opened
			sys_write  STDERR, text.scerror, text.scerror_length
			sys_exit	; error code=2
.script_opened:		mov	[script_id], eax
			mov	[cmdline.prompt], dword text.prompt_ptrace
			jmps	conspired_to_run
			
			;---------------------
			;write welcome message
			;---------------------

.interactive_shell:	sys_write  STDOUT, text.welcome, text.welcome_length
			mov	[script_id], edi	; edi = 0, STDIN

			;-------------------
			;initialize terminal
			;-------------------
			call tty_initialize
			
			;Experimental error handling 
			sys_signal 02,break_hndl

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

conspired_to_run:	xor	dword eax, eax
			mov	dword [cmdline.flags], eax
			mov	dword [cmdline.argument_count], eax
			mov	dword [cmdline.buffer2_offset], eax
			mov	dword [cmdline.buffer1_offset], eax
			mov	dword [cmdline.arguments_offset], eax

			;---------------------------------
			;output shell prompt and read line
			;---------------------------------

get_cmdline:		
			sys_write  STDOUT, [cmdline.prompt], text.prompt_length
			jmp	short .normal_prompt
.incomplete_prompt:	sys_write  STDOUT, text.prompt_incomplete, text.prompt_length
.normal_prompt:		call	cmdline_get
			test	dword eax, eax
			jz	get_cmdline

			
%ifdef HISTORY		
			xchg 	eax,edx   ;save the length of str in buff
			mov 	ecx,[history_start] ;load the counter located some
			or 	ecx,ecx             ;where in stack
			jnz .next_entry
			push 	byte 0              ;count of lines in history
			mov 	[history_start],esp ;write the pos of this counter
			mov 	ecx,esp             ;also from this pos will be
.next_entry:			                    ;saving ptrs to strings
			inc 	dword [ecx]       
			mov 	eax,[ecx]
			mov 	[history_cur],eax   ;update last history
			sys_brk 0                   ;get top of heap
			push 	eax 		    ;store cur addres
			mov 	edi,eax
			add 	eax,edx
			;dec  eax ;dont copy 00, change 0A->00
			sys_brk eax                 ;extend heap
			mov 	esi,cmdline.buffer1
			mov 	ecx,edx
			rep                         ;copy str to free mem
			movsb
			dec 	edi
			mov 	byte [edi],0        ;delete 0A
			xchg 	eax,edx
%endif
			;-------------
			;parse cmdline
			;-------------
			call	cmdline_parse
			test	dword eax, eax
%ifdef	__LONG_JUMPS__		;f***ing nasm!!!!!
			jz	near get_cmdline
			js	near get_cmdline.incomplete_prompt ;this is somewhat broken
%else
			jz	get_cmdline
			js	get_cmdline.incomplete_prompt ;this is somewhat broken
%endif

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

environ_inherit:
			pop	ebx ;EIP 
			or 	ebp,ebp
			jz .ok_next_is_env
.pop_next:		;get rid of rest args
			pop 	eax
			or	eax,eax
			jnz   	.pop_next
			push 	eax
.ok_next_is_env:	
			pop	eax
			or	eax,eax
			jz	.env_done
			mov 	edx,[environ_count]
			mov 	[cmdline.environment+edx*4],eax
			inc 	edx
			cmp 	edx,CMDLINE_MAX_ENVIRONMENT
			mov 	[environ_count],edx
			jnz .ok_next_is_env
			;int 3 ;too much environ...
.env_done:		
			jmp ebx
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
			cmp	[script_id], byte 0
			jne	near .bye

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;TODO: set STDIN options (blocking, echo, icanon etc ...) only on linux ?
;      set signal handlers
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			;db 08h,' ',08h we dont suppose to have writeble CS
			mov  dword [backspace],0x20082008
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
.bye			ret



;****************************************************************************
;* tty_restore **************************************************************
;****************************************************************************

tty_restore:
%ifdef __LINUX__
	cmp	[script_id], dword 0
	jne	.bye
 	    sys_ioctl STDIN, TCSETS,termattrs
%endif	    
.bye:	ret





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

;>AL out
%ifdef __LINUX__
get_char:
		        sys_read [script_id],getchar,1
			cmp	[script_id], byte 0
			je	.noeof
			or	eax, eax
			;js	near cmd_exit
			jz	near cmd_exit
			
.noeof			mov 	al,[ecx]
			ret
%endif

;IN EDI buffer 
;OUT filled with null term str with\n
cmdline_get:
%ifdef __LINUX__
			mov 	edi,cmdline.buffer1 
			mov 	word [edi],0
.do_nothing_loop:
			call 	get_char
			cmp 	al,TABULATOR
			jz  near .tab_pressed 
			cmp 	al,ESC
			jz  near .esc_seq_start
			cmp     al,BACKSPACE
			jz	near .back_space
			cmp     al,DEL
			jz	near .back_space
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
			mov 	ebx,eax
			dec 	ebx
			jnz  .ok_end
			xor 	eax,eax			    ;if EAX==1 =>eax=0 
.ok_end:
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
			sys_read [script_id],getchar+1,2 ;have control code in buffer 
			cmp 	word [ecx],'[D'
			jz  .cursor_left	
			cmp 	word [ecx],'[C'
			jz  .cursor_right
%ifdef HISTORY
			mov 	edx,history_cur
			cmp 	word [ecx],'[A'
			jz  .cursor_up	
			cmp 	word [ecx],'[B'
			jz  .cursor_down
			jmp short .big_fat_jump2		
.cursor_down:		
			inc 	dword [edx]  ;choose which line of hist to display
			jmps .do_history
.cursor_up:		
			cmp 	dword [edx],0
			jz .beep
			dec 	dword [edx]	
			jmps .do_history
%else
			jmp short .big_fat_jump2		
%endif
.cursor_right:
			cmp 	byte [edi],0		;check outer limits
			jz .beep
			sys_write STDOUT,edi,1  	;reprint the charter
			inc 	edi 
			jmp	.big_fat_jump2
.beep:	
			sys_write STDOUT,beep,1 	;beeeeeeeeeep
			jmp short .big_fat_jump3
.cursor_left:
			cmp 	edi,cmdline.buffer1 	;check outer limits
			jz .beep
			dec 	edi
			sys_write STDOUT,backspace,1    ;cursor one left
.big_fat_jump3:			
			jmp    near .do_nothing_loop

%ifdef HISTORY
.do_history:
			mov 	ebx,[history_start]
			or 	ebx,ebx                 ;first use and want history ??
			jz .beep
			mov 	ecx,[edx]
			cmp 	ecx,[ebx]
			jb  .bound_ok
			dec 	dword [edx]  ;stupid, try to thing about better solution
			jmps .beep
.bound_ok:
			inc 	ecx          ;count the adress of pointer to cmdline
			shl 	ecx,2
			sub 	ebx,ecx
			mov 	edi,[ebx]    ;offset of command line, reading fm stack
			mov 	esi,edi 
			call string_length
			mov 	edi,cmdline.buffer1
			dec 	ecx
			mov 	ebp,ecx
			dec 	ebp  ;save length to ebp
			rep
			movsb
			dec edi
			sys_write STDOUT,erase_line,5
			sys_write EMPTY, [cmdline.prompt], text.prompt_length			
			sys_write EMPTY, cmdline.buffer1, ebp
			jmp	.big_fat_jump3
%endif

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
			push byte 0 			;mark last entry
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
			jmp .find_next

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
			jz  near .we_have_really_one
			mov 	esi,file_equal
			cmp 	byte [esi],0
			jnz near .we_have_really_one2	
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
 			sys_read  [script_id], cmdline.buffer1, (CMDLINE_BUFFER1_SIZE - 1)
			test	dword eax, eax
			jns	.end
			xor	dword eax, eax
.end:			mov	byte  [cmdline.buffer1 + eax], 0
			ret
 %endif	;__LINUX__


;****************************************************************************
;* cmdline_parse ************************************************************
;****************************************************************************
;* eax=>  number of characters in cmdline
;* <=eax  number of parameters (0 = none, 0ffffffffh = line incomplete)
;****************************************************************************
;!!!!!!!!!!!!!!!!!!!!!!
;TODO: ' \  2> * ` $
;!!!!!!!!!!!!!!!!!!!!!!

cmdline_parse_flags:
.seperator:		equ	001h
.quota1:		equ	002h
.quota2:		equ	004h
.redir_stdin:		equ	008h
.redir_stdout:		equ	010h
.redir_append:          equ     020h			

cmdline_parse:
cmdline_parse_restart:
			mov	dword esi, cmdline.buffer1
			add	dword esi, [cmdline.buffer1_offset] ;we need this when piping

			mov	dword ebx, [cmdline.flags]  ;this is used when incomplete cmd line
			mov	dword ecx, eax
			mov	dword edx, [cmdline.argument_count]
			mov	dword edi, cmdline.buffer2
			mov	dword ebp, [cmdline.arguments_offset]
			add	dword edi, [cmdline.buffer2_offset]

.next_character:	lodsb			;load next cahr from buffer
			test	byte  al, al
			jz	near  .end      ;we are done
			test	dword ebx, cmdline_parse_flags.seperator ;are we in argument or between ?
			jnz	.check_seperator
			cmp	byte  al, 0x09		;between
			je	.skip_character
			cmp	byte  al, 0x0a
			je	.end
			cmp	byte  al, 0x20
			je	.skip_character
			push    dword .skip_character  ;used by redir where to return
			cmp	byte  al, '>'
			je	near .redir_stdout
			cmp	byte  al, '<'
			je	near .redir_stdin
			pop     dword   [esp-4] ;interessting ... pop [esp] throw it away
			cmp	byte  al, '|'
			je	near  .pipe     ;Pipe Mania !
			mov	dword [cmdline.arguments + 4 * ebp], edi ;ok time to create new arg
			inc	dword ebp ;take notice that we have more args from now
			inc	dword edx
			or	dword ebx, cmdline_parse_flags.seperator ;set in separator flag

.check_seperator:	cmp	byte  al, '"'  ;handle correctly the " between " " nothing to parse
			jne	.not_quota1
			xor	dword ebx, cmdline_parse_flags.quota1
			jmps	.skip_character
.not_quota1:		test	dword ebx, cmdline_parse_flags.quota1 
			jnz	.copy_character
			cmp	byte  al, 0x09  ;are we at the end of arg ?
			je	.seperate
			cmp	byte  al, 0x0a
			je	.end
;****
			push    dword .seperate
			cmp	byte  al, '>'
			je	 .redir_stdout
			cmp	byte  al, '<'
			je	 .redir_stdin
			pop     dword   [esp-4] ;interessting ...
			cmp	byte  al, '|'
			je	near .pipe
;****			
			cmp	byte  al, 0x20
			jne	.copy_character
.seperate:		xor	dword eax, eax
			and	dword ebx, ~cmdline_parse_flags.seperator ;arg end here lets see 
.copy_character:	stosb 						  ;if we have more...
.skip_character:	dec	dword ecx
			jnz	near .next_character

.end:			test	dword ebx, cmdline_parse_flags.quota1
			jnz	near .incomplete			;save all int. val and 
;TODO: both redirections at once					;signal uncomplete cmdline
			xor	dword eax, eax
			stosb
			test   dword ebx, cmdline_parse_flags.redir_stdout ;get ready for redirs
			jnz  .redir_stdout_doit
			test   dword ebx, cmdline_parse_flags.redir_stdin
			jnz .redir_stdin_doit
			jmps .time_to_end
.redir_stdin:
			or	dword ebx, cmdline_parse_flags.redir_stdin 
;			jmps	.skip_character
			ret
.redir_stdout:		
			mov 	eax,ebx
			or	dword ebx, cmdline_parse_flags.redir_stdout
			cmp 	eax,ebx		;was redir already set ?? (second >) if so set append 
			jnz 	.return_back
.set_append:		or 	dword ebx, cmdline_parse_flags.redir_append
			;jmps	.skip_character
.return_back:		ret

.redir_stdin_doit:
			dec ebp
			dec edx
			sys_open [cmdline.arguments + 4 * ebp],O_RDONLY|O_LARGEFILE
		        mov	[cmdline.redir_stdin],eax
			jmps .time_to_end
.redir_stdout_doit:
			dec ebp
			dec edx
			mov	ecx,O_WRONLY|O_CREAT|O_LARGEFILE
			test  dword ebx,cmdline_parse_flags.redir_append
			jz .trunc
			or 	ecx,O_APPEND
			jmps	.ok_open		
.trunc:
			or 	ecx,O_TRUNC
.ok_open:
			sys_open [cmdline.arguments + 4 * ebp],EMPTY, S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH
		        mov	[cmdline.redir_stdout],eax
			jmps .time_to_end


.time_to_end:		;when cmdline is whole done reset int struc to defaults
			xor	eax,eax
			mov	dword [cmdline.arguments + 4 * ebp], eax
			mov	dword [cmdline.flags], eax
			mov	dword [cmdline.argument_count], eax
			mov	dword [cmdline.buffer2_offset], eax
			mov	dword [cmdline.buffer1_offset], eax
			mov	dword [cmdline.arguments_offset], eax
			mov	dword eax, edx
			ret 	;leave parser
			
.incomplete:		xor	dword eax, eax ;time to save all internals
			mov	dword [cmdline.buffer1_offset], eax
			dec	dword eax
			mov	dword [cmdline.flags], ebx
			sub	dword edi, cmdline.buffer2
			mov	dword [cmdline.argument_count], edx
			mov	dword [cmdline.buffer2_offset], edi
			mov	dword [cmdline.arguments_offset], ebp

			ret ;leave parser
    

.pipe:
			push 	ecx ;how many chars left ??? Decrease by one ?
			push    edx ;size
			xor	dword eax, eax
			stosb
			call    .time_to_end 	
;			mov	dword [cmdline.arguments + 4 * ebp], eax
;			mov	dword [cmdline.flags], eax
;			mov	dword [cmdline.argument_count], eax
;			mov	dword [cmdline.buffer2_offset], eax
;			mov	dword [cmdline.arguments_offset], eax
;			mov	dword eax, edx
;			push	eax
			sub	esi,cmdline.buffer1
			mov	dword [cmdline.buffer1_offset], esi
			sys_pipe pipe_pair		;create pipe		
		        mov 	eax,[pipe_pair.write]
		        mov	[cmdline.redir_stdout],eax
			pop	eax
			call	cmdline_execute ;both redir_'s are set to 0 there
		        mov 	eax,[pipe_pair.read]
		        mov	[cmdline.redir_stdin],eax
			pop     eax ;chars left
			jmp     cmdline_parse_restart


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

			;----    |
			;fork    |
			;----   /|\
			;      | | |
;***
			call  tty_restore
			sys_fork
			test	dword eax, eax
			jnz	near  .wait

			;--------------------------------------------------
			;try to execute directly if the name contains a '/'
			;--------------------------------------------------

.execute_extern:	
			xor 	eax,eax
			cmp dword	[cmdline.redir_stdout],eax
			jz	.no_stdout_redir
			sys_dup2 [cmdline.redir_stdout],STDOUT
			sys_close EMPTY
.no_stdout_redir:
			xor	eax,eax
			cmp dword	[cmdline.redir_stdin],eax
			jz	.no_stdin_redir
			sys_dup2 [cmdline.redir_stdin],STDIN
			sys_close EMPTY			
.no_stdin_redir:
			mov	dword edi, [cmdline.arguments]
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
			;TODO: grab paths from ENV ?
			
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

.wait:			
			mov 	[pid],eax
			
			mov ebx, [cmdline.redir_stdin]
			mov ecx, [cmdline.redir_stdout]
			or ebx,ebx
			jz .no_close_in
			sys_close EMPTY
.no_close_in:
			cmp ecx,1  ;FIX ME: I'm suspecting this is obsolote
			jz .no_close_out
			or ecx,ecx  
			jz .no_close_out
			sys_close ecx
.no_close_out:
			;sys_exit 0			
			xor 	eax,eax
			mov	[cmdline.redir_stdin],eax
			mov	[cmdline.redir_stdout],eax	
			xor	ebx,ebx		; Code updated to support
			dec	ebx		; background processes
			_mov	ecx, rtn	; JH
			xor	edx, edx
			xor	esi, esi
.wait4another:		sys_wait4	; 0xffffffff, rtn, NULL, NULL
			cmp	[pid], eax
			jne	.wait4another	; Wrong pid! - end update
			mov 	dword [pid],0
			call tty_restore
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
;TODO: var redefinition/del
cmd_export:
		mov 	edx,[environ_count]
		mov	dword edi, [cmdline.arguments + 4]
		or 	edi,edi
		jz .export_print
		mov 	ebp,edi
		call string_length
		;ecx size of str
		;dec ecx
		sys_brk 0
		mov 	esi,eax
		add 	eax,ecx
		xchg 	eax,ebx
		sys_brk EMPTY
		xchg 	ebp,edi
		xchg 	esi,edi
		;edi the ptr
		mov [cmdline.environment+edx*4],edi
		inc 	edx
		cmp 	edx,CMDLINE_MAX_ENVIRONMENT
		mov 	[environ_count],edx
		jnz .write_var
		int 3
.write_var:
		lodsb
		stosb
		or 	al,al
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
;* cmd_and, cmd_or **********************************************************
;****************************************************************************
cmd_and:		;int 3
			;nop
			cmp	[rtn], dword 0
			jne	cmd_and_nogo

; Stupid hack to call executor
cmd_and_go:		mov	esi, cmdline.arguments
			mov	edi, esi
			xor	eax,eax
			cmp 	[esi+4],eax ;someone is trying to kill us...
			jz	cmd_and_nogo
copyloop:		add	edi, byte 4 
			mov	eax, [edi]
			mov	[esi], eax
			add	esi, byte 4
			or	eax, eax
			jnz	copyloop

			call	cmdline_execute		; Execute the program
cmd_and_nogo:		ret

cmd_or:			cmp	[rtn], dword 0
			jne	cmd_and_go
			ret

;****************************************************************************
;* cmd_colon ****************************************************************
;****************************************************************************

cmd_colon:		xor	eax, eax
			mov	[rtn], eax
			ret

;****************************************************************************
;* cmd_exit *****************************************************************
;****************************************************************************
cmd_exit:
			call	tty_restore
			sys_write  STDOUT, text.logout, text.logout_length
			sys_exit  [rtn]	; last exit code



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
			sys_signal 02,break_hndl
%ifdef	DEBUG
			sys_write STDOUT,text.break,text.break_length
%endif
			cmp dword [pid],0
			jnz .not_us
			sys_write STDOUT,text.suicide,text.suicide_length
			ret
.not_us:	
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
.prompt_ptrace:			db	"+ "
.prompt_user:			db	"$ "
.prompt_root:			db	"# "
.prompt_incomplete:		db	"> "
.prompt_length			equ	2
.cmd_not_found:			db	"command not found", 10
.cmd_not_found_length:		equ	$ - .cmd_not_found
%ifdef DEBUG
.break:				db	__n,">>SIGINT received<<,sending SIGTERM", 10
.break_length:			equ	$ - .break
%endif
.suicide:			db	__n,"Suicide is painless..."
.suicide_length:			equ	$ - .suicide

.cd_failed:			db	"couldn't change directory", 10
.cd_failed_length:		equ	$ - .cd_failed
.logout:			db	"logout", 10
.logout_length:			equ	$ - .logout
.scerror:			db	"couldn't open scriptfile", 10
.scerror_length:		equ	$ - .scerror

builtin_cmds:
				align	4
.table:				dd	.exit, cmd_exit
				dd	.logout, cmd_exit
				dd	.cd, cmd_cd
				dd      .export, cmd_export
				dd	.and, cmd_and
				dd	.or, cmd_or
				dd	.colon, cmd_colon
				dd	0, 0
.and:				db	"and", 0
.or:				db	"or", 0
.colon:				db	":", 0
.exit:				db	"exit", 0
.logout:			db	"logout", 0
.cd:				db	"cd", 0
.export:			db      "export",0
.paths:				db	"/bin", 0
				db	"/sbin", 0
				db	"/usr/bin", 0
				db	"/usr/sbin", 0


erase_line      db     0x1b,"[2K",0xd
insert_char 	db     0x1b,"[1@]"
delete_one_char db 0x8,0x1b,"[1P"
beep   		db 07h
cur_dir db "./",0

;****************************************************************************
;****************************************************************************
;*
;* PART 6: uninitialized data
;*
;****************************************************************************
;****************************************************************************


;DATASEG

UDATASEG
backspace:
;cur_move_tmp 	db 08h,' ',08h
cur_move_tmp resd 1
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
.buffer1_offset:		ULONG	1
.arguments_offset:		ULONG	1
.redir_stdin:                   ULONG   1
.redir_stdout:    		ULONG   1
;fdset: 				resb fd_set_size
;timer: B_STRUC itimerval
pipe_pair:
.read 	ULONG 1
.write 	ULONG 1

environ_count resd 1

%ifdef __LINUX__
termattrs B_STRUC termios,.c_lflag
getchar_buff: resb 3
getchar resb 3
file_buff resb file_buff_size
write_after_slash resd 1 
first_chance resb 1
file_name resb 255
file_equal resb 255
first_time  resb 1 ;stupid
stat_buf B_STRUC Stat,.st_mode
%endif
%ifdef HISTORY
history_cur   resd 1
history_start resd 1
%endif
pid resd 1
rtn resd 1		; Return code
script_id resd 1	; Script handle
END
;****************************************************************** AG + KS *

