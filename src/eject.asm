;Copyright (C) 1999 Bart Hanssens <antares@mail.dma.be>
;
;$Id: eject.asm,v 1.1 2000/01/26 21:19:23 konst Exp $
;
;hackers' eject (eject CD-ROM)
;
;0.01: 29-Jul-1999	initial release
;
;syntax: eject [device]
;
;if no device is given, use /dev/cdrom


%include "system.inc"

%assign	CDROMEJECT	0x5309

CODESEG

START:
	mov	ebx,default_dev
	pop	eax
	dec	eax
	jz	.eject
.get_dev:
	pop	ebx
	pop	ebx
.eject:
	sys_open EMPTY,O_RDONLY|O_NONBLOCK
	test	eax,eax
	js	.exit
	sys_ioctl eax,CDROMEJECT
.exit:
	sys_exit

default_dev	db	"/dev/cdrom"	;,NULL

END
