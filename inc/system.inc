; Copyright (C) 1999-2001 Konstantin Boldyshev <konst@linuxassembly.org>
;
; $Id: system.inc,v 1.5 2001/03/18 07:08:25 konst Exp $
;
; file		: system.inc
; created	: 08-Apr-1999
; modified	: 11-Mar-2001
; version	: 0.14
; assembler	: nasm 0.98
; description	: generic (not OS specific) macros, sections, headers, etc.
; author	: Konstantin Boldyshev <konst@linuxassembly.org>
; comment	: you must include this file to do anything else
;
;0.01: 05-Jun-1999	initial release
;0.02: 17-Jun-1999	total rewrite, new macros & syscalls.
;0.03: 01-Jul-1999	fixed bugs in __setreg32, __syscall_setregs rewritten,
;			new syscalls and constants, added optimization for
;			size/speed
;0.04: 01-Aug-1999	fixed more bugs in __setreg32 :), all constants moved
;			to defines.inc, all syscalls moved to syscall.inc
;0.05: 18-Sep-1999	support for elf.inc, I_STRUC and I_END macros
;0.06: 03-Jan-2000	_mov, _add, _sub, _cmp
;			invoke, PROC, ENDP
;0.07: 07-Feb-2000	_push, configuration moved to makefile
;0.08: 28-Feb-2000	added stack convertion routine, libc support,
;			various bugfixes (_mov and co)
;0.09: 14-Mar-2000	jmps, syscall gates
;0.10: 21-Aug-2000	started stub for BeOS, _mov improved,
;			NetBSD and OpenBSD stuff
;0.11: 24-Oct-2000	AtheOS stuff
;0.12: 19-Jan-2001	_xchg (PR), _jmp (KB)
;0.13: 21-Feb-2001	modified __syscall_gate (KB)
;0.14: 11-Feb-2001	added B_STRUC macro (aka ELF_BSTRUC from elf.inc) (BR),
;			moved __syscall_gate to os_xxx.inc files (KB)

%ifndef __SYSTEM_INC
%define __SYSTEM_INC

;--------------------------------------------------------------------------
; default configuration parameters (used if not specified at compile time)
;--------------------------------------------------------------------------

;
;Operating System
;

%ifndef __LINUX__
%ifndef __ATHEOS__
%ifndef __BEOS__
%define __BSD__
%ifndef __FREEBSD__
%ifndef __NETBSD__
%ifndef __OPENBSD__
%define __LIBC__
%undef	__BSD__
%endif
%endif
%endif
%endif
%endif
%endif

;
;kernel version
;

%ifndef __KERNEL__
%assign	__KERNEL__	22
%endif

;
;optimization method (size/speed)
;

%assign	__O_SIZE__	0
%assign	__O_SPEED__	1

%ifndef __OPTIMIZE__
%assign	__OPTIMIZE__ __O_SIZE__	;size/speed
%endif

;--------------------------------------------------------------------------
;
;--------------------------------------------------------------------------

%include "includes.inc"

%ifdef	__LINUX__
%include "os_linux.inc"
%elifdef __FREEBSD__
%include "os_freebsd.inc"
%elifdef __NETBSD__
%include "os_netbsd.inc"
%elifdef __OPENBSD__
%include "os_openbsd.inc"
%elifdef __BEOS__
%include "os_beos.inc"
%elifdef __ATHEOS__
%include "os_atheos.inc"
%endif

%include "syscall.inc"

%ifdef __ELF_MACROS__
%include "elf.inc"
%endif

;--------------------------------------------------------------------------
;
;--------------------------------------------------------------------------

%ifdef __STARTUP__
%define START _start2
%else
%define START _start
%endif


%macro CODESEG 0
%ifdef __ELF_MACROS__

BEGIN_ELF

%ifdef STAMP_VERSION
	db	__n
__ver	db	STAMP_VERSION, EOL
%endif

%ifdef STAMP_DATE
	db	__t
__date	db	STAMP_DATE, EOL, __n
%endif

%else

%ifdef __AOUT__

    section	.text

%else

%if __OPTIMIZE__=__O_SPEED__
section	.text align=16
%elif __OPTIMIZE__=__O_SIZE__
section	.text align=1
%endif

