;---------- First Strike of an optimized CLIB       (c) CECCHINEL Stephan 1999
;contact:  interzone@pacwan.fr
;
;$Id: clib.asm,v 1.4 2000/04/07 18:36:01 konst Exp $
;
;see doc/clib.html for details

[bits 32]

;-----------------------------------
; Optimisation & Compilation flags
;-----------------------------------
; you have to choose between C_CALL or ASM_CALL
; for C style passing of args(stack)
; or ASM style via registers
;
; you have to choose between SIZEOPT or SPEEDOPT,
; if you want CLIB to be optimize for size or speed
; you CANNOT choose SIZEOPT and SPEEDOPT at the same time, sorry...
;
; just uncomment the one you choose and comment the one you don't use
;

;%define SIZEOPT
%define SPEEDOPT

%define C_CALL
;%define ASM_CALL

;----------------------------

%include "system.inc"

;------------------

CODESEG

global	itoa
global	fprintf
global	memset
global	memcpy
global	memcpyl
global	strlen
global	MemInit
global	malloc
global	calloc
global	free

;-------------------------------------------------------------------------------------------
; --  itoa -->     print a 32 bit number as binary,octal,decimal,or hexadecimal value ------------ 
;
; C syntax:		itoa (unsigned long value, char *string, int radix)
;
; Assembly syntax:
; 			EAX=32 bit value
; 			ECX=base    (2, 8, 10, 16, or another one)
; 			store ascii string in [EDI]
%ifdef C_CALL
PROC itoa, value, itoa_string, radix
	pusha
	mov eax,value
	mov edi,itoa_string
	mov ecx,radix
%endif

%ifdef ASM_CALL
itoa:
	pusha
%endif

	call .printB
	mov byte[edi],0				; zero terminate the string 
	jmp short .enditoa
.printB:
	sub edx,edx 
	div ecx 
	test eax,eax 
	jz short .print0
	push edx
	call .printB
	pop edx 
.print0:
	add dl,'0'
	cmp dl,'9'
	jle short .print1
	add dl,0x27
.print1:
	mov [edi],dl
 	inc edi
 	ret
.enditoa:
	popa
%ifdef C_CALL
	pop ebp
%endif
	ret


;---------------------------------------------
; printf is defined as a macro
; you can also use fprintf(STDOUT,string,args,args....)  it is the same than printf
;
%macro printf 1-*
%assign _params %0
%assign _params _params-1
%if %0 > 10
	push dword %11
%endif
%if %0 > 9
	push dword %10
%endif
%if %0 > 8
	push dword %9
%endif
%if %0 > 7
	push dword %8
%endif
%if %0 > 6
	push dword %7
%endif
%if %0 > 5
	push dword %6
%endif
%if %0 > 4
	push dword %5
%endif
%if %0 > 3
	push dword %4
%endif
%if %0 > 2
	push dword %3
%endif
%if %0 > 1
	push dword %2
%endif
	push dword %1
	_mov eax,STDOUT
	push eax
	call fprintf
%assign _params _params*4
	add esp,_params
%endmacro

;---------------------------------------------------------------------
PROC fprintf,filedesc,ipf_string
	pusha
	cld
	lea edi,[buff_printf]
	push edi
	mov esi,ipf_string
	lea edx,[ebp+16]
.boucle:
	lodsb
	test al,al
	jz short .out_pf
	cmp al,'%'
	jz short .gest_spec
	cmp al,'\'
	jz short .gest_spec2
	stosb
	jmp short .boucle
.gest_spec:
	mov ebx,[edx]
	lodsb
	cmp al,'d'
	jnz short .gest2
	_mov ecx,10
	jmp short .gestf
.gest2:	cmp al,'x'
	jnz short .gest3
	_mov ecx,16
	jmp short .gestf
.gest3:	cmp al,'o'
	jnz short .gest4
	_mov ecx,8
	jmp short .gestf
.gest4:	cmp al,'b'
	jnz short .gest5
	_mov ecx,2
	jmp short .gestf
.gest5:	cmp al,'s'
	jnz short .boucle
.copyit:					; copy the string in args , to output buffer
	mov al,[ebx]
	test al,al				; the string is null terminated
	jz short .allok
	stosb
	inc ebx
	jmp short .copyit

.gestf:
%ifdef C_CALL
	invoke itoa,ebx,edi,ecx
%endif

%ifdef ASM_CALL
	mov eax,ebx
	call itoa
%endif

.stl:	cmp byte[edi],1
	inc edi
	jnc short .stl

.allok:	add edx,byte 4
	jmp short .boucle

.gest_spec2:
	lodsb
	cmp al,'n'
	jnz short .boucle
	mov al,0x0a
	stosb
	jmp short .boucle

