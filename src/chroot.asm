;Copyright (C) 1999 Konstantin Boldyshev <konst@voshod.com>
;
;$Id: chroot.asm,v 1.1 2000/01/26 21:19:16 konst Exp $
;
;hackers' chroot
;
;0.01: 19-Dec-1999	initial release
;
;syntax: chroot directory [command]
;
;example: chroot /tmp
;	  chroot /mnt lilo
;
;Runs command with specified root directory
;If no command is given, runs /bin/sh
;You must be root to succeed

%include "system.inc"

CODESEG

START:
	pop	ebp			;get argc
	dec	ebp			;exit if no args
	jz	exit

	pop	ebx

	pop	ebx
	sys_chroot
	or	eax,eax
	js	exit

	mov	ebx,[esp]		;ebx -- program name (*)
	or	ebx,ebx
	jnz	.set_args
	mov	ebx,shell
.set_args:
	mov	ecx,esp			;ecx -- arguments (**)
	lea	edx,[esp+(ebp+1)*4]	;edx -- environment (**)

	sys_execve

exit:
	sys_exit eax

shell	db	"/bin/sh";,NULL

END
