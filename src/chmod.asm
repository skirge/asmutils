;Copyright (C) 2000 Konstantin Boldyshev <konst@linuxassembly.org>
;
;$Id: chmod.asm,v 1.2 2000/02/10 15:07:04 konst Exp $
;
;hackers' chmod
;
;0.01: 10-Jan-2000	initial release
;
;syntax: chmod MODE [FILE...]
;
;only octal mode strings are suppoted (f.e. 755)

%include "system.inc"

CODESEG

START:
	pop	ebx
	_cmp	ebx,3
	jb	.exit

	pop	esi
	pop	esi

	mov	edx,esi
	xor	ecx,ecx
	xor	eax,eax
	_mov	ebx,8

.next:
	mov	cl,[esi]
	sub	cl,'0'
	jb	.done
	cmp	cl,7
	ja	.done
	mul	bl
	add	eax,ecx
	inc	esi
	jmp short .next

.done:
	cmp	edx,esi
	jz	.exit
	or	eax,eax
	jz	.exit

	mov	ecx,eax

.next_file:
	pop	ebx
	or	ebx,ebx
	jz	.exit
	sys_chmod
	jmp short .next_file
.exit:
	sys_exit eax

END
