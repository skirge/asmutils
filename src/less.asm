; Copyright (C) 2001, Tiago Gasiba (ee97034@fe.up.pt)
;
; $Id: less.asm,v 1.1 2001/08/24 09:47:28 konst Exp $
;
; hacker's less
;
;
; syntax:
;	less file
; or    less < file
;
;
; TODO:
;	- add "/" (search)
;	- optimize source code
;
; known bugs:
;	- there are some problems with TAB's
; 

%include "system.inc"

LineWidth		equ	80
NumLines		equ	24

KEY_DOWN		equ	0x00425b1b
KEY_UP			equ	0x00415b1b
KEY_Q			equ	0x00000071
KEY_PGDOWN		equ	0x7e365b1b
KEY_PGUP		equ	0x7e355b1b

BUFF_IN_LEN		equ	8192
MEM_RESERV		equ	1024

CODESEG

START:
main:
		push	byte STDIN
		pop	dword [fd]

		pop	ebx
		dec	ebx
		pop	ebx
		jz	.entrada
		pop	ebx
		_mov	ecx,O_RDONLY
		sys_open
		mov	dword [fd],eax
.entrada:
		sys_ioctl	STDERR,TCGETS,oldtermios
		sys_ioctl	STDERR,EMPTY,newtermios
		and	dword [newtermios+termios.c_lflag],~(ICANON|ECHO|ISIG)
		sys_ioctl	STDERR,TCSETS,newtermios
		call	ler_ficheiro
		call	init_lines

		push	byte 0
		pop	dword [pos]		; set position = 0 (TOP)

.reescreve:
		sys_write	STDOUT,clear,clearlen
		call	write_lines
		sys_write	STDOUT,rev_on,rev_on_len
		mov	eax,dword [pos]
		mov	edi,msg
		call	itoa
		inc	edx
		push	edx
		mov	byte [edi],'/'
		inc	edi
		mov	eax,dword [nlines]
		call	itoa
		pop	eax
		add	edx,eax
		sys_write	STDOUT,msg
		sys_write	STDOUT,rev_off,rev_off_len
.outra_vez:
		push	byte 0
		pop	dword [key_pressed]
		sys_read	STDERR,key_pressed,4
		mov	eax,[key_pressed]

		cmp	eax,KEY_Q		; KEY_Q event
		je	.terminar

		cmp	eax,KEY_DOWN
		je	event_key_down
						; KEY_DOWN event
		cmp	eax,KEY_UP
		je	event_key_up

		cmp	eax,KEY_PGDOWN
		je	near event_key_pgdown

		cmp	eax,KEY_PGUP
		je	near	event_key_pgup

		jmp	short	.outra_vez
.terminar:
		sys_ioctl	STDERR,TCSETS,oldtermios
		sys_write	STDOUT,NL,1
		sys_exit	0


;=====================================================
;                  event_key_up
;=====================================================
event_key_up:
	cmp	dword [pos],0
	je	near	bell
	cmp	dword [nlines],NumLines
	jl	near	bell
	dec	dword [pos]
	jmp	near main.reescreve

;=====================================================
;                  event_key_down
;=====================================================
event_key_down:
	cmp	dword [nlines],NumLines
	jl	near	bell
	mov	eax,dword [nlines]
	sub	eax,NumLines
	cmp	dword [pos],eax
	je	bell
	inc	dword [pos]
	jmp	near main.reescreve

;=====================================================
;                  event_key_pgdown
;=====================================================
event_key_pgdown:
	cmp	dword [nlines],NumLines
	jl	bell
	mov	eax,dword [nlines]
	sub	eax,NumLines
	mov	ebx,dword [pos]
	add	ebx,NumLines
	cmp	eax,ebx
	jg	.lbl1
	mov	dword [pos],eax
	jmp	short	bell
.lbl1:
	mov	dword [pos],ebx
	jmp	near main.reescreve

;=====================================================
;                  event_key_pgup
;=====================================================
event_key_pgup:
	cmp	dword [nlines],NumLines
	jl	bell
	mov	eax,dword [pos]
	sub	eax,NumLines
	jns	.lbl1
	push	byte 0
	pop	dword [pos]
	jmp	short bell
.lbl1:
	mov	dword [pos],eax
	jmp	near main.reescreve

