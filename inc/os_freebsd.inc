; Copyright (C) 2000 Konstantin Boldyshev <konst@linuxassembly.org>
;
; $Id: os_freebsd.inc,v 1.1 2000/09/03 16:13:53 konst Exp $
;
; file          : os_freebsd.inc
; created       : 08-Feb-2000
; modified      : 23-Aug-2000
; version       : 0.10
; assembler     : nasm 0.98
; description   : FreeBSD kernel (3.2+) defined constants and structures
; author        : Konstantin Boldyshev <konst@linuxassembly.org>
; comment       : included internally from system.inc

%ifndef __SYSTEM_INC
%error "this file must be included internally from system.inc !"
%endif

%ifndef __FREEBSD_INC
%define __FREEBSD_INC

;created from FreeBSD: src/sys/kern/syscalls.master,v 1.72.2.5 2000/08/09 00:08:30 peter Exp
;
;sys/syscall.h
;

%assign	SYS_syscall	0
%assign	SYS_exit	1
%assign	SYS_fork	2
%assign	SYS_read	3
%assign	SYS_write	4
%assign	SYS_open	5
%assign	SYS_close	6
%assign	SYS_wait4	7
;				/* 8 is old creat */
%assign	SYS_link	9
%assign	SYS_unlink	10
;				/* 11 is obsolete execv */
%assign	SYS_chdir	12
%assign	SYS_fchdir	13
%assign	SYS_mknod	14
%assign	SYS_chmod	15
%assign	SYS_chown	16
%assign	SYS_break	17
%assign	SYS_getfsstat	18
;				/* 19 is old lseek */
%assign	SYS_getpid	20
%assign	SYS_mount	21
%assign	SYS_unmount	22
%assign	SYS_setuid	23
%assign	SYS_getuid	24
%assign	SYS_geteuid	25
%assign	SYS_ptrace	26
%assign	SYS_recvmsg	27
%assign	SYS_sendmsg	28
%assign	SYS_recvfrom	29
%assign	SYS_accept	30
%assign	SYS_getpeername	31
%assign	SYS_getsockname	32
%assign	SYS_access	33
%assign	SYS_chflags	34
%assign	SYS_fchflags	35
%assign	SYS_sync	36
%assign	SYS_kill	37
;				/* 38 is old stat */
%assign	SYS_getppid	39
;				/* 40 is old lstat */
%assign	SYS_dup	41
%assign	SYS_pipe	42
%assign	SYS_getegid	43
%assign	SYS_profil	44
%assign	SYS_ktrace	45
%if __KERNEL__ < 40
%assign	SYS_sigaction	46
%endif
%assign	SYS_getgid	47
%if __KERNEL__ < 40
%assign	SYS_sigprocmask	48
%endif
%assign	SYS_getlogin	49
%assign	SYS_setlogin	50
%assign	SYS_acct	51
%if __KERNEL__ < 40
%assign	SYS_sigpending	52
%endif
%assign	SYS_sigaltstack	53
%assign	SYS_ioctl	54
%assign	SYS_reboot	55
%assign	SYS_revoke	56
%assign	SYS_symlink	57
%assign	SYS_readlink	58
%assign	SYS_execve	59
%assign	SYS_umask	60
%assign	SYS_chroot	61
;				/* 62 is old fstat */
;				/* 63 is old getkerninfo */
;				/* 64 is old getpagesize */
%assign	SYS_msync	65
%assign	SYS_vfork	66
;				/* 67 is obsolete vread */
;				/* 68 is obsolete vwrite */
%assign	SYS_sbrk	69
%assign	SYS_sstk	70
;				/* 71 is old mmap */
%assign	SYS_vadvise	72
%assign	SYS_munmap	73
%assign	SYS_mprotect	74
%assign	SYS_madvise	75
;				/* 76 is obsolete vhangup */
;				/* 77 is obsolete vlimit */
%assign	SYS_mincore	78
%assign	SYS_getgroups	79
%assign	SYS_setgroups	80
%assign	SYS_getpgrp	81
%assign	SYS_setpgid	82
%assign	SYS_setitimer	83
;				/* 84 is old wait */
%assign	SYS_swapon	85
%assign	SYS_getitimer	86
%assign	SYS_gethostname 87
%assign	SYS_sethostname 88
%assign	SYS_getdtablesize	89
%assign	SYS_dup2	90
%assign	SYS_fcntl	92
%assign	SYS_select	93
%assign	SYS_fsync	95
%assign	SYS_setpriority	96
%assign	SYS_socket	97
%assign	SYS_connect	98
;				/* 99 is old accept */
%assign	SYS_getpriority	100
;				/* 101 is old send */
;				/* 102 is old recv */
%if __KERNEL__ < 40
%assign	SYS_sigreturn	103
%endif
%assign	SYS_bind	104
%assign	SYS_setsockopt	105
%assign	SYS_listen	106
;				/* 107 is obsolete vtimes */
;				/* 108 is old sigvec */
;				/* 109 is old sigblock */
;				/* 110 is old sigsetmask */
%if __KERNEL__ < 40
%assign	SYS_sigsuspend	111
%endif
;				/* 112 is old sigstack */
;				/* 113 is old recvmsg */
;				/* 114 is old sendmsg */
;				/* 115 is obsolete vtrace */
%assign	SYS_gettimeofday	116
%assign	SYS_getrusage	117
%assign	SYS_getsockopt	118
%assign	SYS_readv	120
%assign	SYS_writev	121
%assign	SYS_settimeofday	122
%assign	SYS_fchown	123
%assign	SYS_fchmod	124
;				/* 125 is old recvfrom */
%assign	SYS_setreuid	126
%assign	SYS_setregid	127
%assign	SYS_rename	128
;				/* 129 is old truncate */
;				/* 130 is old ftruncate */
%assign	SYS_flock	131
%assign	SYS_mkfifo	132
%assign	SYS_sendto	133
%assign	SYS_shutdown	134
%assign	SYS_socketpair	135
%assign	SYS_mkdir	136
%assign	SYS_rmdir	137
%assign	SYS_utimes	138
;				/* 139 is obsolete 4.2 sigreturn */
%assign	SYS_adjtime	140
;				/* 141 is old getpeername */
;				/* 142 is old gethostid */
;				/* 143 is old sethostid */
;				/* 144 is old getrlimit */
;				/* 145 is old setrlimit */
;				/* 146 is old killpg */
%assign	SYS_setsid	147
%assign	SYS_quotactl	148
;				/* 149 is old quota */
;				/* 150 is old getsockname */
%assign	SYS_nfssvc	155
;				/* 156 is old getdirentries */
%assign	SYS_statfs	157
%assign	SYS_fstatfs	158
%assign	SYS_getfh	161
%assign	SYS_getdomainname	162
%assign	SYS_setdomainname	163
%assign	SYS_uname	164
%assign	SYS_sysarch	165
%assign	SYS_rtprio	166
%assign	SYS_semsys	169
%assign	SYS_msgsys	170
%assign	SYS_shmsys	171
%assign	SYS_pread	173
%assign	SYS_pwrite	174
%assign	SYS_ntp_adjtime	176
%assign	SYS_setgid	181
%assign	SYS_setegid	182
%assign	SYS_seteuid	183
%assign	SYS_stat	188
%assign	SYS_fstat	189
%assign	SYS_lstat	190
%assign	SYS_pathconf	191
%assign	SYS_fpathconf	192
%assign	SYS_getrlimit	194
%assign	SYS_setrlimit	195
%assign	SYS_getdirentries	196
%assign	SYS_mmap	197
%assign	SYS___syscall	198
%assign	SYS_lseek	199
%assign	SYS_truncate	200
%assign	SYS_ftruncate	201
%assign	SYS___sysctl	202
%assign	SYS_mlock	203
%assign	SYS_munlock	204
%assign	SYS_undelete	205
%assign	SYS_futimes	206
%assign	SYS_getpgid	207
%assign	SYS_poll	209
%assign	SYS___semctl	220
%assign	SYS_semget	221
%assign	SYS_semop	222
%assign	SYS_semconfig	223
%assign	SYS_msgctl	224
%assign	SYS_msgget	225
%assign	SYS_msgsnd	226
%assign	SYS_msgrcv	227
%assign	SYS_shmat	228
%assign	SYS_shmctl	229
%assign	SYS_shmdt	230
%assign	SYS_shmget	231
%assign	SYS_clock_gettime	232
%assign	SYS_clock_settime	233
%assign	SYS_clock_getres	234
%assign	SYS_nanosleep	240
%assign	SYS_minherit	250
%assign	SYS_rfork	251
%assign	SYS_openbsd_poll	252
%assign	SYS_issetugid	253
%assign	SYS_lchown	254
%assign	SYS_getdents	272
%assign	SYS_lchmod	274
%assign	SYS_netbsd_lchown	275
%assign	SYS_lutimes	276
%assign	SYS_netbsd_msync	277
%assign	SYS_nstat	278
%assign	SYS_nfstat	279
%assign	SYS_nlstat	280
%if __KERNEL__ >= 40
%assign	SYS_fhstatfs	297
%assign	SYS_fhopen	298
%assign	SYS_fhstat	299
%endif
%assign	SYS_modnext	300
%assign	SYS_modstat	301
%assign	SYS_modfnext	302
%assign	SYS_modfind	303
%assign	SYS_kldload	304
%assign	SYS_kldunload	305
%assign	SYS_kldfind	306
%assign	SYS_kldnext	307
%assign	SYS_kldstat	308
%assign	SYS_kldfirstmod	309
%assign	SYS_getsid	310
%if __KERNEL__ >= 40
%assign	SYS_setresuid	311
%assign	SYS_setresgid	312
%endif
;				/* 313 is obsolete signanosleep */
%assign	SYS_aio_return	314
%assign	SYS_aio_suspend	315
%assign	SYS_aio_cancel	316
%assign	SYS_aio_error	317
%assign	SYS_aio_read	318
%assign	SYS_aio_write	319
%assign	SYS_lio_listio	320
%assign	SYS_yield	321
%assign	SYS_thr_sleep	322
%assign	SYS_thr_wakeup	323
%assign	SYS_mlockall	324
%assign	SYS_munlockall	325
%assign	SYS___getcwd	326
%assign	SYS_sched_setparam	327
%assign	SYS_sched_getparam	328
%assign	SYS_sched_setscheduler	329
%assign	SYS_sched_getscheduler	330
%assign	SYS_sched_yield	331
%assign	SYS_sched_get_priority_max	332
%assign	SYS_sched_get_priority_min	333
%assign	SYS_sched_rr_get_interval	334
%assign	SYS_utrace	335
%assign	SYS_sendfile	336
%assign	SYS_kldsym	337

