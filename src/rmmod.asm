;Copyright (C) 1999 Indrek Mandre <indrek.mandre@tallinn.ee>
;
;$Id: rmmod.asm,v 1.3 2000/03/02 08:52:01 konst Exp $
;
;hackers' rmmod
;
;0.01: 17-Jun-1999	initial release
;0.02: 04-Jul-1999	fixed bug with 2.0 kernel
;
;syntax: rmmod module...
;
;example: rmmod sound ppp

%include "system.inc"

CODESEG

START:
	_mov	edi,1
	pop	ebp
	dec	ebp
	jz	.exit	;no argument - error
	pop	ebx	;our own name
.loop:
	pop	ebx	;take the name of module
	sys_delete_module
	or	eax,eax	;in case of error exit this party
	jnz	.exit
	dec	ebp
	jnz	.loop
	dec	edi
.exit:
	sys_exit edi

END
