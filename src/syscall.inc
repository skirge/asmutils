; Copyright (C) 1999-2000 Konstantin Boldyshev <konst@linuxassembly.org>
;
; $Id: syscall.inc,v 1.4 2000/03/02 08:52:01 konst Exp $
;
; file		: syscall.inc
; created	: 01-Aug-1999
; modified	: 28-Feb-2000
; version	: 0.08
; assembler	: nasm 0.98
; description	: system call macros
; author	: Konstantin Boldyshev <konst@linuxassembly.org>
; comment	: included internally from system.inc

%ifndef	__SYSTEM_INC
%error "this file must be included internally from system.inc !"
%endif

%ifndef __SYSCALL_INC
%define __SYSCALL_INC

;
;internal system call macros
;

; system call definition
;
; NEVER USE THIS MACRO DIRECTLY!
;
; %1	syscall name
; %2	number of syscall parameters
; %3	number of registers to prepare
; %4...	parameters

%macro	__syscall 2-8

%if %0>2
%if %3>0
 %if %3>1
  %if %3>2
   %if %3>3
    %if %3>4
	_mov	edi,%8
    %endif
	_mov	esi,%7
   %endif
	_mov	edx,%6
  %endif
	_mov	ecx,%5
 %endif
	_mov	ebx,%4
%endif
%endif

%ifdef __LINUX__

	_mov	eax,SYS_%{1}
	int	0x80

%else

%if %0>2

%if %3 < %2
%assign P %2
%else
%assign P %3
%endif

%if P>0
 %if P>1
  %if P>2
   %if P>3
    %if P>4
	push	edi
    %endif
	push	esi
   %endif
	push	edx
  %endif
	push	ecx
 %endif
	push	ebx
%endif

%endif

%ifdef __LIBC__

extern %{1}
	call	%{1}
	_add	esp, (%{2}) * 4

%elifdef __FREEBSD__

	_mov	eax,SYS_%{1}
	push	eax
	call	7:0
	_add	esp, (%{2} + 1) * 4

%elifdef __BEOS__

	push	dword %%ret
	_mov	eax,SYS_%{1}
	int	0x25
%%ret:
	_add	esp, (%{2} + 1) * 4

%endif

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
	__syscall ioperm, 3, %0, %1, %2, %3
%endmacro

%macro sys_iopl 0-1
	__syscall iopl, 1, %0, %1
%endmacro

;
;arch/i386/kernel/ldt.c
;

%macro sys_modify_ldt 0-3
	__syscall modify_ldt, 3, %0, %1, %2, %3
%endmacro

;
;arch/i386/kernel/process.c
;

%macro sys_idle 0
	__syscall idle, 0
%endmacro

%macro sys_fork 0-1
	__syscall fork, 1, %0, %1
%endmacro

%macro sys_clone 0-1
	__syscall clone, 1, %0, %1
%endmacro

%macro sys_vfork 0-1
	__syscall vfork, 1, %0, %1
%endmacro

%macro sys_execve 0-3
	__syscall execve, 3, %0, %1, %2, %3
%endmacro

;
;arch/i386/kernel/ptrace.c
;

%macro sys_ptrace 0-4
	__syscall ptrace, 4, %0, %1, %2, %3, %4
%endmacro

;
;arch/i386/kernel/signal.c
;

%macro sys_sigaction 0-3
	__syscall sigaction, 3, %0, %1, %2, %3
%endmacro

%macro sys_altstack 0-2
	__syscall rt_altstack, 2, %0, %1, %2
%endmacro

%macro sys_sigreturn 0-1
	__syscall sigreturn, 1 %0, %1
%endmacro

%macro sys_rt_sigreturn 0-1
	__syscall rt_sigreturn, 1, %0, %1
%endmacro

%macro sys_sigsuspend 0-3
	__syscall sigsuspend, 3, %0, %1, %2, %3
%endmacro

%macro sys_rt_sigsuspend 0-2
	__syscall rt_sigsuspend, 2, %0, %1, %2
%endmacro

;
;arch/i386/kernel/sys_i386.c
;

%macro sys_pause 0
	__syscall pause, 0
%endmacro

%macro sys_mmap 0-1
	__syscall mmap, 1, %0, %1
