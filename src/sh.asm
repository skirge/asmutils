;Copyright (C) 2000	Alexandr Gorlov <alexandr@fssrf.spb.ru>, <ct@mail.ru>
;			Karsten Scheibler <karsten.scheibler@bigfoot.de>
;
;$Id: sh.asm,v 1.2 2001/03/18 07:08:25 konst Exp $
;
;small shell
;
;syntax: sh
;
;example: sh
;
;0.01: 07-Oct-2000	initial release (AG + KS)

%include "system.inc"





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
%assign CMDLINE_MAX_ENVIRONMENT		4




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

			;-------------------
			;initialize terminal
			;-------------------

			call	tty_initialize

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
			jmp	.normal_prompt
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
			js	get_cmdline.incomplete_prompt

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
			sys_fcntl  STDIN, F_GETFL
			and	dword eax, ~O_NONBLOCK
			sys_fcntl  STDIN, F_SETFL, eax
			ret



;****************************************************************************
;* tty_restore **************************************************************
;****************************************************************************
tty_restore:
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
cmdline_get:
;!!!!!!!!!!!!!!!!!!!!!!!!!!
;TODO: char orientated mode
;!!!!!!!!!!!!!!!!!!!!!!!!!!
			sys_read  STDIN, cmdline.buffer1, (CMDLINE_BUFFER1_SIZE - 1)
			test	dword eax, eax
			jns	.end
			xor	dword eax, eax
.end:			mov	byte  [cmdline.buffer1 + eax], 0
			ret



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

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;TODO: set more than an empty environment
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.set_environment:
			xor	dword eax, eax
			mov	dword [cmdline.environment], eax

			;----
			;fork
			;----

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

.wait:			sys_wait4  0xffffffff, NULL, NULL, NULL
			jmp	tty_initialize




;****************************************************************************
;****************************************************************************
;*
;* PART 4: built in commands
;*
;****************************************************************************
;****************************************************************************





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
.cd_failed:			db	"couldn't change directory", 10
.cd_failed_length:		equ	$ - .cd_failed
.logout:			db	"logout", 10
.logout_length:			equ	$ - .logout

builtin_cmds:
				align	4
.table:				dd	.exit, cmd_exit
				dd	.logout, cmd_exit
				dd	.cd, cmd_cd
				dd	0, 0
.exit:				db	"exit", 0
.logout:			db	"logout", 0
.cd:				db	"cd", 0
.paths:				db	"/bin", 0
				db	"/sbin", 0
				db	"/usr/bin", 0
				db	"/usr/sbin", 0






;****************************************************************************
;****************************************************************************
;*
;* PART 6: uninitialized data
;*
;****************************************************************************
;****************************************************************************





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

END
;****************************************************************** AG + KS *

