;Copyright (C) 1999 Konstantin Boldyshev <konst@linuxassembly.org>
;
;$Id: cat.asm,v 1.4 2002/03/14 07:12:12 konst Exp $
;
;hackers' cat
;
;syntax: cat [file...]
;
;returns error count
;
;0.01: 05-Jun-1999	initial release
;0.02: 17-Jun-1999	fixed bug with 2.0 kernel, size improvements
;0.03: 04-Jul-1999	fixed more bugs (^D, kernel 2.0), buffered io
;0.04: 14-Mar-2002	squeezed one byte :-) (KB)

%include "system.inc"

CODESEG

;BUFSIZE > 8192 doesn't make sense, BUFSIZE < 8192 results in slower perfomance

%assign	BUFSIZE	0x2000

;ebp	-	current handle of file to read
;edi	-	return code

START:
	_mov	edi,0
	_mov	ebp,STDIN	;file handle (STDIN if no args)
	pop	ebx
	dec	ebx
	pop	ebx
	jz	.read_loop	;if no args - read STDIN

.next_file:
	pop	ebx		;pop filename pointer
	or	ebx,ebx
	jz	.exit		;exit if no more agrs

; open O_RDONLY

	sys_open EMPTY,O_RDONLY
	mov	ebp,eax
	test	eax,eax		;have we opened file?
	jns	.read_loop	;yes, read it
.error:
	inc	edi		;record error
	jmps	.next_file	;try next file

.read_loop:
	sys_read ebp,buf,BUFSIZE
	test	eax,eax
	js	.error
	jz	.next_file
;	jz	.close_file
	sys_write STDOUT,EMPTY,eax	;write to STDOUT
	jmps	.read_loop
;.close_file:
;	sys_close; ebp			;close current file
;
;	jmp short .next_file		;try next file

.exit:
	sys_exit edi

UDATASEG

buf	resb	BUFSIZE

END
