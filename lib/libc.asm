;Copyright (C) 1999-2000 Konstantin Boldyshev <konst@linuxassembly.org>
;Copyright (C) 1999 Cecchinel Stephan <inter.zone@free.fr>
;
;$Id: libc.asm,v 1.6 2000/09/03 16:13:54 konst Exp $
;
;hackers' libc
;
;main feature: cdecl and fastcall can be configured AT RUNTIME.
;
;0.01: 10-Sep-1999	initial alpha pre beta 0 non-release
;0.02: 24-Dec-1999	first working version
;0.03: 21-Feb-2000	fastcall support
;0.04: 20-Jul-2000	fixed stupid bug/misprint, merged clib.asm & string.asm
;			printf()
;
;WARNING!!! THIS IS THE VERY ALPHA VERSION OF LIBC.
;THIS SOURCE IS PROVIDED ONLY FOR CRAZY HACKERS.
;EVERYTHING HERE IS SUBJECT TO CHANGE WITHOUT NOTICE.
;
;Do not ask me to explain what is written here.

%undef __ELF_MACROS__

%include "system.inc"

;
;configuration defines
;

%define C_CALL

;
; macro used for function declaration
;

%macro _DECLARE_FUNCTION 1-*
%rep %0
    global %1:function
%rotate 1
%endrep
%endmacro

;
;%1	syscall name
;%2	number of parameters

%macro _DECLARE_SYSCALL 2
    global %1:function

    db	%2	;dirty trick
%1:
    call __enter
    sys_%{1}
    jmp __sysret
%endmacro

;
; entering usual call
;

%macro _enter 0
%endmacro

;
; leaving usual call
;

%macro _leave 0
    ret
%endmacro


CODESEG

;**************************************************
;*             INTERNAL FUNCTIONS                 *
;**************************************************

;
; entering system call
;

__enter:
	mov	[__eax],eax
	mov	[__ebx],ebx
	mov	[__ecx],ecx
	mov	[__edx],edx
	mov	[__esi],esi
	mov	[__edi],edi

	mov	eax,[esp]		;load number of parameters into eax:
	movzx	eax,byte [eax - 6]	;return address - sizeof(call)

	or	al,al
	jz	.return
	test	al,al
	jns	.sk1
	neg	al
	jmp	short .cdecl
.sk1:
	cmp	[__cc],byte 0
	jnz	.fc

%define _STACK_ADD 8
.cdecl:
	mov	ebx,[esp + _STACK_ADD]
	dec	eax
	jz	.return
	mov	ecx,[esp + _STACK_ADD + 4]
	dec	eax
	jz	.return
	mov	edx,[esp + _STACK_ADD + 8]
	dec	eax
	jz	.return
	mov	esi,[esp + _STACK_ADD + 12]
	dec	eax
	jz	.return
	mov	edi,[esp + _STACK_ADD + 16]

.return:
	ret
.fc:
	mov	ebx,[__eax]
	dec	eax
	jz	.return
	xchg	ecx,edx
	dec	eax
	jz	.return
	dec	eax
	jz	.return
	mov	esi,[esp + _STACK_ADD]
	dec	eax
	jz	.return
	mov	edi,[esp + _STACK_ADD + 4]
%undef _STACK_ADD
	ret	

;
; leaving system call
;

__sysret:
	test	eax,eax
	jns	__leave
	neg	eax
	mov	[errno],eax
	xor	eax,eax
	dec	eax

__leave:
	mov	ebx,[__ebx]
	mov	ecx,[__ecx]
	mov	edx,[__edx]
	mov	esi,[__esi]
	mov	edi,[__edi]
	ret

_DECLARE_SYSCALL	open,	-3	;<0 means always cdecl
_DECLARE_SYSCALL	close,	1
_DECLARE_SYSCALL	read,	3
_DECLARE_SYSCALL	write,	3
_DECLARE_SYSCALL	lseek,	3
_DECLARE_SYSCALL	chmod,	2
_DECLARE_SYSCALL	chown,	2
_DECLARE_SYSCALL	pipe,	1
_DECLARE_SYSCALL	link,	2
_DECLARE_SYSCALL	symlink,2
_DECLARE_SYSCALL	unlink,	1
_DECLARE_SYSCALL	mkdir,	1
_DECLARE_SYSCALL	rmdir,	1

