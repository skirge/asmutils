;Copyright (C) 1999 Konstantin Boldyshev <konst@voshod.com>
;
;$Id: swapon.asm,v 1.1 2000/01/26 21:20:00 konst Exp $
;
;hackers' swapon/swapoff
;
;0.01: 04-Jul-1999	initial release
;
;syntax: swapon device ...
;
;example: swapon /dev/hda9 /dev/hda10
;	  swapoff /dev/hda5
;
;quite dumb version

%include "system.inc"

CODESEG

START:
	pop	esi
	pop	esi
.n1:
	lodsb
	or 	al,al
	jnz	.n1
.next_file:
	pop	ebx
	or	ebx,ebx
	jz	.exit
	cmp	word [esi-3],'ff'
	jnz	.swapon
	sys_swapoff
	jmp short .next_file
.swapon:
	sys_swapon
	jmp short .next_file
.exit:
	sys_exit eax

END
