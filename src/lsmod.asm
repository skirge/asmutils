;Copyright (C) 1999 Indrek Mandre <indrek.mandre@tallinn.ee>
;
;$Id: lsmod.asm,v 1.3 2000/12/10 08:20:36 konst Exp $
;
;hackers' lsmod/rmmod
;
;0.01: 17-Jun-1999	initial release
;0.02: 04-Jul-1999	fixed bug with 2.0 kernel
;0.03: 06-Sep-2000	merged with rmmod (KB)
;
;syntax: lsmod
;	 rmmod module...
;
;example: rmmod sound ppp
;
;lsmod just opens /proc/modules, prints header and the data inside that file

%include "system.inc"

CODESEG

%if __KERNEL__ = 20
header	db	'Module         Pages    Used by',__n
%else		;if __KERNEL__ >= 22
header	db	'Module                  Size  Used by',__n
%endif
_hlength	equ	$-header

%assign hlength _hlength
%assign	BufSize	0x2000

START:
	pop	ebp
	pop	esi	;our name
.n1:			;how we are called?
	lodsb
	or 	al,al
	jnz	.n1
	cmp	word [esi-6],'ls'
	jz	do_lsmod

do_rmmod:
	dec	ebp
	jz	_exit	;no arguments - error

.rmmod_loop:
	pop	ebx	;take the name of the module
	sys_delete_module
	test	eax,eax
	js	_exit
	dec	ebp
	jnz	.rmmod_loop

_exit:
	sys_exit eax

do_lsmod:
	sys_open filename,O_RDONLY
	mov	ebp,eax
	test	eax,eax
	js	_exit
        sys_write STDOUT,header,hlength
	sys_read ebp,Buf,BufSize
	sys_write STDOUT,EMPTY,eax
;	sys_close ebp
	jmps	_exit

filename	db	"/proc/modules",EOL

UDATASEG

Buf	resb	BufSize

END
