;Copyright (C) 1999 Konstantin Boldyshev <konst@voshod.com>
;
;$Id: ln.asm,v 1.1 2000/01/26 21:19:33 konst Exp $
;
;hackers' ln
;
;0.01: 29-Jul-1999	initial release
;0.02: 28-Sep-1999	Added no option check - docwhat@gerf.org 
;
;syntax: ln [-s] target link_name
;
;example: ln -s vmlinuz-2.2.10 vmlinuz


%include "system.inc"

CODESEG

START:
	pop     ebx	; pop argc
	dec     ebx	; is there anything there?
	jz      .exit	; no, exit

	pop	ebx	; pop argv0 - our name

	pop	ebx	; pop target or '-s'

	cmp	word [ebx],"-s"
	jz	.symlink

	pop	ecx	; pop link_name
	sys_link
	jmp short .exit	
.symlink:
	pop	ebx	; pop target
	pop	ecx     ; pop link_name
	sys_symlink
.exit:
	sys_exit eax

END

