;Copyright (C) 1999 Cecchinel Stephan <interzone@pacwan.fr>
;
;$Id: rc6crypt.asm,v 1.2 2000/02/10 15:07:04 konst Exp $
;
; rc6crypt:       assembly version for asmutils
;
;
; encrypt or decrypt the given files
;
; syntax:   rc6crypt e|d key [files]...
;
;   the key is a ascii key use for crypt or decrypt it is internally
; converted to a 256 bit key for RC6 with the Ripemd algo...
;
; this code is free, you can eat it, drink it, fuck it , as you want...
; just send me a mail if you use it, if you find bugs, or anything else...
;

[BITS 32]

%include "system.inc"			; include system calls definition

%define FILEBUFFSIZE	8192		; size of the file buffer (can be choose freely)
				       	; but must be a power of 2 , and a multiple of 64
							
;--==oo0 magic initialization constants. Ooo==--
%define _A	0x67452301
%define _B	0xefcdab89
%define _C	0x98badcfe
%define _D	0x10325476
%define _E	0xc3d2e1f0
;========----------------

	CODESEG

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

START:
	xor edi,edi
	pop esi		; get argv
	cmp esi,byte 4  ; there must me at least 2 args (rc6crypt e|d key file)
	jb near .usage

	pop ebx		; pop program name
	pop ebx		; pop 1st arg (e or d)
	mov al,[ebx]
	pop ebx		; pop 2nd arg (key string)
	invoke parsekey,ebx

	cmp al,'e'
	jnz near .cas2
.encrypt:
	pop 	ebx
	test ebx,ebx
	jz near .exit
;
	mov [name],ebx
	sys_open EMPTY,O_RDWR
	mov ebp,eax
	test eax,eax
	js short .encrypt
.read0:	xor eax,eax
	mov [length],eax

.read1:
	_mov ecx,buffer
	_mov edx,FILEBUFFSIZE
.read_loop:
	sys_read ebp
	test eax,eax
	js near .error
	jz short .next_f2
	
	pusha
	mov ecx,eax
	shr ecx,4
	jz short .crypt2
	mov edx,ecx
	lea esi,[buffer]
	lea edi,[bufferout]
.crypt:
	invoke RC6_encrypt,esi,edi
	add esi,byte 16
	add edi,byte 16
	dec ecx
	jnz short .crypt

	shl edx,4
	add [length],edx
	pusha
	mov esi,edx
	xor edi,edi
	sub edi,eax
	sys_lseek ebp,edi,SEEK_CUR	
	sys_write ebp,bufferout,esi
	popa
.crypt2:
	popa
.next_f2:
	cmp eax,FILEBUFFSIZE
	jz near .read1
	and eax,byte 15
	jz near .finish1
	add [length],eax		; length+=rest
	mov edi,eax
	lea esi,[buffer]
	sys_read ebp,esi,edi
        xor esi,esi
        sub esi,edi
        sys_lseek ebp,esi,SEEK_CUR

	sys_open [textrand],O_RDONLY			; open /dev/random

	mov ebx,eax
	_mov eax,16
	sub eax,edi			; length=16-rest
	lea ecx,[buffer+edi]
	mov edx,eax
	sys_read		; read("/dev/random",buffer+rest,16-rest)

	invoke RC6_encrypt,buffer,bufferout
        sys_write ebp,bufferout,16

.finish1:
	mov eax,[length]
	lea esi,[bufferout]
	mov [esi],eax
	sys_write ebp,esi,4
	sys_close ebp
	jmp near .encrypt

.cas2:	cmp al,'d'
	jnz near .usage

.decrypt:
	pop 	ebx
	test ebx,ebx
	jz near .exit
;
	mov [name],ebx
	sys_open EMPTY,O_RDWR
	mov ebp,eax
	test eax,eax
	js short .decrypt
.read2:	xor eax,eax
	mov [length],eax

.read3:
	_mov ecx,buffer
	_mov edx,FILEBUFFSIZE
