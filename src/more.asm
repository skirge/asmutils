;Copyright (C) 1999 Konstantin Boldyshev <konst@voshod.com>
;
;$Id: more.asm,v 1.1 2000/01/26 21:19:42 konst Exp $
;
;hackers' more
;
;0.01: 28-Aug-1999	initial release
;
;syntax: more [file...]
;
;absolutely dumb 23 line more
;scrolls one page at a time by pressing enter
;no terminal capabilities are used yet

%include "system.inc"

CODESEG

;ebp	-	current handle of file to read

readline:
	_mov	ecx,Buf
	_mov	edx,1
.again:	
	sys_read ebp
	test	eax,eax
	js	.return
	jz	.return
	inc	ecx
	cmp	[ecx-1],byte 0xA
	jnz	.again
.return:
	ret

MoreLine	db	"--More--"
MoreSize	equ	$-MoreLine

;GotoLine	db	0x1B,"[23;1H","        ",0x1B,"[23;1H"
;GotoSize	equ	$-GotoLine

START:
%if KERNEL = 20
	_mov	edi,0
	_mov	ebp,STDIN	;file handle (STDIN if no args)
%endif
	pop	ebx
	dec	ebx
	pop	ebx
	jz	.read	;if no args - read STDIN

.next_file:
	pop	ebx		;pop filename pointer
	or	ebx,ebx
	jnz	.open		;exit if no more agrs
.exit:
	sys_exit edi

.open:
	sys_open EMPTY,O_RDONLY
	mov	ebp,eax
	test	eax,eax		;have we opened file?
	jns	.read		;yes, read it
.error:
	inc	edi		;record error
	jmp short .next_file	;try next file
.read:
	_mov	ecx,MaxLine
.next_line:
	push	ecx
	call	readline
	or	eax,eax
	jz	.next_file
	mov	edx,ecx
	mov	ecx,Buf
	sub	edx,ecx
	sys_write STDOUT
	pop	ecx
	loop	.next_line
	sys_write EMPTY,MoreLine,MoreSize
	sys_read STDERR,Buf,1
	test	eax,eax
	js	.error
;	sys_write STDOUT,GotoLine,GotoSize
	jmp short .read

UDATASEG

MaxLine	equ	23
BufSize	equ	80*MaxLine

Buf	resb	BufSize

END