%if __KERNEL__ >= 40
%assign	SYS_jail	338
%assign	SYS_sigprocmask	340
%assign	SYS_sigsuspend	341
%assign	SYS_sigaction	342
%assign	SYS_sigpending	343
%assign	SYS_sigreturn	344
%assign	SYS___acl_get_file	347
%assign	SYS___acl_set_file	348
%assign	SYS___acl_get_fd	349
%assign	SYS___acl_set_fd	350
%assign	SYS___acl_delete_file	351
%assign	SYS___acl_delete_fd	352
%assign	SYS___acl_aclcheck_file	353
%assign	SYS___acl_aclcheck_fd	354
%assign	SYS_extattrctl	355
%assign	SYS_extattr_set_file	356
%assign	SYS_extattr_get_file	357
%assign	SYS_extattr_delete_file	358
%assign	SYS_aio_waitcomplete	359
%assign	SYS_getresuid	360
%assign	SYS_getresgid	361
%assign	SYS_kqueue	362
%assign	SYS_kevent	363
%endif

;
;loopbacks
;

%assign	SYS_umount	SYS_unmount
%assign	SYS_getcwd	SYS___getcwd
%assign	SYS_alarm	SYS_getpid
%assign	SYS_signal	SYS_getpid

;
;
;

%macro sys_getfsstat 0-3
	__syscall getfsstat, 3, %0, %1, %2, %3
