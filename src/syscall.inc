; Copyright (C) 1999-2000 Konstantin Boldyshev <konst@voshod.com>
;
; $Id: syscall.inc,v 1.2 2000/02/01 19:56:20 konst Exp $
;
; file		: syscall.inc
; created	: 01-Aug-1999
; modified	: 27-Jan-2000
; version	: 0.06
; assembler	: nasm 0.98
; description	: system call macros
; author	: Konstantin Boldyshev <konst@voshod.com>
; comment	: included internally from system.inc

%ifdef __SYSTEM_INC

%ifndef __SYSCALL_INC
%define __SYSCALL_INC

;
;internal system call macros
;

%macro __syscall		0-1
%if %0>0
	_mov	eax,%{1}
%endif
	int	0x80
%endmacro

%macro	__syscall_setregs 1-6
%if %1>0
 %if %1>1
  %if %1>2
   %if %1>3
    %if %1>4
    _mov	edi,%6
    %endif
    _mov	esi,%5
   %endif
    _mov	edx,%4
  %endif
   _mov		ecx,%3
 %endif
  _mov		ebx,%2
%endif
%endmacro

;--------------------------------------------------------------------------
;				System Calls
;--------------------------------------------------------------------------


;--------------------------------------------------------------------------
;arch/i386/
;--------------------------------------------------------------------------

;
;arch/i386/kernel/ioport.c
;

%macro sys_ioperm 0-3
	__syscall_setregs %0,%1,%2,%3
	__syscall __NR_ioperm
%endmacro

%macro sys_iopl 0-1
	__syscall_setregs %0,%1
	__syscall __NR_iopl
%endmacro

;
;arch/i386/kernel/ldt.c
;

%macro sys_modify_ldt 0-3
	__syscall_setregs %0,%1,%2,%3
	__syscall __NR_modify_ldt
%endmacro

;
;arch/i386/kernel/process.c
;

%macro sys_idle 0
	__syscall __NR_idle
%endmacro

%macro sys_fork 0-1
	__syscall_setregs %0,%1
	__syscall __NR_fork
%endmacro

%macro sys_clone 0-1
	__syscall_setregs %0,%1
	__syscall __NR_clone
%endmacro

%macro sys_vfork 0-1
	__syscall_setregs %0,%1
	__syscall __NR_vfork
%endmacro

%macro sys_execve 0-3
	__syscall_setregs %0,%1,%2,%3
	__syscall __NR_execve
%endmacro

;
;arch/i386/kernel/ptrace.c
;

%macro sys_ptrace 0-4
	__syscall_setregs %0,%1,%2,%3,%4
	__syscall __NR_ptrace
%endmacro

;
;arch/i386/kernel/signal.c
;

%macro sys_sigaction 0-3
	__syscall_setregs %0,%1,%2,%3
	__syscall __NR_sigaction
%endmacro

%macro sys_altstack 0-2
	__syscall_setregs %0,%1,%2
	__syscall __NR_rt_altstack
%endmacro

%macro sys_sigreturn 0-1
	__syscall_setregs %0,%1
	__syscall __NR_sigreturn
%endmacro

%macro sys_rt_sigreturn 0-1
	__syscall_setregs %0,%1
	__syscall __NR_rt_sigreturn
%endmacro

%macro sys_sigsuspend 0-3
	__syscall_setregs %0,%1,%2,%3
	__syscall __NR_sigsuspend
%endmacro

%macro sys_rt_sigsuspend 0-2
	__syscall_setregs %0,%1,%2
	__syscall __NR_rt_sigsuspend
%endmacro

;
;arch/i386/kernel/sys_i386.c
;

%macro sys_pause 0
	__syscall __NR_pause
%endmacro

%macro sys_mmap 0-1
	__syscall_setregs %0,%1
	__syscall __NR_mmap
%endmacro

%macro sys_pipe 0-1
	__syscall_setregs %0,%1
	__syscall __NR_pipe
%endmacro

%macro sys_uname 0-1
	__syscall_setregs %0,%1
	__syscall __NR_uname
%endmacro