.read_loop2:
	sys_read ebp
	test eax,eax
	js near .error
	jz short .next_f3

	pusha
	mov ecx,eax
	shr ecx,4
	jz short .crypt3
	mov edx,ecx
	lea esi,[buffer]
	lea edi,[bufferout]
.dcrypt:
	invoke RC6_decrypt,esi,edi
	add esi,byte 16
	add edi,byte 16
	dec ecx
	jnz short .dcrypt

	shl edx,4
	add [length],edx
	pusha
	mov esi,edx
	xor edi,edi
	sub edi,eax
	sys_lseek ebp,edi,SEEK_CUR	
	sys_write ebp,bufferout,esi
	popa
.crypt3:
	popa
.next_f3:
	cmp eax,FILEBUFFSIZE
	jz near .read3

	lea esi,[buffer]
	and eax,byte -16
	mov edi,[esi+eax]
	sys_ftruncate ebp,edi
	sys_close ebp
        jmp near .decrypt
        
.error:	sys_print texterr,ltexterr
	jmp short .exit
.usage:	sys_print syntax,lsyntax
.exit:	sys_exit_true

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
	mov ecx,16
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
;--------------------------------------------------
; parse the given key string, with the Ripemd algo..
; transform it in a 256 bit key to use with RC6...
;
PROC	parsekey , stringkey
	pusha
	xor ecx,ecx
	mov edi,stringkey
.strlen:
	cmp byte[edi+ecx],1
	inc ecx
	jnc short .strlen
	dec ecx

	call RMD_Init		; initalize Ripemd engine

	mov ebx,ecx
	shr ecx,1

	mov esi,edi
	call RMD_Update
	push edi
	lea edi,[key1]
	call RMD_Final
	pop edi
	mov edx,ebx

	call RMD_Init

	mov ebx,ecx
	test edx,1
	jz short .suite
	inc ecx
.suite:	lea esi,[edi+ebx]
	call RMD_Update
	lea edi,[key2]
	call RMD_Final

; compose key with key1 and key2
	lea esi,[key1]
	cld
	lea edi,[key]
	movsd
	movsd
	movsd
	lodsd
	xor eax,[esi+4]
	stosd
	lodsd
	xor eax,[esi+4]
	stosd
	add esi,byte 8
	movsd
	movsd
	movsd
	sub esi,byte 32
	invoke set_key,esi,256
	popa
	ENDP

;----------------------------------
PROC set_key, in_key, keylen

	pusha
	cld
	mov esi,in_key
	lea edi,[l_key]
	push edi
	mov eax,0x0b7e15163
	stosd
	_mov ecx,43

.pass1:	mov eax,[edi-4]
	add eax,0x9e3779b9
	stosd
	loop .pass1

	push edi				; at this point edi=ll
	_mov ecx,8
	rep movsd

	pop esi			; esi=ll
	pop edi			; edi=l_key
	xor eax,eax		; a=0
	xor ebx,ebx		; b=0
	_mov edx,132
	xor ebp,ebp
.pass2:
	add eax,[edi]
	add eax,ebx
	rol eax,3

	add ebx,eax
	mov ecx,ebx
	add ebx,[esi+ebp*4]
	rol ebx,cl

	stosd
	mov [esi+ebp*4],ebx

	cmp edi,(l_key+(44*4))
	jnz short .ok1
	mov edi,l_key
.ok1:
	inc ebp
	and ebp,byte 7
	dec edx
	jnz short .pass2

	popa	
	ENDP


;---------------------------------------
;encrypt:
;
; input:	edi=in_block
;		esi=out_block
PROC RC6_encrypt,in_block,out_block
	pusha
	mov esi,out_block
	mov edi,in_block
	push esi
	lea esi,[l_key]
	push esi
	mov eax,dword[edi]			; a=in_block[0]
	mov ebx,dword[edi+4]
	add ebx,dword[esi]			; b=in_block[1]+l_key[0]
	mov ecx,dword[edi+8]		; c=in_block[2]
	mov edx,dword[edi+12]
	add edx,dword[esi+4]		; d=in_block[3]+l_key[1]
	lea ebp,[esi+8]
