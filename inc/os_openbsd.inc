; Copyright (C) 2000-2001 Konstantin Boldyshev <konst@linuxassembly.org>
; Copyright (C) 2000 Tani Hosokawa <unknown@riverstyx.net>
;
; $Id: os_openbsd.inc,v 1.4 2001/08/20 15:24:36 konst Exp $
;
; file          : os_openbsd.inc
; created       : 18-Aug-2000
; modified      : 20-Aug-2001
; version       : 0.15
; assembler     : nasm 0.98
; description   : OpenBSD kernel (2.7+) defined constants and structures
; author        : Tani Hosokawa <unknown@riverstyx.net>
; comment       : included internally from system.inc

%ifndef __SYSTEM_INC
%error "this file must be included internally from system.inc !"
%endif

%ifndef __OPENBSD_INC
%define __OPENBSD_INC

%macro	DO_SYSCALL 0
%if __OPTIMIZE__=__O_SIZE__
	push	ebp
	push	edi
	push	esi
	push	edx
	push	ecx
	push	ebx
	push	eax
%endif
	int	0x80
	jnc	%%_ok
	neg	eax
%%_ok:
%if __OPTIMIZE__=__O_SIZE__
	add	esp,byte 7*4
%endif
%endmacro

%macro	SYSCALL_GATE 0
__syscall_gate:

	DO_SYSCALL
	ret
%endmacro

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

%assign	SYS_brk		SYS_break
%assign	SYS_sysctl	SYS___sysctl
%assign	SYS_setdomainname SYS_compat_09_osetdomainname
%assign	SYS_setdomainname SYS_compat_09_ogetdomainname
%assign	SYS_sethostname	SYS_compat_43_osethostname
%assign	SYS_gethostname	SYS_compat_43_ogethostname
%assign	SYS_uname	SYS_compat_09_ouname
%assign	SYS_getdents	SYS_getdirentries
%assign	SYS_getcwd	SYS_getpid
%assign	SYS_signal	SYS_getpid
%assign	SYS_alarm	SYS_getpid

;
;
;

