; Copyright (C) 1999-2000 Konstantin Boldyshev <konst@linuxassembly.org>
;
; $Id: includes.inc,v 1.1 2000/09/03 16:13:53 konst Exp $
;
; file          : includes.inc
; created       : 04-Jul-1999
; modified      : 03-Sep-2000
; version       : 0.10
; assembler     : nasm 0.98
; description   : generic constants and structures from header files (libc)
; author        : Konstantin Boldyshev <konst@linuxassembly.org>
; comment       : included internally from system.inc

%ifndef	__SYSTEM_INC
%error "this file must be included internally from system.inc !"
%endif

%ifndef __INCLUDES_INC
%define __INCLUDES_INC

%assign	NULL	0

%assign TRUE	1
%assign FALSE	0

%assign	STDIN	0
%assign	STDOUT	1
%assign	STDERR	2

%assign	EOL	0

%assign	__a	0x07
%assign	__b	0x08
%assign	__e	0x1b
%assign	__f	0x0c
%assign	__n	0x0a
%assign	__r	0x0d
%assign	__t	0x09
%assign	__v	0x0b
%assign	__s	0x20

;
;datatypes
;

%define		INT		resd
%define		UINT		resd
%define		LONG		resd
%define		ULONG		resd
%define 	SHORT		resw
%define		USHORT		resw
%define		CHAR		resb
%define		UCHAR		resb
%define		BYTE		resb
%define		WORD		resw
%define		DWORD		resd
%define		U8		resb
%define		U16		resw
%define		U32		resd

%define		_INT		dd
%define		_UINT		dd
%define		_LONG		dd
%define		_ULONG		dd
%define 	_SHORT		dw
%define		_USHORT		dw
%define		_CHAR		db
%define		_UCHAR		db
%define		_BYTE		db
%define		_WORD		dw
%define		_DWORD		dd
%define		_U8		db
%define		_U16		dw
%define		_U32		dd


;
;please provide corresponding include file when adding new entries
;

;
;fcntl.h
;

%assign SEEK_SET	0
%assign SEEK_CUR	1
%assign SEEK_END	2

%assign O_RDONLY	0
%assign O_WRONLY	1
%assign O_RDWR		2
%assign O_ACCMODE	3
%assign O_CREAT		100q
%assign O_EXCL		200q
%assign O_NOCTTY	400q
%assign O_TRUNC		1000q
%assign O_APPEND	2000q
%assign O_NONBLOCK	4000q
%assign O_NDELAY	O_NONBLOCK
%assign O_SYNC		 10000q
%assign FASYNC		 20000q
%assign O_DIRECT	 40000q
%assign O_LARGEFILE	100000q
%assign O_DIRECTORY	200000q
%assign O_NOFOLLOW	400000q

%assign F_DUPFD		0	;Duplicate file descriptor
%assign F_GETFD		1	;Get file descriptor flags
%assign F_SETFD		2	;Set file descriptor flags
%assign F_GETFL		3	;Get file status flags
%assign F_SETFL		4	;Set file status flags
%assign F_GETLK		5	;Get record locking info
%assign F_SETLK		6	;Set record locking info (non-blocking)
%assign F_SETLKW	7	;Set record locking info (blocking)


;
;unistd.h
;

%assign	R_OK	4	; read
%assign W_OK	2	; write
%assign X_OK	1	; execute
%assign F_OK	0	; existence

;
;signal.h
;

%assign SIG_DFL		0
%assign SIG_IGN		1
%assign SIG_ERR		-1

