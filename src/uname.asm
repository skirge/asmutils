;Copyright (C) 1999 Konstantin Boldyshev <konst@linuxassembly.org>
;
;$Id: uname.asm,v 1.2 2000/02/10 15:07:04 konst Exp $
;
;hackers' uname/arch	[GNU replacement]
;
;0.01: 17-Jun-1999	initial release
;0.02: 03-Jul-1999	arch support
;0.03: 18-Sep-1999	elf macros support
;
;syntax: uname [-snrvma]
;	 arch (same as uname -m)
;
;-s	os name (default)
;-n	network nodename
;-r	os release
;-v	os version
;-m	machine (hardware) type
;-a	all above information
;----------------------------------------------------
;-p	is not documented and always prints 'unknown'
;	so we will not support it
;----------------------------------------------------

%include "system.inc"

%assign	SYSNAME		00000001b
%assign	NODENAME	00000010b
%assign	RELEASE		00000100b
%assign	VERSION		00001000b
%assign	MACHINE		00010000b

ARGC	equ	5

CODESEG

keys	db	"snrvm"
space	db	0x20
lf	db	0x0A


;
;edi	-	switches flag
;

START:
	pop	ebx
	pop	esi
	dec	ebx
	jnz	args

	mov	dl,SYSNAME	;default
.n1:				;how we are called?
	lodsb
	or 	al,al
	jnz	.n1
	cmp	dword [esi-5],'arch'
	jnz	get_uname
	mov	dl,MACHINE	;we are called as arch
	jmp short get_uname

args:
	pop	esi
	lodsb
	cmp	al,'-'
	jnz	near exit

.inner_stage:
	lodsb
	or	al,al
	jz	.check
.scan_other:
	_mov	ecx,ARGC
	_mov	edi,keys
	mov	ebp,edi
	repnz	scasb
	jnz	.a
	dec	edi
	sub	edi,ebp
	mov	ecx,edi
	mov	al,1
	shl	al,cl
	or	dl,al
	jmp short .inner_stage
.a:
	cmp	al,'a'
	jnz	exit
	or	dl,SYSNAME|NODENAME|RELEASE|VERSION|MACHINE
	jmp short .inner_stage

.check:
	or	dl,dl
	jz	exit

	dec	ebx
	jnz	args

get_uname:
	mov	edi,edx

	sys_uname h

	_mov	ecx,5
	mov	ebp,ebx

.printinfo:
	push	ecx

	mov	dl,5
	sub	dl,cl
	xchg	cl,dl
	mov	al,1
	shl	al,cl
	mov	edx,edi
	test	dl,al
	jz	.skip
	
	mov	esi,ebp
	xor	edx,edx
.next:
	lodsb
	inc	edx
	or	al,al
	jnz	.next
	sub	esi,edx

	sys_write	STDOUT,esi

	sys_write	EMPTY,space,1
	
.skip:
	_add	ebp,luts
	pop	ecx
	loop	.printinfo

exit:
	sys_write	EMPTY,lf,1
	sys_exit

UDATASEG

h I_STRUC new_utsname
.sysname	CHAR	luts
.nodename	CHAR	luts
.release	CHAR	luts
.version	CHAR	luts
.machine	CHAR	luts
.domainname	CHAR	luts
I_END

END