%endif

	global	START

%ifdef STAMP_VERSION
	db	__n
__ver	db	STAMP_VERSION, EOL
%endif

%ifdef STAMP_DATE
	db	__t
__date	db	STAMP_DATE, EOL, __n
%endif

;
; syscall gate, if any
;

SYSCALL_GATE

;Here's startup code plugin. It should prepare the stack
;in a [ argc | argv[0]... | envp[0].. ] way for your OS.
;
;for now there's only support for C style stack: main(argc,**argv,**envp)

%ifdef __STARTUP__

__S	equ	4

%ifdef __LIBC__
	global	main
main:
	mov	ebp,esp

	xor	edx,edx
	push	edx

.__env:
	push	edx
	xor	ecx,ecx
	mov	eax,[ebp + __S + 8]
	or	eax,eax
	jz	.__argv
.__find_env:
	cmp	[eax],edx
	jz	.__push_env
	inc	ecx
	add	eax,byte 4
	jmp	short .__find_env
.__push_env:
	sub	eax,byte 4
	push	dword [eax]
	loop	.__push_env
	
.__argv:
	push	edx
	xor	ecx,ecx
	mov	eax,[ebp + __S + 4]
	or	eax,eax
	jz	.__argc

.__find_arg:
	cmp	[eax],edx
	jz	.__push_arg
	inc	ecx
	add	eax,byte 4
	jmp	short .__find_arg
.__push_arg:
	sub	eax,byte 4
	push	dword [eax]
	loop	.__push_arg

.__argc:
	mov	eax,[ebp + __S]
	push	eax
	xor	eax,eax
	xor	ecx,ecx
	xor	ebp,ebp
	jmp	START
%else
	global	_start
_start:

%ifdef	__BEOS__
	pop	eax
	pop	eax
	pop	esi
;	mov	esi,[esi]
	push	eax
.__next1:
	push	esi
.__next2:
	lodsb
	or	al,al
	jnz	.__next2
	inc	esi
	cmp	[esi],byte 0
	jnz	.__next1

	xor	eax,eax
	mov	esi,eax
	jmp	START
%endif

%endif

%endif	;__STARTUP__

%endif
%endmacro

%macro UDATASEG 0
%ifdef __ELF_MACROS__
ELF_DATA
%else
%if __OPTIMIZE__=__O_SPEED__
    section	.bss	align=32
%elif __OPTIMIZE__=__O_SIZE__
    section	.bss
%endif
%endif
%endmacro

%macro DATASEG 0
%ifndef __ELF_MACROS__

%ifdef __AOUT__

    section	.data

%else

%if __OPTIMIZE__=__O_SPEED__
    section	.data	align=16
%elif __OPTIMIZE__=__O_SIZE__
    section	.data	align=1
%endif
%endif

%endif
%endmacro

%macro END 0
%ifdef __ELF_MACROS__
END_ELF
%endif
%endmacro

%macro I_STRUC 1
%ifdef __ELF_MACROS__
ELF_ISTRUC %1
%else
istruc %1
%endif
%endmacro

%macro I_END 0
%ifdef __ELF_MACROS__
ELF_IEND
%else
iend
%endif
%endmacro

; (BR)
; B_STRUC is a more succinct method for using a Nasm structure
; definition within a DATA section. The first argument names a
; previously defined structure. The following arguments indicate
; the members of that structure to declare here.
;
; Please note that the fields of the structure must have been defined
; as local labels (i.e., with a dot prefix).

%ifdef __ELF_MACROS__

%define	B_STRUC ELF_BSTRUC

%else

%macro B_STRUC 1-*
%push foo
%define %$strucname %1
%%top_%$strucname:
%rep %0 - 1
%rotate 1
resb %{$strucname}%1 - ($ - %%top_%$strucname)
%1:
%endrep
resb %{$strucname}_size - ($ - %%top_%$strucname)
%pop
%endmacro

%endif

;------------------------------------------------------------------
; General purpose macros
;------------------------------------------------------------------

;
;explicit short jump
;

%define	jmps jmp short

