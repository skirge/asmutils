;Copyright (C) 1999-2001 Konstantin Boldyshev <konst@linuxassembly.org>
;
;$Id: asmutils.asm,v 1.5 2001/01/21 15:18:46 konst Exp $
;
;asmutils multicall binary
;
;0.03: 17-Jan-2001	initial public release

%include "system.inc"

CODESEG

names:

dd	"arch",	_uname
dd	"base",	_basename
dd	"echo",	_echo
dd	"fact",	_factor
dd	"fals",	_true
dd	"kill",	_kill
dd	"pwd",	_pwd
dd	"slee",	_sleep
dd	"sync",	_sync
dd	"tee",	_tee
dd	"true",	_true
dd	"unam",	_uname
dd	"yes",	_yes

START:
	push	eax
	pusha
	mov	esi,[esp + 4*9 + 4]
	mov	ebx,esi
.n1:
	lodsb
	or 	al,al
	jnz	.n1
.n2:
	dec	esi
	cmp	ebx,esi
	jz	.n3
	cmp	byte [esi],'/'	
	jnz	.n2
	inc	esi	
.n3:

	xor	ebx,ebx
.find_name:
	mov	eax,[ebx + names]
	or	eax,eax
	jz	.exit
	cmp	eax,[esi]
	jz	.run_it
	add	ebx,byte 8
	jmps	.find_name

.run_it:
	
	mov	eax,[ebx + names + 4]
	mov	[esp + 4*9],eax
	popa
	add	esp,byte 4
	ret

.exit:

	sys_write STDOUT, poem, length
	sys_exit 0

;
;
;

poem	db	__n
	db	"this is not a nasty bug",__n
	db	"this is just a cool loopback",__n,__n
	db	__t,"- an ancient assembly poem -",__n
	db	__t,"(by an ancient assembly poet)",__n,__n
	db	"well, it will work as needed. really. "
	db	"a bit later.. be patient.",__n,__n
length	equ	$-poem

_uname:
_basename:
_echo:
_factor:
_true:
_kill:
_pwd:
_sleep:
_sync:
_tee:
_yes:

	sys_exit 1

END
