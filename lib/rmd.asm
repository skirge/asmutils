;Copyright (C) 1999 Cecchinel Stephan <interzone@pacwan.fr>
;
;$Id: rmd.asm,v 1.2 2000/09/03 16:13:54 konst Exp $
;
;calculate the RIPEMD-160 checksum
;
;this code is free, you can eat it, drink it, fuck it , as you want...
;just send me a mail if you use it, if you find bugs, or anything else...

%include "system.inc"

%define FILEBUFFSIZE 8192	; the file buffer size for incoming data
					; need to be fixed for RMD_Final
					; need to be a power of two

;--==oo0 magic initialization constants. Ooo==--
%define _A	0x67452301
%define _B	0xefcdab89
%define _C	0x98badcfe
%define _D	0x10325476
%define _E	0xc3d2e1f0
;========----------------

; The RIPEMD-160  algorithm is a 160 bit checksum algorithm, it is more secure that MD5 algo
; at this time I write this 7 oct 1999 01:31 am   ;  no weakness in this algorithm has been found
; and the creators of the algo tell that for some years it will stay enough secure
; the MD5 algorithm has been proven to be insecure, and should not be used anymore for sensible
; information...
;
;
; it's use is very simple
; first you call RMD_Init  for initialisation of the engine  (no input)
; then you call RMD_Update with esi=buffer
;						ecx=number of bytes to process
;	RMD_Update calculate the checksum of a block of data, you can process a file
;	in one block of in several blocks, you just have to call RMD_Init to re-initialise
;	the RMD engine at the beginning of each new checksum

;	then , when you have process all the file, just call RMD_Final with edi=checksum
;	edi point on a 40 bytes long buffer to store the 160 bit resulting checksum
; very simple no...
; this version is optimize for size , if you want to process big size of data, use rmd160s.asm
; which is the version optimize for speed...

CODESEG

	global RMD_Init
	global RMD_Update
	global RMD_Final


;===========-----------------------------------------------------------
; the RMD-160 core constants , bit shifts, offsets
; (never change the order)
;
Round1:
	dd FF,0
	db 0,11,1,14,2,15,3,12
	db 4,5,5,8,6,7,7,9
	db 8,11,9,13,10,14,11,15
	db 12,6,13,7,14,9,15,8
Round2:	dd GG,0x5a827999
	db 7,7,4,6,13,8,1,13
	db 10,11,6,9,15,7,3,15
	db 12,7,0,12,9,15,5,9
	db 2,11,14,7,11,13,8,12
Round3:	dd HH,0x6ed9eba1
	db 3,11,10,13,14,6,4,7
	db 9,14,15,9,8,13,1,15
	db 2,14,7,8,0,13,6,6
	db 13,5,11,12,5,7,12,5
Round4:	dd II,0x8f1bbcdc
	db 1,11,9,12,11,14,10,15
	db 0,14,8,15,12,9,4,8
	db 13,9,3,14,7,5,15,6
	db 14,8,5,6,6,5,2,12
Round5:	dd JJ,0xa953fd4e
	db 4,9,0,15,5,5,9,11
	db 7,6,12,8,2,13,10,12
	db 14,5,1,12,3,13,8,14
	db 11,11,6,8,15,5,13,6
Round6:	dd JJJ,0x50a28be6
	db 5,8,14,9,7,9,0,11
	db 9,13,2,15,11,15,4,5
	db 13,7,6,7,15,8,8,11
	db 1,14,10,14,3,12,12,6
Round7:	dd III,0x5c4dd124
	db 6,9,11,13,3,15,7,7
	db 0,12,13,8,5,9,10,11
	db 14,7,15,7,8,12,12,7
	db 4,6,9,15,1,13,2,11
Round8:	dd HHH,0x6d703ef3
	db 15,9,5,7,1,15,3,11
	db 7,8,14,6,6,6,9,14
	db 11,12,8,13,12,5,2,14
	db 10,13,0,13,4,7,13,5
