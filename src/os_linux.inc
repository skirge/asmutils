; Copyright (C) 1999-2000 Konstantin Boldyshev <konst@linuxassembly.org>
;
; $Id: os_linux.inc,v 1.3 2000/04/07 18:36:01 konst Exp $
;
; file          : os_linux.inc
; created       : 08-Feb-2000
; modified      : 01-Apr-2000
; version       : 0.09
; assembler     : nasm 0.98
; description   : linux kernel defined constants (from includes)
; author        : Konstantin Boldyshev <konst@linuxassembly.org>
; comment       : included internally from system.inc

%ifndef __SYSTEM_INC
%error "this file must be included internally from system.inc !"
%endif

%ifndef __LINUX_INC
%define __LINUX_INC

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
;linux/kd.h
;

%assign KDGKBTYPE 0x4B33	;get keyboard type
%assign KB_84 0x01
%assign KB_101 0x02		;this is what we always answer
%assign KB_OTHER 0x03

;
;linux/cdrom.h
;

%assign CDROMPAUSE		0x5301	;Pause Audio Operation
%assign CDROMRESUME		0x5302	;Resume paused Audio Operation
%assign CDROMPLAYMSF		0x5303	;Play Audio MSF (struct cdrom_msf)
%assign CDROMPLAYTRKIND		0x5304	;Play Audio Track/index (struct cdrom_ti)
%assign CDROMREADTOCHDR		0x5305	;Read TOC header (struct cdrom_tochdr)
%assign CDROMREADTOCENTRY	0x5306	;Read TOC entry (struct cdrom_tocentry)
%assign CDROMSTOP		0x5307	;Stop the cdrom drive
%assign CDROMSTART		0x5308	;Start the cdrom drive
%assign CDROMEJECT		0x5309	;Ejects the cdrom media
%assign CDROMVOLCTRL		0x530a	;Control output volume (struct cdrom_volctrl)
%assign CDROMSUBCHNL		0x530b	;Read subchannel data (struct cdrom_subchnl)
%assign CDROMREADMODE2		0x530c	;Read CDROM mode 2 data (2336 Bytes) (struct cdrom_read)
%assign CDROMREADMODE1		0x530d	;Read CDROM mode 1 data (2048 Bytes) (struct cdrom_read)
%assign CDROMREADAUDIO		0x530e	;(struct cdrom_read_audio)
%assign CDROMEJECT_SW		0x530f	;enable(1)/disable(0) auto-ejecting
%assign CDROMMULTISESSION	0x5310	;Obtain the start-of-last-session address of multi session disks (struct cdrom_multisession)
%assign CDROM_GET_MCN		0x5311	;Obtain the "Universal Product Code" if available (struct cdrom_mcn)
%assign CDROM_GET_UPC		CDROM_GET_MCN	;This one is depricated, but here anyway for compatability
%assign CDROMRESET		0x5312	;hard-reset the drive
%assign CDROMVOLREAD		0x5313	;Get the drive's volume setting (struct cdrom_volctrl)
%assign CDROMREADRAW		0x5314	;read data in raw mode (2352 Bytes)
%assign CDROMCLOSETRAY	0x5319

;
;linux/vt.h
;

%assign VT_ACTIVATE 0x5606	;make vt active
%assign VT_WAITACTIVE 0x5607	;wait for vt active
%assign VT_DISALLOCATE 0x5608	;free memory associated to vt

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

;
;sys/vfs.h
;

struc statfs
.f_type		LONG	1	;fs type
.f_bsize	LONG	1	;optimal transfer block size
.f_blocks	LONG	1	;total data blocks
.f_bfree	LONG	1	;free blocks
.f_bavail	LONG	1	;free blocks avail to non-superuser
.f_files	LONG	1	;total file nodes
.f_free		LONG	1	;free file nodes
.f_fsid		LONG	1	;fs id
.f_namelen	LONG	1	;maximum filename length
.f_reserv	LONG  	6	;reserved
endstruc

;
;arch/i386/kernel/sys_i386.c
;

struc	mmap_arg_struct
.addr	ULONG	1
.len	ULONG	1
.prot	ULONG	1
.flags	ULONG	1
.fd	ULONG	1
.offset	ULONG	1
endstruc

;
;asm/ptrace.h
;

struc pt_regs
.ebx	ULONG	1
.ecx	ULONG	1
.edx	ULONG	1
.esi	ULONG	1
.edi	ULONG	1
.ebp	ULONG	1
.eax	ULONG	1
%if __KERNEL__ = 20
.ds	USHORT	1
.__dsu	USHORT	1
.es	USHORT	1
.__esu	USHORT	1
.fs	USHORT	1
.__fsu	USHORT	1
.gs	USHORT	1
.__gsu	USHORT	1
%elif __KERNEL__ = 22
.xds	INT	1
.xes	INT	1
%endif
.orig_eax	ULONG	1
.eip		ULONG	1
%if __KERNEL__ = 20
.cs	USHORT	1
.__csu	USHORT	1
%elif __KERNEL__ = 22
.xcs	INT	1
%endif
.eflags	ULONG	1
.esp	ULONG	1
%if __KERNEL__ = 20
.ss	USHORT	1
.__ssu	USHORT	1
%elif __KERNEL__ = 22
.xss	INT	1
%endif
endstruc

