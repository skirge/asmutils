;Copyright (C) 2000 Konstantin Boldyshev <konst@linuxassembly.org>
;
;$Id: sln.asm,v 1.1 2000/03/02 08:52:01 konst Exp $
;
;hackers' sln
;
;0.01: 26-Feb-2000	initial release
;
;syntax: sln src dest
;
;example: sln aaa bbb

%include "system.inc"

CODESEG

START:
	pop     ebx
	cmp	ebx,byte 3
	jnz	_exit

	pop	esi
	pop	edi     ;src
	pop	esi	;dst
	sys_unlink esi

	sys_access edi,F_OK
	test	eax,eax
	js	_exit

	sys_symlink edi,esi
_exit:
	sys_exit eax

END