Round9:	dd GGG,0x7a6d76e9
	db 8,15,6,5,4,8,1,11
	db 3,14,11,14,15,6,0,14
	db 5,6,12,9,2,12,13,9
	db 9,12,7,5,10,15,14,8
Round10: dd FFF,0
	db 12,8,15,5,10,12,4,9
	db 1,12,5,5,8,14,7,6
	db 6,8,2,13,13,6,14,5
	db 0,15,3,13,9,11,11,11

;============------------------

;------------------ macro for calling the FF,GG,HH,II functions
%macro invoke_f 5
	mov eax,%1
	mov ebx,%2
	mov ecx,%3
	mov edx,%4
	call dword[esi]
	add eax,%5
	mov %1,eax
	rol %3,10
%endmacro
;-----------------------------------------
; return:  eax=(b)^(c)^(d)
FF:
FFF:	xor ecx,ebx
	xor ecx,edx
	jmp short endf2
;----------------------------------------
; return:  eax= ( (b)&(c) | (~b)&(d) )
%define var	dword [ebp-24]
GGG:
GG:	and ecx,ebx
	not ebx
	and edx,ebx
	or ecx,edx
	jmp short endf
;----------------------------------------
; return:  eax=( (b)&(d)  |  (c)&(~d) )
III:
II:	and ebx,edx
	not edx
	and ecx,edx
	or ecx,ebx
	jmp short endf
;------------------------------------------
; return:  (b)^(c)|(~d)
JJJ:
JJ:	not edx
	or ecx,edx
	xor ecx,ebx
	jmp short endf