%assign CTL_MAXNAME	12	; largest number of components supported
%assign	CTLTYPE_NODE	1	; name is a node
%assign	CTLTYPE_INT	2	; name describes an integer
%assign	CTLTYPE_STRING	3	; name describes a string
%assign	CTLTYPE_QUAD	4	; name describes a 64-bit number
%assign	CTLTYPE_STRUCT	5	; name describes a structure
%assign	CTL_UNSPEC	0		; unused
%assign	CTL_KERN	1		; "high kernel": proc, limits
%assign	CTL_VM		2		; virtual memory
%assign	CTL_FS		3		; file system, mount type is next
%assign	CTL_NET		4		; network, see socket.h
%assign	CTL_DEBUG	5		; debugging parameters
%assign	CTL_HW		6		; generic cpu/io
%assign	CTL_MACHDEP	7		; machine dependent
%assign	CTL_USER	8		; user-level
%assign	CTL_DDB		9		; DDB user interface, see db_var.h
%assign CTL_VFS         10              ; VFS sysctl's
%assign	CTL_MAXID	11		; number of valid top-level ids
%assign	KERN_OSTYPE	 	 1	; string: system version
%assign	KERN_OSRELEASE	 	 2	; string: system release
%assign	KERN_OSREV	 	 3	; int: system revision
%assign	KERN_VERSION	 	 4	; string: compile time info
%assign	KERN_MAXVNODES	 	 5	; int: max vnodes
%assign	KERN_MAXPROC	 	 6	; int: max processes
%assign	KERN_MAXFILES	 	 7	; int: max open files
%assign	KERN_ARGMAX	 	 8	; int: max arguments to exec
%assign	KERN_SECURELVL	 	 9	; int: system security level
%assign	KERN_HOSTNAME		10	; string: hostname
%assign	KERN_HOSTID		11	; int: host identifier
%assign	KERN_CLOCKRATE		12	; struct: struct clockrate
%assign	KERN_VNODE		13	; struct: vnode structures
%assign	KERN_PROC		14	; struct: process entries
%assign	KERN_FILE		15	; struct: file entries
%assign	KERN_PROF		16	; node: kernel profiling info
%assign	KERN_POSIX1		17	; int: POSIX.1 version
%assign	KERN_NGROUPS		18	; int: # of supplemental group ids
%assign	KERN_JOB_CONTROL	19	; int: is job control available
%assign	KERN_SAVED_IDS		20	; int: saved set-user/group-ID
%assign	KERN_BOOTTIME		21	; struct: time kernel was booted
%assign	KERN_DOMAINNAME		22	; string: (YP) domainname
%assign	KERN_MAXPARTITIONS	23	; int: number of partitions/disk
%assign KERN_RAWPARTITION	24	; int: raw partition number
%assign	KERN_NTPTIME		25	; struct: extended-precision time
%assign	KERN_TIMEX		26	; struct: ntp timekeeping state
%assign	KERN_OSVERSION		27	; string: kernel build version
%assign	KERN_SOMAXCONN		28	; int: listen queue maximum
%assign	KERN_SOMINCONN		29	; int: half-open controllable param
%assign	KERN_USERMOUNT		30	; int: users may mount filesystems
%assign KERN_RND		31	; struct: rnd(4) statistics
%assign KERN_NOSUIDCOREDUMP	32	; int: no setuid coredumps ever */ 
%assign	KERN_FSYNC		33      ; int: file synchronization support
%assign	KERN_SYSVMSG		34      ; int: SysV message queue suppoprt
%assign	KERN_SYSVSEM		35      ; int: SysV semaphore support
%assign	KERN_SYSVSHM		36      ; int: SysV shared memory support
%assign	KERN_ARND		37	; int: random integer from arc4rnd
%assign	KERN_MSGBUFSIZE		38	; int: size of message buffer
%assign	KERN_MAXID		39	; number of valid kern ids
%assign KERN_PROC_ALL		0	; everything
%assign	KERN_PROC_PID		1	; by process id
%assign	KERN_PROC_PGRP		2	; by process group id
%assign	KERN_PROC_SESSION	3	; by session of pid
%assign	KERN_PROC_TTY		4	; by controlling tty
%assign	KERN_PROC_UID		5	; by effective uid
%assign	KERN_PROC_RUID		6	; by real uid
%assign	WMESGLEN	7
%assign	EPROC_CTTY	0x01	; controlling tty vnode active
%assign	EPROC_SLEADER	0x02	; session leader
%assign EMULNAMELEN	7
%assign	FS_POSIX	1		; POSIX flags
%assign	FS_MAXID	2
%assign	FS_POSIX_SETUID	1		; int: always clear SGID/SUID bit when owner change
%assign	FS_POSIX_MAXID	2
%assign	HW_MACHINE	 1		; string: machine class
%assign	HW_MODEL	 2		; string: specific machine model
%assign	HW_NCPU		 3		; int: number of cpus
%assign	HW_BYTEORDER	 4		; int: machine byte order
%assign	HW_PHYSMEM	 5		; int: total memory
%assign	HW_USERMEM	 6		; int: non-kernel memory
%assign	HW_PAGESIZE	 7		; int: software page size
%assign	HW_DISKNAMES	 8		; strings: disk drive names
%assign	HW_DISKSTATS	 9		; struct: diskstats[]
%assign	HW_MAXID	10		; number of valid hw ids
%assign	USER_CS_PATH		 1	; string: _CS_PATH
%assign	USER_BC_BASE_MAX	 2	; int: BC_BASE_MAX
%assign	USER_BC_DIM_MAX		 3	; int: BC_DIM_MAX
%assign	USER_BC_SCALE_MAX	 4	; int: BC_SCALE_MAX
%assign	USER_BC_STRING_MAX	 5	; int: BC_STRING_MAX
%assign	USER_COLL_WEIGHTS_MAX	 6	; int: COLL_WEIGHTS_MAX
%assign	USER_EXPR_NEST_MAX	 7	; int: EXPR_NEST_MAX
%assign	USER_LINE_MAX		 8	; int: LINE_MAX
%assign	USER_RE_DUP_MAX		 9	; int: RE_DUP_MAX
%assign	USER_POSIX2_VERSION	10	; int: POSIX2_VERSION
%assign	USER_POSIX2_C_BIND	11	; int: POSIX2_C_BIND
%assign	USER_POSIX2_C_DEV	12	; int: POSIX2_C_DEV
%assign	USER_POSIX2_CHAR_TERM	13	; int: POSIX2_CHAR_TERM
%assign	USER_POSIX2_FORT_DEV	14	; int: POSIX2_FORT_DEV
%assign	USER_POSIX2_FORT_RUN	15	; int: POSIX2_FORT_RUN
%assign	USER_POSIX2_LOCALEDEF	16	; int: POSIX2_LOCALEDEF
%assign	USER_POSIX2_SW_DEV	17	; int: POSIX2_SW_DEV
%assign	USER_POSIX2_UPE		18	; int: POSIX2_UPE
%assign	USER_STREAM_MAX		19	; int: POSIX2_STREAM_MAX
%assign	USER_TZNAME_MAX		20	; int: POSIX2_TZNAME_MAX
%assign	USER_MAXID		21	; number of valid user ids
%assign	CTL_DEBUG_NAME		0	; string: variable name
%assign	CTL_DEBUG_VALUE		1	; int: variable value
%assign	CTL_DEBUG_MAXID		20

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
;sys/stat.h
;

