;Copyright (C) 2001 Thomas M. Ogrisegg (thomas.ogrisegg@sbg.ac.at)
;
;$Id: mesg.asm,v 1.2 2001/11/14 16:02:44 konst Exp $
;
;syntax: mesg [y|n]
;
;control write access to your terminal

%include "system.inc"

%assign BufSize 0x100

CODESEG

START:
	sys_readlink fd0, Buf, BufSize
	test eax, eax
	js _exit

	xor eax, eax
	sys_stat Buf, statbuf
	mov eax, [ecx+stat.st_mode]
	add esp, 8
	pop ebx
	test ebx, ebx
	jnz _chmod

	and eax, 16
	cmp eax, 16
	jnz isn
	mov ecx, yes
	jmp _write
isn:
	mov ecx, no
_write:
	sys_write STDOUT, ecx, 5

_exit:
	sys_exit eax

_chmod:
	cmp byte [ebx], 'n'
	jz _no
	cmp byte [ebx], 'y'
	jnz _exit
	or eax, 16
	jmp __do_chmod
_no:
	or eax, 16
	xor eax, 16
__do_chmod:
	sys_chmod Buf, eax
	jmp _exit

yes	db	"is y", __n
no	db	"is n", __n
fd0	db	"/proc/self/fd/0"

UDATASEG

Buf resb BufSize
statbuf B_STRUC stat, .st_mode

END