;
;linux/dirent.h
;

ld_name		equ	256
struc dirent
.d_ino		ULONG	1
.d_off		ULONG	1
.d_reclen	USHORT	1
.d_name		CHAR	ld_name
endstruc

;
;asm/unistd.h
;

%assign SYS_exit		1
%assign SYS_fork		2
%assign SYS_read		3
%assign SYS_write		4
%assign SYS_open		5
%assign SYS_close		6
%assign SYS_waitpid		7
%assign SYS_creat		8
%assign SYS_link		9
%assign SYS_unlink		10
%assign SYS_execve		11
%assign SYS_chdir		12
%assign SYS_time		13
%assign SYS_mknod		14
%assign SYS_chmod		15
%assign SYS_lchown		16
%assign SYS_break		17
%assign SYS_oldstat		18
%assign SYS_lseek		19
%assign SYS_getpid		20
%assign SYS_mount		21
%assign SYS_umount		22
%assign SYS_setuid		23
%assign SYS_getuid		24
%assign SYS_stime		25
%assign SYS_ptrace		26
%assign SYS_alarm		27
%assign SYS_oldfstat		28
%assign SYS_pause		29
%assign SYS_utime		30
%assign SYS_stty		31
%assign SYS_gtty		32
%assign SYS_access		33
%assign SYS_nice		34
%assign SYS_ftime		35
%assign SYS_sync		36
%assign SYS_kill		37
%assign SYS_rename		38
%assign SYS_mkdir		39
%assign SYS_rmdir		40
%assign SYS_dup		41
%assign SYS_pipe		42
%assign SYS_times		43
%assign SYS_prof		44
%assign SYS_brk		45
%assign SYS_setgid		46
%assign SYS_getgid		47
%assign SYS_signal		48
%assign SYS_geteuid		49
%assign SYS_getegid		50
%assign SYS_acct		51
%assign SYS_umount2		52
%assign SYS_lock		53
%assign SYS_ioctl		54
%assign SYS_fcntl		55
%assign SYS_mpx		56
%assign SYS_setpgid		57
%assign SYS_ulimit		58
%assign SYS_oldolduname	59
%assign SYS_umask		60
%assign SYS_chroot		61
%assign SYS_ustat		62
%assign SYS_dup2		63
%assign SYS_getppid		64
%assign SYS_getpgrp		65
%assign SYS_setsid		66
%assign SYS_sigaction		67
%assign SYS_sgetmask		68
%assign SYS_ssetmask		69
%assign SYS_setreuid		70
%assign SYS_setregid		71
%assign SYS_sigsuspend		72
%assign SYS_sigpending		73
%assign SYS_sethostname	74
%assign SYS_setrlimit		75
%assign SYS_getrlimit		76
%assign SYS_getrusage		77
%assign SYS_gettimeofday	78
%assign SYS_settimeofday	79
%assign SYS_getgroups		80
%assign SYS_setgroups		81
%assign SYS_select		82
%assign SYS_symlink		83
%assign SYS_oldlstat		84
%assign SYS_readlink		85
%assign SYS_uselib		86
%assign SYS_swapon		87
%assign SYS_reboot		88
%assign SYS_readdir		89
%assign SYS_mmap		90
%assign SYS_munmap		91
%assign SYS_truncate		92
%assign SYS_ftruncate		93
%assign SYS_fchmod		94
%assign SYS_fchown		95
%assign SYS_getpriority	96
%assign SYS_setpriority	97
%assign SYS_profil		98
%assign SYS_statfs		99
%assign SYS_fstatfs		100
%assign SYS_ioperm		101
%assign SYS_socketcall		102
%assign SYS_syslog		103
%assign SYS_setitimer		104
%assign SYS_getitimer		105
%assign SYS_stat		106
%assign SYS_lstat		107
%assign SYS_fstat		108
%assign SYS_olduname		109
%assign SYS_iopl		110
%assign SYS_vhangup		111
%assign SYS_idle		112
%assign SYS_vm86old		113
%assign SYS_wait4		114
%assign SYS_swapoff		115
%assign SYS_sysinfo		116
%assign SYS_ipc		117
%assign SYS_fsync		118
%assign SYS_sigreturn		119
%assign SYS_clone		120
%assign SYS_setdomainname	121
%assign SYS_uname		122
%assign SYS_modify_ldt		123
%assign SYS_adjtimex		124
%assign SYS_mprotect		125
%assign SYS_sigprocmask	126
%assign SYS_create_module	127
%assign SYS_init_module	128
%assign SYS_delete_module	129
%assign SYS_get_kernel_syms	130
%assign SYS_quotactl		131
%assign SYS_getpgid		132
%assign SYS_fchdir		133
%assign SYS_bdflush		134
%assign SYS_sysfs		135
%assign SYS_personality	136
%assign SYS_afs_syscall	137
%assign SYS_setfsuid		138
%assign SYS_setfsgid		139
%assign SYS__llseek		140
%assign SYS_getdents		141
%assign SYS_newselect		142
%assign SYS_flock		143
%assign SYS_msync		144
%assign SYS_readv		145
%assign SYS_writev		146
%assign SYS_getsid		147
%assign SYS_fdatasync		148
%assign SYS_sysctl		149
%assign SYS_mlock		150
%assign SYS_munlock		151
%assign SYS_mlockall		152
%assign SYS_munlockall		153
%assign SYS_sched_setparam		154
%assign SYS_sched_getparam		155
%assign SYS_sched_setscheduler		156
%assign SYS_sched_getscheduler		157
%assign SYS_sched_yield		158
%assign SYS_sched_get_priority_max	159
%assign SYS_sched_get_priority_min	160
%assign SYS_sched_rr_get_interval	161
%assign SYS_nanosleep		162
%assign SYS_mremap		163
%if __KERNEL__ = 22
%assign SYS_setresuid		164
%assign SYS_getresuid		165
%assign SYS_vm86		166
%assign SYS_query_module	167
%assign SYS_poll		168
%assign SYS_nfsservctl		169
%assign SYS_setresgid		170
%assign SYS_getresgid		171
%assign SYS_prctl		172
%assign SYS_rt_sigreturn	173
%assign SYS_rt_sigaction	174
%assign SYS_rt_sigprocmask	175
%assign SYS_rt_sigpending	176
%assign SYS_rt_sigtimedwait	177
%assign SYS_rt_sigqueueinfo	178
%assign SYS_rt_sigsuspend	179
%assign SYS_pread		180
%assign SYS_pwrite		181
%assign SYS_chown		182
%assign SYS_getcwd		183
%assign SYS_capget		184
%assign SYS_capset		185
%assign SYS_sigaltstack	186
%assign SYS_sendfile		187
%endif
%assign SYS_getpmsg		188
%assign SYS_putpmsg		189
%if __KERNEL__ = 22
%assign SYS_vfork		190
%endif

