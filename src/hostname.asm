;Copyright (C) 1999-2001 Konstantin Boldyshev <konst@linuxassembly.org>
;
;$Id: hostname.asm,v 1.5 2001/03/18 07:08:25 konst Exp $
;
;hackers' hostname/domainname
;
;syntax: hostname [name]
;	 domainname [name]
;
;if name parameter is omited it displays name, else sets it to name
;you must be root to set host/domain name
;
;0.01: 05-Jun-1999	initial release
;0.02: 17-Jun-1999	size improvements
;0.03: 04-Jun-1999	domainname added
;0.04: 18-Sep-1999	elf macros support 
;0.05: 03-Sep-2000	portable utsname, BSD port
;0.06: 04-Mar-2001	size improvements

%include "system.inc"

CODESEG

START:
	xor	edi,edi
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
	_mov	ecx,MAXHOSTNAMELEN
	dec	edi
	jz	.setdomain
	sys_sethostname
	jmps	_exit
.setdomain:
	sys_setdomainname
	jmps	_exit

.getname:

	mov	esi,h

%ifdef __BSD__
	sys_gethostname esi,MAXHOSTNAMELEN - 1
	dec	edi
	jnz	.done_get
	sys_getdomainname
%else
	sys_uname esi
	_add	esi,utsname.nodename
;	lea	esi,[esi+utsname.nodename]
	dec	edi
	jnz	.done_get
	_add	esi,utsname.domainname-utsname.nodename

%endif
.done_get:
	_mov	edx,0		;not needed, edx was not touched yet
.strlen:
	lodsb
	inc	edx
	or	al,al
	jnz	.strlen
	mov	byte [esi-1],__n
	sub	esi,edx
	sys_write STDOUT,esi
_exit:
	sys_exit eax

UDATASEG

h B_STRUC utsname,.nodename,.domainname

END
