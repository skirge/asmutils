;Copyright (C) 1999-2000 Konstantin Boldyshev <konst@linuxassembly.org>
;
;$Id: libc.asm,v 1.5 2000/04/07 18:36:01 konst Exp $
;
;linux libc :)
;
;main feature: cdecl and fastcall can be configured AT RUNTIME.
;
;0.01: 10-Sep-1999	initial alpha pre beta 0 non-release
;0.02: 24-Dec-1999	first working version
;0.03: 21-Feb-2000	fastcall support
;
;WARNING!!! THIS IS VERY ALPHA VERSION OF LIBC
;THIS SOURCE IS PROVIDED ONLY FOR CRAZY HACKERS
;EVERYTHING HERE IS SUBJECT TO CHANGE WITHOUT NOTICE
;
;Do not ask me to explain what is written here.

%undef __ELF_MACROS__

%include "system.inc"

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

    _DECLARE_FUNCTION	_fastcall

    _DECLARE_FUNCTION	strlen

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
    _DECLARE_SYSCALL	idle,	0
    _DECLARE_SYSCALL	fork,	0
    _DECLARE_SYSCALL	execve,	3
    _DECLARE_SYSCALL	uname,	1
    _DECLARE_SYSCALL	ioctl,	3
    _DECLARE_SYSCALL	alarm,	1
    _DECLARE_SYSCALL	nanosleep,	2
    _DECLARE_SYSCALL	kill,	2
    _DECLARE_SYSCALL	signal,	2
    _DECLARE_SYSCALL	wait4,	4

;    _DECLARE_SYSCALL	stat,	2
    _DECLARE_SYSCALL	fstat,	2
    _DECLARE_SYSCALL	lstat,	2

    _DECLARE_SYSCALL	getuid,	0
    _DECLARE_SYSCALL	getgid,	0


_fastcall:
	cmp	[__cc],byte 0
	jnz	.ret
	mov	eax,[esp + 4]
.ret:
	mov	[__cc],al
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

DATASEG

__cc	db	0	;calling convention (how many registers for fastcall)
			;0 = cdecl
UDATASEG

	global errno
errno	dd	0

__eax	resd	1
__ebx	resd	1
__ecx	resd	1
__edx	resd	1
__esi	resd	1
__edi	resd	1
__ebp	resd	1

END