%endmacro

%macro sys_pipe 0-1
	__syscall pipe, 1, %0, %1
%endmacro

%macro sys_uname 0-1
	__syscall uname, 1, %0, %1
%endmacro

;
;arch/i386/kernel/vm86.c
;

%macro sys_vm86old 0-1
	__syscall vm86old, 1, %0, %1
%endmacro

%macro sys_vm86 0-2
	__syscall vm86, 2, %0, %1, %2
%endmacro

;--------------------------------------------------------------------------
;fs/
;--------------------------------------------------------------------------

;
;fs/readdir.c
;

%macro sys_getdents 0-3
	__syscall getdents, 3, %0, %1, %2, %3
%endmacro

;
;fs/dcache.c
;

%macro sys_getcwd 0-2
	__syscall getcwd, 2, %0, %1, %2
%endmacro


;
;fs/read_write.c
;

%macro sys_read 0-3
	__syscall read, 3, %0, %1, %2, %3
%endmacro

%macro sys_write 0-3
	__syscall write, 3, %0, %1, %2, %3
%endmacro

%macro sys_lseek 0-3
	__syscall lseek, 3, %0, %1, %2, %3
%endmacro

;
;fs/open.c
;

%macro sys_open 0-3
	__syscall open, 3, %0, %1, %2, %3
%endmacro

%macro sys_close 0-1
	__syscall close, 1, %0, %1
%endmacro

%macro sys_statfs 0-2
	__syscall statfs, 2, %0, %1, %2
%endmacro

%macro sys_chroot 0-1
	__syscall chroot, 1, %0, %1
%endmacro

%macro sys_chmod 0-2
	__syscall chmod, 2, %0, %1, %2
%endmacro

%macro sys_access 0-2
	__syscall access, 2, %0, %1, %2
%endmacro

%macro sys_ftruncate 0-2
	__syscall ftruncate, 2, %0, %1, %2
%endmacro

;
;fs/super.c
;

%macro sys_mount 0-5
	__syscall mount, 5, %0, %1, %2, %3, %4, %5
%endmacro

%macro sys_umount 0-1
	__syscall umount, 1, %0, %1
%endmacro

%macro sys_umount2 0-2
	__syscall umount2, 2, %0, %1, %2
%endmacro

;
;fs/buffer.c
;

%macro sys_sync 0
	__syscall sync, 0
%endmacro

%macro sys_bdflush 0-2
	__syscall bdflush, 2, %0, %1, %2
%endmacro

;
;fs/fcntl.c
;

%macro sys_fcntl 0-3
    __syscall fcntl, 3, %0, %1, %2, %3
%endmacro

%macro sys_dup 0-1
	__syscall dup, 1, %0, %1, %2
%endmacro

%macro sys_dup2 0-2
	__syscall dup2, 2, %0, %1, %2
%endmacro

;
;fs/namei.c
;

%macro sys_mkdir 0-2
	__syscall mkdir, 2, %0, %1, %2
%endmacro

%macro sys_rmdir 0-1
	__syscall rmdir, 1, %0, %1
%endmacro

%macro sys_link 0-2
	__syscall link, 2, %0, %1, %2
%endmacro

%macro sys_symlink 0-2
	__syscall symlink, 2, %0, %1, %2
%endmacro

%macro sys_unlink 0-1
	__syscall unlink, 1, %0, %1
%endmacro

;
;fs/ioctl.c
;

%macro sys_ioctl 0-3
	__syscall ioctl, 3, %0, %1, %2, %3
%endmacro

;
;fs/stat.c
;

%macro sys_readlink 0-3
	__syscall readlink, 3, %0, %1, %2, %3
%endmacro

%macro sys_stat 0-2
	__syscall stat, 2, %0, %1, %2
%endmacro

%macro sys_fstat 0-2
	__syscall fstat, 2, %0, %1, %2
%endmacro

%macro sys_lstat 0-2
	__syscall lstat, 2, %0, %1, %2
%endmacro

;--------------------------------------------------------------------------
;kernel/
;--------------------------------------------------------------------------

;
;kernel/sched.c
;

%macro sys_alarm 0-1
	__syscall alarm, 1, %0, %1