.out_pf:
	xor al,al
	stosb
	pop edx
	sub edi,edx
	sys_write filedesc,buff_printf,edi
	popa
	ENDP



;-------------------------------------------------------------------
;--------- memset -> fille an array of memory ----------------------	
;
; C syntax:	memset(addr,value,size)
;
; ASM syntax:
; 	EDX=pointer on memory to fill
; 	AL=byte value to fill with
; 	ECX=number of bytes to fill
;
%ifdef C_CALL
PROC memset, addrs, fillv, sizev
	push edx
	push ecx
	push eax
	mov edx,addrs
	mov ecx,sizev
	mov eax,fillv
%endif
%ifdef ASM_CALL
memset:
	push edx
	push ecx
	push eax
%endif


%ifdef SPEEDOPT
	cmp ecx,byte 20					; if length is below 20 , better use byte fill
	jl short .below20
	mov ah,al		; expand al to eax like alalalal
	push ax
	shl eax,16
	pop ax
.lalign:
	test dl,3					; align edx on a 4 multiple
	jz short .align1
	mov [edx],al
	inc edx
	dec ecx
	jnz short .lalign
	jmp short .memfin
.align1:
	push ecx
        shr ecx,3					; divide ecx by 8
	pushf
.boucle:
	mov [edx],eax				; then fill by 2 dword each times
	mov [edx+4],eax				; it is faster than stosd (on PII)
	add edx,byte 8
	dec ecx
	jnz short .boucle
	popf
	jnc short .boucle2
	mov [edx],eax
	add edx,byte 4
.boucle2:
	pop ecx
        and ecx,byte 3
        jz short .memfin
.below20:
	mov [edx+ecx-1],al
	dec ecx
	jnz short .below20
.memfin:
	pop eax
	pop ecx
	pop edx
%endif

%ifdef SIZEOPT
	push edi
	cld
	mov edi,edx
	rep stosb
	pop edi
%endif

%ifdef C_CALL
	pop ebp
%endif
	ret


;-------------------------------------------------------------------
;------------ memcpy -> copy an array of memory
; C syntax:	memset(dest, source , length)
; ASM syntax:
;	EDI=dest
;	ESI=source
;	ECX=length in bytes
;
%ifdef C_CALL
PROC memcpy, dest, source, length
%endif
%ifdef ASM_CALL
memcpy:
%endif
%ifdef SPEEDOPT
	push ecx
	push edi
	push esi
%endif
%ifdef SIZEOPT
	pusha
%endif
%ifdef C_CALL
	mov edi,dest
	mov esi,source
	mov ecx,length
%endif
	cld
	rep movsb
%ifdef SPEEDOPT
	pop esi
	pop edi
	pop ecx
%endif
%ifdef SIZEOPT
	popa
%endif
%ifdef C_CALL
	pop ebp
%endif
	ret

;-------------------------------------------------------------------
;------------ memcpyl -> copy an array of memory of dword ---------
; source & dest must be dword aligned
; C syntax:	memcpyl(dest, source , length)
; ASM syntax:
;	EDI=dest
;	ESI=source
;	ECX=length in dword (for example, for 1024 bytes -> ECX=256)
;
%ifdef C_CALL
PROC memcpyl, dest2, source2, length2
%endif
%ifdef ASM_CALL
memcpyl:
%endif
%ifdef SPEEDOPT
	push ecx
	push edi
	push esi
%endif
%ifdef SIZEOPT
	pusha
%endif
%ifdef C_CALL
	mov edi,dest2
	mov esi,source2
	mov ecx,length2
%endif
	cld
	rep movsd
%ifdef SPEEDOPT
	pop esi
	pop edi
	pop ecx
%endif
%ifdef SIZEOPT
	popa
%endif
%ifdef C_CALL
	pop ebp
%endif
	ret

;----------------------------------------------------------------------
;---------------- strlen -> return length of a null-terminated string
; C syntax:
;			unsigned long strlen(*string)
;			return length in eax
;
; assembly syntax:
; 			EDX=pointer on string
;			return length in eax
%ifdef	C_CALL
	PROC strlen, strlen_string
	mov edx,strlen_string
%endif

%ifdef ASM_CALL
strlen:
%endif

%ifdef SPEEDOPT
	push ecx
	mov eax,edx
	test dl,3
	jz short .boucle
	cmp byte[eax],0
	jz short .strfi
	cmp byte[eax+1],0
	jz short .ret1
	cmp byte[eax+2],0
	jnz short .align
	add eax,byte 2
	jmp short .strfi
.align:	add eax,byte 3
	and eax,byte -4
