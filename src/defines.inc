; Copyright (C) 1999-2000 Konstantin Boldyshev <konst@voshod.com>
; Copyright (C) 1999 Indrek Mandre <indrek.mandre@tallinn.ee>
;
; $Id: defines.inc,v 1.2 2000/02/01 19:56:20 konst Exp $
;
; file          : defines.inc
; created       : 04-Jul-1999
; modified      : 27-Jan-2000
; version       : 0.06
; assembler     : nasm 0.98
; description   : kernel and libc defined constants (from includes)
; author        : Indrek Mandre <indrek.mandre@tallinn.ee>
; comment       : included internally from system.inc

%ifdef	__SYSTEM_INC

%ifndef __DEFINES_INC
%define __DEFINES_INC

%assign	NULL	0

%assign TRUE	1
%assign FALSE	0

%assign	STDIN	0
%assign	STDOUT	1
%assign	STDERR	2

%assign	__n	0xa
%assign	__r	0xd
%assign	__t	0x9
%assign	__spc	0x20

;
;please provide corresponding include file when adding new entries
;


;
;fcntl.h
;

%assign SEEK_SET	0
%assign SEEK_CUR	1
%assign SEEK_END	2

;
;unistd.h
;

%assign	R_OK	4	; read
%assign W_OK	2	; write
%assign X_OK	1	; execute
%assign F_OK	0	; existence

;
;asm/fcntl.h
;

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

;
;asm/signal.h
;

%assign SIG_DFL		0
%assign SIG_IGN		1
%assign SIG_ERR		-1

%assign SIGHUP		1
%assign SIGINT		2
%assign SIGQUIT		3
%assign SIGILL		4
%assign SIGTRAP		5
%assign SIGABRT		6
%assign SIGIOT		6
%assign SIGBUS		7
%assign SIGFPE		8
%assign SIGKILL		9
%assign SIGUSR1		10
%assign SIGSEGV		11
%assign SIGUSR2		12
%assign SIGPIPE		13
%assign SIGALRM		14
%assign SIGTERM		15
%assign SIGSTKFLT	16
%assign SIGCHLD		17
%assign SIGCLD		SIGCHLD
%assign SIGCONT		18
%assign SIGSTOP		19
%assign SIGTSTP		20
%assign SIGTTIN		21
%assign SIGTTOU		22
%assign SIGURG		23
%assign SIGXCPU		24
%assign SIGXFSZ		25
%assign SIGVTALRM	26
%assign SIGPROF		27
%assign SIGWINCH	28
%assign SIGIO		29
%assign SIGPOLL		SIGIO
%assign SIGPWR		30
%assign SIGUNUSED	31

;
;linux/reboot.h
;

%assign	LINUX_REBOOT_MAGIC1	0xfee1dead
%assign	LINUX_REBOOT_MAGIC2	0x28121969
%assign	LINUX_REBOOT_MAGIC2A	85072278
%assign	LINUX_REBOOT_MAGIC2B	369367448

%assign	LINUX_REBOOT_CMD_RESTART	0x01234567	;Restart system using default command and mode.
%assign	LINUX_REBOOT_CMD_HALT		0xCDEF0123	;Stop OS and give system control to ROM monitor, if any.
%assign	LINUX_REBOOT_CMD_CAD_ON		0x89ABCDEF	;Ctrl-Alt-Del sequence causes RESTART command.
%assign	LINUX_REBOOT_CMD_CAD_OFF	0x00000000	;Ctrl-Alt-Del sequence sends SIGINT to init task.
%assign	LINUX_REBOOT_CMD_POWER_OFF	0x4321FEDC	;Stop OS and remove all power from system, if possible.
%assign	LINUX_REBOOT_CMD_RESTART2	0xA1B2C3D4	;Restart system using given command string.

;
;asm/mman.h
;

%assign PROT_READ	0x1
%assign PROT_WRITE	0x2
%assign PROT_EXEC	0x4
%assign PROT_NONE	0x0

%assign MAP_SHARED	0x01
%assign MAP_PRIVATE	0x02
%assign MAP_TYPE	0x0f
%assign MAP_FIXED	0x10
%assign MAP_ANONYMOUS	0x20