.boucle:
	lea esi,[edx+edx+1]
	imul esi,edx
	rol esi,5			; u=rol(d*(d+d+1),5)

	lea edi,[ebx+ebx+1]
	imul edi,ebx
	rol edi,5			; t=rol(b*(b+b+1),5)

	push ecx
	mov ecx,esi
	xor eax,edi
	rol eax,cl
	add eax,[ebp]		; a=rol(a^t,u)+l_key[i]
	pop ecx

	xchg ecx,eax
	xchg ecx,edi
	xor eax,esi
	rol eax,cl
	add eax,[ebp+4]		; c=rol(c^u,t)+l_key[i+1]
	mov ecx,eax
	mov eax,edi
;
	push eax
	mov eax,ebx
	mov ebx,ecx
	mov ecx,edx
	pop edx
	add ebp,byte 8
	cmp ebp,(l_key+(42*4))
	jnz short .boucle

	pop esi
	pop edi
	add eax,dword[esi+(42*4)]
	stosd
	mov [edi],ebx
	add ecx,dword[esi+(43*4)]
	mov [edi+4],ecx
	mov [edi+8],edx
	
	popa
	ENDP

;---------------------------------------
PROC RC6_decrypt,in_blk2,out_blk2

	pusha
	mov esi,out_blk2
	push esi
	mov edi,in_blk2
	lea esi,[l_key]

	mov edx,dword [edi+12]			;   d=in_blk[3]
	mov ecx,dword [edi+8]
	sub ecx,dword [esi+(43*4)]		;   c=in_blk[2]-l_key[43]
	mov ebx,dword [edi+4]			;   b=in_blk[1]
	mov eax,dword [edi]
	sub eax,dword [esi+(42*4)]		;   a=in_blk[0]-l_key[42]
	lea ebp,[esi+(40*4)]

.boucle2:
	mov esi,edx
	mov edx,ecx
	mov ecx,ebx
	mov ebx,eax
	mov eax,esi
;
	lea esi,[edx+edx+1]
	imul esi,edx
	rol esi,5			; u=rol(d*(d+d+1),5)

	lea edi,[ebx+ebx+1]
	imul edi,ebx
	rol edi,5			; t=rol(b*(b+b+1),5)

	push eax
	mov eax,ecx
	mov ecx,edi
	sub eax,[ebp+4]
	ror eax,cl
	xor eax,esi
	mov ecx,eax
	pop eax

	xchg ecx,esi
	sub eax,[ebp]
	ror eax,cl
	xor eax,edi
	mov ecx,esi
;
	sub ebp,byte 8
	cmp ebp,(l_key)
	jnz short .boucle2

	pop edi
	sub edx,dword [ebp+4]
	mov [edi+12],edx		; out_blk[3]=d-l_key[1]
	mov [edi+8],ecx			; out_blk[2]=c
	sub ebx,dword [ebp]
	stosd					; out_blk[0]=a
	mov [edi],ebx			; out_blk[1]=b-l_key[0]

	popa
	ENDP


;---------------------------------------------------------------------
syntax:
	db 'Usage: rc6crypt e|d  KEY  [FILEs]...',10
	db '(c)Cecchinel Stephan 1999.',10,10
	db 'basic info:    rc6crypt e KEY [FILEs] -> for encrypt',10
	db '               rc6crypt d KEY [FILEs] -> ... decrypt',10
	db '               KEY is ascii string of any size,',10
	db ' it is internally convert to 256 bits length key (via RIPEMD 160)...',10,10
lsyntax:	equ ($-syntax)
textrand:	db '/dev/random',0
texterr:	db 'error happens...',10
ltexterr:	equ ($-texterr)

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
buffer:		resb FILEBUFFSIZE		; the file buffer
bufferout:	resb FILEBUFFSIZE		; output file buffer
name:	resd 1					; name of the file processed
length:	resd 1

; rc6 needed buffers

l_key	resd	45				; the internel RC6 key
ll	resd	9
key1:	resd 5
key2:	resd 5
key:	resd 8
;


	END