struc stat
.st_dev		U32	1
.st_ino		U32	1
.st_mode	U16	1
.st_nlink	U16	1
.st_uid		U32	1
.st_gid		U32	1
.st_rdev	U32	1
.st_atime	LONG	1
.st_atimensec	LONG	1
.st_mtime	LONG	1
.st_mtimensec	LONG	1
.st_ctime	LONG	1
.st_ctimensec	LONG	1
.st_size	U32	2
.st_blocks	U32	2
.st_blksize	U32	1
.st_flags	U32	1
.st_gen		U32	1
.st_lspare	U32	1
.st_qspare	U32	4
endstruc

;
;sys/dirent.h
;

struc dirent
.d_fileno	U32	1
.d_reclen	U16	1
.d_type		U8	1
.d_namlen	U8	1
.d_name		CHAR	NAME_MAX + 1
endstruc

%assign	DT_UNKNOWN	0
%assign	DT_FIFO		1
%assign	DT_CHR		2
%assign	DT_DIR		4
%assign	DT_BLK		6
%assign	DT_REG		8
%assign	DT_LNK		10
%assign	DT_SOCK		12
%assign	DT_WHT		14

;
;sys/termios.h
;

%assign NCCS 20
struc termios
.c_iflag	UINT	1	; input flags
.c_oflag	UINT	1	; output flags
.c_cflag	UINT	1	; control flags
.c_lflag	UINT	1	; local flags
.c_cc		UCHAR	NCCS	; control chars
.c_ispeed	UINT	1	; input speed
.c_ospeed	UINT	1	; output speed
endstruc

%assign TIOSZ	NCCS+4*6

%assign	ECHOE		0x00000002
%assign	ECHOK		0x00000004
%assign ECHO		0x00000008
%assign	ECHONL		0x00000010
%assign	ISIG		0x00000080
%assign	ICANON		0x00000100
%assign	IEXTEN		0x00000400
%assign EXTPROC         0x00000800
%assign TOSTOP		0x00400000
%assign	NOFLSH		0x80000000

;
;sys/iocomm.h
;

%define	IOCPARM_MASK	0x1fff		;parameter length, at most 13 bits
%define	IOCPARM_LEN(x)	(((x) >> 16) & IOCPARM_MASK)
%define	IOCBASECMD(x)	((x) & ~(IOCPARM_MASK << 16))
%define	IOCGROUP(x)	(((x) >> 8) & 0xff)

;%define	IOCPARM_MAX	PAGE_SIZE	; max size of ioctl, mult. of PAGE_SIZE */
%define	IOC_VOID	0x20000000	; no parameters
%define	IOC_OUT		0x40000000	; copy out parameters
%define	IOC_IN		0x80000000	; copy in parameters
%define	IOC_INOUT	(IOC_IN|IOC_OUT)
%define	IOC_DIRMASK	0xe0000000	;mask for IN/OUT/VOID

%define	_IOC(inout,group,num,len) ((inout | ((len & IOCPARM_MASK) << 16) | ((group) << 8) | (num)))
%define	_IO(g,n)	_IOC(IOC_VOID,	(g), (n), 0)
%define	_IOR(g,n,sz)	_IOC(IOC_OUT,	(g), (n), sz)
%define	_IOW(g,n,sz)	_IOC(IOC_IN,	(g), (n), sz)
%define	_IOWR(g,n,sz)	_IOC(IOC_INOUT,	(g), (n), sz)

;
;sys/cdio.h
;

%define	CDIOCEJECT	_IO('c',24)

;
;sys/ttycom.h
;

