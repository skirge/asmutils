;Copyright (C) 1999 Konstantin Boldyshev <konst@voshod.com>
;
;$Id: tee.asm,v 1.1 2000/01/26 21:20:04 konst Exp $
;
;hackers' tee		[GNU replacement]
;
;0.01: 04-Jul-1999	initial release
;0.02: 27-Jul-1999	files are created with permissions of 664
;
;syntax: tee [-ai] [file...]
;
;-a	append to files instead of overwriting
;-i	ignore interrupt signals

;returns error count

%include "system.inc"

CODESEG

;ebp	-	return code

START:
%if KERNEL = 20
	_mov	ebp,0
%endif
	_mov	edi,handles
	pop	ebx
	dec	ebx
	pop	ebx
	jz	open_done	;if no args - write to STDOUT only

	_mov	ecx,O_CREAT|O_WRONLY|O_TRUNC
	pop	ebx
	mov	esi,ebx
	lodsb
	cmp	al,'-'
	jnz	open_2
.scan:
	lodsb
	or	al,al
	jz	open_files
	cmp	al,'a'
	jnz	.i
	_mov	ecx,O_CREAT|O_WRONLY|O_APPEND
	jmp short .scan
.i:
	cmp	al,'i'
	jnz	exit
	sys_signal	SIGPIPE,SIG_IGN
	sys_signal	SIGINT	;,SIG_IGN
	jmp short .scan
	
open_files:
	pop	ebx		;pop filename pointer
	or	ebx,ebx
	jz	open_done	;exit if no more agrs
open_2:
	sys_open EMPTY,EMPTY,664q
	test	eax,eax
	jns	open_ok
	inc	ebp
	jmp short open_files
open_ok:
	stosd
	jmp short open_files

open_done:
	xor	eax,eax
	stosd
read_loop:
	sys_read STDIN,Buf,BufSize
	test	eax,eax
	js	read_error
	jz	close
	sys_write STDOUT,EMPTY,eax	;write to STDOUT

	mov	esi,handles
.write_loop:
	lodsd
	or	eax,eax
	jz	read_loop
	sys_write eax
	jmp short .write_loop
read_error:
	inc	ebp

close:
;	mov	esi,handles
;.close_loop:
;	lodsd
;	or	eax,eax
;	jz	exit
;	sys_close eax
;	jmp	short .close_loop

exit:
	sys_exit ebp

UDATASEG

BufSize	equ	8192
Buf	resb	BufSize

;well, here is our malloc() :-)
handles	resd	1

END
