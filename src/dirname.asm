;Copyright (C) Alexandr Gorlov <ct@mail.ru>
;
;$Id: dirname.asm,v 1.1 2000/04/07 18:36:01 konst Exp $
;
;hackers dirname
;
;0.01: 15-Mar-2000	initial release
;0.02: 21-Mar-2000	full rewrite ;)
;
;syntax: 
;	 dirname <path>
;
%include "system.inc"

lf 	equ	0x0A

CODESEG

START:

;====== У нас 2 аргумента ? ===========

	pop ecx		; argc

	dec ecx
	dec ecx
	jnz .exit	; argc == 2, else .exit
			; !!?? Show syntax, in next version
	
	pop edi
	pop edi		; Get the address of ASCIIZ string

	call StrLen	; edx: = length of our string
	call Strip_trailing_slashes

	push	edi		; ( addr )
	
	add	edi, edx	;
	dec	edi		; edi : = last character in string

	mov	ecx, edx	 
	mov	al, "/"
	repne	scasb

.if:	test	ecx, ecx
	je	.then		; If nothig like "/"
				; print "."
.else:				
	mov	edx, ecx
	pop	edi
	call	Strip_trailing_slashes

	mov	byte [edx+edi], lf
	inc	edx
	sys_write STDOUT, edi, edx
	sys_exit
.then:

	sys_write STDOUT, dot, len_dot

.exit:
	sys_exit


dot	db	'.', lf
len_dot	equ $ - dot

;
;Return string length
;
;>EDI
;<EDX
;Regs: none ;)
StrLen:
        push    edi
        mov     edx,edi
        dec     edi
.l1:
        inc     edi
        cmp     [edi],byte 0
        jnz     .l1
        xchg    edx,edi
        sub     edx,edi
        pop     edi
        ret


;============================================================================
; Strip_trailing_slashes - remove all "/" characters in the end of the string
;============================================================================
;In:	edi - addr of string
;	edx - length of string
;	edi - addr of string
;Out:	edx - new length of the string
;============================================================================
Strip_trailing_slashes:
	push eax 
	
	mov	al, "/"
	xchg	edi, edx
	add	edi, edx
	dec	edi
	std

.loop:
	cmp	edi, edx
	je	.end
	scasb
	je	.loop
	inc	edi
.end:
	sub	edi, edx
	inc	edi
	xchg	edi, edx
	
	
	pop eax
	ret

END