;
;auto short/long jump
;currently works only backwards :(
;

%macro _jmp 1
%%__offset_%1 equ $-%1
%assign __offset__ %%__offset_%1

%if (__offset__<0) && (__offset__>0xFFFFFF80)
	jmp	short %1
%elif (__offset__>0) && (__offset__<0x80)
	jmp	short %1
%else
	jmp	%1
%endif
%endmacro

;
;intellectual register assignment, generates smaller code.. long weird macro.
;warning: macro may touch flags!
;

%macro _mov 2-3
%ifnidn	%2,EMPTY
 %if __OPTIMIZE__=__O_SPEED__
    %ifid %2
	mov	%1,%2
    %elifnum %2
     %if %2=0
	sub	%1,%1
     %else
	mov	%1,%2
     %endif
    %else
	mov	%1,%2
    %endif
 %else			;%if __OPTIMIZE__=__O_SIZE__
    %ifid %2
     %ifnidni %1,%2
	mov	%1,%2
     %endif
    %elifstr %2
	mov	%1,%2
    %elifnum %2
     %if %2=0
	xor	%1,%1
     %elif %2<0 && %2>0xffffff7f
	push	byte %2
	pop	%1
     %elif %2<0
	mov	%1,%2
     %elif %2<0x80
	push	byte %2
	pop	%1
     %elif %2<0x100
	%ifidn %1,eax
	    __setreg32_08_lo al,%1,%2
	%elifidn %1,ebx
	    __setreg32_08_lo bl,%1,%2
	%elifidn %1,ecx
	    __setreg32_08_lo cl,%1,%2
	%elifidn %1,edx
	    __setreg32_08_lo dl,%1,%2
	%else
	    mov	%1,%2
	%endif
     %elif %2<0x00010000 
	%if (%2 % 0x100) = 0
	    %ifidn %1,eax
		__setreg32_08_hi ah,%1,%2
	    %elifidn %1,ebx
	        __setreg32_08_hi bh,%1,%2
	    %elifidn %1,ecx
		__setreg32_08_hi ch,%1,%2
	    %elifidn %1,edx
		__setreg32_08_hi dh,%1,%2
	    %else
		mov	%1,%2
	    %endif
	%else
	    %ifidn %1,eax
		__setreg32_16 ax,%1,%2
	    %elifidn %1,ebx
		__setreg32_16 bx,%1,%2
	    %elifidn %1,ecx
		__setreg32_16 cx,%1,%2
	    %elifidn %1,edx
		__setreg32_16 dx,%1,%2
	    %else
		mov	%1,%2
	    %endif
	%endif
     %else
	mov	%1,%2
     %endif
    %else
	mov	%1,%2
    %endif
 %endif
%endif
%endmacro

;
; _mov helpers
;

%macro __setreg32_08_lo 3
%ifnidn	%3,EMPTY
	xor	%2,%2
	mov	%1,%3
%endif
%endmacro

%macro __setreg32_08_hi 3
%ifnidn	%3,EMPTY
	xor	%2,%2
	mov	%1,(%3 / 0x100)
%endif
%endmacro

%macro __setreg32_16 3
%ifnidn	%3,EMPTY
    %if %3=0xFFFF
        xor	%2,%2
	dec	%1
    %else
	mov	%2,%3
    %endif
%endif
%endmacro

;
; another weird one :)
;

%macro _add 2
%if %2 != 0
 %if __OPTIMIZE__=__O_SPEED__

	add	%1,%2

 %else			;%if __OPTIMIZE__=__O_SIZE__

    %if %2=1
	inc	%1
    %elif %2=2
	inc	%1
	inc	%1
    %elif %2=0xFFFFFFFF || %2=-1
	dec	%1
    %elif %2=0xFFFFFFFE || %2=-2
	dec	%1
	dec	%1
    %elif %2=0x80
	add	%1,byte 0x7F
	inc	%1
    %elif %2>0 && %2<0x80
	add	%1,byte %2
    %elif %2<0 && %2>-0x80
	sub	%1, byte  -(%2)
    %else
	add	%1,%2
    %endif

 %endif

%endif
%endmacro

;
;
;

