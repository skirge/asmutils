;Copyright (C) 1999 Konstantin Boldyshev <konst@linuxassembly.org>
;
;$Id: grep.asm,v 1.3 2000/03/02 08:52:01 konst Exp $
;
;hackers' grep
;
;0.01: 19-Dec-1999	initial release (dumb and slow version)
;
;syntax: grep [-q] PATTERN [file...]
;
;-q	be quiet (supress output, only set exit code)
;
;there's no support for regexp, only pure string patterns.
;returns 0 on success (if pattern was found), 1 otherwise

%include "system.inc"

CODESEG

BufSize	equ	0x4000
_q	equ	00000001b

_exit:
	sys_exit [retcode]

START:
	_mov	ebp,STDIN	;file handle (STDIN if no args)
	mov	[retcode],byte 1

	pop	ebx
	dec	ebx
	jz	_exit
	pop	esi
	pop	edi		;get pattern

	cmp	word [edi],"-q"
	jnz	.proceed

	pop	edi
	dec	ebx
	mov	[flag],byte _q

.proceed:
	dec	ebx
	jz	.mainloop	;if no args - read STDIN

.next_file:
	pop	ebx		;pop filename pointer
	or	ebx,ebx
	jz	_exit		;exit if no more agrs

; open O_RDONLY

	sys_open EMPTY,O_RDONLY
	mov	ebp,eax
	test	eax,eax
	js	.next_file

.mainloop:
	mov	esi,Buf
	call	gets
	cmp	[tmp], byte 0
	jnz	.next_file

	call	strstr
	or	eax,eax
	jz	.mainloop

	mov	[retcode],byte 0
	test	[flag],byte _q
	jnz	.mainloop

	call	strlen
	sys_write STDOUT,esi,eax

	jmp	short .mainloop


;esi	-	buffer
gets:
	pusha
	mov	[tmp], byte 1

.read_byte:
	sys_read ebp,tmp,1
	cmp	eax,edx
	jnz	.return

	mov	al,[tmp]
	mov	[esi],al
	inc	esi
	cmp	al,__n
	jnz	.read_byte
;	dec	esi
	mov	[esi],byte 0
	mov	[tmp],byte 0

.return:
	popa
	ret

;very dumb but short strstr
;
;esi	-	haystack
;edi	-	needle

strstr:
	push	esi
	push	edi

	xor	eax,eax
	cmp	[esi],byte 0
	jz	.rets

	push	esi
	mov	esi,edi
	call	strlen
	mov	ecx,eax
	pop	esi
	or	ecx,ecx
	jz	.return	

.next:
	xor	eax,eax

	push	ecx
	push	edi
	repz	cmpsb
	pop	edi
	pop	ecx
	jz	.rets
	cmp	[esi],byte 0
	jnz	.next
	jmp	short .return
	
.rets:
	mov	eax,esi

.return:
	pop	edi
	pop	esi
	ret


strlen:
	push	edi
	mov	edi,esi
	mov	eax,esi
	dec	edi
.l1:
	inc	edi
	cmp	[edi],byte 0
	jnz	.l1
	xchg	eax,edi
	sub	eax,edi
	pop	edi
	ret


UDATASEG

retcode	resd	1
tmp	resb	1
flag	resb	1
Buf	resb	BufSize

END
