;Copyright (C) 1999 Cecchinel Stephan <interzone@pacwan.fr>
;
;$Id: rmdsum.asm,v 1.1 2000/01/26 21:19:57 konst Exp $
;
; rmdsum:       assembly version for asmutils
;
;
; calculate the RIPEMD-160 checksum of the input files
;
; syntax:   rmdsum FILES
;
; this code is free, you can eat it, drink it, fuck it , as you want...
; just send me a mail if you use it, if you find bugs, or anything else...
;

%include "system.inc"			; include system calls definition

%define FILEBUFFSIZE	8192	;size of file buffer (can be choosen freely)
				;but must be power of 2, and multiple of 64

%define		SMALL_VERSION	;optimized for size
;%undef		SMALL_VERSION	;optimized for speed



;--==oo0 magic initialization constants. Ooo==--
%define _A	0x67452301
%define _B	0xefcdab89
%define _C	0x98badcfe
%define _D	0x10325476
%define _E	0xc3d2e1f0
;========----------------

;--------------------------------
; print a message to the console
;
;args: 	sys_print	message,length
;
%macro sys_print 2
	lea ecx,[%1]
	sys_write STDOUT,EMPTY,%2
%endmacro
;-------------------------------

CODESEG

;
;
;

%ifdef SMALL_VERSION

;
;
;

START:
	call RMD_Init
	xor edi,edi
	_mov ebp,STDIN
	pop ebx
	dec ebx
	pop ebx
	jz short .read
.next_file:
	pop ebx
	or ebx,ebx
	jz near .exit
	mov [name],ebx
	sys_open EMPTY,O_RDONLY
	mov ebp,eax
	test eax,eax
	jns short .read
.error:
	inc edi
	jmp short .next_file
.read:
	mov ecx,buffer
	mov edx,FILEBUFFSIZE
.read_loop:
	sys_read ebp
	test eax,eax
        js short .error
	jz short .next_f2

	lea esi,[buffer]
	mov ecx,eax
	call RMD_Update
	jmp short .read
.next_f2:
	pusha
	lea edi,[digest]
	call RMD_Final		; finalize the MD5 digest
	_mov ecx,20
	mov esi,edi
	add edi,byte (text2-digest)
.write:	lodsb
;
	_mov edx,2	; two hex number in ah
	mov ah,al
.ph1:	rol ah,4
	mov al,ah
	and al,0x0f
	add al,'0'
	cmp al,'9'
	jle short .ph2
	add al,0x27
.ph2:	stosb
	dec edx
	jnz short .ph1
;
	loop .write
	mov dword[edi],0x0a2d2020
	sys_print text2,42	; print the resulting MD5 chain
	call RMD_Init		; re-init MD5 engine
	mov esi,[name]
	lea ecx,[ecx+42]	; if no name write '-'
	_mov edx,2			; so length 2
	or esi,esi
	jz short .strfini
	push ecx
	push esi
.strlen:
	lodsb
	test al,al
	jnz short .strlen
.strf:
	pop edi
	sub esi,edi
	dec esi
	sys_print edi,esi
	pop ecx
	inc ecx
	_mov edx,1
.strfini:
	sys_write STDOUT
	popa
	jmp .next_file

.exit:	sys_exit

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
	shl ecx,3
	add ecx,byte 7
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
	_mov ecx,16
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

;---------------------------------------------------------------------
; 
digest:	resd 5					; the resulting 160 bits RMD-160 code
text2:	resd 11				; the ascii version of the RMD code
name:	resd 1
buffer:	resb FILEBUFFSIZE

;
;
;

%else

;
;this version is optimized for speeeeed.....
;

START:

	call RMD_Init
	xor edi,edi
	_mov ebp,STDIN
	pop ebx
	dec ebx
	pop ebx
	jz short .read
.next_file:
	pop ebx
	or ebx,ebx
	jz near .exit
	mov [name],ebx
	sys_open EMPTY,O_RDONLY
	mov ebp,eax
	test eax,eax
	jns short .read
.error:
	inc edi
	jmp short .next_file
.read:
	mov ecx,buffer
	mov edx,FILEBUFFSIZE
.read_loop:
	sys_read ebp
	test eax,eax
        js short .error
	jz short .next_f2

	lea esi,[buffer]
	mov ecx,eax
	call RMD_Update
	jmp short .read
.next_f2:
	pusha
	lea edi,[digest]
	call RMD_Final		; finalize the MD5 digest
	_mov ecx,20
	mov esi,edi
	add edi,byte (text2-digest)
.write:	lodsb
;
	_mov edx,2	; two hex number in ah
	mov ah,al
.ph1:	rol ah,4
	mov al,ah
	and al,0x0f
	add al,'0'
	cmp al,'9'
	jle short .ph2
	add al,0x27