%assign	SIGHUP		1	; Hangup (POSIX)
%assign	SIGINT		2	; Interrupt (ANSI)
%assign	SIGQUIT		3	; Quit (POSIX)
%assign	SIGILL		4	; Illegal instruction (ANSI)
%assign	SIGTRAP		5	; Trace trap (POSIX)
%assign	SIGABRT		6	; Abort (ANSI)
%assign	SIGIOT		6	; IOT trap (4.2 BSD)
%assign	SIGBUS		7	; BUS error (4.2 BSD)
%assign	SIGFPE		8	; Floating-point exception (ANSI)
%assign	SIGKILL		9	; Kill, unblockable (POSIX)
%assign	SIGUSR1		10	; User-defined signal 1 (POSIX)
%assign	SIGSEGV		11	; Segmentation violation (ANSI)
%assign	SIGUSR2		12	; User-defined signal 2 (POSIX)
%assign	SIGPIPE		13	; Broken pipe (POSIX)
%assign	SIGALRM		14	; Alarm clock (POSIX)
%assign	SIGTERM		15	; Termination (ANSI)
%assign	SIGSTKFLT	16	; Stack fault
%assign	SIGCHLD		17	; Child status has changed (POSIX)
%assign	SIGCLD		SIGCHLD	; Same as SIGCHLD (System V)
%assign	SIGCONT		18	; Continue (POSIX)
%assign	SIGSTOP		19	; Stop, unblockable (POSIX)
%assign	SIGTSTP		20	; Keyboard stop (POSIX)
%assign	SIGTTIN		21	; Background read from tty (POSIX)
%assign	SIGTTOU		22	; Background write to tty (POSIX)
%assign	SIGURG		23	; Urgent condition on socket (4.2 BSD)
%assign	SIGXCPU		24	; CPU limit exceeded (4.2 BSD)
%assign	SIGXFSZ		25	; File size limit exceeded (4.2 BSD)
%assign	SIGVTALRM	26	; Virtual alarm clock (4.2 BSD)
%assign	SIGPROF		27	; Profiling alarm clock (4.2 BSD)
%assign	SIGWINCH	28	; Window size change (4.3 BSD, Sun)
%assign	SIGIO		29	; I/O now possible (4.2 BSD)
%assign	SIGPOLL		SIGIO	; Pollable event occurred (System V)
%assign	SIGPWR		30	; Power failure restart (System V)
%assign SIGUNUSED	31
%assign	_NSIG		64	; Biggest signal number + 1

;
;wait.h
;

%assign WNOHANG		1
%assign WUNTRACED	2

;
;sys/mount.h
;

%define MS_RDONLY	1
%define MS_MGC_VAL	0xc0ed0000

;
;sys/socket.h
;

%assign AF_UNSPEC	0
%assign AF_UNIX		1	; Unix domain sockets
%assign AF_LOCAL	1	; POSIX name for AF_UNIX
%assign AF_INET		2	; Internet IP Protocol
%assign AF_AX25		3	; Amateur Radio AX.25
%assign AF_IPX		4	; Novell IPX
%assign AF_APPLETALK	5	; AppleTalk DDP
%assign AF_NETROM	6	; Amateur Radio NET/ROM
%assign AF_BRIDGE	7	; Multiprotocol bridge
%assign AF_ATMPVC	8	; ATM PVCs
%assign AF_X25		9	; Reserved for X.25 project
%assign AF_INET6	10	; IP version 6
%assign AF_ROSE		11	; Amateur Radio X.25 PLP
%assign AF_DECnet	12	; Reserved for DECnet project
%assign AF_NETBEUI	13	; Reserved for 802.2LLC project
%assign AF_SECURITY	14	; Security callback pseudo AF
%assign AF_KEY		15	; PF_KEY key management API
%assign AF_NETLINK	16
%assign AF_ROUTE	AF_NETLINK 	; Alias to emulate 4.4BSD
%assign AF_PACKET	17	; Packet family
%assign AF_ASH		18	; Ash
%assign AF_ECONET	19	; Acorn Econet
%assign AF_ATMSVC	20	; ATM SVCs
%assign AF_SNA		22	; Linux SNA Project (nutters!)
%assign AF_IRDA		23	; IRDA sockets
%assign AF_MAX		32	; For now..

%assign PF_UNSPEC	AF_UNSPEC
%assign PF_UNIX		AF_UNIX
%assign PF_LOCAL	AF_LOCAL
%assign PF_INET		AF_INET
%assign PF_AX25		AF_AX25
%assign PF_IPX		AF_IPX
%assign PF_APPLETALK	AF_APPLETALK
%assign	PF_NETROM	AF_NETROM
%assign PF_BRIDGE	AF_BRIDGE
%assign PF_ATMPVC	AF_ATMPVC
%assign PF_X25		AF_X25
%assign PF_INET6	AF_INET6
%assign PF_ROSE		AF_ROSE
%assign PF_DECnet	AF_DECnet
%assign PF_NETBEUI	AF_NETBEUI
%assign PF_SECURITY	AF_SECURITY
%assign PF_KEY		AF_KEY
%assign PF_NETLINK	AF_NETLINK
%assign PF_ROUTE	AF_ROUTE
%assign PF_PACKET	AF_PACKET
%assign PF_ASH		AF_ASH
%assign PF_ECONET	AF_ECONET
%assign PF_ATMSVC	AF_ATMSVC
%assign PF_SNA		AF_SNA
%assign PF_IRDA		AF_IRDA
%assign PF_MAX		AF_MAX

