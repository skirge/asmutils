;Copyright (C) 2000 Konstantin Boldyshev <konst@linuxassembly.org>
;
;$Id: tty.asm,v 1.1 2000/04/07 18:36:01 konst Exp $
;
;hackers' tty
;
;0.01: 21-Mar-2000	initial release
;
;syntax: tty

%include "system.inc"

%assign	BufSize	0x1000

CODESEG

START:
	sys_readlink fd0, Buf, BufSize
	test	eax,eax
	js	_exit

	inc	eax
	mov	edx,eax
	mov	esi,ecx
.next:
	lodsb
	or	al,al
	jnz	.next
	mov	byte [esi-1],__n

	sys_write STDOUT

_exit:
	sys_exit eax

fd0	db	"/proc/self/fd/0"	;,EOL

UDATASEG

Buf	resb	BufSize

END