;
;arch/i386/kernel/vm86.c
;

%macro sys_vm86old 0-1
	__syscall_setregs %0,%1
	__syscall __NR_vm86old
%endmacro

%macro sys_vm86 0-2
	__syscall_setregs %0,%1,%2
	__syscall __NR_vm86
%endmacro

;--------------------------------------------------------------------------
;fs/
;--------------------------------------------------------------------------

;
;fs/readdir.c
;

%macro sys_getdents 0-3
	__syscall_setregs %0,%1,%2,%3
	__syscall __NR_getdents
%endmacro

;
;fs/dcache.c
;

%macro sys_getcwd 0-2
	__syscall_setregs %0,%1,%2
	__syscall __NR_getcwd
%endmacro


;
;fs/read_write.c
;

%macro sys_read 0-3
	__syscall_setregs %0,%1,%2,%3
	__syscall __NR_read
%endmacro

%macro sys_write 0-3
	__syscall_setregs %0,%1,%2,%3
	__syscall __NR_write
%endmacro

%macro sys_lseek 0-3
	__syscall_setregs %0,%1,%2,%3
	__syscall __NR_lseek
%endmacro

;
;fs/open.c
;

%macro sys_open 0-3
	__syscall_setregs %0,%1,%2,%3
	__syscall __NR_open
%endmacro

%macro sys_close 0-1
	__syscall_setregs %0,%1
	__syscall __NR_close
%endmacro

%macro sys_statfs 0-2
	__syscall_setregs %0,%1,%2
	__syscall __NR_statfs
%endmacro

%macro sys_chroot 0-1
	__syscall_setregs %0,%1
	__syscall __NR_chroot
%endmacro

%macro sys_chmod 0-2
	__syscall_setregs %0,%1,%2
	__syscall __NR_chmod
%endmacro

%macro sys_access 0-2
	__syscall_setregs %0,%1,%2
	__syscall  __NR_access
%endmacro

;
;fs/super.c
;

%macro sys_mount 0-5
	__syscall_setregs %0,%1,%2,%3,%4,%5
	__syscall __NR_mount
%endmacro

%macro sys_umount 0-1
	__syscall_setregs %0,%1
	__syscall __NR_umount
%endmacro

%macro sys_umount2 0-2
	__syscall_setregs %0,%1,%2
	__syscall __NR_umount2
%endmacro

;
;fs/buffer.c
;

%macro sys_sync 0
	__syscall __NR_sync
%endmacro

%macro sys_bdflush 0-2
	__syscall_setregs %0,%1,%2
	__syscall __NR_bdflush
%endmacro

;
;fs/namei.c
;

%macro sys_mkdir 0-2
	__syscall_setregs %0,%1,%2
	__syscall __NR_mkdir
%endmacro

%macro sys_rmdir 0-1
	__syscall_setregs %0,%1
	__syscall __NR_rmdir
%endmacro

%macro sys_link 0-2
	__syscall_setregs %0,%1,%2
	__syscall __NR_link
%endmacro

%macro sys_symlink 0-2
	__syscall_setregs %0,%1,%2
	__syscall __NR_symlink
%endmacro

%macro sys_unlink 0-1
	__syscall_setregs %0,%1
	__syscall __NR_unlink
%endmacro

;
;fs/ioctl.c
;

%macro sys_ioctl 0-3
	__syscall_setregs %0,%1,%2,%3
	__syscall __NR_ioctl
%endmacro

;
;fs/stat.c
;

%macro sys_readlink 0-3
	__syscall_setregs %0,%1,%2,%3
	__syscall __NR_readlink
%endmacro

%macro sys_stat 0-2
	__syscall_setregs %0,%1,%2
	__syscall __NR_stat
%endmacro

%macro sys_fstat 0-2
	__syscall_setregs %0,%1,%2
	__syscall __NR_fstat
%endmacro

%macro sys_lstat 0-2
	__syscall_setregs %0,%1,%2
	__syscall __NR_lstat
%endmacro

;--------------------------------------------------------------------------
;kernel/
;--------------------------------------------------------------------------

;
;kernel/sched.c
;