.ph2:	stosb
	dec edx
	jnz short .ph1
;
	loop .write
	mov dword[edi],0x0a2d2020
	sys_print text2,42	; print the resulting MD5 chain
	call RMD_Init		; re-init MD5 engine
	mov esi,[name]
	lea ecx,[ecx+42]	; if no name write '-'
	_mov edx,2			; so length 2
	or esi,esi
	jz short .strfini
	push ecx
	push esi
.strlen:
	lodsb
	test al,al
	jnz short .strlen
.strf:
	pop edi
	sub esi,edi
	dec esi
	sys_print edi,esi
	pop ecx
	inc ecx
	_mov edx,1
.strfini:
	sys_write STDOUT
	popa
	jmp .next_file

.exit:	sys_exit


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
%define eee	dword [ebp-24]		;
%define ddd	dword [ebp-28]		;
%define	ccc	dword [ebp-32]		; local vars on the stack
%define	bbb	dword [ebp-36]		;
%define aaa	dword [ebp-40]		;
%define a eax
%define b ebx
%define c ecx
%define d edx
%define e ebp

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

	push ebp
	mov eax,aaa
	mov ebx,bbb
	mov ecx,ccc
	mov edx,ddd
	mov ebp,eee
;-------------------------

%macro invokeff 7
	mov esi,%2
	xor esi,%3
	xor esi,%4
	add esi,[edi+(%6*4)]
	add %1,esi
	rol %1,%7
	add %1,%5
	rol %3,10
%endmacro

;--- Round 1
;1
	invokeff a,b,c,d,e,0,11
	invokeff e,a,b,c,d,1,14
	invokeff d,e,a,b,c,2,15
	invokeff c,d,e,a,b,3,12
	invokeff b,c,d,e,a,4,5
;
	invokeff a,b,c,d,e,5,8
	invokeff e,a,b,c,d,6,7
	invokeff d,e,a,b,c,7,9
	invokeff c,d,e,a,b,8,11
	invokeff b,c,d,e,a,9,13
;
	invokeff a,b,c,d,e,10,14
	invokeff e,a,b,c,d,11,15
	invokeff d,e,a,b,c,12,6
	invokeff c,d,e,a,b,13,7
	invokeff b,c,d,e,a,14,9
;
	invokeff a,b,c,d,e,15,8

;--- Round 2
%macro invokegg 7
	push %2						;3   (these numbers are micro-ops  for PII family)
	mov esi,%2					;1
	and esi,%3					;1
	not %2						;1
	and %2,%4					;1
	or esi,%2					;1
	add esi,[edi+(%6*4)]		;2
	lea %1,[%1+esi+0x5a827999]	;1
	rol %1,%7					;1
	pop %2						;2
	rol %3,10					;1
	add %1,%5					;1
%endmacro

	invokegg e,a,b,c,d,7,7
	invokegg d,e,a,b,c,4,6
	invokegg c,d,e,a,b,13,8
	invokegg b,c,d,e,a,1,13
	invokegg a,b,c,d,e,10,11
;
	invokegg e,a,b,c,d,6,9
	invokegg d,e,a,b,c,15,7
	invokegg c,d,e,a,b,3,15
	invokegg b,c,d,e,a,12,7
	invokegg a,b,c,d,e,0,12
;
	invokegg e,a,b,c,d,9,15
	invokegg d,e,a,b,c,5,9
	invokegg c,d,e,a,b,2,11
	invokegg b,c,d,e,a,14,7
	invokegg a,b,c,d,e,11,13
;
	invokegg e,a,b,c,d,8,12

; -- Round 3
%macro invokehh 7
	mov esi,%3						;1
	not esi							;1
	or esi,%2						;1
	xor esi,%4						;1
	add esi,[edi+(%6*4)]			;2
	lea %1,[%1+esi+0x6ed9eba1]		;1
	rol %1,%7						;1
	rol %3,10						;1
	add %1,%5						;1
%endmacro
;
	invokehh d,e,a,b,c,3,11
	invokehh c,d,e,a,b,10,13
	invokehh b,c,d,e,a,14,6
	invokehh a,b,c,d,e,4,7
	invokehh e,a,b,c,d,9,14
;
	invokehh d,e,a,b,c,15,9
	invokehh c,d,e,a,b,8,13
	invokehh b,c,d,e,a,1,15
	invokehh a,b,c,d,e,2,14
	invokehh e,a,b,c,d,7,8
;
	invokehh d,e,a,b,c,0,13
	invokehh c,d,e,a,b,6,6
	invokehh b,c,d,e,a,13,5
	invokehh a,b,c,d,e,11,12
	invokehh e,a,b,c,d,5,7
;
	invokehh d,e,a,b,c,12,5

