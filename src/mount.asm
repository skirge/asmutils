;Copyright (C) 1999 Konstantin Boldyshev <konst@voshod.com>
;
;$Id: mount.asm,v 1.1 2000/01/26 21:19:42 konst Exp $
;
;hackers' mount/umount
;
;0.01: 04-Jul-1999	initial release
;
;syntax: mount device dir [fstype]
;	 umount device
;
;example: mount /dev/hda1 /c vfat
;	  umount /dev/hdb3
;
;quite dumb version

%include "system.inc"

CODESEG

START:
	pop	esi
	pop	esi
.n1:
	lodsb
	or 	al,al
	jnz	.n1
	pop	ebx
	or	ebx,ebx
	jz	.exit
	cmp	byte [esi-7],'u'
	jnz	.mount
	sys_umount
.exit:
	sys_exit eax

.mount:
	pop	ecx
	or	ecx,ecx
	jz	.exit
	pop	edx
	sys_mount
	jmp short .exit

END
