;Copyright (C) 1999-2002 Konstantin Boldyshev <konst@linuxassembly.org>
;
;$Id: grep.asm,v 1.5 2002/02/14 13:38:15 konst Exp $
;
;hackers' grep
;
;syntax: grep [-q] [-v] PATTERN [file...]
;
;-q	be quiet (supress output, only set exit code)
;-v	invert matching (select non-matching lines)
;
;there's no support for regexp, only pure string patterns.
;returns 0 on success (if pattern was found), 1 otherwise
;
;0.01: 19-Dec-1999	initial release (dumb and slow version)
;0.02: 14-Feb-2002	added -v option

%include "system.inc"

CODESEG

%assign	_q	00000001b
%assign	_v	00000010b

%assign	BUFSIZE	0x4000

do_exit:
	sys_exit [retcode]

START:
	_mov	ebp,STDIN	;file handle (STDIN if no args)
	mov	[retcode],byte 1

	pop	ebx
	dec	ebx
	jz	do_exit
	pop	esi
.s0:
	pop	edi		;get pattern

	cmp	word [edi],"-q"
	jnz	.s2
	or	[flag],byte _q
.s1:
	dec	ebx
	jmps	.s0
.s2:
	cmp	word [edi],"-v"
	jnz	.proceed
	or	[flag],byte _v
	jmps	.s1

.proceed:
	dec	ebx
	jz	.mainloop	;if no args - read STDIN

.next_file:
	pop	ebx		;pop filename pointer
	or	ebx,ebx
	jz	do_exit		;exit if no more agrs

; open O_RDONLY

	sys_open EMPTY,O_RDONLY
	mov	ebp,eax
	test	eax,eax
	js	.next_file

.mainloop:
	mov	esi,buf
	call	gets
	cmp	[tmp], byte 0
	jnz	.next_file

	call	strstr

	test	[flag],byte _v
	setz	bl
	test	eax,eax
	setz	bh

	xor	bl,bh
	jz	.mainloop

.match:
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
buf	resb	BUFSIZE

END
