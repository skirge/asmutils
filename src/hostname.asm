;Copyright (C) 1999 Konstantin Boldyshev <konst@linuxassembly.org>
;
;$Id: hostname.asm,v 1.2 2000/02/10 15:07:04 konst Exp $
;
;hackers' hostname/domainname
;
;0.01: 05-Jun-1999	initial release
;0.02: 17-Jun-1999	size improvements
;0.03: 04-Jun-1999	domainname added
;0.04: 18-Sep-1999	elf macros support 
;
;syntax: hostname [name]
;	 domainname [name]
;
;if name parameter is omited it displays name, else sets it to name
;you must be root to set host/domain name

%include "system.inc"

CODESEG

START:
%if __KERNEL__ = 20
	_mov	edi,0
%endif
	pop	ebx
	pop	esi
.n1:
	lodsb
	or 	al,al
	jnz	.n1
	cmp	dword [esi-9],'host'
	jz	.n2
	inc	edi			;domainname
.n2:
	dec	ebx
	jz	.getname

	pop	ebx
	_mov	ecx,UTS_LEN
	dec	edi
	jz	.setdomain
	sys_sethostname
	jmp short exit
.setdomain:
	sys_setdomainname
	jmp short exit

.getname:
	sys_uname	h

;	_mov	edx,0	;not needed, edx was not touched yet
	mov	esi,h.nodename
	dec	edi
	jnz	.next
	mov	esi,h.domainname
.next:
	lodsb
	inc	edx
	or	al,al
	jnz	.next
	mov	byte [esi-1],0x0A
	sub	esi,edx

	sys_write STDOUT,esi
exit:
	sys_exit eax

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