%endmacro

;
;sys/socket.h
;

%assign	SO_DEBUG	0x0001		;turn on debugging info recording
%assign	SO_ACCEPTCONN	0x0002		;socket has had listen()
%assign	SO_REUSEADDR	0x0004		;allow local address reuse
%assign	SO_KEEPALIVE	0x0008		;keep connections alive
%assign	SO_DONTROUTE	0x0010		;just use interface addresses
%assign	SO_BROADCAST	0x0020		;permit sending of broadcast msgs
%assign	SO_USELOOPBACK	0x0040		;bypass hardware when possible
%assign	SO_LINGER	0x0080		;linger on close if data present
%assign	SO_OOBINLINE	0x0100		;leave received OOB data in line
%assign	SO_REUSEPORT	0x0200		;allow local address & port reuse
%assign	SO_TIMESTAMP	0x0400		;timestamp received dgram traffic

%assign	SOL_SOCKET	0xffff		;options for socket level

;
;sys/mount.h
;

%assign	MNT_WAIT	1
%assign MNT_NOWAIT	2

%assign	MFSNAMELEN	16	;length of fs type name, including null
%assign	MNAMELEN	90	;length of buffer for returned name


struc statfs
.f_spare2	LONG	1	;placeholder
.f_bsize	LONG	1	;fundamental file system block size
.f_iosize	LONG	1	;optimal trasfer block size
.f_blocks	LONG	1	;total data blocks in file system
.f_bfree	LONG	1	;free blocks in fs
.f_bavail	LONG	1	;free blocks avail to non-superuser
.f_files	LONG	1	;total file nodes in file system
.f_ffree	LONG	1	;free file nodes in fs
.f_fsid		LONG	1	;file system id
.f_owner	LONG	1	;user that mounted the filesystem
.f_type		INT	1	;type of filesystem
.f_flags	INT	1	;copy of mount flags
.f_spare	LONG	2	;spare for later
.f_fstypename	CHAR	MFSNAMELEN	;fs type name
.f_mntonname	CHAR	MNAMELEN	;mount point
.f_mntfromname	CHAR	MNAMELEN	;mounted filesystem
endstruc

;
;sys/cdio.h
;

%assign	IOCPARM_MASK	0x1fff		;parameter length, at most 13 bits
%define	IOCPARM_LEN(x)	(((x) >> 16) & IOCPARM_MASK)
%define	IOCBASECMD(x)	((x) & ~(IOCPARM_MASK << 16))
%define	IOCGROUP(x)	(((x) >> 8) & 0xff)

%assign	IOC_VOID	0x20000000	;no parameters
%assign	IOC_OUT		0x40000000	;copy out parameters
%assign	IOC_IN		0x80000000	;copy in parameters
%define	IOC_INOUT	(IOC_IN|IOC_OUT)
%assign	IOC_DIRMASK	0xe0000000	;mask for IN/OUT/VOID

;#define	_IOC(inout,group,num,len) 
;	((inout | ((len & IOCPARM_MASK) << 16) | ((group) << 8) | (num)))
;#define	_IO(g,n)	_IOC(IOC_VOID,	(g), (n), 0)
;#define	CDIOCEJECT	_IO('c',24)

%endif	;__FREEBSD_INC