bell:
	sys_write	STDOUT,bell_str,bell_str_len
	jmp	near main.reescreve


;-----------------------------------------------------
; function    : ler_ficheiro
; description : initializes the buffer
; needs       : [fd]
; returns     : [lines]
; destroys    : -
;-----------------------------------------------------
ler_ficheiro:
	pusha
	_mov	ebp,filebuffer
.lbl1:
	sys_read	[fd],buffin,BUFF_IN_LEN

	test	eax,eax
	jz	.fim
	mov	ebx,eax
	add	ebx,ebp
	push	eax
	sys_brk
	_mov	esi,buffin
	_mov	edi,ebp
	cld
	pop	ecx
	rep	movsb
	mov	ebp,edi
	jmp	short	.lbl1
.fim:	
	mov	dword [lines],ebp
	mov	dword [ebp],filebuffer
	popa
	ret

;-----------------------------------------------------
; function    : init_lines
; description : initializes lines structure
; needs       : -
; returns     : -
; destroys    : -
;-----------------------------------------------------
init_lines:
	pusha
	cld
	mov	esi,filebuffer
	mov	ebp,dword [lines]
	mov	ecx,ebp
	sub	ecx,esi
	mov	edx,LineWidth
	mov	edi,ebp
.lbl1:
	lodsb
	dec	edx
	cmp	al,0xa
	je	.lbl2
	test	edx,edx
	jnz	.lbl4
.lbl2:
	add	ebp,4
	cmp	edi,ebp
	jg	.lbl3
	add	edi,MEM_RESERV
	sys_brk	edi
.lbl3:
	mov	dword [ebp],esi
	inc	dword [nlines]
	mov	edx,LineWidth
.lbl4:
	loop	.lbl1
.fim:
	popa
	ret

;-----------------------------------------------------
; function    : write_lines
; description : writes a max. of NumLines to STDOUT
; needs       : -
; returns     : -
; destroys    : -
;-----------------------------------------------------
write_lines:
	mov	ebp,dword [lines]
	mov	edx,dword [pos]
	mov	eax,dword [nlines]
	sub	eax,edx
	mov	ecx,eax

	shl	edx,2
	add	ebp,edx
	cmp	eax,NumLines
	jle	.lbl1
	mov	ecx,NumLines
.lbl1:
	push	ecx
	push	edx
	mov	ecx,dword [ebp]
	mov	edx,dword [ebp+4]
	sub	edx,ecx
	sys_write	STDOUT
	add	ebp,4
	pop	edx
	pop	ecx
	loop	.lbl1
	ret

;-----------------------------------------------------
; function  : itoa (modified version)
; objective : convert from int to string
; needs     : eax - unsigned integer
;           : edi - destination buffer
; returns   : edx - string length
; destroys  : edx
;           : edi
;           : eax
;-----------------------------------------------------
itoa:
	_mov	ebx,10
	_mov	ecx,0
	cmp	eax,0
	jne	.lbl1
	push	byte 0x30
	inc	ecx
	jmp	short .lbl2
.lbl1:
	test	eax,eax
	jz	.lbl2
	_mov	edx,0
	idiv	ebx
	or	dl,0x30
	push	edx
	inc	ecx
	jmp	short .lbl1
.lbl2:
	mov	edx,ecx
.fim:	
	pop	eax
	stosb
	loop	.fim
	mov	dword [esp+20],edx
	ret

DATASEG
fd		dd	0
clear		db	0x1b,"[2J",0x1b,"[1H"
clearlen	equ	$-clear
bell_str	db	7
bell_str_len	equ	$-bell_str
rev_on		db	0x1b,"[7m["
rev_on_len	equ	$-rev_on
rev_off		db	"]",0x1b,"[27m"
rev_off_len	equ	$-rev_off
NL		db	0xa

UDATASEG
msg			resb	LineWidth
oldtermios:
	B_STRUC termios,.c_iflag,.c_oflag
newtermios:
	B_STRUC termios,.c_iflag,.c_oflag
key_pressed		resd	1
lines			resd	1			; pnt to lines struct
nlines			resd	1			; nr. of lines
pos			resd	1			; current position
buffin			resb	BUFF_IN_LEN
filebuffer		resb	1			; file buffer
END
