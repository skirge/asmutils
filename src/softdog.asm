;Copyright (C) 1999 Konstantin Boldyshev <konst@linuxassembly.org>
;
;$Id: softdog.asm,v 1.3 2000/03/02 08:52:01 konst Exp $
;
;hackers' softdog (software watchdog)
;
;0.01: 04-Jul-1999	initial release
;0.02: 29-Jul-1999	fixed bug with sys_open
;0.03: 18-Sep-1999	elf macros support
;
;syntax: softdog [PERIOD]
;
;PERIOD (in seconds) - kick period, if missing use default of 10
;
;example:	softdog
;		softdog 15

%include "system.inc"

DEFPERIOD	equ	10	;default period
MAXPERIOD	equ	60	;maximum kernel margin

CODESEG

;ebp - period

START:
	_mov	ebp,DEFPERIOD
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
	or	eax,eax	;zero?
	jz	.start
	_mov	ebx,MAXPERIOD
	cmp	eax,ebx			;if more than max - set max
	jb	.start0
	mov	eax,ebx
.start0:
	mov	ebp,eax
.start:
	mov	[t.tv_sec],ebp

	sys_open softdog,O_WRONLY
	mov	ebp,eax
	test	eax,eax
	js	.exit

	sys_fork
	or	eax,eax
	jz	.child
.exit:
	sys_exit


.child:
	sys_write ebp,softdog,1
	sys_nanosleep t,NULL
	jmp short .child

softdog	db	'/dev/watchdog',EOL

UDATASEG

t I_STRUC timespec
.tv_sec		ULONG	1
.tv_nsec	ULONG	1
I_END

END
