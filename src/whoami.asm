; Copyright (C) 2001, Tiago Gasiba (ee97034@fe.up.pt)
;
; $Id: whoami.asm,v 1.1 2001/08/19 12:41:59 konst Exp $
;
; hacker's whoami
;
;
; TO DO:
;        - UID not found in /etc/passwd
;        - read() doesn't read all file at once
;        - optimize SPEED and SIZE (algorithm??)

%include "system.inc"

BUFFERLEN		equ	20
MAXSTRLEN		equ	200

STACK_FRAME_SIZE	equ	16

FSIZE			equ	12
FD			equ	8
UID			equ	4
BEG_DATA		equ	0

CODESEG

START:
	mov	ebp,esp				; create stack frame

	sub	esp,STACK_FRAME_SIZE
	sys_brk
	mov	dword [esp+BEG_DATA],eax	; save beg. of data

	sys_getuid
	mov	dword [esp+UID],eax

	sys_open	file,O_RDONLY
	test	eax,eax
	js	near .exit
	mov	dword [esp+FD],eax		; save file descrp.
	
	sys_lseek	[esp+FD],0,SEEK_END
	mov	dword	[esp+FSIZE],eax

	sys_lseek	[esp+FD],0,SEEK_SET

	mov	eax,dword [esp+BEG_DATA]
	add	eax,dword [esp+FSIZE]
	inc	eax
	sys_brk	eax
	mov	eax,dword [esp+BEG_DATA]
	mov	byte [eax],0xa

	mov	eax,[esp+BEG_DATA]
	inc	eax
	sys_read	[esp+FD],eax,[esp+FSIZE]
						;  FIXME FIXME FIXME
						; have we read all???
	
	sys_close	[esp+FD]

	; search for name
	cld
	mov	edi,[esp+BEG_DATA]
	mov	ecx,[esp+FSIZE]

.outro:
	_mov	eax,':'
times 2	repne	scasb
	mov	esi,edi
	repne	scasb
	dec	edi
	mov	byte [edi],0
	call	ascii2uint
	cmp	eax,[esp+UID]
	je	.encontrado
	_mov	eax,0xa
	repne	scasb
	jmp	short	.outro

.encontrado:
	std
	_mov	eax,0xa
	mov	edi,esi
	repne	scasb
	inc	edi
	inc	edi
	push	edi
	_mov	eax,':'
	cld
	repne	scasb
	dec	edi
	mov	word [edi],0x000a
	pop	esi

	call	strlen

	sys_write	STDOUT,esi,eax
.exit:
	mov	esp,ebp				; destroy stack frame
	sys_exit	0

;--------------------------------------------------
; Function    : ascii2uint
; Description : converts an ASCIIZ number to uint
; Needs       : esi - pointer to string
; Gives       : eax - converted number
; Destroys    : eax
;--------------------------------------------------
ascii2uint:
	pusha
	_mov	eax,0			; initialize sum
	_mov	ebx,0			; zero digit
.repete:
	_mov	bl,byte [esi]		; get digit
	test	bl,bl
	jz	.exit			; are we done ?
	and	bl,~0x30		; ascii digit -> bin digit
	imul	eax,10			; prepare next conversion
	add	eax,ebx
	inc	esi			; next digit
	jmp	short .repete
.exit:
	mov	dword[esp+28],eax	;save eax
	popa
	ret

;-----------------------------------------------------
; function  : strlen
; objective : returns the length of a string
; needs     : esi - pointer to stringz
; returns   : eax - string length
; destroys  : eax
;-----------------------------------------------------
strlen:
	pusha
	cld
	_mov	ecx,MAXSTRLEN
	mov	edi,esi
	_mov	eax,0
	repne	scasb
	_mov	eax,MAXSTRLEN
	sub	eax,ecx
	dec	eax
	mov	dword [esp+28],eax
	popa
	ret


file	db	"/etc/passwd",0

UDATASEG					; to be able to brk()

END
