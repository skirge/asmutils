; Copyright (C) 1999-2000 Konstantin Boldyshev <konst@linuxassembly.org>
;
; $Id: system.inc,v 1.3 2000/02/10 15:07:04 konst Exp $
;
; file		: system.inc
; created	: 08-Apr-1999
; modified	: 09-Feb-2000
; version	: 0.07
; assembler	: nasm 0.98
; description	: configuration, sections, headers, etc.
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


%ifndef __SYSTEM_INC
%define __SYSTEM_INC

;--------------------------------------------------------------------------
; default configuration parameters (used if not specified at compile time)
;--------------------------------------------------------------------------

;
;Operating System
;

%ifndef __FREEBSD__
%define __LINUX__
%endif

;
;kernel version
;

%ifndef __KERNEL__
%assign	__KERNEL__	20
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
%endif

%ifdef __ELF_MACROS__
%include "elf.inc"
%endif

;--------------------------------------------------------------------------
;System calls
;--------------------------------------------------------------------------

%include "syscall.inc"

;--------------------------------------------------------------------------
;
;--------------------------------------------------------------------------

%define START _start 

%macro CODESEG 0
%ifdef __ELF_MACROS__

BEGIN_ELF

%else

%if __OPTIMIZE__=__O_SPEED__
    section	.text	align=16
%elif __OPTIMIZE__=__O_SIZE__
    section	.text	align=1
%endif
    global	START

%endif

%ifdef STAMP_VERSION
	db	__n
__ver	db	STAMP_VERSION, EOL
%endif

%ifdef STAMP_DATE
	db	__t
__date	db	STAMP_DATE, EOL, __n
%endif

%endmacro

%macro UDATASEG 0
%ifdef __ELF_MACROS__
ELF_DATA
%else
section	.bss
%endif
%endmacro

%macro DATASEG 0
%ifndef __ELF_MACROS__
%if __OPTIMIZE__=__O_SPEED__
    section	.data	align=16
%elif __OPTIMIZE__=__O_SIZE__
    section	.data	align=1
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

;------------------------------------------------------------------
;intellectual register assignment (generate smallest possible code)
;------------------------------------------------------------------

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

;--------------------------------------------------------------------------
;			here it is.. long weird macro
;--------------------------------------------------------------------------

%macro _mov 2-3
%ifnidn	%2,EMPTY
 %if __OPTIMIZE__=__O_SPEED__
        %ifid %2
	    mov	%1,%2
	%elifnum %2 && %if %2=0x00000000
	    sub	%1,%1
	%else
	    mov	%1,%2
	%endif
 %else			;%if __OPTIMIZE__=__O_SIZE__
    %ifid %2
	mov	%1,%2
    %elifstr %2
	mov	%1,%2
    %elifnum %2
     %if %2=0x00000000
	xor	%1,%1
     %elif %2=0x00000001
    	xor	%1,%1
	inc	%1
     %elif %2=0x00000002
    	xor	%1,%1
	inc	%1
	inc	%1
     %elif %2=0xFFFFFFFF
	xor	%1,%1
	dec	%1
     %elif %2=0xFFFFFFFE
	xor	%1,%1
	dec	%1
	dec	%1
     %elif %2<0
	mov	%1,%2
     %elif %2<0x00000100
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
; another weird one :)
;

%macro _add 2
%if %2 != 0
 %if __OPTIMIZE__=__O_SPEED__

	add	%1,%2

 %else			;%if __OPTIMIZE__=__O_SIZE__

    %if %2=0x00000001
	inc	%1
    %elif %2=0x00000002
	inc	%1
	inc	%1
    %elif %2<0x00000100 && %2>0
	add	%1,byte %2
    %elif %2=0xFFFFFFFE || %2=-2
	dec	%1
	dec	%1
    %elif %2=0xFFFFFFFF || %2=-1
	dec	%1
    %elif %2>-0x00000100 && %2<0
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

    %if %2=0x00000001
	dec	%1
    %elif %2=0x00000002
	dec	%1
	dec	%1
    %elif %2<0x00000100 && %2>0
	sub	%1,byte %2
    %elif %2=0xFFFFFFFE || %2=-2
	inc	%1
	inc	%1
    %elif %2=0xFFFFFFFF || %2=-1
	inc	%1
    %elif %2>-0x00000100 && %2<0
	add	%1, byte  -(%2)
    %else
	sub	%1,%2
    %endif

 %endif

%endif
%endmacro

%macro _cmp 2
%if %2=0
	or	%1,%1
%elif %2<0x00000100 && %2>0
	cmp	%1,byte %2
%elif %2>-0x00000100 && %2<0
	cmp	%1,byte %2
%else
	sub	%1,%2
%endif
%endmacro

%macro _and 2
%if %2=0
	xor	%1,%1
%elif %2<0x00000100 && %2>0
	and	%1,byte %2
%elif %2>-0x00000100 && %2<0
	and	%1,byte %2
%else
	and	%1,%2
%endif
%endmacro

%macro _or 2
%if %2<0x00000100 && %2>0
	or	%1,byte %2
%elif %2>-0x00000100 && %2<0
	or	%1,byte %2
%else
	or	%1,%2
%endif
%endmacro

%macro _xor 2
%if %2<0x00000100 && %2>0
	xor	%1,byte %2
%elif %2>-0x00000100 && %2<0
	xor	%1,byte %2
%else
	xor	%1,%2
%endif
%endmacro

%macro _push 1
%if %2<0x00000100 && %2>0
	push	byte %1
%elif %2>-0x00000100 && %2<0
	push	byte %1
%else
	push	%1
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
	add esp,_params
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
	push ebp
	mov ebp, esp
%endmacro

%macro ENDP 0
	pop ebp
	ret
%endmacro


%endif	;__SYSTEM_INC