;-- Round 4
;
%macro invokeii 7
	push %4							;3
	mov esi,%4						;1
	and esi,%2						;1
	not %4							;1
	and %4,%3						;1
	or esi,%4						;1
	add esi,[edi+(%6*4)]			;2
	lea %1,[%1+esi+0x8f1bbcdc]		;1
	rol %1,%7						;1
	pop %4							;2
	rol %3,10						;1
	add %1,%5						;1
%endmacro
;	
	invokeii c,d,e,a,b,1,11
	invokeii b,c,d,e,a,9,12
	invokeii a,b,c,d,e,11,14
	invokeii e,a,b,c,d,10,15
	invokeii d,e,a,b,c,0,14
;	
	invokeii c,d,e,a,b,8,15
	invokeii b,c,d,e,a,12,9
	invokeii a,b,c,d,e,4,8
	invokeii e,a,b,c,d,13,9
	invokeii d,e,a,b,c,3,14
;	
	invokeii c,d,e,a,b,7,5
	invokeii b,c,d,e,a,15,6
	invokeii a,b,c,d,e,14,8
	invokeii e,a,b,c,d,5,6
	invokeii d,e,a,b,c,6,5
;	
	invokeii c,d,e,a,b,2,12

;--- Round 5
;
%macro invokejj 7
	mov esi,%4					;1
	not esi						;1
	or esi,%3					;1
	xor esi,%2					;1
	add esi,[edi+(%6*4)]		;2
	lea %1,[%1+esi+0xa953fd4e]	;1
	rol %1,%7					;1
	rol %3,10					;1
	add %1,%5					;1
%endmacro
;
	invokejj b,c,d,e,a,4,9
	invokejj a,b,c,d,e,0,15
	invokejj e,a,b,c,d,5,5
	invokejj d,e,a,b,c,9,11
	invokejj c,d,e,a,b,7,6
;
	invokejj b,c,d,e,a,12,8
	invokejj a,b,c,d,e,2,13
	invokejj e,a,b,c,d,10,12
	invokejj d,e,a,b,c,14,5
	invokejj c,d,e,a,b,1,12
;
	invokejj b,c,d,e,a,3,13
	invokejj a,b,c,d,e,8,14
	invokejj e,a,b,c,d,11,11
	invokejj d,e,a,b,c,6,8
	invokejj c,d,e,a,b,15,5
;
	invokejj b,c,d,e,a,13,6

;000ooo=======---------------

	mov [var1],ebp
	pop ebp
	mov aaa,eax
	mov bbb,ebx
	mov ccc,ecx
	mov ddd,edx
	mov eax,[var1]
	mov eee,eax
	push ebp
	mov eax,aa
	mov ebx,bb
	mov ecx,cc
	mov edx,dd
	mov ebp,ee

;000ooo=======---------------


;--- Round 6
%macro invokejjj 7
	mov esi,%4
	not esi
	or esi,%3
	xor esi,%2
	add esi,[edi+(%6*4)]
	lea %1,[%1+esi+0x50a28be6]
	rol %1,%7
	rol %3,10
	add %1,%5
%endmacro
;1
	invokejjj a,b,c,d,e,5,8
	invokejjj e,a,b,c,d,14,9
	invokejjj d,e,a,b,c,7,9
	invokejjj c,d,e,a,b,0,11
	invokejjj b,c,d,e,a,9,13
;
	invokejjj a,b,c,d,e,2,15
	invokejjj e,a,b,c,d,11,15
	invokejjj d,e,a,b,c,4,5
	invokejjj c,d,e,a,b,13,7
	invokejjj b,c,d,e,a,6,7
;
	invokejjj a,b,c,d,e,15,8
	invokejjj e,a,b,c,d,8,11
	invokejjj d,e,a,b,c,1,14
	invokejjj c,d,e,a,b,10,14
	invokejjj b,c,d,e,a,3,12
;
	invokejjj a,b,c,d,e,12,6

;-- Round 7
;
%macro invokeiii 7
	push %4						;3
	mov esi,%4					;1
	and esi,%2					;1
	not %4						;1
	and %4,%3					;1
	or esi,%4					;1
	add esi,[edi+(%6*4)]		;2
	lea %1,[%1+esi+0x5c4dd124]	;1
	rol %1,%7					;1
	pop %4						;2
	rol %3,10					;1
	add %1,%5					;1
%endmacro
;
	invokeiii e,a,b,c,d,6,9
	invokeiii d,e,a,b,c,11,13
	invokeiii c,d,e,a,b,3,15
	invokeiii b,c,d,e,a,7,7
	invokeiii a,b,c,d,e,0,12
;
	invokeiii e,a,b,c,d,13,8
	invokeiii d,e,a,b,c,5,9
	invokeiii c,d,e,a,b,10,11
	invokeiii b,c,d,e,a,14,7
	invokeiii a,b,c,d,e,15,7
