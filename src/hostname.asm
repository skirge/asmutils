;Copyright (C) 1999-2001 Konstantin Boldyshev <konst@linuxassembly.org>
;
;$Id: hostname.asm,v 1.6 2001/12/03 19:19:45 konst Exp $
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
;0.07: 03-Dec-2001	sysctl-based version

%include "system.inc"

;%ifdef	__BSD__
%define	USE_SYSCTL
;%endif

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

%ifdef	USE_SYSCTL
	mov	esi,ebx
.n3:
	lodsb
	or	al,al
	jnz	.n3
	sub	esi,ebx
	dec	esi
	_mov	eax,kern_hostname_req
%else
	_mov	ecx,MAXHOSTNAMELEN
%endif
	dec	edi
	jz	.setdomain

%ifdef USE_SYSCTL
.sethostname:
	sys_sysctl eax, 2, 0, 0, ebx, esi
%else
	sys_sethostname
%endif
	jmps	_exit

.setdomain:

%ifdef USE_SYSCTL
	add	eax, byte 8
	jmps	.sethostname
%else
	sys_setdomainname
	jmps	_exit
%endif
.getname:
%ifdef USE_SYSCTL
	pusha
	mov	dword [len],SYS_NMLN
	mov	eax,kern_hostname_req
	dec	edi
	jnz	.sysctl
	add	eax,byte 8
.sysctl:
	sys_sysctl	eax, 2, h, len, 0, 0
	test	eax,eax
	js	.done_get
	popa
	mov	esi,h
	dec	edi
	jnz	.done_get
;	sys_getdomainname
%else
	mov	esi,h
	sys_uname esi
	_add	esi,utsname.nodename
;	lea	esi,[esi+utsname.nodename]
	dec	edi
	jnz	.done_get
	_add	esi,utsname.domainname-utsname.nodename
%endif

.done_get:
	_mov	edx,0
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

%ifdef	USE_SYSCTL
kern_hostname_req:
	dd	CTL_KERN
	dd	KERN_HOSTNAME
kern_domainname_req:
	dd	CTL_KERN
	dd	KERN_DOMAINNAME
%endif

UDATASEG

%ifdef	USE_SYSCTL
len	resd	1
%endif

h B_STRUC utsname,.nodename,.domainname

END
