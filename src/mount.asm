;Copyright (C) 1999 Konstantin Boldyshev <konst@linuxassembly.org>
;
;$Id: mount.asm,v 1.3 2001/03/18 07:08:25 konst Exp $
;
;hackers' mount/umount
;
;syntax: mount device dir [fstype] [next options....]
;	 umount device
;
;example: mount /dev/hda1 /c vfat ro   
;	  umount /dev/hdb3
;
;avaiable options:
;
;ro	Mount read-only				(MS_RDONLY	1)
;ns	Ignore suid and sgid bits		(MS_NOSUID	2)
;nd	Disallow access to device special files (MS_NODEV	4)
;ne	Disallow program execution		(MS_NOEXEC	8)
;sy	Writes are synced at once  		(MS_SYNCHRONOUS	16)
;re	Alter flags of a mounted FS		(MS_REMOUNT	32)
;ml	Allow mandatory locks on an FS		(MS_MANDLOCK	64)
;na	Do not update access times		(MS_NOATIME	1024)
;ni	Do not update directory access times	(MS_NODIRATIME	2048)
;bi	Who knows ? 				(MS_BIND	4096)
;
;0.01: 04-Jul-1999	initial release
;0.02: 19-Feb-2001      added options support & listing of mounted devices (RM)

%include "system.inc"

%assign	BufSize	0x2000 ;we have 4KB anyway

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
	jz	.list_mounted
	cmp	byte [esi-7],'u'
	jnz	.mount
	sys_umount
.exit:  
	sys_exit eax
.mount:
	pop	ecx
	mov 	ebp,ecx		
	or	ecx,ecx
	jz	.exit
	pop	edx
	xor 	esi,esi
.next_arg:
	pop     edi
	or	edi,edi
	jz 	.do_mount  	;we don't have any special wishes..
	movzx 	eax,word [edi]  
	mov 	edi,options	
	mov 	ecx,(options_len/2)+1
	repnz
	scasw
	or 	ecx,ecx
	jz 	.not_found
	mov 	eax,options_len/2
	sub 	eax,ecx
	xchg 	ecx,eax
	xor 	eax,eax
	inc 	eax
	shl 	eax,cl
	or  	esi,eax		;set flag
.not_found:			;unknown option
	mov 	ecx,ebp
	jmp short .next_arg	
	
.do_mount:
	sys_mount		; for pre 0.97 version of mount  
	jmp short .exit		; there should be in high word of flags magic MSC_MGC_VAL
				;dont know which kernel need this 
	
.list_mounted:         		;Stolen from lsmod

	sys_open filename,O_RDONLY
	mov	ebp,eax
	test	eax,eax
	js	.exit
	sys_read ebp,Buf,BufSize
	sys_write STDOUT,EMPTY,eax
;	sys_close ebp 			;system will do dirty work :)
	xor 	eax,	eax   		;good end 
	jmps	.exit

options	db	'ronsndnesyremlnanibi' ;compressed options the sequence exactly match bits flags
options_len 	equ $-options

filename	db	"/proc/mounts",EOL

UDATASEG

Buf	resb	BufSize

END