_DECLARE_SYSCALL	exit,	1
;_DECLARE_SYSCALL	idle,	0	;not posix
_DECLARE_SYSCALL	fork,	0
_DECLARE_SYSCALL	execve,	3
_DECLARE_SYSCALL	uname,	1
_DECLARE_SYSCALL	ioctl,	3
_DECLARE_SYSCALL	alarm,	1
_DECLARE_SYSCALL	nanosleep,	2
_DECLARE_SYSCALL	kill,	2
_DECLARE_SYSCALL	signal,	2
_DECLARE_SYSCALL	wait4,	4

;_DECLARE_SYSCALL	stat,	2
_DECLARE_SYSCALL	fstat,	2
_DECLARE_SYSCALL	lstat,	2

_DECLARE_SYSCALL	getuid,	0
_DECLARE_SYSCALL	getgid,	0


_DECLARE_FUNCTION	_fastcall

_DECLARE_FUNCTION	memset, memcpy, memcpyl
_DECLARE_FUNCTION	printf
_DECLARE_FUNCTION	strlen
_DECLARE_FUNCTION	itoa


;**************************************************
;*          GLOBAL LIBRARY FUNCTIONS              *
;**************************************************

;
;set fastcall/cdecl calling convention
;

_fastcall:
	cmp	[__cc],byte 0
	jnz	.ret
	mov	eax,[esp + 4]
.ret:
	mov	[__cc],al
	ret


;strlen:

	_enter
%if  __OPTIMIZE__=__O_SIZE__
	push	edi
	mov	edi,[esp + 8]
	mov	eax,edi
	dec	edi
.l1:
	inc	edi
	cmp	[edi],byte 0
	jnz	.l1
	xchg	eax,edi
	sub	eax,edi
	pop	edi
%else
; (Nick Kurshev)
; note: below is classic variant of strlen
; if not needed to save ecx register then size of classic code
; will be same as above 
; remark: fastcall version of strlen will on 2 bytes less than cdecl
	push	esi
	push	ecx
	mov	esi,[esp + 12]
	xor	eax,eax
        or	ecx,byte -1
	repne	scasb
	not	ecx
	mov	eax,ecx
	dec	eax
	pop	ecx
	pop	esi
%endif
	_leave


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

;---------------------------------------------------------------------
PROC printf,ipf_string
	pusha
	cld
	lea	edi,[printb]
	push	edi
	mov	esi,ipf_string
	lea	edx,[ebp+12]
.boucle:
	lodsb
	test	al,al
	jz	.out_pf
	cmp	al,'%'
	jz	.gest_spec
	cmp	al,'\'
	jz	.gest_spec2
	stosb
	jmps	.boucle
.gest_spec:
	mov	ebx,[edx]
	lodsb
	cmp	al,'d'
	jnz	.gest2
	_mov	ecx,10
	jmps	.gestf
.gest2:	cmp	al,'x'
	jnz	.gest3
	_mov	ecx,16
	jmps	.gestf
.gest3:	cmp	al,'o'
	jnz	.gest4
	_mov	ecx,8
	jmps	.gestf
.gest4:	cmp	al,'b'
	jnz	.gest5
	_mov	ecx,2
	jmp	.gestf
.gest5:	cmp	al,'s'
	jnz	.boucle
.copyit:			; copy the string in args , to output buffer
	mov	al,[ebx]
	test	al,al		; the string is null terminated
	jz	.allok
	stosb
	inc	ebx
	jmps	.copyit

.gestf:
%ifdef C_CALL
	invoke itoa,ebx,edi,ecx
%endif

%ifdef ASM_CALL
	mov	eax,ebx
	call	itoa
%endif

.stl:	cmp	byte[edi],1
	inc	edi
	jnc	.stl

.allok:	add	edx,byte 4
	jmps	.boucle

.gest_spec2:
	lodsb
	cmp	al,'n'
	jnz	.boucle
	mov	al,0x0a
	stosb
	jmps	.boucle

.out_pf:
	xor	al,al
	stosb
	pop	edx
	sub	edi,edx
	sys_write STDOUT,printb,edi
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


%if __OPTIMIZE__=__O_SPEED__
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

%else		;__O_SIZE

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
%if __OPTIMIZE__=__O_SPEED__
	push ecx
	push edi
	push esi
%else
	pusha
%endif
%ifdef C_CALL
	mov edi,dest
	mov esi,source
	mov ecx,length
%endif
	cld
	rep movsb
%if __OPTIMIZE__=__O_SPEED__
	pop esi
	pop edi
	pop ecx
%else
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
%if __OPTIMIZE__=__O_SPEED__
	push ecx
	push edi
	push esi
%else
	pusha
%endif
%ifdef C_CALL
	mov edi,dest2
	mov esi,source2
	mov ecx,length2
%endif
	cld
	rep movsd
