;Copyright (C) 1999-2001 Konstantin Boldyshev <konst@linuxassembly.org>
;
;$Id: sleep.asm,v 1.3 2001/02/23 12:39:29 konst Exp $
;
;hackers' sleep		[GNU replacement]
;
;syntax: sleep number[nsmhd]...
;
;n	-	nanoseconds
;s	-	seconds
;m	-	minutes
;h	-	hours
;d	-	days
;
;example:	sleep 1 2 3s
;
;NOTE:	this utility has nanoseconds suffix extension
;	in addition to usual GNU sleep suffixes
;
;0.01: 17-Jun-1999	initial release
;0.02: 03-Jul-1999	sleep is now using sys_nanosleep
;0.03: 18-Sep-1999	elf macros support
;0.04: 22-Jan-2001	nanoseconds support

%include "system.inc"

CODESEG

START:
	pop	esi
	pop	esi

.args:
	pop	esi
	or	esi,esi
	jz	.exit
	mov	edi,esi

	xor	eax,eax
	xor	ebx,ebx
.next_digit:
	lodsb
	sub	al,'0'
	jb	.done
	cmp	al,9
	ja	.done
	imul	ebx,byte 10
	add	ebx,eax
	adc	edx,byte 0
	_jmp	.next_digit
.done:
	mov	eax,ebx
	test	edx,edx
	jnz	.ok
	test	eax,eax
	jnz	.ok
.exit:
	sys_exit eax

.ok:
	_mov	ebx,1
	mov	cl,byte [esi - 1]

	test	cl,cl
	jz	.set_sleep
.s:
    	cmp	cl,'s'
	jz	.set_sleep2
.m:
	_mov	ebx,60
	cmp	cl,'m'
	jz	.set_sleep
.h:
	_mov	ebx,60*60
	cmp	cl,'h'
	jz	.set_sleep
.d:
	_mov	ebx,60*60*24
	cmp	cl,'d'
	jz	.set_sleep	
	cmp	cl,'n'
	jnz	.exit
	xchg	eax,edx
	jmps	.set_sleep2
.set_sleep:
	mul	ebx
.set_sleep2:
	mov	ebx,t
.nanosleep:
	mov	dword [ebx],eax
	mov	dword [ebx+4],edx
.do_sleep:
	sys_nanosleep EMPTY,NULL
	_jmp	.args

UDATASEG

t I_STRUC timespec
.tv_sec		ULONG	1
.tv_nsec	ULONG	1
I_END

END
