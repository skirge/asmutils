;Copyright (C) 1999 Konstantin Boldyshev <konst@linuxassembly.org>
;
;$Id: execve.asm,v 1.2 2000/02/10 15:07:04 konst Exp $
;
;execute a given program
;
;use with regs
;
;example: ./execve ./regs

%include "system.inc"

struc regs
.eax	resd	1
.ebx	resd	1
.ecx	resd	1
.edx	resd	1
.esi	resd	1
.edi	resd	1
.ebp	resd	1
.esp	resd	1
.eflags	resd	1
.cs	resd	1
.ds	resd	1
.es	resd	1
.fs	resd	1
.gs	resd	1
.ss	resd	1
endstruc

CODESEG

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
	_mov	ecx,16	;10 - decimal
	_mov	esi,0
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

PrintRegs:
	pushad
	mov	[r.eax],eax
	mov	eax,r
	pushfd
	pop	dword [eax+r.eflags-r]
	mov	[eax+r.ebx-r],ebx
	mov	[eax+r.ecx-r],ecx
	mov	[eax+r.edx-r],edx
	mov	[eax+r.esi-r],esi
	mov	[eax+r.edi-r],edi
	mov	[eax+r.ebp-r],ebp
	mov	[eax+r.esp-r],esp
	add	dword [eax+r.esp-r],4
	mov	[eax+r.cs-r],cs
	mov	[eax+r.ds-r],ds
	mov	[eax+r.es-r],es
	mov	[eax+r.fs-r],fs
	mov	[eax+r.gs-r],gs
	mov	[eax+r.ss-r],ss
	
	mov	esi,eax
	mov	ebp,rstring

	sys_write STDOUT,before,s_before
	sys_write EMPTY,line,s_line

	_mov	ecx,15

.mainloop:
	push	ecx
	mov	ecx,ebp
.l1:
	inc	ebp
	cmp	[ebp],byte 0
	jnz	.l1
	mov	edx,ebp
	sub	edx,ecx
	sys_write STDOUT
	inc	ebp
	lodsd
	mov	edi,tmpstr
	call	LongToStr
	call	StrLen
	sys_write STDOUT,edi
	sys_write EMPTY,lf,1
	pop	ecx
	loop	.mainloop

	sys_write STDOUT,inside,s_inside
	sys_write EMPTY,line,s_line

	popad
	ret

rstring:

db	"EAX	:	",EOL
db	"EBX	:	",EOL
db	"ECX	:	",EOL
db	"EDX	:	",EOL
db	"ESI	:	",EOL
db	"EDI	:	",EOL
db	"EBP	:	",EOL
db	"ESP	:	",EOL
db	"EFLAGS	:	",EOL
db	"CS	:	",EOL
db	"DS	:	",EOL
db	"ES	:	",EOL
db	"FS	:	",EOL
db	"GS	:	",EOL
db	"SS	:	",EOL

line	db	0x0A,"--------------------------"
lf	db	0x0A
s_line	equ	$-line

before	db	"Before sys_execve:"
s_before	equ	$-before

inside	db	0x0A,"Inside called program:"
s_inside	equ	$-inside


START:
	pop	ebp			;get argc
	dec	ebp			;exit if no args
	jnz	.go
	sys_exit_true
.go:
	pop	esi			;get our name
	mov	ebx,[esp]		;ebx -- program name (*)
	mov	ecx,esp			;ecx -- arguments (**)
	lea	edx,[esp+(ebp+1)*4]	;edx -- environment (**)

;now we will try to pass some magic values to launched program
;on Linux 2.0 program will get them!

	mov	esi,0x11223344
	mov	edi,0x55667788
	mov	ebp,0x9900AABB

	call	PrintRegs

	sys_execve

UDATASEG

r I_STRUC regs
.eax	resd	1
.ebx	resd	1
.ecx	resd	1
.edx	resd	1
.esi	resd	1
.edi	resd	1
.ebp	resd	1
.esp	resd	1
.eflags	resd	1
.cs	resd	1
.ds	resd	1
.es	resd	1
.fs	resd	1
.gs	resd	1
.ss	resd	1
iend

tmpstr	resd	10

END
