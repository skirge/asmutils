;Copyright (C) 1999 Indrek Mandre <indrek.mandre@tallinn.ee>
;
;$Id: dmesg.asm,v 1.3 2000/03/02 08:52:01 konst Exp $
;
;hackers' dmesg
;
;0.01: 17-Jun-1999	initial release
;0.02: 04-Jul-1999	fixed bug with 2.0 kernel
;
;syntax: dmesg [-c]
;
;example: dmesg
;         dmesg -c
;
;-c	clears the kernel buffer
;
;TODO: add support to -n option

%include "system.inc"

CODESEG

START:
	_mov	ebx,3		;just print the buffer [3]
	pop	edi		;edi holds argument count
	dec	edi
	jz	.forward
	pop	eax		;our own name
	pop	eax
	cmp	word [eax],"-c"
	jz	.forward
	inc	ebx		;clear the kernel buffer [4] (-c argument)
.forward:
	sys_syslog EMPTY, Buf, BufSize
;	mov	edx,eax
;	sys_write STDOUT,Buf
	xchg	edi,ecx
	xchg	esi,eax
.write:
	cmp	byte [edi],'<'
	jnz	.do_write
	cmp	byte [edi+2],'>'
	jnz	.do_write
	_add	edi,3
	_sub	esi,3
.do_write:
	sys_write STDOUT,edi,1
	inc	edi
	dec	esi
	jnz	.write

	sys_exit_true

UDATASEG

BufSize	equ	8192
Buf	resb	BufSize

END