%if __OPTIMIZE__=__O_SPEED__
	pop esi
	pop edi
	pop ecx
%else
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
	mov	edx,strlen_string
%endif

%ifdef ASM_CALL
strlen:
%endif

%if __OPTIMIZE__=__O_SPEED__
	push	ecx
	mov	eax,edx
	test	dl,3
	jz	.boucle
	cmp	byte[eax],0
	jz	.strfi
	cmp	byte[eax+1],0
	jz	.ret1
	cmp	byte[eax+2],0
	jnz	.align
	add	eax,byte 2
	jmps	.strfi
.align:	add	eax,byte 3
	and	eax,byte -4
.boucle:		;normally the whole loop is 7 cycles (for 8 bytes)
	mov	ecx,dword[eax]
	test	cl,cl
	jz	.strfi
	test	ch,ch
	jz	.ret1
	test	ecx,0xFF0000
	jz	.ret2
	shr	ecx,24
	jz	.ret3
	mov	ecx,dword[eax+8]
	test	cl,cl
	jz	.ret4
	test	ch,ch
	jz	.ret5
	test	ecx,0xFF0000
	jz	.ret6
	add	eax,byte 8
	shr	ecx,4
	jnz	.boucle
	dec	eax
	jmps	.strfi
.ret1:	inc	eax
	jmps	.strfi
.ret2:	add	eax,byte 2
	jmps	.strfi
.ret3:	add	eax,byte 3
	jmps	.strfi
.ret4:	add	eax,byte 4
	jmps	.strfi
.ret5:	dec	eax
.ret6:	add	ecx,byte 6
.strfi:	sub	eax,edx
	pop	ecx

%else		;__O_SIZE__

	xor	eax,eax
.boucle:
	cmp	byte[edx+eax],1
	inc	eax
	jnc	.boucle
	dec	eax

%endif

%ifdef C_CALL
	ENDP
%endif

%ifdef ASM_CALL
	ret
%endif

;---------------------------------------------------------------------------
; inet_aton:   convert IP adress ascii string, to 32 bit network oriented

PROC inet_aton, char_cp, in_addr

	pusha
	cld
	mov	esi,char_cp
	mov	edi,in_addr
	_mov	ecx,4
; convert xx.xx.xx.xx  to  network notation
.conv:	xor	edx,edx
.next:	lodsb
	sub	al,'0'
	jb	.loop1
	add	edx,edx
	lea	edx,[edx+edx*4]
	add	dl,al
	jmps	.next
.loop1:	mov	al,dl
	stosb
	loop	.next
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

;
;
;

;
;convert 32 bit number to hex string
;
;>EAX
;<EDI

LongToStr:
	pushad
	sub	esp,4
	mov	ebp,esp
	mov	[edi],word "0x"
	inc	edi
	inc	edi
	mov	esi,edi
	push	esi
	mov     [ebp],eax
	_mov ecx,16	;10 - decimal
	_mov esi,0
.l1:
        inc     esi
	xor	edx,edx
	mov	eax,[ebp]
	div	ecx
	mov	[ebp],eax
        mov     al,dl

;dec convertion
;	add	al,'0'
;hex convertion
	add	al,0x90
	daa
	adc	al,0x40
	daa

        stosb
	xor	eax,eax
	cmp	eax,[ebp]
	jnz	.l1
        stosb
	pop	ecx
	xchg	ecx,esi
        shr	ecx,1
	jz	.l3
	xchg	edi,esi
	dec	esi
	dec	esi
.l2:
        mov	al,[edi]
	xchg	al,[esi]
	stosb
	dec     esi
	loop    .l2
.l3:
	add	esp,4
	popad
	ret

;
;convert string to 32 bit number
;
;<EDI
;>EAX

StrToLong:
	push	ebx
	push	ecx
	push	edi
	_mov	eax,0
	_mov	ebx,10
	_mov	ecx,0
.next:
	mov	cl,[edi]
	sub	cl,'0'
	jb	.done
	cmp	cl,9
	ja	.done
	mul	bx
	add	eax,ecx
;	adc	edx,0	;for 64 bit
	inc	edi
	jmp short .next

.done:
	pop	edi
	pop	ecx
	pop	ebx
	ret

UDATASEG

global errno
errno	resd	1

__eax	resd	1
__ebx	resd	1
__ecx	resd	1
__edx	resd	1
__esi	resd	1
__edi	resd	1
__ebp	resd	1

__cc	resb	1	;calling convention (how many registers for fastcall)
			;0 = cdecl

printb	resd	0x2000	;buffer for fprintf temporary formatted string

END
