;Copyright (C) 1999-2001 Konstantin Boldyshev <konst@linuxassembly.org>
;
;$Id: mount.asm,v 1.5 2001/12/09 15:12:15 konst Exp $
;
;hackers' mount/umount
;
;syntax: mount [-o options] [-t type] device mountpoint
;	 umount mountpoint
;
;example: mount -o ro,noexec -t vfat /dev/hda1 /c
;	  umount /mnt
;
;0.01: 04-Jul-1999	initial release
;0.02: 19-Feb-2001      added options support & listing of mounted devices (RM)
;0.03: 09-Dec-2001	rewritten to resemble usual mount, *BSD port (KB)
;
;NOTES:
;1) mount arguments must be exactly in above written order
;2) BSD version requires -t argument
;3) only generic mount options are implemented, you may add your own if needed

%include "system.inc"

%assign	BUFSIZE	0x2000

CODESEG

START:
	pop	ecx		;argc
	dec	ecx
	jz	.list_mounted

	pop	esi
	pop	ebx

.n1:				;find out our name
	lodsb
	or 	al,al
	jnz	.n1
	cmp	byte [esi-7],'u'
	jnz	.mount

	xor	ecx,ecx
	sys_umount

.exit:  
	sys_exit eax

;
;display /proc/mounts or /etc/mtab
;

.list_mounted:

	sys_open lname1,O_RDONLY
	test	eax,eax
	jns	.l0
	sys_open lname2
	test	eax,eax
	js	.exit
.l0:
	sys_read eax,buf,BUFSIZE
	sys_write STDOUT,EMPTY,eax
	xor 	eax,eax   		;good end 
	jmps	.exit

;
;
;

.mount:
	cmp	cl,2
	jb	.list_mounted

	cmp	word [ebx],"-o"
	jnz	.m1

	pop	ebp		;options to parse
.options:
	mov	esi,ebp
.o0:
	lodsb
	cmp	al,','
	jz	.o1
	or	al,al
	jnz	.o0

	inc	byte [buf]	;indicate that this is the last option

.o1:
	mov	ebx,esi
	sub	ebx,ebp
	dec	ebx

	mov	ecx,MOUNT_OPTIONS_SIZE		;compare with all options
	mov	edx,mount_options
.o2:
	pusha
	mov	esi,ebp
	mov	edi,[edx]
	mov	ecx,ebx
	rep	cmpsb
	popa
	jnz	.o3
	mov	eax,[edx + 4]
	or	[flag],eax
	jmps	.onext
.o3:
	add	edx,byte 8	
	loop	.o2

.onext:
	mov	ebp,esi
	cmp	byte [buf],1
	jnz	.options

.m0:
	pop	ebx
.m1:	
	cmp	word [ebx],"-t"
	jnz	.do_mount

	pop	edx		;fstype
	pop	ebx		;device
	
.do_mount:
	pop	ecx		;mountpoint

%ifdef	__BSD__
	mov	[buf],ebx	;void *data points to structure, where char* is the first
	mov	ebx,edx		;fstype
	mov	esi,buf		;data
	mov	edx,[flag]	;flags
%else
	mov	esi,[flag]
	xor	edi,edi
%endif

;for pre 0.97 version of mount there should be in high word of flags
;magic MSC_MGC_VAL dont know which kernel need this 

	sys_mount
	jmp	.exit

mount_options:

dd	.ro,		MS_RDONLY
dd	.nosuid,	MS_NOSUID
dd	.nodev,		MS_NODEV
dd	.noexec,	MS_NOEXEC
dd	.sync,		MS_SYNCHRONOUS
dd	.remount,	MS_REMOUNT
dd	.noatime,	MS_NOATIME

MOUNT_OPTIONS_SIZE equ (($ - mount_options) / 8)

.ro		db	"ro",EOL
.nosuid		db	"nosuid",EOL
.nodev		db	"nodev",EOL
.noexec		db	"noexec",EOL
.sync		db	"sync",EOL
.remount	db	"remount",EOL
.noatime	db	"noatime",EOL

lname1	db	"/proc/mounts",EOL
lname2	db	"/etc/mtab",EOL

UDATASEG

flag	resd	1
buf	resb	BUFSIZE

END