%macro sys_alarm 0-1
	__syscall_setregs %0,%1
	__syscall __NR_alarm
%endmacro

%macro sys_nanosleep 0-2
	__syscall_setregs %0,%1,%2
	__syscall __NR_nanosleep
%endmacro

;
;kernel/signal.c
;

%macro sys_kill 0-2
	__syscall_setregs %0,%1,%2
	__syscall __NR_kill
%endmacro

%macro sys_signal 0-2
	__syscall_setregs %0,%1,%2
	__syscall __NR_signal
%endmacro

;
;kernel/sys.c
;

%macro sys_reboot 0-4
	__syscall_setregs %0,%1,%2,%3,%4
	__syscall __NR_reboot
%endmacro

%macro sys_sethostname 0-2
	__syscall_setregs %0,%1,%2
	__syscall __NR_sethostname
%endmacro

%macro sys_setdomainname 0-2
	__syscall_setregs %0,%1,%2
	__syscall __NR_setdomainname
%endmacro

;
;kernel/mmap.c
;

%macro sys_munmap 0-2
	__syscall_setregs %0,%1,%2
	__syscall __NR_munmap
%endmacro

%macro	sys_brk	0-1
	__syscall_setregs %0,%1
	__syscall __NR_brk
%endmacro

;
;kernel/exit.c
;

%macro sys_wait4 0-4
	__syscall_setregs %0,%1,%2,%3,%4
	__syscall __NR_wait4
%endmacro

%macro sys_exit 0-1
	__syscall_setregs %0,%1
	__syscall    __NR_exit
%endmacro

%macro sys_exit_true 0
	sys_exit 0
%endmacro

%macro sys_exit_false 0
%if __OPTIMIZE = __O_SIZE
	_mov	eax,__NR_exit
	mov	ebx,eax
	__syscall
%else
	sys_exit 1
%endif
%endmacro

;
;kernel/info.c
;

%macro sys_sysinfo 0-1
	__syscall_setregs %0,%1
	__syscall __NR_sysinfo
%endmacro

;
;kernel/printk.c
;

%macro sys_syslog 0-3
	__syscall_setregs %0,%1,%2,%3
	__syscall __NR_syslog
%endmacro

;
;kernel/module.c
;

%macro sys_delete_module 0-1
	__syscall_setregs %0,%1
	__syscall __NR_delete_module
%endmacro

%macro sys_init_module 0-2
	__syscall_setregs %0,%1,%2
	__syscall __NR_init_module
%endmacro

%macro sys_create_module 0-2
	__syscall_setregs %0,%1,%2
	__syscall __NR_create_module
%endmacro

%macro sys_query_module 0-5
	__syscall_setregs %0,%1,%2,%3,%4,%5
	__syscall __NR_query_module
%endmacro

%macro sys_get_kernel_syms 0-1
	__syscall_setregs %0,%1
	__syscall __NR_get_kernel_syms
%endmacro

;--------------------------------------------------------------------------
;mm/
;--------------------------------------------------------------------------

;
;mm/mprotect.c
;

%macro sys_mprotect 0-3
	__syscall_setregs %0,%1,%2,%3
	__syscall __NR_mprotect
%endmacro

;
;mm/filemap.c
;

%macro sys_sendfile 0-4
	__syscall_setregs %0,%1,%2,%3,%4
	__syscall __NR_sendfile
%endmacro

;
;mm/swapfile.c
;

%macro sys_swapon 0-2
	__syscall_setregs %0,%1,%2
	__syscall __NR_swapon
%endmacro

%macro sys_swapoff 0-1
	__syscall_setregs %0,%1
	__syscall __NR_swapoff
%endmacro


;--------------------------------------------------------------------------
;net/
;--------------------------------------------------------------------------

;
;net/socket.c
;

%macro sys_socketcall 0-3
	__syscall_setregs %0,%1,%2,%3
        __syscall __NR_socketcall
%endmacro

;--------------------------------------------------------------------------

%endif	;__SYSCALL_INC

%else

%error "this file must be included internally from system.inc !"

%endif	;__SYSTEM_INC
