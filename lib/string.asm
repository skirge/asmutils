;Copyright (C) 1999 Konstantin Boldyshev <konst@linuxassembly.org>
;
;$Id: string.asm,v 1.2 2000/02/10 15:07:04 konst Exp $
;
;different string functions
;
;0.01: 04-Jul-1999	initial release

%include "system.inc"

;
;convert 32 bit number to hex string
;
;>EAX
;<EDI

LongToStr:
	pushad
	sub	esp,4
	mov	ebp,esp
	mov	[edi],word "0x"
	inc	edi
	inc	edi
	mov	esi,edi
	push	esi
	mov     [ebp],eax
	_mov ecx,16	;10 - decimal
	_mov esi,0
.l1:
        inc     esi
	xor	edx,edx
	mov	eax,[ebp]
	div	ecx
	mov	[ebp],eax
        mov     al,dl

;dec convertion
;	add	al,'0'
;hex convertion
	add	al,0x90
	daa
	adc	al,0x40
	daa

        stosb
	xor	eax,eax
	cmp	eax,[ebp]
	jnz	.l1
        stosb
	pop	ecx
	xchg	ecx,esi
        shr	ecx,1
	jz	.l3
	xchg	edi,esi
	dec	esi
	dec	esi
.l2:
        mov	al,[edi]
	xchg	al,[esi]
	stosb
	dec     esi
	loop    .l2
.l3:
	add	esp,4
	popad
	ret

;
;convert string to 32 bit number
;
;<EDI
;>EAX

StrToLong:
	push	ebx
	push	ecx
	push	edi
	_mov	eax,0
	_mov	ebx,10
	_mov	ecx,0
.next:
	mov	cl,[edi]
	sub	cl,'0'
	jb	.done
	cmp	cl,9
	ja	.done
	mul	bx
	add	eax,ecx
;	adc	edx,0	;for 64 bit
	inc	edi
	jmp short .next

.done:
	pop	edi
	pop	ecx
	pop	ebx
	ret

;
;Return string length
;
;>EDI
;<EDX
StrLen:
	push	edi
	mov	edx,edi
	dec	edi
.l1:
	inc	edi
	cmp	[edi],byte 0
	jnz	.l1
	xchg	edx,edi
	sub	edx,edi
	pop	edi
	ret
