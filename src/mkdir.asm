;Copyright (C) 1999-2000 Konstantin Boldyshev <konst@voshod.com>
;
;$Id: mkdir.asm,v 1.1 2000/01/26 21:19:42 konst Exp $
;
;hackers' mkdir/rmdir
;
;0.01: 05-Jun-1999	initial release
;0.02: 17-Jun-1999	size improvements
;0.03: 04-Jul-1999	fixed bug with 2.0 kernel, size improvements
;0.04: 10-Jan-2000	-m support
;
;syntax: mkdir [-m mode] dir...
;	 rmdir dir...
;
;only octal mode strings are suppoted (f.e. 750)
;by default directories are created with permissions of 755
;
;returns last error number

%include "system.inc"

%define MKDIR 0
%define RMDIR 1

CODESEG

START:
	pop	esi
	pop	esi
.n1:				;set edi to argv[0] eol
	lodsb
	or 	al,al
	jnz	.n1
	mov	edi,esi

	_mov	ecx,755q

	pop	esi
	push	esi
	cmp	word [esi],"-m"
	jnz	.next_file

	pop	esi
	pop	esi
	or	esi,esi
	jz	.exit

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
	cmp	word [edi-6],"rm"
	jnz	.mkdir
	sys_rmdir
	jmp short .next_file

.mkdir:
	sys_mkdir
	jmp short .next_file

.exit:
	sys_exit eax

END