;------------------------------------------
; II:  return eax=( (b)| ((~c)^(d) )
HHH:
HH:	not ecx
	or ecx,ebx
	xor ecx,edx
endf:	add ecx,[esi+4]
endf2:	movzx edx,byte[esi+8]
	add ecx,[edi+edx*4]
	add eax,ecx
	mov cl,byte[esi+9]
	rol eax,cl
	add esi,byte 10
	ret

;---------------------------------------------------
; the core RMD-160 hashing function
; do the calculation in 5 rounds of 16 calls to in order FF,GG,HH,II,JJ
; then one parallel pass of 5 rounds of 16 calls to JJJ,III,HHH,GGG,FFF  
; don't try to understand the code, it extensively use black magic, and Voodoo incantations
;
; input:    edi: buffer to process
;

RMD_Transform:

%define ee	dword [ebp-4]		;
%define dd	dword [ebp-8]		;
%define	cc	dword [ebp-12]		; local vars on the stack
%define	bb	dword [ebp-16]		;
%define aa	dword [ebp-20]		; 
%define e	dword [ebp-24]		;
%define d	dword [ebp-28]		;
%define	c	dword [ebp-32]		; local vars on the stack
%define	b	dword [ebp-36]		;
%define a	dword [ebp-40]		;

	pusha
	mov ebp,esp
	sub esp,byte 40		; protect the local vars space

	cld
	push edi
	lea esi,[A]
	lea edi,[ebp-40]
	push esi
	_mov ecx,5
	push ecx
	rep movsd		;
	pop ecx			;	copy A to E in a-d and aa-dd
	pop esi			;
	rep movsd		;
	pop edi
	add esi,byte (Rounds-LowPart)		; esi=Rounds

	_mov ecx,2
.round0:
	push ecx
	_mov ecx,16
.round1:
	push ecx			;
	invoke_f a,b,c,d,e		;
	invoke_f e,a,b,c,d			;
	invoke_f d,e,a,b,c				; do the jerk
	invoke_f c,d,e,a,b			;
	invoke_f b,c,d,e,a
	pop ecx					;
	loop .round1
	pop ecx
	add ebp,byte 20
	dec ecx
	jnz near .round0
	sub ebp,byte 40

	lea edi,[A]
	mov eax,dd
	add eax,c
	add eax,[edi+4]
	push eax
	mov eax,ee
	add eax,d
	add eax,[edi+8]
	mov [edi+4],eax
	mov eax,aa
	add eax,e
	add eax,[edi+12]
	mov [edi+8],eax
	mov eax,bb
	add eax,a
	add eax,[edi+16]
	mov [edi+12],eax
	mov eax,cc
	add eax,b
	add eax,[edi]
	mov [edi+16],eax
	pop eax
	mov [edi],eax	
	add esp,byte 40
	popa
	ret

;---------------------------------------------
; initialize the RIPEMD-160 engine with the 5 magic constants(_A to _E)
; and clear the LowPart & HighPart counters & the calculation buffer
; then generate the Rounds table from the Round1 to Round8 tables
;
; 1st function to call to calc.RMD160 
;
RMD_Init:
	pusha
	cld
	lea edi,[A]
	mov eax,_A
	stosd
	mov eax,_B
	stosd
	mov eax,_C
	stosd
	mov eax,_D
	stosd
	mov eax,_E
	stosd
	xor eax,eax
	stosd
	stosd
	_mov ecx,16
	rep stosd			; clear the buffer
;------
; build a Rounds table
;--
	lea esi,[Round1]
	_mov ecx,10
.in1:	push ecx
	mov ebx,[esi]		; get func.
	mov edx,[esi+4]		; get var.
	add esi,byte 8
	_mov ecx,16
.in2:	lodsw
	mov dword[edi],ebx
	mov dword[edi+4],edx
	mov word[edi+8],ax
	add edi,byte 10
	loop .in2
	pop ecx
	loop .in1
	popa
	ret

;-----------------------------------------------
; the most of the job is done here
; process ecx bytes from esi input buffer
;
; input:	esi=input
;		ecx=number of bytes
RMD_Update:
	pusha
	mov edi,esi
	mov edx,ecx
	shr ecx,6
	jz short .upd1a	
.upd1:	call RMD_Transform
	add edi,byte 64
	loop .upd1
.upd1a:
	lea esi,[LowPart]
	mov eax,[esi]
	mov ecx,eax
	
	add eax,edx
	cmp eax,ecx
	jge short .upd2
	inc dword[esi+4]
.upd2:	mov [esi],eax
	popa
	ret

;--------------------------------------------------------------------
; finalize the job, and write the resulting 160 bits digest RMD code
; in edi buffer (20 bytes length) 
;
; RMD_Final:
;	input:	edi=digest
;

RMD_Final:
	pusha
	push edi

	lea esi,[buffer]
	mov eax,[LowPart]
	push eax
	mov ecx,eax
	mov edx,eax
	and eax,(FILEBUFFSIZE-64)
	add esi,eax
	and ecx,byte 63
	lea edi,[buff1]
	push edi
	rep movsb

	mov ebx,edx
	mov ecx,edx
	shr edx,2
	and edx,byte 15
	and ecx,byte 3
        lea ecx,[ecx*8+7]
	xor eax,eax
	inc eax
	shl eax,cl
	pop edi
	xor [edi+edx*4],eax

	and ebx,byte 63
	cmp ebx,byte 55
	jle short .fin2

	call RMD_Transform
	push edi
	xor eax,eax
	_mov ecx, 16
	rep stosd
	pop edi
.fin2:
	pop eax
	shl eax,3
	mov [edi+(14*4)],eax
	mov eax,[HighPart]
	shr eax,29
	mov [edi+(15*4)],eax
	call RMD_Transform

	pop edi
	_mov ecx,5
	lea esi,[A]
	rep movsd
	popa
	ret
;---------------------------------------------------------------------

UDATASEG

;=============--------------------------------------------------------
; the RMD-160 core registers, & buffer
; don't change their order 'cause the RMD engine is based on this order
A:	resd 1
B:	resd 1
C:	resd 1
D:	resd 1
E:	resd 1
LowPart:	resd 1
HighPart:	resd 1
buff1:	resd 16				; the calculation buffer
Rounds:	resb (10*16*10)		; to store the expanded Round1 to Round8 tables

;---------------------------------------

buffer:	resd FILEBUFFSIZE

END