%assign MAP_GROWSDOWN	0x0100
%assign MAP_DENYWRITE	0x0800
%assign MAP_EXECUTABLE	0x1000
%assign MAP_LOCKED	0x2000
%assign MAP_NORESERVE	0x4000

;
;asm/unistd.h
;

%assign __NR_exit		1
%assign __NR_fork		2
%assign __NR_read		3
%assign __NR_write		4
%assign __NR_open		5
%assign __NR_close		6
%assign __NR_waitpid		7
%assign __NR_creat		8
%assign __NR_link		9
%assign __NR_unlink		10
%assign __NR_execve		11
%assign __NR_chdir		12
%assign __NR_time		13
%assign __NR_mknod		14
%assign __NR_chmod		15
%assign __NR_lchown		16
%assign __NR_break		17
%assign __NR_oldstat		18
%assign __NR_lseek		19
%assign __NR_getpid		20
%assign __NR_mount		21
%assign __NR_umount		22
%assign __NR_setuid		23
%assign __NR_getuid		24
%assign __NR_stime		25
%assign __NR_ptrace		26
%assign __NR_alarm		27
%assign __NR_oldfstat		28
%assign __NR_pause		29
%assign __NR_utime		30
%assign __NR_stty		31
%assign __NR_gtty		32
%assign __NR_access		33
%assign __NR_nice		34
%assign __NR_ftime		35
%assign __NR_sync		36
%assign __NR_kill		37
%assign __NR_rename		38
%assign __NR_mkdir		39
%assign __NR_rmdir		40
%assign __NR_dup		41
%assign __NR_pipe		42
%assign __NR_times		43
%assign __NR_prof		44
%assign __NR_brk		45
%assign __NR_setgid		46
%assign __NR_getgid		47
%assign __NR_signal		48
%assign __NR_geteuid		49
%assign __NR_getegid		50
%assign __NR_acct		51
%assign __NR_umount2		52
%assign __NR_lock		53
%assign __NR_ioctl		54
%assign __NR_fcntl		55
%assign __NR_mpx		56
%assign __NR_setpgid		57
%assign __NR_ulimit		58
%assign __NR_oldolduname	59
%assign __NR_umask		60
%assign __NR_chroot		61
%assign __NR_ustat		62
%assign __NR_dup2		63
%assign __NR_getppid		64
%assign __NR_getpgrp		65
%assign __NR_setsid		66
%assign __NR_sigaction		67
%assign __NR_sgetmask		68
%assign __NR_ssetmask		69
%assign __NR_setreuid		70
%assign __NR_setregid		71
%assign __NR_sigsuspend		72
%assign __NR_sigpending		73
%assign __NR_sethostname	74
%assign __NR_setrlimit		75
%assign __NR_getrlimit		76
%assign __NR_getrusage		77
%assign __NR_gettimeofday	78
%assign __NR_settimeofday	79
%assign __NR_getgroups		80
%assign __NR_setgroups		81
%assign __NR_select		82
%assign __NR_symlink		83
%assign __NR_oldlstat		84
%assign __NR_readlink		85
%assign __NR_uselib		86
%assign __NR_swapon		87
%assign __NR_reboot		88
%assign __NR_readdir		89
%assign __NR_mmap		90
%assign __NR_munmap		91
%assign __NR_truncate		92
%assign __NR_ftruncate		93
%assign __NR_fchmod		94
%assign __NR_fchown		95
%assign __NR_getpriority	96
%assign __NR_setpriority	97
%assign __NR_profil		98
%assign __NR_statfs		99
%assign __NR_fstatfs		100
%assign __NR_ioperm		101
%assign __NR_socketcall		102
%assign __NR_syslog		103
%assign __NR_setitimer		104
%assign __NR_getitimer		105
%assign __NR_stat		106
%assign __NR_lstat		107
%assign __NR_fstat		108
%assign __NR_olduname		109
%assign __NR_iopl		110
%assign __NR_vhangup		111
%assign __NR_idle		112
%assign __NR_vm86old		113
%assign __NR_wait4		114
%assign __NR_swapoff		115
%assign __NR_sysinfo		116
%assign __NR_ipc		117
%assign __NR_fsync		118
%assign __NR_sigreturn		119
%assign __NR_clone		120
%assign __NR_setdomainname	121
%assign __NR_uname		122
%assign __NR_modify_ldt		123
%assign __NR_adjtimex		124
%assign __NR_mprotect		125
%assign __NR_sigprocmask	126
%assign __NR_create_module	127
%assign __NR_init_module	128
%assign __NR_delete_module	129
%assign __NR_get_kernel_syms	130
%assign __NR_quotactl		131
%assign __NR_getpgid		132
%assign __NR_fchdir		133
%assign __NR_bdflush		134
%assign __NR_sysfs		135
%assign __NR_personality	136
%assign __NR_afs_syscall	137
%assign __NR_setfsuid		138
%assign __NR_setfsgid		139
%assign __NR__llseek		140
%assign __NR_getdents		141
%assign __NR__newselect		142
%assign __NR_flock		143
%assign __NR_msync		144
%assign __NR_readv		145
%assign __NR_writev		146
%assign __NR_getsid		147
%assign __NR_fdatasync		148
%assign __NR__sysctl		149
%assign __NR_mlock		150
%assign __NR_munlock		151
%assign __NR_mlockall		152
%assign __NR_munlockall		153
%assign __NR_sched_setparam		154
%assign __NR_sched_getparam		155
%assign __NR_sched_setscheduler		156
%assign __NR_sched_getscheduler		157
%assign __NR_sched_yield		158
%assign __NR_sched_get_priority_max	159
%assign __NR_sched_get_priority_min	160
%assign __NR_sched_rr_get_interval	161
%assign __NR_nanosleep		162
%assign __NR_mremap		163
%if KERNEL=22
%assign __NR_setresuid		164
%assign __NR_getresuid		165
%assign __NR_vm86		166
%assign __NR_query_module	167
%assign __NR_poll		168
%assign __NR_nfsservctl		169
%assign __NR_setresgid		170
%assign __NR_getresgid		171
%assign __NR_prctl              172
%assign __NR_rt_sigreturn	173
%assign __NR_rt_sigaction	174
%assign __NR_rt_sigprocmask	175
%assign __NR_rt_sigpending	176
%assign __NR_rt_sigtimedwait	177
%assign __NR_rt_sigqueueinfo	178
%assign __NR_rt_sigsuspend	179
%assign __NR_pread		180
%assign __NR_pwrite		181
%assign __NR_chown		182
%assign __NR_getcwd		183
%assign __NR_capget		184
%assign __NR_capset		185
%assign __NR_sigaltstack	186
%assign __NR_sendfile		187
%endif
%assign __NR_getpmsg		188
%assign __NR_putpmsg		189
%if KERNEL=22
%assign __NR_vfork		190
%endif

