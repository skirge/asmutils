;Copyright (C) 1999 Indrek Mandre <indrek.mandre@tallinn.ee>
;
;$Id: lsmod.asm,v 1.1 2000/01/26 21:19:40 konst Exp $
;
;hackers' lsmod
;
;0.01: 17-Jun-1999	initial release
;0.02: 04-Jul-1999	fixed bug with 2.0 kernel
;
;syntax: lsmod
;
;Just open /proc/modules, print header and the data inside that file

%include "system.inc"

CODESEG

%if KERNEL = 20
    header	db	'Module         Pages    Used by',0x0A
    hlength	equ	$-header
%elif KERNEL = 22
    header	db	'Module                  Size  Used by',0x0A,0
    hlength	equ	$-header
%endif

START:
%if KERNEL = 20
	_mov	edi,1
	sys_open filename,O_RDONLY
%elif KERNEL = 22
	inc	edi
	sys_open filename
%endif
	mov	ebp,eax
	test	eax,eax
	js	.exit
        sys_write STDOUT,header,hlength
	_mov	ecx,Buf
.backloop:
	_mov	edx,0xff
	sys_read ebp
	mov	edx,eax
	sys_write STDOUT
	or	edx,edx
	jnz	.backloop
;	sys_close ebp
	dec	edi
.exit:
	sys_exit edi

filename	db	"/proc/modules",NULL

UDATASEG

BufSize	equ	0xFF
Buf	resb	BufSize

END
