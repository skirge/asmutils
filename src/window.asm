;Copyright (C) 1995-2000 Konstantin Boldyshev <konst@linuxassembly.org>
;
;$Id: window.asm,v 1.2 2000/02/10 15:07:04 konst Exp $
;
;test window example (currently works only in 80x25)


%include "system.inc"

wX	equ	2
wY	equ	1        ; Window position
wXlen	equ	64
wYlen	equ	12       ; Window size

cBack	equ	0x1BB0
cWin	equ	0x01DB
cShadow	equ	0x03      ; shadow attribute


scradd		equ	4
xcoef		equ	2
ycoef		equ	0xA0

cEnd		equ	0x00
cXY		equ	0x02
cAttr		equ	0x01
cDefAttr	equ	0x07

%define xy(x,y) (x) * xcoef + (y) * ycoef

%macro s_end 0
	db	cEnd
%endmacro

%macro s_attr 1
	db	cAttr,%1
%endmacro

%macro s_xy 2
	db	cXY
	dw	xy(%1,%2)
%endmacro


CODESEG


sHeader:
	s_xy	wX+(wXlen-lHeader)/2,wY
	s_attr	0x1F
.text:
	db	'Shadowed window with header and status bar'
	s_end
lHeader	equ	$ - .text

sText:
	s_xy	wX+(wXlen-lText1-4)/2, (wYlen)/2 - 1
	s_attr	0x09
	db	'[ '
	s_attr	0x8E
.t1:
	db	'Assembler Inside'
lText1	equ	$ - .t1
	s_attr	0x09
	db	' ]'
sText2
	s_xy	wX+(wXlen-lText2)/2, (wYlen)/2 + 1
	s_attr	0x0A
.t2:
	db	'kick enter to crash keyboard'
lText2	equ	$ - .t2
	s_end


sStatus:
	s_xy	wX+2,wY+wYlen-1 
	s_attr	0x1B
.text:
	db	'Designed for Linux/i386 '
;	s_attr	0x9F
;	db	':)'
	s_end
lStatus	equ	$ - .text

;
;
;

START:
	call	open_screen

;clear screen

	mov	ecx,2000
	mov	ax,cBack
.next:
	call	writech
	loop	.next


;draw window

	call	window

	call	close_screen

;read a key

	xor	ebx,ebx
	mov	edx,ebx
	inc	edx
	mov	ecx,tmp
	sys_read

	sys_exit

;
; Window function
;

window:
	mov	ecx,xy(wX,wY)
	call	gotoxy
	
	mov	ecx,wXlen
	mov	ax,cWin
.first:
	call	writech
	loop	.first

	mov	ecx,wYlen-2
.middle:
	push	ecx
	add	ecx,wY
	mov	eax,ycoef
	mul	ecx
	add	eax,wX*2
	xchg	eax,ecx
	call	gotoxy
	mov	ax,cWin
	mov	al,221
	call	writech
	mov	ecx,wXlen-2
	mov	al,' '
.spc:
	call	writech
	loop	.spc
	mov	al,222
	call	writech
	mov	al,cShadow
	call	write_attr
	call	write_attr
	pop	ecx
	loop	.middle

	mov	ecx,xy(wX,wY+wYlen-1)
	call	gotoxy

	mov	ecx,wXlen
	mov	ax,cWin
.last:
	call	writech
	loop	.last

	mov	al,cShadow
	call	write_attr
	call	write_attr

	mov	ecx,xy(wX+2,wY+wYlen)
	call	gotoxy
	mov	ecx,wXlen
.down:
	call	write_attr	
	loop	.down

	mov	esi,sHeader
	call	write
	mov	esi,sText
	call	write
	mov	esi,sStatus
	call	write
	ret

;
; Screen library itself
;


sScreenDevice	db	"/dev/vcsa0",0

open_screen:
	pushad
	sys_open sScreenDevice,O_RDWR
	mov	[sHandle],eax

	sys_read eax,sMaxY,2

	mov	ecx,xy(0,0)
	call	gotoxy

	popad
	ret

close_screen:
	pushad
	sys_close [sHandle]
	popad
	ret

;
; set cursor position
;

;setxy:
;	pushad
;	popad
;	ret

;
; get cursor position
;

;getxy:
;	pushad
;	popad
;	ret

write_char:
	pushad
	mov	ecx,sChar
	mov	[ecx],al
	xor	edx,edx
	inc	edx
	sys_write [sHandle]
	popad
	ret

write_attr:
	pushad
	mov	ecx,sAttr
	mov	[ecx],al
	push	ecx
	xor	edx,edx
	inc	edx
	mov	ecx,edx
	mov	ebx,[sHandle]
	sys_lseek	
	pop	ecx
	sys_write
	popad
	ret

;write out char (al - char, ah - attr)
writech:
	pushad
	mov	ecx,sChar
	mov	[ecx],ax
	xor	edx,edx
	inc	edx
	inc	edx
	sys_write [sHandle]
	popad
	ret

;write string to the screen (esi - offset)
write:
	pushad
	mov	ah,cDefAttr
.loop:
	lodsb
	or	al,al
	jz	.end
	cmp	al,cAttr
	jz	.attr
	cmp	al,cXY
	jnz	.put
	push	ax
	lodsw
	xor	ecx,ecx
	mov	cx,ax
	call	gotoxy
	pop	ax

	stc
	jc	.loop
.attr:
	lodsb
	mov	ah,al
	stc
	jc	.loop
.put:
	call	writech
	stc
	jc	.loop		
.end
	popad
	ret

;goto xy (ecx - coordinates)
gotoxy:
	pushad
	_add	ecx,scradd
	xor	edx,edx
	sys_lseek [sHandle]
	popad
	ret

UDATASEG

sHandle		resd	1
sChar		resb	1
sAttr		resb	1

sMaxY		resb	1
sMaxX		resb	1

tmp		resd	1

END