.boucle:								; normally the whole loop is 7 cycles (for 8 bytes)
	mov ecx,dword[eax]			; 1
	test cl,cl					; 1
	jz short .strfi				; 1
	test ch,ch					; 1
	jz short .ret1				; 1
	test ecx,0xFF0000			; 1
	jz short .ret2				; 1
	shr ecx,24					; 1
	jz short .ret3				; 1
	mov ecx,dword[eax+8]		; 1
	test cl,cl					; 1
	jz short .ret4				; 1
	test ch,ch					; 1
	jz short .ret5				; 1
	test ecx,0xFF0000			; 1
	jz short .ret6				; 1
	add eax,byte 8				; 1
	shr ecx,4					; 1
	jnz short .boucle			;
	dec eax
	jmp short .strfi
.ret1:	inc eax
	jmp short .strfi
.ret2:	add eax,byte 2
	jmp short .strfi
.ret3:	add eax,byte 3
	jmp short .strfi
.ret4:	add eax,byte 4
	jmp short .strfi
.ret5:	dec eax
.ret6:	add ecx,byte 6
.strfi:	sub eax,edx
	pop ecx
%endif


%ifdef SIZEOPT
	xor eax,eax
.boucle:
	cmp byte[edx+eax],1
	inc eax
	jnc short .boucle
	dec eax
%endif

%ifdef C_CALL
	ENDP
%endif

%ifdef ASM_CALL
	ret
%endif


;---------------------------------------------------
; MemInit:    initialize the memory allocation core
;
; C  syntax:	MemInit(memaddr, blsize)
;	where   memaddr is the physical memory adress of mem space to work with
;		blsize is the size of this block (multiple of 32)
; ASM syntax:
;		eax=memaddr
;		ebx=blsize
;
%ifdef C_CALL
PROC MemInit, memaddr,blsize
	push eax
	push ebx
	mov eax,memaddr
	mov ebx,blsize
%endif

%ifdef ASM_CALL
MemInit:
	push eax
	push ebx
%endif

	test eax,0x1f
	jz short .ok
	add eax,byte 32
.ok:	and eax,byte -32				; align on a 32 byte boundary
	mov [MEMBASE],eax
	and ebx,byte -32				; idem for size
	shr ebx,5						; and divide size by 32
	mov [MEMSIZE],ebx

	pop ebx
	pop eax
%ifdef C_CALL
	pop ebp
%endif

	ret

;---------------------------------------------------
; malloc:	try to allocate a memory block
; C syntax:	malloc(size)
; ASM syntax:	eax=size of block requested
;
; return:	eax=address of block if success
;		eax=0	if it fails
;

;---------------------------
; structure of memory block
;
struc MAB
	.start	resd 1
	.size	resd 1
	.pid	resd 1
endstruc
;--------------------

%ifdef C_CALL
PROC malloc, sizebl
	push esi
	push edx
	push edx
	mov eax,sizebl
%endif

%ifdef ASM_CALL
malloc:
	push ebp
	push esi
	push edx
	push ecx
%endif

	mov edx,eax
	shr eax,5
	and edx,byte 31
	jz short .suite
	inc eax
.suite:
	lea esi,[mem_table]
	mov ecx,[esi-4]			; number of mem_blocks
	push esi
	xor ebp,ebp				; start address 0
	test ecx,ecx
	jz short .storeit
.scan:
	mov edx,[esi]
	sub edx,ebp
	cmp edx,eax
	jge short .insert
	add ebp,edx
	add ebp,[esi+4]
	add esi,byte 12
	dec ecx
	jnz short .scan

	lea ecx,[ebp+eax]
	cmp ecx,[MEMSIZE]		; check if there is enough memory left
	jl short .storeit		; if ok then it's ok ...
	xor eax,eax				; if no we return 0
	jmp short .allocend
.insert:
	push edi
	push edx
	mov edx,[mem_numb]
	lea edx,[edx*4]
	lea edi,[mem_table+edx+edx*2]
.decal:
	mov edx,[edi-12]
	mov [edi],edx
	mov edx,[edi-8]
	mov [edi+4],edx
	mov edx,[edi-4]
	mov [edi+8],edx
	sub edi,byte 12
	dec ecx
	jnz short .decal
	pop edx
	pop edi
.storeit:
	mov [esi],ebp
	mov [esi+MAB.size],eax
	pusha
	_mov eax,20
	int 0x80
	mov [esi+MAB.pid],eax
	popa
	pop esi
	inc dword[esi-4]
	mov eax,ebp
	shl eax,5
	add eax,[MEMBASE]
.allocend:
	pop ecx
	pop edx
	pop esi
	pop ebp
	ret

;------------------------------------------
; calloc:  allocate memory for an array of nmemb elements
;	   of size bytes each...
; input:
; C syntax:	calloc(size_t nmemb,size_t size)
; ASM syntax:
;	 eax=nmemb
;	 ebx=bytes size
;
%ifdef C_CALL
PROC calloc, nmemb,nsize
	push eax
	push ecx
	push edx
	mov eax,nmemb
	mov ebx,nsize