%define	TIOCFLUSH	_IOW('t', 16, 4)	; flush buffers
%define	TIOCGETA	_IOR('t', 19, TIOSZ)	; get termios struct
%define	TIOCSETA	_IOW('t', 20, TIOSZ)	; set termios struct
%define	TIOCSETAW	_IOW('t', 21, TIOSZ)	; drain output, set
%define	TIOCSETAF	_IOW('t', 22, TIOSZ)	; drn out, fls in, set
%define	TIOCGETD	_IOR('t', 26, 4)	; get line discipline
%define	TIOCSETD	_IOW('t', 27, 4)	; set line discipline
%define	TIOCSBRK	_IO('t', 123)		; set break bit
%define	TIOCCBRK	_IO('t', 122)		; clear break bit
%define	TIOCSDTR	_IO('t', 121)		; set data terminal ready
%define	TIOCCDTR	_IO('t', 120)		; clear data terminal ready
%define	TIOCGPGRP	_IOR('t', 119, 4)	; get pgrp of tty
%define	TIOCSPGRP	_IOW('t', 118, 4)	; set pgrp of tty
%define	TIOCOUTQ	_IOR('t', 115, 4)	; output queue size
%define	TIOCSTI		_IOW('t', 114, 1)	; simulate terminal input
%define	TIOCNOTTY	_IO('t', 113)		; void tty association
%define	TIOCPKT		_IOW('t', 112, 4)	; pty: set/clear packet mode
%define	TIOCPKT_DATA		0x00		; data packet
%define	TIOCPKT_FLUSHREAD	0x01		; flush packet
%define	TIOCPKT_FLUSHWRITE	0x02		; flush packet
%define	TIOCPKT_STOP		0x04		; stop output
%define	TIOCPKT_START		0x08		; start output
%define	TIOCPKT_NOSTOP		0x10		; no more ^S, ^Q
%define	TIOCPKT_DOSTOP		0x20		; now do ^S ^Q
%define	TIOCPKT_IOCTL		0x40		; state change of pty driver
%define	TIOCSTOP	_IO('t', 111)		; stop output, like ^S
%define	TIOCSTART	_IO('t', 110)		; start output, like ^Q
%define	TIOCMSET	_IOW('t', 109, 4)	; set all modem bits
%define	TIOCMBIS	_IOW('t', 108, 4)	; bis modem bits
%define	TIOCMBIC	_IOW('t', 107, 4)	; bic modem bits
%define	TIOCMGET	_IOR('t', 106, 4)	; get all modem bits
%define	TIOCREMOTE	_IOW('t', 105, 4)	; remote input editing
%define	TIOCGWINSZ	_IOR('t', 104, 8)	; get window size
%define	TIOCSWINSZ	_IOW('t', 103, 8)	; set window size
%define	TIOCUCNTL	_IOW('t', 102, 4)	; pty: set/clr usr cntl mode
%define	TIOCSTAT	_IO('t', 101)		; simulate ^T status message
%define	UIOCCMD(n)	_IO('u', n)		; usr cntl op "n"
%define	TIOCCONS	_IOW('t', 98, 4)	; become virtual console
%define	TIOCSCTTY	_IO('t', 97)		; become controlling tty
%define	TIOCEXT		_IOW('t', 96, 4)	; pty: external processing
%define	TIOCSIG		_IO('t', 95)		; pty: generate signal
%define	TIOCDRAIN	_IO('t', 94)		; wait till output drained
%define	TIOCMSDTRWAIT	_IOW('t', 91, 4)	; modem: set wait on close
%define	TIOCMGDTRWAIT	_IOR('t', 90, 4)	; modem: get wait on close
%define	TIOCTIMESTAMP	_IOR('t', 89, 8)	; enable/get timestamp of last input event
%define	TIOCDCDTIMESTAMP _IOR('t', 88, 8)	; enable/get timestamp of last DCd rise
%define	TIOCSDRAINWAIT	_IOW('t', 87, 4)	; set ttywait timeout
%define	TIOCGDRAINWAIT	_IOR('t', 86, 4)	; get ttywait timeout

;

%define	TCGETS	TIOCGETA
%define	TCSETS	TIOCSETA
%define	TCSETSW	TIOCSETAW

;
;BSD specific syscalls
;

%macro sys_getfsstat 0-3
	__syscall getfsstat, 3, %0, %1, %2, %3
%endmacro

%macro sys_getdirentries 0-5
	__syscall getdirentries, 5, %0, %1, %2, %3, %4, %5
%endmacro

%macro	sys_sbrk	0-1
	__syscall sbrk, 1, %0, %1
%endmacro

%endif	;__OPENBSD_INC
