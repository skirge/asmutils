; Copyright (C) 2000 Konstantin Boldyshev <konst@linuxassembly.org>
;
; $Id: os_netbsd.inc,v 1.2 2000/12/10 08:20:36 konst Exp $
;
; file          : os_netbsd.inc
; created       : 10-Aug-2000
; modified      : 09-Sep-2000
; version       : 0.11
; assembler     : nasm 0.98
; description   : NetBSD kernel (1.4+) defined constants and structures
; author        : Konstantin Boldyshev <konst@linuxassembly.org>
; comment       : included internally from system.inc

%ifndef __SYSTEM_INC
%error "this file must be included internally from system.inc !"
%endif

%ifndef __NETBSD_INC
%define __NETBSD_INC

;created from NetBSD: syscalls.master,v 1.102 2000/08/07 17:59:33 bjh21 Exp
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
%assign	SYS_compat_43_ocreat	8
%assign	SYS_link	9
%assign	SYS_unlink	10
%assign	SYS_chdir	12
%assign	SYS_fchdir	13
%assign	SYS_mknod	14
%assign	SYS_chmod	15
%assign	SYS_chown	16
%assign	SYS_break	17
%assign	SYS_getfsstat	18
%assign	SYS_compat_43_olseek	19
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
%assign	SYS_compat_43_stat43	38
%assign	SYS_getppid	39
%assign	SYS_compat_43_lstat43	40
%assign	SYS_dup	41
%assign	SYS_pipe	42
%assign	SYS_getegid	43
%assign	SYS_profil	44
%assign	SYS_ktrace	45
;				/* 45 is excluded ktrace */
%assign	SYS_compat_13_sigaction13	46
%assign	SYS_getgid	47
%assign	SYS_compat_13_sigprocmask13	48
%assign	SYS___getlogin	49
%assign	SYS_setlogin	50
%assign	SYS_acct	51
%assign	SYS_compat_13_sigpending13	52
%assign	SYS_compat_13_sigaltstack13	53
%assign	SYS_ioctl	54
%assign	SYS_compat_12_oreboot	55
%assign	SYS_revoke	56
%assign	SYS_symlink	57
%assign	SYS_readlink	58
%assign	SYS_execve	59
%assign	SYS_umask	60
%assign	SYS_chroot	61
%assign	SYS_compat_43_fstat43	62
%assign	SYS_compat_43_ogetkerninfo	63
%assign	SYS_compat_43_ogetpagesize	64
%assign	SYS_compat_12_msync	65
%assign	SYS_vfork	66
;				/* 67 is obsolete vread */
;				/* 68 is obsolete vwrite */
%assign	SYS_sbrk	69
%assign	SYS_sstk	70
%assign	SYS_compat_43_ommap	71
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
%assign	SYS_compat_43_owait	84
%assign	SYS_compat_12_oswapon	85
%assign	SYS_getitimer	86
%assign	SYS_compat_43_ogethostname	87
%assign	SYS_compat_43_osethostname	88
%assign	SYS_compat_43_ogetdtablesize	89
%assign	SYS_dup2	90
%assign	SYS_fcntl	92
%assign	SYS_select	93
%assign	SYS_fsync	95
%assign	SYS_setpriority	96
%assign	SYS_socket	97
%assign	SYS_connect	98
%assign	SYS_compat_43_oaccept	99
%assign	SYS_getpriority	100
%assign	SYS_compat_43_osend	101
%assign	SYS_compat_43_orecv	102
%assign	SYS_compat_13_sigreturn13	103
%assign	SYS_bind	104
%assign	SYS_setsockopt	105
%assign	SYS_listen	106
;				/* 107 is obsolete vtimes */
%assign	SYS_compat_43_osigvec	108
%assign	SYS_compat_43_osigblock	109
%assign	SYS_compat_43_osigsetmask	110
%assign	SYS_compat_13_sigsuspend13	111
%assign	SYS_compat_43_osigstack	112
%assign	SYS_compat_43_orecvmsg	113
%assign	SYS_compat_43_osendmsg	114
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
%assign	SYS_compat_43_orecvfrom	125
%assign	SYS_setreuid	126
%assign	SYS_setregid	127
%assign	SYS_rename	128
%assign	SYS_compat_43_otruncate	129
%assign	SYS_compat_43_oftruncate	130
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
%assign	SYS_compat_43_ogetpeername	141
%assign	SYS_compat_43_ogethostid	142
%assign	SYS_compat_43_osethostid	143
%assign	SYS_compat_43_ogetrlimit	144
%assign	SYS_compat_43_osetrlimit	145
%assign	SYS_compat_43_okillpg	146
%assign	SYS_setsid	147
%assign	SYS_quotactl	148
%assign	SYS_compat_43_oquota	149
%assign	SYS_compat_43_ogetsockname	150
%assign	SYS_nfssvc	155
;				/* 155 is excluded nfssvc */
%assign	SYS_compat_43_ogetdirentries	156
%assign	SYS_statfs	157
%assign	SYS_fstatfs	158
%assign	SYS_getfh	161
%assign	SYS_compat_09_ogetdomainname	162
%assign	SYS_compat_09_osetdomainname	163
%assign	SYS_compat_09_ouname	164
%assign	SYS_sysarch	165
%assign	SYS_compat_10_osemsys	169
;				/* 169 is excluded 1.0 semsys */
%assign	SYS_compat_10_omsgsys	170
;				/* 170 is excluded 1.0 msgsys */
%assign	SYS_compat_10_oshmsys	171
;				/* 171 is excluded 1.0 shmsys */
%assign	SYS_pread	173
%assign	SYS_pwrite	174
%assign	SYS_ntp_gettime	175
%assign	SYS_ntp_adjtime	176
;				/* 176 is excluded ntp_adjtime */
%assign	SYS_setgid	181
%assign	SYS_setegid	182
%assign	SYS_seteuid	183
%assign	SYS_lfs_bmapv	184
%assign	SYS_lfs_markv	185
%assign	SYS_lfs_segclean	186
%assign	SYS_lfs_segwait	187
;				/* 184 is excluded lfs_bmapv */
;				/* 185 is excluded lfs_markv */
;				/* 186 is excluded lfs_segclean */
;				/* 187 is excluded lfs_segwait */
%assign	SYS_compat_12_stat12	188
%assign	SYS_compat_12_fstat12	189
%assign	SYS_compat_12_lstat12	190
%assign	SYS_pathconf	191
%assign	SYS_fpathconf	192
%assign	SYS_getrlimit	194
%assign	SYS_setrlimit	195
%assign	SYS_compat_12_getdirentries	196
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
%assign	SYS_reboot	208
%assign	SYS_poll	209
;				/* 210-219 are excluded lkmnosys */
%assign	SYS_compat_14___semctl	220
%assign	SYS_semget	221
%assign	SYS_semop	222
%assign	SYS_semconfig	223
;				/* 220 is excluded compat_14_semctl */
;				/* 221 is excluded semget */
;				/* 222 is excluded semop */
;				/* 223 is excluded semconfig */
%assign	SYS_compat_14_msgctl	224
%assign	SYS_msgget	225
%assign	SYS_msgsnd	226
%assign	SYS_msgrcv	227
;				/* 224 is excluded compat_14_msgctl */
;				/* 225 is excluded msgget */
;				/* 226 is excluded msgsnd */
;				/* 227 is excluded msgrcv */
%assign	SYS_shmat	228
%assign	SYS_compat_14_shmctl	229
%assign	SYS_shmdt	230
%assign	SYS_shmget	231
;				/* 228 is excluded shmat */
;				/* 229 is excluded compat_14_shmctl */
;				/* 230 is excluded shmdt */
;				/* 231 is excluded shmget */
%assign	SYS_clock_gettime	232
%assign	SYS_clock_settime	233
%assign	SYS_clock_getres	234
%assign	SYS_nanosleep	240
%assign	SYS_fdatasync	241
%assign	SYS_mlockall	242
%assign	SYS_munlockall	243
%assign	SYS___posix_rename	270
%assign	SYS_swapctl	271
%assign	SYS_getdents	272
%assign	SYS_minherit	273
%assign	SYS_lchmod	274
%assign	SYS_lchown	275
%assign	SYS_lutimes	276
%assign	SYS___msync13	277
%assign	SYS___stat13	278
%assign	SYS___fstat13	279
%assign	SYS___lstat13	280
%assign	SYS___sigaltstack14	281
%assign	SYS___vfork14	282
%assign	SYS___posix_chown	283
%assign	SYS___posix_fchown	284
%assign	SYS___posix_lchown	285
%assign	SYS_getsid	286
%assign	SYS_fktrace	288
;				/* 288 is excluded ktrace */
%assign	SYS_preadv	289
%assign	SYS_pwritev	290
%assign	SYS___sigaction14	291
%assign	SYS___sigpending14	292
%assign	SYS___sigprocmask14	293
%assign	SYS___sigsuspend14	294
%assign	SYS___sigreturn14	295
%assign	SYS_getcwd	296
%assign	SYS_fchroot	297
%assign	SYS_fhopen	298
%assign	SYS_fhstat	299
%assign	SYS_fhstatfs	300
%assign	SYS_____semctl13	301
;				/* 301 is excluded ____semctl13 */
%assign	SYS___msgctl13	302
;				/* 302 is excluded __msgctl13 */
%assign	SYS___shmctl13	303
;				/* 303 is excluded __shmctl13 */
%assign	SYS_lchflags	304
%assign	SYS_issetugid	305
%assign	SYS_MAXSYSCALL	306

;
;loopbacks
;

%assign	SYS_sigaction	SYS___sigaction14
%assign	SYS_uname	SYS_compat_09_ouname
%assign	SYS_stat	SYS_compat_43_stat43
%assign	SYS_lstat	SYS_compat_43_lstat43
%assign	SYS_fstat	SYS_compat_43_fstat43
%assign	SYS_sethostname	SYS_compat_43_osethostname
%assign	SYS_gethostname	SYS_compat_43_ogethostname
%assign	SYS_setdomainname	SYS_compat_09_osetdomainname
%assign	SYS_setdomainname	SYS_compat_09_ogetdomainname

%assign	SYS_signal	SYS_getpid
%assign	SYS_alarm	SYS_getpid

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

%endif	;__NETBSD_INC
