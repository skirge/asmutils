;Copyright (C) 2001 Jani Monoses <jani@astechnix.ro>
;
;$Id: ifconfig.asm,v 1.3 2002/02/02 08:49:25 konst Exp $
;
;hackers' ifconfig/route
;
;syntax: ifconfig interface [ip_address] [netmask net_address] 
;				[broadcast brd_address] [up] [down]
;
;	 
;	 route [ add | del ] [ -net | -host ] ip_address 
;				[netmask net_address] [gw gw_address] [dev interface] 
;
;only tested on linux 2.4 with ethernet & loopback
;
; 
;TODO ?:	print interface status/routing table
;	  	set hw addresses (hw ether)
;		other flags (arp,promisc)
		


;route and interface flags

%assign	RTF_UP		1
%assign RTF_GATEWAY	2
%assign RTF_HOST	4

%assign	IFF_UP		1		


%include "system.inc"

CODESEG

START:
	pop		ebp					;get argument count
	dec		ebp
	dec		ebp
	jle		.exit1					;if argc <= 2 bail out	

	sys_socket	AF_INET,SOCK_DGRAM,IPPROTO_IP		;subject to ioctls
	mov		dword [sockfd],eax			;save sock descr

	pop		esi					;program name

.findlast:							;ifconfig or route?	
	lodsb
	or		al,al
	jnz		.findlast
	cmp		byte[esi-2],'e'
	jz		near .route


;
;	ifconfig part
;
.ifconfig:


	pop		esi					;interface name
	mov		edi,ifreq				
	_mov		ecx,16					;max name length
	repne		movsb					;put if name in ifreq


.argloop:
	dec		ebp
	jl		.exit
	pop		esi

	cmp		byte[esi],"9"
	jle		.ipaddr

	cmp		byte[esi],"b"				; 'broadcast' 
	jnz		.netm

	pop		esi
	dec		ebp
	mov		edi,addr
	call		.ip2int
	mov		word[flags],AF_INET
	mov		ecx,SIOCSIFBRDADDR
	jmps		.ioctl

;ignore "hw ether" for now
;	cmp		byte[esi],"h"
;	jz		.ignore2	

.exit1:
	jmps		.exit
.netm:
	cmp		byte[esi],"n"
	jnz		.updown
	pop		esi
	dec		ebp	
	mov		edi,addr
	call		.ip2int
	mov		word[flags],AF_INET

	_mov		ecx,SIOCSIFNETMASK
.ioctl:
	call		.do_ioctl
	jmps		.argloop

;.ignore2:
;	pop		esi
;	dec		ebp
;	pop		esi
;	dec		ebp
;	jmps		.argloop	

.do_ioctl:
	mov		ebx, dword [sockfd]
	sys_ioctl	EMPTY,EMPTY,ifreq	
	ret
.exit:
	sys_exit
.ipaddr:
	mov		edi,addr
	call		.ip2int
	mov		word[flags],AF_INET

	_mov		ecx,SIOCSIFADDR
	call		.do_ioctl


;"up" or "down"
.updown:
	_mov		ecx,SIOCGIFFLAGS			;get interface flags 
	call		.do_ioctl
	and		byte[flags],~IFF_UP
	cmp		byte[esi],"d"				;interface down 
	jz		.setf		
	or		byte[flags],IFF_UP	
.setf:
	_mov		ecx,SIOCSIFFLAGS			;set interface flags 
	jmps		.ioctl	 


;convert IP number pointed to by esi to dword pointed to by edi
;for invalid IP number the result is 0 (so that default == 0.0.0.0 for route)

.ip2int:
	xor		eax,eax
	xor		ecx,ecx	
.cc:	
	xor		edx,edx
.c:	
	lodsb
	sub		al,'0'
	jb		.next
	cmp		al,'a'-'0'
	jae		.next
	imul		edx,byte 10
	add		edx,eax
	jmp		short .c	
.next:
	mov		[edi+ecx],dl
	inc		ecx
	cmp		ecx, byte 4
	jne		.cc
	ret	

;
;	route part
;

.route:

	or		byte[route_flags], RTF_HOST 

	_mov		ebx,SIOCADDRT
	pop		esi
	cmp		byte[esi],'a'			; 'add' or 'del' ?
	jz		.routeargs
	_mov		ebx,SIOCDELRT
.routeargs:
	dec		ebp
	jl		.doit				;if no more args proceed
	pop		esi
	cmp		word[esi], '-n'			; '-net'
	jnz		.l1
	and		byte[route_flags], ~RTF_HOST
.l1:
	cmp		word[esi], '-h'			; '-host'
	jz		.routeargs

	cmp		byte[esi], 'g'			; 'gw'
	jnz		.l2
	or		byte[route_flags], RTF_GATEWAY
	mov		edi, gw
	jmps 		.helper
.l2:
	cmp		byte[esi], 'n'			; 'netmask'
	jnz		.l3
	mov		edi, genmask
	jmps		.helper
.l3:
	cmp		word[esi+1],'ev'		; 'dev' 
	jnz		.l4
	pop		esi
	dec		ebp	
	mov		dword[dev],esi
	jmps		.routeargs
.l4:
	mov		edi,dst				; destination
	mov		word[edi], AF_INET
	_add		edi, 4
	cmp		byte[esi], 'd'			; 'default'
	jnz		.l5
	and		byte[route_flags], ~RTF_HOST
.l5:
	call		.ip2int
	jmps		.routeargs
	
.doit:	
	push		ebx
	pop		ecx
	mov		ebx, dword [sockfd]
	sys_ioctl	EMPTY,EMPTY,rtentry

	jmp		.exit 			

.helper:
	pop		esi
	dec		ebp	
	mov		word[edi], AF_INET
	_add		edi, 4
	jmps		.l5


UDATASEG
	sockfd		resd	1
	
;this corresponds to struct ifreq
	ifreq:		resb	16	;interface name
	flags:		resb	2	;flags | start of sockaddr_in
	port:		resb	2	;
	addr:		resb	4	;IP address
	unused:		resb	8	;padding in sockaddr_in

;this corresponds to struct rtentry
	rtentry:	resb	4
	dst:		resb	16	
	gw:		resb	16
	genmask:	resb	16
	route_flags:	resb	2
	unused2:	resb	14	;dword align while skipping some fields
	dev:		resb	4	;interface name
;	we don't care about the rest of it	
END
