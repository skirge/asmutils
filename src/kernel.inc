; Copyright (C) 1999-2000 Konstantin Boldyshev <konst@voshod.com>
;
; $Id: kernel.inc,v 1.1 2000/01/26 21:19:31 konst Exp $
;
; file		: kernel.inc
; created	: 12-Apr-1999
; modified	: 03-Jan-2000
; version	: 0.06
; assembler	: nasm 0.98
; description	: kernel structures (from kernel includes)
; author	: Konstantin Boldyshev <konst@voshod.com>
; comment	: you need this if you work with kernel structures

%ifndef __KERNEL_INC
%define __KERNEL_INC

;
;data types
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
;linux/utsname.h
;

luts		equ	65

struc new_utsname
.sysname	CHAR	luts
.nodename	CHAR	luts
.release	CHAR	luts
.version	CHAR	luts
.machine	CHAR	luts
.domainname	CHAR	luts
endstruc

;
;linux/time.h
;

struc timespec
.tv_sec		ULONG	1
.tv_nsec	ULONG	1
endstruc

;
;asm/stat.h
;

struc stat
.st_dev		USHORT	1
.__pad1		USHORT	1
.st_ino		ULONG	1
.st_mode	USHORT	1
.st_nlink	USHORT	1
.st_uid		USHORT	1
.st_gid		USHORT	1
.st_rdev	USHORT	1
.__pad2		USHORT	1
.st_size	ULONG	1
.st_blksize	ULONG	1
.st_blocks	ULONG	1
.st_atime	ULONG	1
.__unused1	ULONG	1
.st_mtime	ULONG	1
.__unused2	ULONG	1
.st_ctime	ULONG	1
.__unused3	ULONG	1
.__unused4	ULONG	1
.__unused5	ULONG	1
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
%if KERNEL=20
.ds	USHORT	1
.__dsu	USHORT	1
.es	USHORT	1
.__esu	USHORT	1
.fs	USHORT	1
.__fsu	USHORT	1
.gs	USHORT	1
.__gsu	USHORT	1
%elif KERNEL=22
.xds	INT	1
.xes	INT	1
%endif
.orig_eax	ULONG	1
.eip		ULONG	1
%if KERNEL=20
.cs	USHORT	1
.__csu	USHORT	1
%elif KERNEL=22
.xcs	INT	1
%endif
.eflags	ULONG	1
.esp	ULONG	1
%if KERNEL=20
.ss	USHORT	1
.__ssu	USHORT	1
%elif KERNEL=22
.xss	INT	1
%endif
endstruc

;
;linux/socket.h
;

struc	sockaddr
.sa_family_t	USHORT	1		;address family, AF_xxx
.sa_data	CHAR	14		;14 bytes of protocol address
endstruc

;
;linux/in.h
;

struc in_addr
.s_addr		U32	1
endstruc

%endif	;__KERNEL_INC
