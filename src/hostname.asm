;Copyright (C) 1999 Konstantin Boldyshev <konst@linuxassembly.org>
;
;$Id: hostname.asm,v 1.4 2000/09/03 16:13:54 konst Exp $
;
;hackers' hostname/domainname
;
;0.01: 05-Jun-1999	initial release
;0.02: 17-Jun-1999	size improvements
;0.03: 04-Jun-1999	domainname added
;0.04: 18-Sep-1999	elf macros support 
;0.05: 03-Sep-2000	portable utsname, BSD port
;
;syntax: hostname [name]
;	 domainname [name]
;
;if name parameter is omited it displays name, else sets it to name
;you must be root to set host/domain name

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
%ifdef __BSD__
	mov	esi,h
	sys_gethostname esi,MAXHOSTNAMELEN - 1
	dec	edi
	jnz	.done_get
	sys_getdomainname
%else
	sys_uname h

	_mov	edx,0	;not needed, edx was not touched yet
	mov	esi,h.nodename
	dec	edi
	jnz	.done_get
	mov	esi,h.domainname
%endif
.done_get:
	lodsb
	inc	edx
	or	al,al
	jnz	.done_get
	mov	byte [esi-1],__n
	sub	esi,edx
	sys_write STDOUT,esi
_exit:
	sys_exit eax

UDATASEG

h I_STRUC utsname
.sysname	CHAR	SYS_NMLN
.nodename	CHAR	SYS_NMLN
.release	CHAR	SYS_NMLN
.version	CHAR	SYS_NMLN
.machine	CHAR	SYS_NMLN
.domainname	CHAR	SYS_NMLN
I_END

END
