;Copyright (C) 1999 Indrek Mandre <indrek.mandre@tallinn.ee>
;
;$Id: yes.asm,v 1.3 2000/03/02 08:52:01 konst Exp $
;
;hackers' yes		[GNU replacement]
;
;0.01: 17-Jun-1999	initial release
;0.02: 04-Jul-1999	fixed bug with 2.0 kernel
;
;syntax: yes [string...]
;
;example: yes string1 string2 string3
;         yes
;         yes onlyonestring
;
;Concatenates all strings, the resulting string can be 0xfff bytes long

%include "system.inc"

CODESEG

START:
	_mov	ebx,1
	mov	byte [Buf],'y'
	pop	edi		;edi holds argument count
	dec	edi
	jz	.startinfiniteprint;if no args, then print 'y'

;now we have to take arguments and cat them to out Buf
	dec	ebx
	pop	eax		;we ignore our own name

.nextarg:
	xor	ecx,ecx			;counter in string
	pop	eax			;pop the string
.back:
	cmp	byte [eax+ecx],0	;end of string?
	jz	.endofstring
	mov	dl,[eax+ecx]
	mov	byte [Buf+ebx],dl
	inc	ecx
	inc	ebx
	cmp	ebx,BufSize-3		;end of our dear Buf?
	jnl	.startinfiniteprint	;in that case just print out what we got
	jmp short .back

.endofstring:
	dec	edi
	jz	.startinfiniteprint
	mov	byte [Buf+ebx],' '
	inc	ebx
	cmp	ebx,BufSize-3		;end of our dear Buf?
	jb	.nextarg		;in that case just print out what we got

.startinfiniteprint:
	mov	word [Buf+ebx],0x000A	;concatenate \n\0
	mov	edx,ebx			;the length of final string
	inc	edx
.myloop:
	sys_write STDOUT,Buf
	jmp short .myloop

;.exit:
;	sys_exit

UDATASEG

BufSize	equ	0xfff
Buf	resb	BufSize		;our internal buffer size?!

END
