;Copyright (C) 1999-2000 Konstantin Boldyshev <konst@linuxassembly.org>
;
;$Id: asmutils.asm,v 1.3 2000/03/02 08:52:01 konst Exp $
;
;asmutils multicall binary

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

.exit:
	sys_exit
