; Copyright (C) 2000 Konstantin Boldyshev <konst@linuxassembly.org>
; Copyright (C) 2000 Tani Hosokawa <unknown@riverstyx.net>
;
; $Id: os_openbsd.inc,v 1.1 2000/09/03 16:13:54 konst Exp $
;
; file          : os_openbsd.inc
; created       : 18-Aug-2000
; modified      : 03-Sep-2000
; version       : 0.10
; assembler     : nasm 0.98
; description   : OpenBSD kernel (2.7+) defined constants and structures
; author        : Tani Hosokawa <unknown@riverstyx.net>
; comment       : included internally from system.inc

%ifndef __SYSTEM_INC
%error "this file must be included internally from system.inc !"
%endif

%ifndef __OPENBSD_INC
%define __OPENBSD_INC

;created from OpenBSD: syscalls.master,v 1.41 2000/06/22 22:41:19 mickey Exp
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
;				/* 8 is compat_43 ocreat */
%assign	SYS_link	9
%assign	SYS_unlink	10
;				/* 11 is obsolete execv */
%assign	SYS_chdir	12
%assign	SYS_fchdir	13
%assign	SYS_mknod	14
%assign	SYS_chmod	15
%assign	SYS_chown	16
%assign	SYS_break	17
%assign	SYS_ogetfsstat	18
;				/* 19 is compat_43 olseek */
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
;				/* 38 is compat_43 ostat */
%assign	SYS_getppid	39
;				/* 40 is compat_43 olstat */
%assign	SYS_dup	41
%assign	SYS_opipe	42
%assign	SYS_getegid	43
%assign	SYS_profil	44
%assign	SYS_ktrace	45
%assign	SYS_sigaction	46
%assign	SYS_getgid	47
%assign	SYS_sigprocmask	48
%assign	SYS_getlogin	49
%assign	SYS_setlogin	50
%assign	SYS_acct	51
%assign	SYS_sigpending	52
%assign	SYS_sigaltstack	53
%assign	SYS_ioctl	54
%assign	SYS_reboot	55
%assign	SYS_revoke	56
%assign	SYS_symlink	57
%assign	SYS_readlink	58
%assign	SYS_execve	59
%assign	SYS_umask	60
%assign	SYS_chroot	61
;				/* 62 is compat_43 ofstat */
;				/* 63 is compat_43 ogetkerninfo */
;				/* 64 is compat_43 ogetpagesize */
%assign	SYS_omsync	65
%assign	SYS_vfork	66
;				/* 67 is obsolete vread */
;				/* 68 is obsolete vwrite */
%assign	SYS_sbrk	69
%assign	SYS_sstk	70
;				/* 71 is compat_43 ommap */
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
;				/* 84 is compat_43 owait */
%assign	SYS_swapon	85
%assign	SYS_getitimer	86
%assign	SYS_compat_43_ogethostname	87
%assign	SYS_compat_43_osethostname	88
;				/* 87 is compat_43 ogethostname */
;				/* 88 is compat_43 osethostname */
;				/* 89 is compat_43 ogetdtablesize */
%assign	SYS_dup2	90
%assign	SYS_fcntl	92
%assign	SYS_select	93
%assign	SYS_fsync	95
%assign	SYS_setpriority	96
%assign	SYS_socket	97
%assign	SYS_connect	98
;				/* 99 is compat_43 oaccept */
%assign	SYS_getpriority	100
;				/* 101 is compat_43 osend */
;				/* 102 is compat_43 orecv */
%assign	SYS_sigreturn	103
%assign	SYS_bind	104
%assign	SYS_setsockopt	105
%assign	SYS_listen	106
;				/* 107 is obsolete vtimes */
;				/* 108 is compat_43 osigvec */
;				/* 109 is compat_43 osigblock */
;				/* 110 is compat_43 osigsetmask */
%assign	SYS_sigsuspend	111
;				/* 112 is compat_43 osigstack */
;				/* 113 is compat_43 orecvmsg */
;				/* 114 is compat_43 osendmsg */
;				/* 115 is obsolete vtrace */
%assign	SYS_gettimeofday	116
%assign	SYS_getrusage	117
%assign	SYS_getsockopt	118
;				/* 119 is obsolete resuba */
%assign	SYS_readv	120
%assign	SYS_writev	121
%assign	SYS_settimeofday	122
%assign	SYS_fchown	123
%assign	SYS_fchmod	124
;				/* 125 is compat_43 orecvfrom */
;				/* 126 is compat_43 osetreuid */
;				/* 127 is compat_43 osetregid */
%assign	SYS_rename	128
;				/* 129 is compat_43 otruncate */
;				/* 130 is compat_43 oftruncate */
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
;				/* 141 is compat_43 ogetpeername */
;				/* 142 is compat_43 ogethostid */
;				/* 143 is compat_43 osethostid */
;				/* 144 is compat_43 ogetrlimit */
;				/* 145 is compat_43 osetrlimit */
;				/* 146 is compat_43 okillpg */
%assign	SYS_setsid	147
%assign	SYS_quotactl	148
;				/* 149 is compat_43 oquota */
;				/* 150 is compat_43 ogetsockname */
%assign	SYS_nfssvc	155
;				/* 156 is compat_43 ogetdirentries */
%assign	SYS_ostatfs	157
%assign	SYS_ofstatfs	158
%assign	SYS_getfh	161
;				/* 162 is compat_09 ogetdomainname */
;				/* 163 is compat_09 osetdomainname */
;				/* 164 is compat_09 ouname */
%assign	SYS_compat_09_osetdomainname 163
%assign	SYS_compat_09_ogetdomainname 162
%assign	SYS_compat_09_ouname 164
%assign	SYS_sysarch	165
;				/* 169 is compat_10 osemsys */
;				/* 170 is compat_10 omsgsys */
;				/* 171 is compat_10 oshmsys */
%assign	SYS_pread	173
%assign	SYS_pwrite	174
%assign	SYS_ntp_gettime	175
%assign	SYS_ntp_adjtime	176
%assign	SYS_setgid	181
%assign	SYS_setegid	182
%assign	SYS_seteuid	183
%assign	SYS_lfs_bmapv	184
%assign	SYS_lfs_markv	185
%assign	SYS_lfs_segclean	186
%assign	SYS_lfs_segwait	187
%assign	SYS_stat	188
%assign	SYS_fstat	189
%assign	SYS_lstat	190
%assign	SYS_pathconf	191
%assign	SYS_fpathconf	192
%assign	SYS_swapctl	193
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
%assign	SYS_xfspioctl	208
%assign	SYS___osemctl	220
%assign	SYS_semget	221
%assign	SYS_semop	222
;				/* 223 is obsolete sys_semconfig */
%assign	SYS_omsgctl	224
%assign	SYS_msgget	225
%assign	SYS_msgsnd	226
%assign	SYS_msgrcv	227
%assign	SYS_shmat	228
%assign	SYS_oshmctl	229
%assign	SYS_shmdt	230
%assign	SYS_shmget	231
%assign	SYS_clock_gettime	232
%assign	SYS_clock_settime	233
%assign	SYS_clock_getres	234
%assign	SYS_nanosleep	240
%assign	SYS_minherit	250
%assign	SYS_rfork	251
%assign	SYS_poll	252
%assign	SYS_issetugid	253
%assign	SYS_lchown	254
%assign	SYS_getsid	255
%assign	SYS_msync	256
%assign	SYS___semctl	257
%assign	SYS_shmctl	258
%assign	SYS_msgctl	259
%assign	SYS_getfsstat	260
%assign	SYS_statfs	261
%assign	SYS_fstatfs	262
%assign	SYS_pipe	263
%assign	SYS_fhopen	264
%assign	SYS_fhstat	265
%assign	SYS_fhstatfs	266
%assign	SYS_preadv	267
%assign	SYS_pwritev	268
%assign	SYS_MAXSYSCALL	269

;
;loopbacks
;

%assign	SYS_setdomainname SYS_compat_09_osetdomainname
%assign	SYS_setdomainname SYS_compat_09_ogetdomainname
%assign	SYS_sethostname	SYS_compat_43_osethostname
%assign	SYS_gethostname	SYS_compat_43_ogethostname
%assign	SYS_uname	SYS_compat_09_ouname
%assign	SYS_getdents	SYS_getdirentries	;?
%assign	SYS_getcwd	SYS_getpid
%assign	SYS_signal	SYS_getpid
%assign	SYS_alarm	SYS_getpid

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

%macro sys_getfsstat 0-3
	__syscall getfsstat, 3, %0, %1, %2, %3
%endmacro

%endif	;__OPENBSD_INC
