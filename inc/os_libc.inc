; Copyright (C) 2001 Konstantin Boldyshev <konst@linuxassembly.org>
;
; $Id: os_libc.inc,v 1.1 2001/08/21 12:58:17 konst Exp $
;
; file          : os_libc.inc
; created       : 20-Aug-2001
; modified      : 21-Aug-2001
; version       : 0.15
; assembler     : nasm 0.98
; description   : libc defined constants (from includes)
; author        : Konstantin Boldyshev <konst@linuxassembly.org>
; comment       : included internally from system.inc

%ifndef __SYSTEM_INC
%error "this file must be included internally from system.inc !"
%endif

%ifndef __LIBC_INC
%define __LIBC_INC

%macro	SYSCALL_GATE 0
%endmacro

%assign	FD_SETSIZE	1024

struc fd_set
	U32	FD_SETSIZE / 32
endstruc

;
;stat.h
;

struc Stat
.st_dev		ULONG	2
.st_ino		ULONG	1
.st_mode	USHORT	1
.st_nlink	USHORT	1
.st_uid		USHORT	1
.st_gid		USHORT	1
.st_rdev	ULONG	2
.st_size	ULONG	1
.st_blksize	ULONG	1
.st_blocks	ULONG	1
.st_atime	ULONG	1
.st_mtime	ULONG	1
.st_ctime	ULONG	1
endstruc

;
;signal.h
;

%assign SA_NOCLDSTOP	0x00000001
%assign SA_NOCLDWAIT	0x00000002
%assign SA_SIGINFO	0x00000004
%assign SA_ONSTACK	0x08000000
%assign SA_RESTART	0x10000000
%assign SA_NODEFER	0x40000000
%assign SA_RESETHAND	0x80000000
%assign SA_RESTORER	0x04000000

%assign SA_NOMASK	SA_NODEFER
%assign SA_ONESHOT	SA_RESETHAND

struc sigset_t
		U32	_NSIG / 32
endstruc

struc sigaction
.sa_handler	ULONG	1
.sa_flags	ULONG	1
.sa_restorer	ULONG	1
.sa_mask	resb	sigset_t_size
endstruc

;
;sys/dirent.h
;

struc dirent
.d_ino		ULONG	1
.d_off		ULONG	1
.d_reclen	USHORT	1
.d_name		CHAR	256
endstruc


;
;time.h
;

%assign	ITIMER_REAL	0
%assign	ITIMER_VIRTUAL	1
%assign	ITIMER_PROF	2

struc itimerval
.it_interval_sec:	ULONG	1
.it_interval_usec:	ULONG	1
.it_value_sec:		ULONG	1
.it_value_usec:		ULONG	1
endstruc

struc itimerspec
.it_interval_sec:	ULONG	1
.it_interval_nsec:	ULONG	1
.it_value_sec:		ULONG	1
.it_value_nsec:		ULONG	1
endstruc

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

%endif	;__LIBC_INC
