; Copyright (C) Tiago Gasiba (ee97034@fe.up.pt)
;
; $Id: clear.asm,v 1.1 2001/08/24 09:47:28 konst Exp $
;
; syntax: clear

%include "system.inc"

CODESEG
clear_string	db	0x1b,"[H",0x1b,"[J"
clear_string_len	equ	$-clear_string

START:
	sys_write	STDOUT,clear_string,clear_string_len
	sys_exit	0
END