;
;linux/net.h (socket calls)
;

%assign SYS_SOCKET	1	; sys_socket
%assign SYS_BIND	2	; sys_bind
%assign SYS_CONNECT	3	; sys_connect
%assign SYS_LISTEN	4	; sys_listen
%assign SYS_ACCEPT	5	; sys_accept
%assign SYS_GETSOCKNAME	6	; sys_getsockname
%assign SYS_GETPEERNAME	7	; sys_getpeername
%assign SYS_SOCKETPAIR	8	; sys_socketpair
%assign SYS_SEND	9	; sys_send
%assign SYS_RECV	10	; sys_recv
%assign SYS_SENDTO	11	; sys_sendto
%assign SYS_RECVFROM	12	; sys_recvfrom
%assign SYS_SHUTDOWN	13	; sys_shutdown
%assign SYS_SETSOCKOPT	14	; sys_setsockopt
%assign SYS_GETSOCKOPT	15	; sys_getsockopt
%assign SYS_SENDMSG	16	; sys_sendmsg
%assign SYS_RECVMSG	17	; sys_recvmsg

;
;system calls
;

;--------------------------------------------------------------------------
;net/
;--------------------------------------------------------------------------

;
;net/socket.c
;

%macro sys_socketcall 0-3
        __syscall socketcall, 3, %0, %1, %2, %3
%endmacro

%macro	sys_socket 3
	_push	%3
	_push	%2
	_push	%1
	sys_socketcall SYS_SOCKET,esp
	_add	esp,(%0 * 4)
%endmacro

%macro	sys_accept 3
	_push	%3
	_push	%2
	_push	%1
	sys_socketcall SYS_ACCEPT,esp
	_add	esp,(%0 * 4)
%endmacro

%macro	sys_connect 3
	_push	%3
	_push	%2
	_push	%1
	sys_socketcall SYS_CONNECT,esp
	_add	esp,(%0 * 4)
%endmacro

%macro	sys_bind 3
	_push	%3
	_push	%2
	_push	%1
	sys_socketcall SYS_BIND,esp
	_add	esp,(%0 * 4)
%endmacro

%macro	sys_setsockopt 5
	_push	%5
	_push	%4
	_push	%3
	_push	%2
	_push	%1
	sys_socketcall SYS_SETSOCKOPT,esp
	_add	esp,(%0 * 4)
%endmacro

%macro	sys_shutdown 2
	_push	%2
	_push	%1
	sys_socketcall SYS_SHUTDOWN,esp
	_add	esp,(%0 * 4)
%endmacro

%macro	sys_listen 2
	_push	%2
	_push	%1
	sys_socketcall SYS_LISTEN,esp
	_add	esp,(%0 * 4)
%endmacro

%endif	;__LINUX_INC
