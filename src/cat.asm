;Copyright (C) 1999 Konstantin Boldyshev <konst@linuxassembly.org>
;
;$Id: cat.asm,v 1.3 2000/03/02 08:52:01 konst Exp $
;
;hackers' cat
;
;0.01: 05-Jun-1999	initial release
;0.02: 17-Jun-1999	fixed bug with 2.0 kernel, size improvements
;0.03: 04-Jul-1999	fixed more bugs (^D, kernel 2.0), buffered io
;
;syntax: cat [file...]
;
;returns error count

%include "system.inc"

CODESEG

;ebp	-	current handle of file to read
;edi	-	return code

START:
	_mov	edi,0
	_mov	ebp,STDIN	;file handle (STDIN if no args)
	pop	ebx
	dec	ebx
	pop	ebx
	jz	.read	;if no args - read STDIN

.next_file:
	pop	ebx		;pop filename pointer
	or	ebx,ebx
	jz	.exit		;exit if no more agrs

; open O_RDONLY

	sys_open EMPTY,O_RDONLY
	mov	ebp,eax
	test	eax,eax		;have we opened file?
	jns	.read		;yes, read it
.error:
	inc	edi		;record error
	jmp short .next_file	;try next file
.read:
	_mov	ecx,Buf
	_mov	edx,BufSize
.read_loop:
	sys_read ebp
	test	eax,eax
	js	.error
	jz	.next_file
;	jz	.close_file
	sys_write STDOUT,EMPTY,eax	;write to STDOUT
	jmp short .read_loop
;.close_file:
;	sys_close; ebp			;close current file
;
;	jmp short .next_file		;try next file

.exit:
	sys_exit edi

UDATASEG

;benchmark showed:
;setting BufSize more than 8192 only eats memory
;setting BufSize lower than 8192 will result in slower perfomance

BufSize	equ	8192
Buf	resb	BufSize

END
