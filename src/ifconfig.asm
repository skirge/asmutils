;Copyright (C) 2001 Jani Monoses <jani@astechnix.ro>
;
;$Id: ifconfig.asm,v 1.1 2001/08/27 15:41:08 konst Exp $
;
;hackers' ifconfig
;
;syntax: ifconfig interface [ip_address] [netmask net_address] [up] [down]
;
;	 much like 'normal' ifconfig, order of args is not fixed
;	 no other args supported (yet) 
;	 
;
;only tested on linux 2.4 with ethernet & loopback
; 
;TODO ?:	print interface status
;	  	set hw addresses (hw ether)
;		other flags (arp,promisc,broadcast)
		
%include "system.inc"

CODESEG

START:
	pop		ebx					;get argument count
	dec		ebx
	mov		byte[argc],bl
	dec		ebx
	jle		near .exit				;if argc <= 2 bail out	
	pop		esi					;program name

	pop		esi					;interface name
	mov		edi,ifreq				
	mov		ecx,16					;max name length

	repne		movsb					;put if name in ifreq

	sys_socket	AF_INET,SOCK_DGRAM,IPPROTO_IP		;subject to ioctls
	mov		ebp,eax					;save sock descr
	

.argloop:
	dec		byte[argc]
	jz		.exit
	pop		esi

	cmp		byte[esi],"9"
	jle		.ipaddr

;ignore "broadcast" for now
	cmp		byte[esi],"b"
	jz		.ignore1	
;ignore "hw ether" for now
	cmp		byte[esi],"h"
	jz		.ignore2	

	cmp		byte[esi],"n"
	jnz		.updown
	pop		esi
	dec		byte[argc]
	mov		edi,addr
	call		.ip2int
	mov		word[flags],AF_INET

	sys_ioctl	ebp,SIOCSIFNETMASK,ifreq

	jmps		.argloop

.ignore2:
	pop		esi
	dec		byte[argc]
.ignore1:
	pop		esi
	dec		byte[argc]
	jmps		.argloop	
.exit:
	sys_exit
		
.ipaddr:
	mov		edi,addr
	call		.ip2int
	mov		word[flags],AF_INET

	sys_ioctl	ebp,SIOCSIFADDR,ifreq


;"up" or "down"
.updown:
	sys_ioctl	ebp,SIOCGIFFLAGS,ifreq			;get interface flags
	and		word[flags],0xfffe
	cmp		byte[esi],"d"				;interface down 
	jz		.setf		
	or		word[flags],1	
.setf:
	sys_ioctl	ebp,SIOCSIFFLAGS,ifreq			;set interface flags 
	jmp		.argloop	 


.ip2int:
	xor		eax,eax
	xor		ecx,ecx	
.cc:	
	xor		edx,edx
.c:	
	lodsb
	sub		al,'0'
	jb		.next
	imul		edx,byte 10
	add		edx,eax
	jmp		short .c	
.next:
	mov		[edi+ecx],dl
	inc		ecx
	cmp		ecx, byte 4
	jne		.cc
	ret	

UDATASEG
	argc		resb	1
	ifreq:		resb	16
	flags:		resb	2	
	p:		resb	2
	addr:		resb	4
END
