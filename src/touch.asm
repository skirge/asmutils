;Copyright (C) 2000 Jonathan Leto <jonathan@leto.net>
;
;$Id: touch.asm,v 1.3 2001/08/01 05:05:29 konst Exp $
;
;hackers' touch
;
;syntax: touch [-c] file [file] ...
;
; Version 0.1 - Wed Dec 20 02:58:02 EST 2000  
;
; All comments/feedback welcome.

%include "system.inc"

CODESEG

START:
	pop eax
	pop eax
.next:
	pop eax
	or eax,eax
	jnz .continue

.continue:
	sys_exit 0 

	cmp word [eax],'-c'
	je	.nocreate

	_mov [file],eax
	test	eax,eax
	jns	.touchfile

	cmp [nocreate], byte 1
	je	.touchfile

	; create new file
	sys_open [file],O_RDWR|O_CREAT,0666q

.touchfile:
	sys_utime [file],NULL
	_jmp .next

.nocreate:
        inc     byte [nocreate]
        _jmp     .next

UDATASEG
	
file:	resd 255
nocreate: resb 1

END
