;Copyright (C) 1995-2000 Konstantin Boldyshev <konst@linuxassembly.org>
;
;$Id: window.asm,v 1.4 2000/04/07 18:36:01 konst Exp $
;
;text window example


%include "system.inc"

wX	equ	2
wY	equ	1        ; Window position
wXlen	equ	64
wYlen	equ	12       ; Window size

cBack	equ	0x1BB0
cWin	equ	0x01DB
cShadow	equ	0x03      ; shadow attribute


CODESEG

%define xy(x,y) ((x) << 8) | (y)

%macro s_xy 2
	db	cXY
	db	%2
	db	%1
%endmacro
%macro s_attr 1
	db	cAttr,%1
%endmacro
%macro s_end 0
	db	cEnd
%endmacro


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

;
;calculate scr len
;
	xor	eax,eax
	mov	ax,word [sMaxY]
	mul	ah
	shl	eax,1
	mov	[len_scr],eax

;save old screen

	mov	ebx,old_scr
	_mov	ecx,xy(0,0)
	call	vread

;clear screen

	_mov	ecx,xy(0,0)
	call	gotoXY

	mov	ecx,eax
	shr	ecx,1
	mov	ax,cBack
.next:
	call	writech
	loop	.next


;draw window

	call	window

;read a key

	sys_read STDIN,tmp,1

;restore old screen

	mov	eax,len_scr
	mov	ebx,old_scr
	_mov	ecx,xy(0,0)
	call	vwrite

	call	close_screen

	sys_exit_true

;
; Window function
;

window:
	_mov	ecx,xy(wX,wY)
	call	gotoXY
	
	mov	ecx,wXlen
	mov	ax,cWin
.first:
	call	writech
	loop	.first

	mov	ecx,wYlen-2
.middle:
	push	ecx
	add	ecx,wY
	add	ecx,(wX << 8)
	call	gotoXY
	mov	ax,(cWin & 0xf0) | 221
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
	call	gotoXY

	mov	ecx,wXlen
	mov	ax,cWin
.last:
	call	writech
	loop	.last

	mov	al,cShadow
	call	write_attr
	call	write_attr

	mov	ecx,xy(wX+2,wY+wYlen)
	call	gotoXY
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

MAX_X		equ	200
MAX_Y		equ	100

cXY		equ	0x02
cAttr		equ	0x01
cEnd		equ	0x00
cDefAttr	equ	0x07

cScreenDevice	db	"/dev/vcsa0",EOL

_exit:
	sys_exit eax

open_screen:
	pushad
	sys_open cScreenDevice, O_RDWR
	mov	[sHandle],eax
	test	eax,eax
	js	_exit
	sys_read eax,sMaxY,4
	_mov	ecx,xy(0,0)
	call	gotoXY
	popad
	ret

close_screen:
	pushad
	sys_close [sHandle]
	popad
	ret

;
;write character at current position
;
;<al	character
;
write_char:
	pushad
	mov	ecx,sChar
	mov	[ecx],al
	sys_write [sHandle], EMPTY, 1
	popad
	ret

;
;write attribute at current position
;
;<al	character
;
write_attr:
	pushad
	mov	ecx,sAttr
	mov	[ecx],al
	push	ecx
	sys_lseek [sHandle], 1, SEEK_CUR
	pop	ecx
	sys_write
	popad
	ret

;
;write character and attribute at current position
;
;<al	character
;<ah	attribute
;
writech:
	pushad
	mov	ecx,sChar
	mov	[ecx],ax
	sys_write [sHandle], EMPTY, 2
	popad
	ret

;
;write string to the screen
;
;<esi	string offset
;
write:
	pushad
	_mov	eax,0
	mov	ah,cDefAttr
.loop:
	lodsb
	or	al,al
	jz	.end
	cmp	al,cAttr
	jz	.attr
	cmp	al,cXY
	jnz	.put
	push	eax
	lodsw
	mov	ecx,eax
	call	gotoXY
	pop	eax
	jmp	.loop
.attr:
	lodsb
	mov	ah,al
	jmp	.loop
.put:
	call	writech
	jmp	.loop
.end
	popad
	ret

;
;set cursor position
;
;<ch	X
;<cl	Y
;
gotoXY:
	pushad

calcXY:

_xadd		equ	0x04
_xcoef		equ	0x02
_ycoef		equ	0xa0

	mov	eax,ecx
	mov	bl,[sMaxX]
	mul	bl
	mov	ebx,eax
	xor	eax,eax
	mov	al,ch
	add	ebx,eax
	shl	ebx,1
	add	ebx,_xadd
	mov	ecx,ebx

	sys_lseek [sHandle], EMPTY, SEEK_SET
	popad
	ret

;
;get cursor position
;
;>ch	X
;>cl	Y
;
getXY:
	pushad
	sys_lseek [sHandle], 2, SEEK_SET
	sys_read EMPTY, sCurY, 2
	popad
	mov	cx,word [sCurY]
	ret

;
;<ch	X
;<cl	Y
;<eax	number of bytes
;>ebx	destination
;
vread:
	pushad
	call gotoXY
	mov	ecx,ebx
	mov	edx,eax
	sys_read [sHandle]
	popad
	ret

vwrite:
	pushad
	call gotoXY
	mov	ecx,ebx
	mov	edx,eax
	sys_write [sHandle]
	popad
	ret


UDATASEG

sMaxY		resb	1
sMaxX		resb	1
sCurY		resb	1
sCurX		resb	1
sHandle		resd	1
sChar		resb	1
sAttr		resb	1

tmp		resd	1

len_scr		resd	1
old_scr		resb	MAX_X * MAX_Y * 2


END