;
	invokeiii e,a,b,c,d,8,12
	invokeiii d,e,a,b,c,12,7
	invokeiii c,d,e,a,b,4,6
	invokeiii b,c,d,e,a,9,15
	invokeiii a,b,c,d,e,1,13
;
	invokeiii e,a,b,c,d,2,11

; -- Round 8
%macro invokehhh 7
	mov esi,%3
	not esi
	or esi,%2
	xor esi,%4
	add esi,[edi+(%6*4)]
	lea %1,[%1+esi+0x6d703ef3]
	rol %1,%7
	rol %3,10
	add %1,%5
%endmacro
;
	invokehhh d,e,a,b,c,15,9
	invokehhh c,d,e,a,b,5,7
	invokehhh b,c,d,e,a,1,15
	invokehhh a,b,c,d,e,3,11
	invokehhh e,a,b,c,d,7,8
;
	invokehhh d,e,a,b,c,14,6
	invokehhh c,d,e,a,b,6,6
	invokehhh b,c,d,e,a,9,14
	invokehhh a,b,c,d,e,11,12
	invokehhh e,a,b,c,d,8,13
;
	invokehhh d,e,a,b,c,12,5
	invokehhh c,d,e,a,b,2,14
	invokehhh b,c,d,e,a,10,13
	invokehhh a,b,c,d,e,0,13
	invokehhh e,a,b,c,d,4,7
;
	invokehhh d,e,a,b,c,13,5

;--- Round 9
;
%macro invokeggg 7
	push %2						;3
	mov esi,%2					;1
	and esi,%3					;1
	not %2						;1
	and %2,%4					;1
	or esi,%2					;1
	add esi,[edi+(%6*4)]		;2
	lea %1,[%1+esi+0x7a6d76e9]	;1
	rol %1,%7					;1
	pop %2						;2
	rol %3,10					;1
	add %1,%5					;1
%endmacro
;	
	invokeggg c,d,e,a,b,8,15
	invokeggg b,c,d,e,a,6,5
	invokeggg a,b,c,d,e,4,8
	invokeggg e,a,b,c,d,1,11
	invokeggg d,e,a,b,c,3,14
;	
	invokeggg c,d,e,a,b,11,14
	invokeggg b,c,d,e,a,15,6
	invokeggg a,b,c,d,e,0,14
	invokeggg e,a,b,c,d,5,6
	invokeggg d,e,a,b,c,12,9
;	
	invokeggg c,d,e,a,b,2,12
	invokeggg b,c,d,e,a,13,9
	invokeggg a,b,c,d,e,9,12
	invokeggg e,a,b,c,d,7,5
	invokeggg d,e,a,b,c,10,15
;	
	invokeggg c,d,e,a,b,14,8


;-- Round 10

;
	invokeff b,c,d,e,a,12,8
	invokeff a,b,c,d,e,15,5
	invokeff e,a,b,c,d,10,12
	invokeff d,e,a,b,c,4,9
	invokeff c,d,e,a,b,1,12
;
	invokeff b,c,d,e,a,5,5
	invokeff a,b,c,d,e,8,14
	invokeff e,a,b,c,d,7,6
	invokeff d,e,a,b,c,6,8
	invokeff c,d,e,a,b,2,13
;
	invokeff b,c,d,e,a,13,6
	invokeff a,b,c,d,e,14,5
	invokeff e,a,b,c,d,0,15
	invokeff d,e,a,b,c,3,13
	invokeff c,d,e,a,b,9,11
;
	invokeff b,c,d,e,a,11,11


;000ooo===----------------------------

	mov [var1],ebp
	pop ebp
	mov aa,eax
	mov bb,ebx
	mov cc,ecx
	mov dd,edx
	mov eax,[var1]
	mov ee,eax

	lea edi,[A]
	mov eax,dd
	add eax,ccc
	add eax,[edi+4]
	push eax
	mov eax,ee
	add eax,ddd
	add eax,[edi+8]
	mov [edi+4],eax
	mov eax,aa
	add eax,eee
	add eax,[edi+12]
	mov [edi+8],eax
	mov eax,bb
	add eax,aaa
	add eax,[edi+16]
	mov [edi+12],eax
	mov eax,cc
	add eax,bbb
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
	mov [length],eax
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

	mov ecx,16
        lea edi,[buff1]
        xor eax,eax
        rep stosd

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
	jbe short .fin2

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
;---------------------------------------------------------------------;

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


;---------------------------------------------------------------------
; 
buffer:	resb FILEBUFFSIZE			; the file buffer
digest:	resd 5					; the resulting 160 bits RMD-160 code
text2:	resd 11				; the ascii version of the RMD code
name:	resd 1					; name of the file processed
var1:	resd 1
length:	resd 1

%endif		;SMALL_VERSION

END
