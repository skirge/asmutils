; Copyright (C) 1999-2000 Konstantin Boldyshev <konst@linuxassembly.org>
;
; $Id: os_linux.inc,v 1.1 2000/02/10 15:07:04 konst Exp $
;
; file          : os_linux.inc
; created       : 08-Feb-2000
; modified      : 09-Feb-2000
; version       : 0.07
; assembler     : nasm 0.98
; description   : linux kernel defined constants (from includes)
; author        : Konstantin Boldyshev <konst@linuxassembly.org>
; comment       : included internally from system.inc

%ifdef	__SYSTEM_INC

%ifndef __LINUX_INC
%define __LINUX_INC

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
%assign SYS_prctl              172
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
;linux/net.h (socket calls_
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

%endif	;__LINUX_INC

%else

%error "this file must be included internally from system.inc !"

%endif	;__SYSTEM_INC