%macro _sub 2
%if %2 != 0
 %if __OPTIMIZE__=__O_SPEED__

	sub	%1,%2

 %else			;%if __OPTIMIZE__=__O_SIZE__

    %if %2=1
	dec	%1
    %elif %2=2
	dec	%1
	dec	%1
    %elif %2=0x80
	sub	%1,byte 0x7F
	dec	%1
    %elif %2>0 && %2<0x80
	sub	%1,byte %2
    %elif %2=-2 || %2=0xfffffffe
	inc	%1
	inc	%1
    %elif %2=-1 || %2=0xffffffff
	inc	%1
    %elif %2>-0x80 && %2<0
	add	%1, byte  -(%2)
    %else
	sub	%1,%2
    %endif

 %endif

%endif
%endmacro

%macro _cmp 2
%ifid	%2
	cmp	%1,%2
%elif %2=0
	or	%1,%1
%elif (%2>0 && %2<0x80) || (%2<0 && %2>-0x80)
	cmp	%1,byte %2
%else
	cmp	%1,%2
%endif
%endmacro

%macro _and 2
%ifid	%2
	and	%1,%2
%elif %2=0
	xor	%1,%1
%elif (%2>0 && %2<0x80) || (%2<0 && %2>-0x80)
	and	%1,byte %2
%else
	and	%1,%2
%endif
%endmacro

%macro _or 2
%ifid	%2
	or	%1,%2
%elif (%2>0 && %2<0x80) || (%2<0 && %2>-0x80)
	or	%1,byte %2
%else
	or	%1,%2
%endif
%endmacro

%macro _xor 2
%ifid	%2
	xor	%1,%2
%elif (%2>0 && %2<0x80) || (%2<0 && %2>-0x80)
	xor	%1,byte %2
%else
	xor	%1,%2
%endif
%endmacro

%macro _push 1
%ifid %1
	push	dword %1
%elifstr %1
	push	dword %1
%elif %1=0 || (%1>0 && %1<0x80) || (%1<0 && %1>-0x80)
	push	byte %1
%else
	push	dword %1
%endif
%endmacro

;PR: <xchg> is very slow, reg/mem takes 33 clocks.
;this macro for nasm helps speeding up regardless of what addressing mode used

%macro _xchg 2
%if __OPTIMIZE__=__O_SIZE__
%assign ea 4
%else
%assign ea 0
%ifid %{2}
%assign ea ea|2
%endif
%ifid %{1}
%assign ea ea|1
%endif
%endif
;handles reg,mem and mem,reg differently, because:
;	9 clocks if last, negated opd is in memory
;	5 clocks if that one is a register
%if ea=2
    add %{1},%{2}
    sub %{2},%{1}
    add %{1},%{2}
    neg dword %{2}
%elif ea=1
    add %{2},%{1}
    sub %{1},%{2}
    add %{2},%{1}
    neg dword %{1}
%else
;  2 clocks w. reg,reg
;	(lea variant wasn't faster, may be cpu dependent?)
; 33 clocks w. reg,mem or mem,reg - either case
    xchg %{1},%{3}
%endif
%endmacro

;
;former macros.inc
;

%macro invoke 2-10
%assign _params %0
%assign _params _params-1
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
	push dword %2
	call %1
%assign _params _params*4
	_add esp,_params
%endmacro

%macro PROC 1-10
GLOBAL %{1}
%{1}:
%if %0 > 1
%define %2 dword[ebp+8]
%endif
%if %0 > 2
%define %3 dword[ebp+12]
%endif
%if %0 > 3
%define %4 dword[ebp+16]
%endif
%if %0 > 4
%define %5 dword[ebp+20]
%endif
%if %0 > 5
%define %6 dword[ebp+24]
%endif
%if %0 > 6
%define %7 dword[ebp+28]
%endif
%if %0 > 7
%define %8 dword[ebp+32]
%endif
%if %0 > 8
%define %9 dword[ebp+36]
%endif
%if %0 > 9
%define %10 dword[ebp+40]
%endif
	push	ebp
	mov	ebp,esp
%endmacro

%macro ENDP 0
	pop	ebp
	ret
%endmacro

%endif	;__SYSTEM_INC