;Copyright (C) 1999 Konstantin Boldyshev <konst@voshod.com>
;
;$Id: reboot.asm,v 1.1 2000/01/26 21:19:51 konst Exp $
;
;hackers' reboot/halt/poweroff
;
;0.01: 04-Jul-1999	initial release
;
;syntax: reboot
;	 halt
;	 poweroff
;
;WARNING: current version is dumb !!! It doesnot call shutdown,
;	  it does actual reboot. You have been warned.


%include "system.inc"

CODESEG

START:
	pop	esi
	pop	esi
.n1:
	lodsb
	or 	al,al
	jnz	.n1
	pop	eax
	mov	ebx,LINUX_REBOOT_MAGIC1
	mov	ecx,LINUX_REBOOT_MAGIC2
	mov	edx,LINUX_REBOOT_CMD_RESTART
	cmp	dword [esi-5],'halt'		;halt
	jnz	.poweroff
	mov	edx,LINUX_REBOOT_CMD_HALT
.poweroff:
	cmp	word [esi-3],'ff'		;poweroff
	jnz	.reboot
	mov	edx,LINUX_REBOOT_CMD_POWER_OFF
.reboot:
	sys_reboot
	sys_exit

END
