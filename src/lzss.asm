;LZSS compression algorithm implementation  (c) CECCHINEL Stephan 1999
; contact:  interzone@pacwan.fr
;
;$Id: lzss.asm,v 1.1 2000/01/26 21:19:40 konst Exp $
;
[BITS 32]

%define N_BITS 15
%define F_BITS 4
%define N	(1<<N_BITS)
%define	F (1<<F_BITS)
%define THRESHOLD	3
%define FBUFFSIZE	16384		; i/o file buffer size (16k by default) must be a 2^x
%define BUFFCYCL ((FBUFFSIZE/4)-1)

%include "system.inc"

CODESEG

START:
	_mov	ebp,STDIN
	_mov	eax,STDOUT
	mov [outfile],eax

	pop eax
	dec eax
	pop edi

	dec eax
	js short .usage
	pop edi
	dec eax
	js short .read
	pop ebx
	sys_open EMPTY,O_RDONLY
	mov ebp,eax
	test eax,eax
	jns short .read
	sys_write STDOUT,text2,len2
	sys_exit_false
.usage:
	sys_write STDOUT,text1,len1
	sys_exit_true
.read:
	mov [infile],ebp
	cmp byte[edi],"e"
	jz near lzss_encode
	cmp byte[edi],"d"
	jnz short .usage
	call lzss_decode
	sys_exit_true
;-------------------------------------------
; initialize ring_buff,prev,next
;
;	   edi=ring_buff
;
init_lzss:
	pusha
	mov ecx,((N+F)/4)
	xor eax,eax
	mov dword[edi-(ring_buff-bit_pos)],31
	mov dword[edi-(ring_buff-bit_val)],eax
	mov dword[edi-(ring_buff-output)],eax

	rep stosd
						; normally edi point on next (as next follow ring_buff)
	mov ecx,((N*3)+2)
	mov eax,N
	rep stosd
	popa
	ret
;-----------------------------------------
;
; input:   eax=r
;	   edi=ring_buff
;
delete:
	push ebx
	push ecx
	push edx
	mov edx,N
	mov ebx,dword[edi+(prev-ring_buff)+eax*4]	; ebx=prev[r]
	cmp ebx,edx
	je short .fdel
	mov ecx,dword[edi+(next-ring_buff)+eax*4]				; ecx=next[r]
	mov dword[edi+(next-ring_buff)+ebx*4],ecx				; next[prev[r]]=next[r]
	mov dword[edi+(prev-ring_buff)+ecx*4],ebx	; prev[next[r]]=prev[r]
	mov dword[edi+(next-ring_buff)+eax*4],edx				; next[r]=N
	mov dword[edi+(prev-ring_buff)+eax*4],edx	; prev[r]=N
.fdel:	pop edx
	pop ecx
	pop ebx
	ret

;---------------------------------------------
;
; input:	eax=r
;		edi=ring_buff

insert:
	push edx
	push ecx
	push ebx
	mov bx,word[edi+eax]
	and ebx,(N-1)			; ebx=(ring_buf[r]+(ring_buf[r+1]<<8))& (N-1)
	mov ecx,dword[edi+ebx*4+((N+1)*4)+(next-ring_buff)]		; ecx=next[c+N+1]
	mov dword[edi+ebx*4+((N+1)*4)+(next-ring_buff)],eax		; next[c+N+1]=r
	lea edx,[ebx+(N+1)]
	mov dword[edi+(prev-ring_buff)+eax*4],edx				; prev[r]=ebx+N+1
	mov dword[edi+eax*4+(next-ring_buff)],ecx				; next[r]=ecx
	cmp ecx,N
	je short .fins
	mov dword[edi+(prev-ring_buff)+ecx*4],eax				; prev[ecx]=r
.fins:	pop ebx
	pop ecx
	pop edx
	ret

