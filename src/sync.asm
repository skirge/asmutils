;Copyright (C) 1999 Konstantin Boldyshev <konst@voshod.com>
;
;$Id: sync.asm,v 1.1 2000/01/26 21:20:00 konst Exp $
;
;hackers' sync
;
;0.01: 05-Jun-1999	initial release
;0.02: 17-Jun-1999	size improvements
;
;syntax: sync

%include "system.inc"

CODESEG

START:
;right way
;	sys_sync			
;	sys_exit

;shorter way :)

	mov	al,__NR_sync
	__syscall

	mov	al,__NR_exit
	__syscall

END
