;Copyright (C) 1999 Konstantin Boldyshev <konst@linuxassembly.org>
;
;$Id: update.asm,v 1.3 2000/03/02 08:52:01 konst Exp $
;
;hackers' update
;
;initial version was based on "updated"
;by Sander van Malssen <svm@kozmix.hacktic.nl>
;
;
;0.01: 05-Jun-1999	initial release
;0.02: 17-Jun-1999	period parameter added
;0.03: 04-Jul-1999	fixed bug with 2.0 kernel,removed MAXPERIOD,
;			sys_nanosleep instead of SIGALRM
;0.04: 18-Sep-1999	elf macros support
;
;syntax: update [PERIOD]
;
;PERIOD (in seconds) - flush period, if missing use default of 30
;
;example:	update
;		update 60

%include "system.inc"

PERIOD	equ	30	;default flush interval in seconds

CODESEG

;ebp - flush period
;
;

START:
	_mov	ebp,PERIOD
	pop	esi
	dec	esi
	jz	.start
	pop	esi
	pop	esi
	mov	edi,esi

;convert string to 16 bit integer

	xor	eax,eax
	xor	ecx,ecx
	mov	bl,10
.next:
	mov	cl,[esi]
	sub	cl,'0'
	jb	.done
	cmp	cl,9
	ja	.done
	mul	bl
	add	eax,ecx
	inc	esi
	jmp short .next
.done:
;some reasonable checks
;can be removed if sure
	cmp	edi,esi	;some wrong number?
	jz	.start
	or	eax,eax
	jz	.start
	mov	ebp,eax
.start:	
	mov	[t.tv_sec],ebp
	sys_fork
	or	eax,eax
	jz	.child
	sys_exit

.child:
	sys_bdflush 1,0
	sys_nanosleep t	;,NULL
	jmp short .child

UDATASEG

t I_STRUC timespec
.tv_sec		ULONG	1
.tv_nsec	ULONG	1
I_END

END
