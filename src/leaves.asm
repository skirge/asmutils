;Copyright (C) 1996-2000 Konstantin Boldyshev <konst@linuxassembly.org>
;
;$Id: leaves.asm,v 1.4 2000/03/02 08:52:01 konst Exp $
;
;leaves		-	Linux fbcon intro in 396 bytes
;
;Once I've took one of my old DOS intros made in tasm, and rewrote it
;for nasm and Linux/fbcon.. He-he.. I've got 396 bytes.
;(DOS 16-bit version was 381 byte long)
;
;This intro is the smallest implementation
;of linear transformation with recursion (AFAIK).
;
;This intro was presented on a few parties and produced
;an explosion of interest :) (however it wasn't nominated,
;because it doesn't fit into rules [yet])
;
;Intro MUST be run only in 640x480x256 mode (vga=0x301 in lilo.conf).
;You will see garbage or incorrect colors in other modes.
;
;Warning! Intro assumes that everything is ok with the system (/dev/fb0 exists,
;can be opened and mmap()ed, correct video mode is set, and so on). So, if you
;ain't root, check permissions on /dev/fb0 first, or you will not see anything.
;
;If everything is ok you should see two branches of green leaves,
;and kinda wind blowing on them ;)
;
;Intro runs for about a minute and a half (depends on machine),
;and is interruptible at any time with ^C.
;
;Here is the source. It is quite short and self-explaining..
;Well, actually source is badly optimized for size, contains
;some Linux specific tricks, and can be hard to understand.
;
;Source is quite portable, you only need to implement
;putpixel() and initialization part for your OS.
;
;Ah, /if haven't guessed yet/ license is GPL, so enjoy! :)

%include "system.inc"

%assign SIZE_X 640
%assign SIZE_Y 480
%assign DEPTH 8

%assign VMEM_SIZE SIZE_X*SIZE_Y

;%define MaxX 640.0
;%define MaxY 480.0
;%define xc MaxX/2
;%define yc MaxY/2
;%define xmin0 100.0
;%define xmax0 -xmin0
;%define ymin0 xmin0
;%define ymax0 -ymin0

CODESEG

;
;al	-	color
;

putpixel: 
	push	edx		
        lea	edx,[ebx+ebx*4]	;computing offset..
        shl	edx,byte 7	;multiply on 640
	add	edx,[esp+8]	;
	mov	[edx+esi],al	;write to frame buffer
	pop	edx
_return:
        ret

;
; recursive function itself
;

leaves: 
        mov	ecx,[esp+12]
        test	cl,cl
	jz	_return

        mov	[esp-13],cl

        mov	eax,[edi]

        push	ecx

        sub	esp,byte 8
	mov	edx,esp

	fld	dword [ebp+16]	;[f]
	fld	st0
	fld	st0
	fmul	dword [edx+16]
	fadd	dword [ebp+24]	;[y1coef]
	fistp	dword [edx]
        mov	ebx,[edx]

	fmul	dword [edx+20]
	fsubr	dword [ebp+20]	;[x1coef]
	fistp	dword [edx]

        call	putpixel

	fmul	dword [edx+20]
	fadd	dword [ebp+28]	;[x2coef]
	fistp	dword [edx]
        call	putpixel

	inc	edi
        cmp	edi,ColorEnd
        jl	.rec
	sub	edi,byte ColorEnd-ColorBegin
.rec:

	fld	dword [ebp+4]	;[b]
	fld	dword [ebp]	;[a]
	fld	st1
	fld	st1
	fxch
	fmul	dword [edx+16]
	fxch
	fmul	dword [edx+20]
	fsubp	st1
	fstp	dword [edx-8]

	fmul	dword [edx+16]
	fxch
	fmul	dword [edx+20]
	faddp	st1

	dec	ecx
        push	ecx

        sub	esp,byte 8
	fstp	dword [esp]

        call	leaves		;esp+12

	mov	edx,esp
	fld	dword [ebp+12]	;[d]
	fld	dword [edx+28]
	fld	dword [ebp+8]	;[c]
	fld	dword [ebp+32]	;[x0]
	fsub	to st2
	fld	st3
	fld	st2
	fxch
	fmul	st4
	fxch
	fmul	dword [edx+32]
	faddp	st1
	fstp	dword [edx-8]

	fxch
	fmulp	st2
	fxch	st2
	fmul	dword [edx+32]
	fsubp	st1
	faddp	st1

        push	ecx

        sub	esp,byte 8
	fstp	dword [esp]

        call	leaves

        add	esp,byte 12*2+8

        pop	ecx
.return:
        ret

;
; main()
;

START:

;init fb
	mov	edi,VMEM_SIZE
	mov	ebp,Params

	lea	ebx,[ebp + 0x2c]	;fb-Params
	sys_open EMPTY,O_RDWR

;	test	eax,eax			;have we opened file?
;	js	exit

;prepare structure for mmap on the stack

	_push	0			;.offset
	_push	eax			;.fd
	_push	MAP_SHARED		;.flags
	_push	PROT_READ|PROT_WRITE	;.prot
	_push	edi			;.len
	_push	0			;.addr
	mov	ebx,esp
	sys_mmap

;	test	eax,eax		;have we mmaped file?
;	js	exit

	mov	esi,eax

;clear screen
	mov	ecx,edi
	mov	edi,esi
	xor	eax,eax
	rep	stosb

;leaves
	lea	edi,[ebp + 0x24]	;ColorBegin-Params
        _push	28			;recursion depth
	_push	eax
	_push	eax
        call	leaves

;close fb
;	sys_munmap esi,VMEM_SIZE
;	sys_close mm.fd

exit:
	sys_exit

;
;
;

Params:

a	dd	0.7
b	dd	0.2
c	dd	0.5
d	dd	0.3

f	dd	0xc0400000	;MaxY/(ymax0-ymin0)*3/2	
x1coef	dd	0x433b0000	;MaxX-MaxY*4/9-yc
y1coef	dd	0x43dc0000	;MaxY/4+xc
x2coef	dd	0x43e28000	;MaxY*4/9+yc
x0	dd	112.0

ColorBegin:
	db	0,0,2,0,0,2,10,2
ColorEnd:

fb	db	"/dev/fb0";,EOL

END