;-------------------------------------------------
;
; input:	eax=r
;		edi=ring_buff
;
locate:
	push ebx
	push ecx
	push edx
	push esi
	
	xor ecx,ecx
	mov dword[edi+(match_pos-ring_buff)],ecx		; match_pos=match_len=0
	mov dword[edi+(match_len-ring_buff)],ecx		; match_pos=match_len=0
	mov bx,word[edi+eax]
	and ebx,(N-1)				; ebx=(ring_buf[r]+(ring_buf[r+1]<<8))& (N-1)
	mov ecx,[edi+ebx*4+((N+1)*4)+(next-ring_buff)]		; ecx=p=next[c+N+1]
	xor edx,edx							; i=edx=0

.loc0:	cmp ecx,N
	je short .loc4
	xor edx,edx
	push ebx
	push eax
	lea esi,[edi+ecx]
	lea ebx,[edi+eax]
.loc1:	mov al,byte[esi+edx]
	cmp al,byte[ebx+edx]
	jne short .loc2
	inc edx
	cmp edx,F
	jbe short .loc1
.loc2:	pop eax
	pop ebx
	cmp edx,dword[edi+(match_len-ring_buff)]	; if i>match_len
	jbe short .loc3
	mov dword[edi+(match_len-ring_buff)],edx	; match_len=i
	push eax
	sub eax,ecx
	and eax,(N-1)
	mov dword[edi+(match_pos-ring_buff)],eax ; match_pos=(r-next[c+N+1])&(N-1)
	pop eax
.loc3:	cmp edx,F
	je short .flocate
	mov ecx,dword[edi+ecx*4+(next-ring_buff)]		; ecx=next[ecx]
	jmp short .loc0
.loc4:	cmp edx,F
	jne short .floc
.flocate:
	mov eax,ecx
	call delete		; delete(p)
.floc:
	pop esi
	pop edx
	pop ecx
	pop ebx
	ret

;------------------------------------------
; macros definition needed by lzss_encode
%macro _sendbit0 0
	_mov	eax,0
	call	sendbit
%endmacro
%macro _sendbit1 0
	_mov eax,1
	call sendbit
%endmacro

;--------------------------------------
;
; input:
;
lzss_encode:
	pusha
	cld
	lea edi,[ring_buff]
	call init_lzss
	xor edx,edx					; maxlen=edx=0
	xor ebx,ebx						; r=0
	
	call get_inbuff		; get a FBUFFSIZE length block in inbuff

.enc0:	cmp edx,F
	jge short .enc1
	test ecx,ecx
	jnz short .enc0a
	call get_inbuff			; if whole inbuff is read try to get another FBUFFSIZE length block,
	test ecx,ecx			; if no more are available, get_inbuff return ecx=0
	jz short .enc1
.enc0a:	lodsb
	dec ecx
	mov [edi+edx],al
	mov [edi+edx+N],al
	inc edx									; maxlen++
	jmp short .enc0
;
.enc1:	test edx,edx
	jz near .fenc1
	mov eax,ebx
	call locate								; locate(r)
	cmp edx,[edi+(match_len-ring_buff)]
	jge short .enc2
	mov [edi+(match_len-ring_buff)],edx			; match_len=maxlen

.enc2:	push ecx
	cmp dword[edi+(match_len-ring_buff)],THRESHOLD
	jge short .enc3

	_sendbit0
	xor eax,eax
	inc eax										; after _sendbit0 eax=0 so now eax=1
	mov dword[edi+(match_len-ring_buff)],eax		; match_len=1
	movzx eax,byte[edi+ebx]		; al=ring_buff[r]
	mov cl,8
	call sendbits				; sendbits(ring_buff[r],8)
	jmp short .enc23
.enc3:
	_sendbit1
	mov eax,[edi+(match_pos-ring_buff)]
	mov cl,N_BITS
	call sendbits
	mov eax,[edi+(match_len-ring_buff)]
	dec eax
	mov cl,F_BITS
	call sendbits
.enc23:	pop ecx

.enc4:	mov eax,[edi+(match_len-ring_buff)]
	test eax,eax
	jz short .enc1
	dec eax
	mov dword[edi+(match_len-ring_buff)],eax

	lea eax,[ebx+F]
	and eax,(N-1)
	call delete			; delete( (r+F) & (N-1) )
	dec edx				; maxlen--
;
	push ebx
	test ecx,ecx
	jnz short .enc41
	call get_inbuff
	test ecx,ecx
	jz short .enc5
