;Copyright (C) 1999-2000 Konstantin Boldyshev <konst@linuxassembly.org>
;
;$Id: libc.asm,v 1.3 2000/02/10 15:07:04 konst Exp $
;
;linux libc :)
;
;0.01: 10-Sep-1999	initial alpha pre beta 0 non-release
;0.02: 24-Dec-1999	first working version
;
;WARNING!!! THIS IS NOT "REAL" VERSION OF LIBC!
;THIS SOURCE IS PROVIDED ONLY FOR CRAZY HACKERS!
;
;NO COMMENTS. EVERYTHING HERE IS SUBJECT TO CHANGE.
;
;libc.asm and clib.asm will merge
;
;main feature: cdecl and fastcall will be configured AT RUNTIME !

%undef __ELF_MACROS

%include "system.inc"

%assign __FASTCALL 0xfc

;
; entering system call
;

%macro _sys_enter 0
    call __enter
%endmacro

;
; leaving system call
;

%macro _sys_leave 0
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
;
;

%macro _DECLARE_SYSCALL 1-*
%rep %0
    global %1:function
%1:
    _sys_enter
    sys_%{1}
    _sys_leave
%rotate 1
%endrep
%endmacro

CODESEG

    _DECLARE_FUNCTION	_cdecl, _fastcall

    _DECLARE_FUNCTION	strlen

    _DECLARE_SYSCALL	exit, open, close, read, write, lseek, unlink


_cdecl:
	mov	[__cc],byte 0
	ret

_fastcall:
	mov	[__cc],byte __FASTCALL
	ret


strlen:
	_enter
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
	_leave





__enter:
	mov	[__ebx],ebx
	mov	[__ecx],ecx
	mov	[__edx],edx
	mov	[__esi],esi
	mov	[__edi],edi

	cmp	[__cc],byte __FASTCALL
	jz	.fc
%define _STACK_ADD 8
	mov	ebx,[esp + _STACK_ADD]
	mov	ecx,[esp + _STACK_ADD + 4]
	mov	edx,[esp + _STACK_ADD + 8]
	mov	esi,[esp + _STACK_ADD + 12]
	mov	edi,[esp + _STACK_ADD + 16]
%undef _STACK_ADD
	ret
.fc:
	push	ecx
	mov	ebx,eax
	mov	ecx,edx
	pop	edx
	ret	


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

UDATASEG

global errno
errno	resd	1

__tmp	resd	1	
__cc	resd	1	;calling convention

__eax	resd	1
__ebx	resd	1
__ecx	resd	1
__edx	resd	1
__esi	resd	1
__edi	resd	1

END
