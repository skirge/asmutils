;Copyright (C) 1999 Konstantin Boldyshev <konst@voshod.com>
;
;$Id: dumpcore.asm,v 1.1 2000/01/26 21:19:14 konst Exp $
;
;dumps core
;
;was used to examine ELF segment layout 

%include "system.inc"

UDATASEG

u1:
	resd	0x100
u2:

DATASEG

d1	db	"THIS IS MY DATA SEGMENT"
d2	dd	0x12345678

CODESEG

c1	db	"THIS IS MY CODE SEGMENT"
c2	dd	0xFEDCBA98

START:
	mov	eax,c1
	mov	ebx,d1
	mov	ecx,u1
	mov	edx,u2

;mark start of bss
	mov	[ecx],dword "[BSS"
	mov	[ecx+4],dword " STA"
	mov	[ecx+8],dword "RT] "
;mark end of bss
	mov	[edx-8],dword "[BSS "
	mov	[edx-4],dword "END]"

;and dump core

	hlt