%assign SOCK_STREAM    1	;stream (connection) socket
%assign SOCK_DGRAM     2	;datagram (conn.less) socket
%assign SOCK_RAW       3	;raw socket
%assign SOCK_RDM       4	;reliably-delivered message
%assign SOCK_SEQPACKET 5	;sequential packet socket
%assign SOCK_PACKET    10	;linux specific way of getting packets at the dev level

%assign IPPROTO_IP		0		; Dummy protocol for TCP
%assign IPPROTO_HOPOPTS		0		; IPv6 Hop-by-Hop options
%assign IPPROTO_ICMP		1		; Internet Control Message Protocol
%assign IPPROTO_IGMP		2		; Internet Group Management Protocol
%assign IPPROTO_IPIP		4		; IPIP tunnels (older KA9Q tunnels use 94)
%assign IPPROTO_TCP		6		; Transmission Control Protocol
%assign IPPROTO_EGP		8		; Exterior Gateway Protocol
%assign IPPROTO_PUP		12		; PUP protocol
%assign IPPROTO_UDP		17		; User Datagram Protocol
%assign IPPROTO_IDP		22		; XNS IDP protocol
%assign IPPROTO_TP		29		; SO Transport Protocol Class 4
%assign IPPROTO_IPV6		41		; IPv6 header
%assign IPPROTO_ROUTING		43		; IPv6 routing header
%assign IPPROTO_FRAGMENT 	44		; IPv6 fragmentation header
%assign IPPROTO_RSVP		46		; Reservation Protocol
%assign IPPROTO_GRE		47		; General Routing Encapsulation
%assign IPPROTO_ESP		50		; encapsulating security payload
%assign IPPROTO_AH		51		; authentication header
%assign IPPROTO_ICMPV6		58		; ICMPv6
%assign IPPROTO_NONE		59		; IPv6 no next header
%assign IPPROTO_DSTOPTS		60		; IPv6 destination options
%assign IPPROTO_MTP		92		; Multicast Transport Protocol
%assign IPPROTO_ENCAP		98		; Encapsulation Header
%assign IPPROTO_PIM		103		; Protocol Independent Multicast
%assign IPPROTO_RAW		255		; Raw IP packets

%ifdef __LIBC__

;
;sys/socket.h
;

%assign	SOL_SOCKET	1

%assign SO_DEBUG	1
%assign SO_REUSEADDR	2
%assign SO_TYPE		3
%assign SO_ERROR	4
%assign SO_DONTROUTE	5
%assign SO_BROADCAST	6
%assign SO_SNDBUF	7
%assign SO_RCVBUF	8
%assign SO_KEEPALIVE	9
%assign SO_OOBINLINE	10
%assign SO_NO_CHECK	11
%assign SO_PRIORITY	12
%assign SO_LINGER	13
%assign SO_BSDCOMPAT	14
%assign SO_REUSEPORT	15
%assign SO_PASSCRED	16
%assign SO_PEERCRED	17
%assign SO_RCVLOWAT	18
%assign SO_SNDLOWAT	19
%assign SO_RCVTIMEO	20
%assign SO_SNDTIMEO	21

%endif

;
;time.h
;

struc timespec
.tv_sec		ULONG	1
.tv_nsec	ULONG	1
endstruc

struc timeval
.tv_sec		ULONG	1
.tv_usec	ULONG	1
endstruc

;
;sys/utsname.h
;

%ifdef __BSD__
%assign SYS_NMLN 32
%assign MAXHOSTNAMELEN 256
%else
%assign SYS_NMLN 65
%assign MAXHOSTNAMELEN SYS_NMLN - 1
%endif

struc utsname
.sysname	CHAR	SYS_NMLN
.nodename	CHAR	SYS_NMLN
.release	CHAR	SYS_NMLN
.version	CHAR	SYS_NMLN
.machine	CHAR	SYS_NMLN
.domainname	CHAR	SYS_NMLN
endstruc

;
;socket.h
;

struc	sockaddr
.sa_family_t	USHORT	1		;address family, AF_xxx
.sa_data	CHAR	14		;14 bytes of protocol address
endstruc

;
;in.h
;

struc in_addr
.s_addr		U32	1
endstruc

%endif	;__INCLUDES_INC
