;Copyright (C) 1995-2000 Konstantin Boldyshev <konst@linuxassembly.org>
;
;$Id: window.asm,v 1.5 2000/09/03 16:13:54 konst Exp $
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
sText2:
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
	movzx	eax,word [sMaxY]
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

.read_key:
	sys_read STDIN,tmp,1
	test	eax,eax
	js	.read_key

	mov	al,byte [tmp]
	cmp	al,0x1b	;Escape
	jz	.restore_screen
	cmp	al,0xd	;Enter
	jnz	.read_key

.restore_screen:

	mov	eax,len_scr
	mov	ebx,old_scr
	_mov	ecx,xy(0,0)
	call	vwrite

	call	close_screen

_exit:
	sys_exit eax

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

open_screen:
	pusha

;
;set non-blocking mode and one-char-at-a-time mode for STDIN
;
	sys_fcntl STDIN,F_SETFL,(O_RDONLY|O_NONBLOCK)
	sys_ioctl STDIN,TCGETS,sattr				; saved until restore
	sys_ioctl EMPTY,EMPTY,tattr				; will be modified
	and dword [tattr+termios.c_lflag],~(ICANON|ECHO|ISIG)	;disable erase/fill processing, echo, signals
	or  dword [tattr+termios.c_oflag],OPOST|ONLCR		;enable output processg, NL<-CR/NL
	and dword [tattr+termios.c_iflag],~(INPCK|ISTRIP|IXON|ICRNL);disable parity chk, 8th bit strip,start/stop prot.
	mov byte [tattr+termios.c_cc+VTIME],0			; timo * 1/10 s (if ~ICANON)
	mov byte [tattr+termios.c_cc+VMIN],1			; min no. of chars for a single read opr
	sys_ioctl STDIN,TCSETS,tattr

;
; open /dev/vcsa
;
	sys_open cScreenDevice, O_RDWR
	mov	[sHandle],eax
	test	eax,eax
	js	near _exit
;
; get console size and cursor position
;
	sys_read eax,sMaxY,4

	_mov	ecx,xy(0,0)
	call	gotoXY

	popa
	ret


close_screen:
	pusha
	sys_ioctl STDIN,TCSETS,sattr
	sys_close [sHandle]
	popa
	ret

;
;write character at current position
;
;<al	character
;
write_char:
	pusha
	mov	ecx,sChar
	mov	[ecx],al
	sys_write [sHandle], EMPTY, 1
	popa
	ret

;
;write attribute at current position
;
;<al	character
;
write_attr:
	pusha
	mov	ecx,sAttr
	mov	[ecx],al
	push	ecx
	sys_lseek [sHandle], 1, SEEK_CUR
	pop	ecx
	sys_write
	popa
	ret

;
;write character and attribute at current position
;
;<al	character
;<ah	attribute
;
writech:
	pusha
	mov	ecx,sChar
	mov	[ecx],ax
	sys_write [sHandle], EMPTY, 2
	popa
	ret

;
;write string to the screen
;
;<esi	string offset
;
write:
	pusha
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
	jmp	short .loop
.attr:
	lodsb
	mov	ah,al
	jmp	short .loop
.put:
	call	writech
	jmp	short .loop
.end:
	popa
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
	pusha
	sys_lseek [sHandle], 2, SEEK_SET
	sys_read EMPTY, sCurY, 2
	popa
	mov	cx,word [sCurY]
	ret

;
;<ch	X
;<cl	Y
;<eax	number of bytes
;>ebx	destination
;
vread:
	pusha
	call gotoXY
	mov	ecx,ebx
	mov	edx,eax
	sys_read [sHandle]
	popa
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

tattr I_STRUC termios
.c_iflag	UINT	1
.c_oflag	UINT	1
.c_cflag	UINT	1
.c_lflag	UINT	1
.c_line		UCHAR	1
.c_cc		UCHAR	NCCS
I_END

sattr I_STRUC termios
.c_iflag	UINT	1
.c_oflag	UINT	1
.c_cflag	UINT	1
.c_lflag	UINT	1
.c_line		UCHAR	1
.c_cc		UCHAR	NCCS
I_END

END