.enc41:	lodsb
	_add ebx,F
	cmp ebx,N
	jl short .enc4b
	mov byte[edi+ebx],al
.enc4b:	and ebx,(N-1)
	mov byte[edi+ebx],al
	inc edx									; maxlen++
	dec ecx
.enc5:	pop ebx
;
	mov eax,ebx
	call insert						; insert(r)
	inc eax
	and eax,(N-1)
	mov ebx,eax		; r=(r+1)&(N-1)
	jmp short .enc4
.fenc1:
	_sendbit1
	xor eax,eax
	mov cl,N_BITS
	call sendbits
	call flushbuff
	popa
	sys_exit_true

;----------------------------------------
lzss_decode:


;------------------------------------------
; input: 	eax=bits pattern
;		cl=bit_length
;
sendbits:
	push ebx
	mov ebx,eax
	dec ecx
	and ecx,byte 0x1f
	xor eax,eax
.boucle:
	bt ebx,ecx
	setc al
	call sendbit
	dec ecx
	jns short .boucle
	pop ebx
	ret

;------------------------------------------
;
; input: eax=0 or 1
;	 edi point on ring_buff
sendbit:
	push edi
	push ecx
	xor ecx,ecx
	inc ecx
	and eax,ecx
	lea edi,[edi-(ring_buff-outbuff)]
	mov ecx,dword[edi+(bit_pos-outbuff)]]
	test ecx,ecx
	jz short .send2
	shl eax,cl
	or [edi+(bit_val-outbuff)],eax
	dec dword[edi+(bit_pos-outbuff)]

	pop ecx
	pop edi
	ret
.send2:
	or eax,dword[edi+(bit_val-outbuff)]
	mov ecx,dword[edi+(output-outbuff)]
	bswap eax
	mov dword[edi+ecx*4],eax
	inc ecx
	and ecx,BUFFCYCL
	jz short .sendbuff
.send3:	xor eax,eax
	mov dword[edi+(output-outbuff)],ecx
	mov dword[edi+(bit_pos-outbuff)],31
	mov dword[edi+(bit_val-outbuff)],eax
	pop ecx
	pop edi
	ret
.sendbuff:
	pusha
	mov ebx,[outfile]
	lea ecx,[outbuff]
	mov edx,FBUFFSIZE
	sys_write
	popa
	jmp short .send3

;------------------------------------------
; input:	edi point on ring_buff
;
flushbuff:
	lea ecx,[edi-(ring_buff-outbuff)]
	mov ebx,[edi-(ring_buff-outfile)]

	mov eax,[edi-(ring_buff-bit_val)]
	mov edx,[edi-(ring_buff-output)]
	mov dword[ecx+edx*4],eax
	inc edx
	shl edx,2
	sys_write
	ret

;------------------------------------------
; get_inbuff:	refill the input buffer
;
;	return number of byte read in ecx
;	and inbuff addr in esi
;
get_inbuff:
	push eax
	push ebx
	push edx
	push edi
	
	mov ebx,[infile]
	lea ecx,[inbuff]
	mov edx,FBUFFSIZE
	sys_read
	xor ecx,ecx
	test eax,eax
	jz short .endin
	js short .endin
	mov ecx,eax
.endin:	lea esi,[inbuff]
	pop edi
	pop edx
	pop ebx
	pop eax
	ret

text1:	db "usage: lzss [e|d] [file...]"
text1b:	db 10
len1	equ ($-text1)
text2:	db "Can't open input file...",10
len2:	equ ($-text2)


UDATASEG
	
;------------------------ file in/out descriptors
infile:		resd 1
outfile:	resd 1
inbuff:		resd (FBUFFSIZE/4)
outbuff:	resd (FBUFFSIZE/4)
;------------------------ bits i/o vars
output:		resd 1
bit_pos:	resd 1
bit_val:	resd 1
;------------------------ lzss internal engine
ring_buff:	resb (N+F)
next:		resd ((N*2)+1)
prev:		resd (N+1)
match_pos:	resd 1
match_len:	resd 1
;------------------------
outname:	resb 256

END
