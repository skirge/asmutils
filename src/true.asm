;Copyright (C) Indrek Mandre <indrek.mandre@tallinn.ee>
;
;$Id: true.asm,v 1.4 2001/01/21 15:18:46 konst Exp $
;
;hackers' true/false
;
;0.01: 17-Jun-1999	initial release
;0.02: 04-Jul-1999	fixed bug with 2.0 kernel
;0.03: 20-Sep-1999	size improvements
;0.04: 05-Jan-2001	even more size improvements ;)
;
;syntax: true
;	 false

%include "system.inc"

CODESEG

START:
	pop	esi
	pop	esi
.n1:				; how we are called?
	lodsb
	or 	al,al
	jnz	.n1
	xor	ebx,ebx
	cmp	byte [esi-5],'t'
	jz	.exit
	inc	ebx
.exit:
	sys_exit

END