;
;linux/wait.h
;

%assign WNOHANG		1
%assign WUNTRACED	2

;
;linux/kd.h
;

%assign KDGKBTYPE 0x4B33	;get keyboard type
%assign KB_84 0x01
%assign KB_101 0x02		;this is what we always answer
%assign KB_OTHER 0x03

;
;linux/vt.h
;

%assign VT_ACTIVATE 0x5606	;make vt active
%assign VT_WAITACTIVE 0x5607	;wait for vt active
%assign VT_DISALLOCATE 0x5608	;free memory associated to vt

;
;linux/utsname.h
;

%assign	__NEW_UTS_LEN	64

;
;
;

;* Supported address families. *
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

;* Protocol families, same as address families.
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

%assign SOCK_STREAM    1		; stream (connection) socket
%assign SOCK_DGRAM     2		; datagram (conn.less) socket
%assign SOCK_RAW       3		; raw socket
%assign SOCK_RDM       4		; reliably-delivered message
%assign SOCK_SEQPACKET 5		; sequential packet socket
%assign SOCK_PACKET    10		; linux specific way of
					; getting packets at the dev
					; level.  For writing rarp and
					; other similar things on the
					; user level.

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


%endif	;__DEFINES_INC

%else

%error "this file must be included internally from system.inc !"

%endif	;__SYSTEM_INC
