;Copyright (C) 1999 Konstantin Boldyshev <konst@linuxassembly.org>
;
;$Id: sleep.asm,v 1.2 2000/02/10 15:07:04 konst Exp $
;
;hackers' sleep		[GNU replacement]
;
;0.01: 17-Jun-1999	initial release
;0.02: 03-Jul-1999	sleep is now using sys_nanosleep
;0.03: 18-Sep-1999	elf macros support
;
;syntax: sleep number[smhd]...
;
;s	-	seconds
;m	-	minutes
;h	-	hours
;d	-	days
;
;example:	sleep 1 2 3s
;
;TODO: add nanoseconds

%include "system.inc"

CODESEG

;ebp	-	nanoseconds flag

START:
	pop	esi
	pop	esi

.args:
	pop	esi
	or	esi,esi
	jz	.exit
	mov	edi,esi

	_mov	eax,0
	_mov	ebx,10
	_mov	ecx,0
.next:				;convert string to 64 bit integer
	mov	cl,[esi]
	sub	cl,'0'
	jb	.done
	cmp	cl,9
	ja	.done
	mul	ebx
	add	eax,ecx
	adc	edx,0
	inc	esi
	jmp short .next

;some reasonable checks
;can be removed if sure

.done:
	cmp	edi,esi	;some wrong number?
	jz	.exit
	or	edx,edx
	jnz	.ok
	or	eax,eax
	jnz	.ok
.exit:
	sys_exit

.ok:

	_mov	ebx,1

	add	cl,'0'
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
	jnz	.exit

.set_sleep:
	mul	ebx
.set_sleep2:
	mov	ebx,t
	_mov	ecx,NULL

.nanosleep:
;reserved for nanoseconds support
;	mov	dword [ebx],edx
;	mov	dword [ebx+4],eax
;	or	ebp,ebp
;	jnz	.do_sleep
	mov	dword [ebx],eax
	mov	dword [ebx+4],edx
.do_sleep:
	sys_nanosleep
	jmp .args

UDATASEG

t I_STRUC timespec
.tv_sec		ULONG	1
.tv_nsec	ULONG	1
I_END

END