%endmacro

%macro sys_nanosleep 0-2
	__syscall nanosleep, 2, %0, %1, %2
%endmacro

%macro sys_getuid 0
	__syscall getuid, 0
%endmacro

%macro sys_getgid 0
	__syscall getgid, 0
%endmacro


;
;kernel/signal.c
;

%macro sys_kill 0-2
	__syscall kill, 2, %0, %1, %2
%endmacro

%macro sys_signal 0-2
	__syscall signal, 2, %0, %1, %2
%endmacro

;
;kernel/sys.c
;

%macro sys_reboot 0-4
	__syscall reboot, 4, %0, %1, %2, %3, %4
%endmacro

%macro sys_sethostname 0-2
	__syscall sethostname, 2, %0, %1, %2
%endmacro

%macro sys_setdomainname 0-2
	__syscall setdomainname, 2, %0, %1, %2
%endmacro

;
;kernel/mmap.c
;

%macro sys_munmap 0-2
	__syscall munmap, 2, %0, %1, %2
%endmacro

%macro	sys_brk	0-1
	__syscall brk, 1, %0, %1
%endmacro

;
;kernel/exit.c
;

%macro sys_wait4 0-4
	__syscall wait4, 2, %0, %1, %2, %3, %4
%endmacro

%macro sys_exit 0-1
	__syscall exit, 1, %0, %1
%endmacro

%macro sys_exit_true 0
	sys_exit 0
%endmacro

%macro sys_exit_false 0
	sys_exit 1
%endmacro

;
;kernel/info.c
;

%macro sys_sysinfo 0-1
	__syscall sysinfo, 1, %0, %1
%endmacro

;
;kernel/printk.c
;

%macro sys_syslog 0-3
	__syscall syslog, 3, %0, %1, %2, %3
%endmacro

;
;kernel/module.c
;

%macro sys_delete_module 0-1
	__syscall delete_module, 1, %0, %1
%endmacro

%macro sys_init_module 0-2
	__syscall init_module, 2, %0, %1, %2
%endmacro

%macro sys_create_module 0-2
	__syscall create_module, 2, %0, %1, %2
%endmacro

%macro sys_query_module 0-5
	__syscall query_module, 5, %0, %1, %2, %3, %4, %5
%endmacro

%macro sys_get_kernel_syms 0-1
	__syscall get_kernel_syms, 1, %0, %1
%endmacro

;--------------------------------------------------------------------------
;mm/
;--------------------------------------------------------------------------

;
;mm/mprotect.c
;

%macro sys_mprotect 0-3
	__syscall mprotect, 3, %0, %1, %2, %3
%endmacro

;
;mm/filemap.c
;

%macro sys_sendfile 0-4
	__syscall sendfile, 4, %0, %1, %2, %3, %4
%endmacro

;
;mm/swapfile.c
;

%macro sys_swapon 0-2
	__syscall swapon, 2, %0, %1, %2
%endmacro

%macro sys_swapoff 0-1
	__syscall swapoff, 1, %0, %1
%endmacro

;--------------------------------------------------------------------------
;network syscalls
;--------------------------------------------------------------------------

%ifndef __LINUX__	;linux has its own implementation in os_linux.inc

%macro	sys_socket 3
	__syscall socket, 3, %0, %1, %2, %3
%endmacro

%macro	sys_accept 3
	__syscall accept, 3, %0, %1, %2, %3
%endmacro

%macro	sys_connect 3
	__syscall connect, 3, %0, %1, %2, %3
%endmacro

%macro	sys_bind 3
	__syscall bind, 3, %0, %1, %2, %3
%endmacro

%macro	sys_setsockopt 5
	__syscall setsockopt, 5, %0, %1, %2, %3, %4, %5
%endmacro

%macro	sys_getsockopt 5
	__syscall getsockopt, 5, %0, %1, %2, %3, %4, %5
%endmacro

%macro	sys_shutdown 2
	__syscall shutdown, 2, %0, %1, %2
%endmacro

%macro	sys_listen 2
	__syscall listen, 2, %0, %1, %2
%endmacro

%endif	;__LINUX__

;--------------------------------------------------------------------------

%endif