%endif

%ifdef ASM_CALL
calloc:
	push eax
	push ecx
	push edx
%endif

	imul eax,ebx
	mov ecx,eax

%ifdef ASM_CALL
	call malloc
%endif

%ifdef C_CALL
	invoke malloc,eax
%endif

	test eax,eax
	jz short .fin
	mov edx,eax
	xor eax,eax

%ifdef ASM_CALL
	call memset
%endif

%ifdef C_CALL
	invoke memset,edx,eax,ecx
%endif

.fin:	pop edx
	pop ecx
	pop eax

%ifdef C_CALL
	pop ebp
%endif
	ret

;------------------------------------------
; free:   free(eax)
; free the memory block previously allocated
;

%ifdef C_CALL
PROC free, memblk
	push ecx
	push eax
	push esi
        push edi
	mov eax,memblk
%endif

%ifdef ASM_CALL
free:
	push ecx
	push eax
	push esi
	push edi
%endif

	sub eax,[MEMBASE]
	shr eax,5
	lea esi,[mem_table]
	lea edi,[esi-4]
	mov ecx,[edi]
.search:
	cmp [esi],eax
	jz short .found
	add esi,byte 12
	dec ecx
	jnz short .search
	jmp short .fin0
.found:
	dec ecx
	jz short .fin1
.moveit:
	mov eax,[esi+12]
	mov [esi],eax
	mov eax,[esi+16]
	mov [esi+4],eax
	mov eax,[esi+20]
	mov [esi+8],eax
	add esi,byte 12
	dec ecx
	jnz short .moveit
.fin1:
	dec dword[edi]
.fin0:
	pop edi
	pop esi
	pop eax
	pop ecx

%ifdef C_CALL
	pop ebp
%endif
	ret

;---------------------------------------------------------------------------
; inet_aton:   convert IP adress ascii string, to 32 bit network oriented

PROC inet_aton, char_cp, in_addr

	pusha
	cld
	mov esi,char_cp
	mov edi,in_addr
	_mov ecx,4
; convert xx.xx.xx.xx  to  network notation
.conv:	xor edx,edx
.next:	lodsb
	sub al,'0'
	jb short .loop1
	add edx,edx
	lea edx,[edx+edx*4]
	add dl,al
	jmp short .next
.loop1:	mov al,dl
	stosb
	loop .next
	popa
	ENDP



;---------------------------------------------------------------------
; --  Strtol -->    convert string in npt to a long integer value
;		    according to given base (between 2 and 36)
;		    if enptr if not 0 , it is the end of the string
;		   else the string is null-terminated
;
; C syntax:  long int Strtol(const char *nptr, char **endptr, int base)
;
; Assembly syntax:
; 			EDI point on string
; 			ECX=base    (2, 8, 10, 16, or another one max=36)
; 			ESI=0 if string is null-terminated
;			    else ESI=address of end of string
;	       Return: EAX=32 bit value

%ifdef C_CALL
PROC Strtol, nptr, endptr,  base
	push edi
        push esi
        push ebx
        push ecx
	mov edi,nptr
	mov esi,endptr
	mov ecx,base
%endif
%ifdef ASM_CALL
Strtol:
	push edi
        push ebx
%endif
	test ecx,ecx
        cmovz ecx,[b_default]
        xor eax,eax
	xor ebx,ebx
.parse1:
	cmp byte[edi],32
	jnz short .parse2
        inc edi
        jmp short .parse1
.parse2:
	cmp word[edi],'0x'
        jnz short .next
        _mov ecx,16
	add edi,byte 2
.next:	mov bl,[edi]
	sub bl,'0'
        jb short .done
        cmp bl,9
        jbe short .ok
        sub bl,7
        cmp bl,35
        jbe short .ok
        sub bl,32
.ok:	imul ecx
	add eax,ebx
        inc edi
        cmp edi,esi
        jz short .done
        jmp short .next
.done:
%ifdef C_CALL
	pop ecx
        pop ebx
        pop esi
        pop edi
        pop ebp
%endif
%ifdef ASM_CALL
	pop ebx
        pop edi
%endif
	ret
b_default:	dd 10		; default base to use
;---------------------------------------------


UDATASEG

buff_printf:	resd 8192			; buffer for fprintf temporary formatted string

;-- memory alloc structure
;-
MEMBASE:	resd 1			; start of avilable physical memory
MEMSIZE:	resd 1			; size of available physical memory
;
mem_numb:	resd 1				; number of block allocated
mem_table:	resd (16384*3)			; space for 16384 blocks (each block is 12 bytes)


END
