; Copyright (C) 2000 Konstantin Boldyshev <konst@linuxassembly.org>
;
; $Id: os_beos.inc,v 1.2 2001/03/18 07:08:25 konst Exp $
;
; file          : os_beos.inc
; created       : 21-Feb-2000
; modified      : 11-Mar-2001
; version       : 0.14
; assembler     : nasm 0.98
; description   : beos kernel constants (R4.5.2)
; author        : Konstantin Boldyshev <konst@linuxassembly.org>
; comment       : included internally from system.inc
;
;IMPORTANT NOTES:
;
;BeOS port doesnot work yet (mostly because of weird BeOS kernel bugs)
;
;Be kernel developers do not want to share any information on syscalls,
;so I had to figure out these constants and system call convention
;manually by disassembling libroot.so (of course BIEW helped a lot).
;As BeOS is not Open Source, do not even think of blaming
;me if these few numbers will destroy your hard disk data,
;my BeOS hanged dozens times when I was playing with them.
;
;***
;Yes, syscall with invalid stack kills BeOS, shame on it!
;Likely being the first who tried to play with direct kernel calls
;on BeOS, I immediatelly run into nasty system crashes.
;
;Be has registered this bug before R5.0, but is not fixed in R5.0
;details are at http://bebugs.be.com/devbugs/detail.php3?oid=2324160
;
;Also there was a discussion on this bug in BeDevTalk mailing list
;during Feb-Mar 2000, it may be of your interest: look for the topics
;"assembly & BeOS", "system calls", "System call stress testing"
;in the BeDevTalk archives at http://www.escribe.com/software/bedevtalk/
;***
;
;Personally I think that at least half of entries here are correct ;)
;
;In BeOS most calls are done through int 0x25, but some
;go through int 0x26 (or syscall/sysenter instructions).
;Quite common is practice of implementing several library calls
;through one kernel call.
;
;Here are listed only int 0x25 calls (and only for R4.5.2)
;
;R5.0 has 0xC7 syscalls
;(according to libroot-obj.tgz, src/kernel/kit/obj.i586.dyn/scalls.o)
;
;BeOS kernel hackers, if you exist, HELP ME !!!

%ifndef __SYSTEM_INC
%error "this file must be included internally from system.inc !"
%endif

%ifndef __BEOS_INC
%define __BEOS_INC

;%error "Hey, are you crazy? Never play with fire!"

%macro DO_SYSCALL 0
%if __OPTIMIZE__=__O_SIZE__
	push	ebp
	push	edi
	push	esi
	push	edx
	push	ecx
	push	ebx
	push	eax
%endif
	int	0x25
%if __OPTIMIZE__=__O_SIZE__
	add	esp,byte 7*4
%endif
%endmacro

%macro	SYSCALL_GATE 0
__syscall_gate:

	DO_SYSCALL
	ret
%endmacro

;
;
;

%assign SYS_open		0
%assign SYS_close		1
%assign SYS_read		2
%assign SYS_write		3
%assign SYS_ioctl		4
%assign SYS_lseek		5
%assign SYS_time		7
%assign SYS_opendir		0x0c
%assign SYS_closedir		0x0f
%assign SYS_rewinddir		0x17
%assign SYS_reboot		0x18
%assign SYS_readdir		0x1c
%assign SYS_mkdir		0x1e
%assign SYS_symlink		0x1f
%assign SYS_readlink		0x23
%assign SYS_rename		0x26
%assign SYS_unlink		0x27
%assign SYS_mount		0x31
%assign SYS_exit		0x3f
%assign SYS_umount		0x40
%assign SYS_dup2		0x4a
%assign SYS_chdir		0x57
%assign SYS_access		0x58
%assign SYS_statfs		0x5f
%assign SYS_rmdir		0x60
%assign SYS_link		0x6e
%assign SYS_sync		0x6f
%assign SYS_sigaction		0x70
%assign SYS_sigpending		0x71
%assign SYS_pause		0x72
%assign SYS_sigsuspend		0x72
%assign SYS_kill		0x74
%assign SYS_stime		0x76
%assign SYS_getgid		0x77
%assign SYS_getpgrp		0x78
%assign SYS_alarm		0x79
%assign SYS_getppid		0x7a
%assign SYS_getuid		0x7b
%assign SYS_setgid		0x7c
%assign SYS_setpgid		0x7d
%assign SYS_setsid		0x7e
%assign SYS_setuid		0x7f

%assign SYS_fork		0xa1
%assign SYS_execve		0xa2
%assign SYS_waitpid		0xa3
%assign SYS_gettimeofday	0xa6

%assign SYS_readv		0xbf
%assign SYS_writev		0xc0

;
;???
;

%assign SYS_times		0xc2
%assign SYS_getrusage		0xc2

%assign SYS_nanosleep		0x0e
%assign SYS_lock		0x8e
%assign SYS_mmap		0xaa	;0xbc?
%assign SYS_munmap		0x45

%assign SYS_ftruncate	0x4b	;SYS_truncate, SYS_chmod
%assign SYS_fnctl	0x0b	;SYS_dup

;
;loopbacks
;
%assign SYS_getcwd	SYS_exit
%assign SYS_uname	SYS_exit
%assign SYS_chmod	SYS_exit
%assign SYS_chroot	SYS_exit

;
;int 0x26??
;

%assign SYS_mknod	SYS_exit
%assign SYS_getpid	SYS_exit
%assign SYS_utime	SYS_exit
%assign SYS_pipe	SYS_exit
%assign SYS_brk		SYS_exit
%assign SYS_signal	SYS_exit
%assign SYS_fstat	SYS_exit
%assign SYS_getgroups	SYS_exit

;BeOS has dprintf system call -- 0x68? Wow, I am impressed :)

%endif