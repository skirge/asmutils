;Copyright (C) 2001 Karsten Scheibler <karsten.scheibler@bigfoot.de>
;
;$Id: init.asm,v 1.1 2001/03/18 07:08:25 konst Exp $
;
;simple init
;
;syntax: init
;
;example: init
;
;0.01: 03-Mar-2001	initial release

%include "system.inc"

%assign MAX_TTYS	4

%define TTY_PATH	"/dev/tty"
%define SHELL_PATH	"/bin/sh"

CODESEG

START:
			;--------------------------------------------
			;for the moment: mount /proc /proc proc
			;this should be replaced by a rc script later
			;--------------------------------------------

			sys_fork
			test	dword eax, eax
			jnz	.skip
			sys_execve  [arguments_rc], arguments_rc, environment
			sys_exit  0
.skip:
			;---------------
			;initialize ttys
			;---------------

			xor	dword ebp, ebp
.init_loop		inc	dword ebp
			call	tty_initialize
			cmp	dword ebp, MAX_TTYS
			jb	.init_loop

			;------------------------
			;wait for child processes
			;------------------------

.wait:			sys_wait4  0xffffffff, NULL, NULL, NULL
			test	dword eax, eax
			js	.wait

			;-----------------------------------------------
			;find the PID of the child process and respawn a
			;shell process on the right tty
			;-----------------------------------------------

			xor	dword ebp, ebp
.respawn_loop:		inc	dword ebp
			cmp	dword ebp, MAX_TTYS
			ja	.wait
			cmp	dword [pids + 4 * ebp - 4], eax
			jne	.respawn_loop
			call	tty_initialize
			jmp	short .wait


tty_initialize:
			;------------------------------------------------
			;convert the number in ebp to an ASCII character,
			;store it in the tty_path and open this file
			;------------------------------------------------

			mov	dword eax, ebp
			cmp	byte  al, 009h
			jbe	.ok
			mov	byte  al, 009h
.ok:			add	byte  al, 030h
			mov	byte  [tty_path.number], al
			sys_open  tty_path, O_RDWR
			test	dword eax, eax
			js	near  .error

			;-------------------------------------------------
			;initialize the terminal (maybe not all of this is
			;really necessary)
			;-------------------------------------------------

			mov	dword [tty_fd], eax
			mov	dword ebx, eax
			sys_dup2  EMPTY, STDIN
			sys_dup2  [tty_fd], STDOUT
			sys_dup2  [tty_fd], STDERR
			sys_fcntl  STDIN, F_SETFL, O_RDONLY
			sys_fcntl  STDOUT, F_SETFL, O_WRONLY
			sys_fcntl  STDERR, F_SETFL, O_WRONLY
			sys_ioctl  [tty_fd], TCGETS, tty_termios
			sys_ioctl  [tty_fd], TCSETSW, tty_termios
			mov	dword eax, [tty_fd]
			cmp	dword eax, STDERR
			jbe	.skip
			sys_close  [tty_fd]
.skip:			
			;-----------------------------------------------------
			;create a child process and try to execute a shell.
			;if this fails print an error message wait 300 seconds
			;(look at select_timeval) and exit.
			;-----------------------------------------------------

			sys_fork
			test	dword eax, eax
			js	.error
			jnz	.exit
			sys_execve  [arguments_shell], arguments_shell, environment
			test	dword eax, eax
			jns	.terminate
			sys_write  STDERR, shell_not_found, shell_path_length
			sys_select  0, NULL, NULL, NULL, select_timeval
			sys_exit  1
.error:			xor	dword eax, eax
			dec	dword eax
.exit:			mov	dword [pids + 4 * ebp - 4], eax
			ret
.terminate:		sys_exit  0


shell_not_found:	db	"couldn't find "
shell_path:		db	SHELL_PATH, 0, 10
shell_path_length:	equ	$ - shell_not_found
rc_path:		db	"/bin/mount", 0
rc_option1:		db	"/proc", 0
rc_option2:		db	"proc", 0
			align	4
arguments_shell:	dd	shell_path
environment:		dd	0
arguments_rc:		dd	rc_path
			dd	rc_option1
			dd	rc_option1
			dd	rc_option2
			dd	0
select_timeval:		dd	300
			dd	0


DATASEG
tty_path:		db	TTY_PATH
.number:		db	0, 0



UDATASEG
			alignb	4
pids:			resd	MAX_TTYS
tty_fd:			resd	1
tty_termios:		resd	01000h



END

