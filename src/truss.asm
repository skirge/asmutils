; Copyright (C) 2002 Thomas M. Ogrisegg
;
; truss - trace systemcalls of other processes
;
; syntax:
;       truss program
;
; License           :       GNU General Public License
; Author            :       Thomas Ogrisegg
; E-Mail            :       tom@rhadamanthys.org
; Created           :       05/05/02
; Last updated      :       06/09/02
; Version           :       0.1
; SuSV2-Compliant   :       not in SUSV2
; GNU-compatible    :       no GNU pendant
;
; $Id: truss.asm,v 1.1 2002/06/11 08:41:06 konst Exp $
;
; TODO:
;     trace pid's (PTRACE_ATTACH)
;     show parameters of syscall
;
; Notes:
;
; The following Shell-Script was used to extract the systemcall names:
; (a smiliar script should work with FreeBSD)
;
;#! /bin/sh
;
;grep "^#define __NR_" /usr/include/asm/unistd.h | \
;sed -e 's/^#define __NR_//' | awk '
;BEGIN   {
;		FS=" "
;}
;{
;		F = $1;
;		B = $2;
;		print $1 "  db  " "\""$1"\", EOL";
;}'
;
; The following Shell-Script was used to print the systemcall index:
;
;#! /bin/sh
;
;grep "^#define __NR_" /usr/include/asm/unistd.h | \
;sed -e 's/^#define __NR_//' | awk '
;BEGIN   {
;		FS=" "
;		print "syscall_table:"
;}
;{
;		F = $1;
;		B = $2;
;		print "  dd  " $1;
;}'
;
; General Notes on porting:
;
; SystemV-Unices (Solaris + Unixware) use proc(5)fs and do not provide a
; ptrace(2) Systemcall.
;
; At the BSD-Side it's a bit different. NetBSD and OpenBSD only provide
; a ktrace(2) Systemcall, but FreeBSD's ptrace is very similiar to  the
; Linux one. (Actually, the Net- and OpenBSD both have a ptrace System-
; call, but it doesn't "understand" the PTRACE_SYSCALL parameter)
;

%include "system.inc"

%ifdef __LINUX__
%assign PTRACE_TRACEME 0
%assign PTRACE_PEEKUSR 3
%assign PTRACE_SYSCALL 24
%assign PTRACE_GETREGS 12

struc user_regs
.ebx    LONG    1
.ecx    LONG    1
.edx    LONG    1
.esi    LONG    1
.edi    LONG    1
.ebp    LONG    1
.eax    LONG    1
.ds     USHORT  1
.__ds   USHORT  1
.es     USHORT  1
.__es   USHORT  1
.fs     USHORT  1
.__fs   USHORT  1
.gs     USHORT  1
.__gs   USHORT  1
.orig_eax   LONG    1
.eip    LONG    1
.cs     USHORT  1
.__cs   USHORT  1
.eflags LONG    1
.esp    LONG    1
.ss     USHORT  1
.__ss   USHORT  1
endstruc
%endif

CODESEG

exit  db  "exit", EOL
fork  db  "fork", EOL
read  db  "read", EOL
write  db  "write", EOL
open  db  "open", EOL
close  db  "close", EOL
waitpid  db  "waitpid", EOL
creat  db  "creat", EOL
link  db  "link", EOL
unlink  db  "unlink", EOL
execve  db  "execve", EOL
chdir  db  "chdir", EOL
time  db  "time", EOL
mknod  db  "mknod", EOL
chmod  db  "chmod", EOL
lchown  db  "lchown", EOL
break  db  "break", EOL
oldstat  db  "oldstat", EOL
lseek  db  "lseek", EOL
getpid  db  "getpid", EOL
mount  db  "mount", EOL
umount  db  "umount", EOL
setuid  db  "setuid", EOL
getuid  db  "getuid", EOL
stime  db  "stime", EOL
ptrace  db  "ptrace", EOL
alarm  db  "alarm", EOL
oldfstat  db  "oldfstat", EOL
pause  db  "pause", EOL
utime  db  "utime", EOL
stty  db  "stty", EOL
gtty  db  "gtty", EOL
access  db  "access", EOL
nice  db  "nice", EOL
ftime  db  "ftime", EOL
sync  db  "sync", EOL
kill  db  "kill", EOL
rename  db  "rename", EOL
mkdir  db  "mkdir", EOL
rmdir  db  "rmdir", EOL
dup  db  "dup", EOL
pipe  db  "pipe", EOL
_times  db  "times", EOL
prof  db  "prof", EOL
brk  db  "brk", EOL
setgid  db  "setgid", EOL
getgid  db  "getgid", EOL
signal  db  "signal", EOL
geteuid  db  "geteuid", EOL
getegid  db  "getegid", EOL
acct  db  "acct", EOL
umount2  db  "umount2", EOL
_lock  db  "lock", EOL
ioctl  db  "ioctl", EOL
fcntl  db  "fcntl", EOL
mpx  db  "mpx", EOL
setpgid  db  "setpgid", EOL
ulimit  db  "ulimit", EOL
oldolduname  db  "oldolduname", EOL
umask  db  "umask", EOL
chroot  db  "chroot", EOL
ustat  db  "ustat", EOL
dup2  db  "dup2", EOL
getppid  db  "getppid", EOL
getpgrp  db  "getpgrp", EOL
setsid  db  "setsid", EOL
sigaction  db  "sigaction", EOL
sgetmask  db  "sgetmask", EOL
ssetmask  db  "ssetmask", EOL
setreuid  db  "setreuid", EOL
setregid  db  "setregid", EOL
sigsuspend  db  "sigsuspend", EOL
sigpending  db  "sigpending", EOL
sethostname  db  "sethostname", EOL
setrlimit  db  "setrlimit", EOL
getrlimit  db  "getrlimit", EOL
getrusage  db  "getrusage", EOL
gettimeofday  db  "gettimeofday", EOL
settimeofday  db  "settimeofday", EOL
getgroups  db  "getgroups", EOL
setgroups  db  "setgroups", EOL
select  db  "select", EOL
symlink  db  "symlink", EOL
oldlstat  db  "oldlstat", EOL
readlink  db  "readlink", EOL
uselib  db  "uselib", EOL
swapon  db  "swapon", EOL
reboot  db  "reboot", EOL
readdir  db  "readdir", EOL
mmap  db  "mmap", EOL
munmap  db  "munmap", EOL
truncate  db  "truncate", EOL
ftruncate  db  "ftruncate", EOL
fchmod  db  "fchmod", EOL
fchown  db  "fchown", EOL
getpriority  db  "getpriority", EOL
setpriority  db  "setpriority", EOL
profil  db  "profil", EOL
statfs  db  "statfs", EOL
fstatfs  db  "fstatfs", EOL
ioperm  db  "ioperm", EOL
socketcall  db  "socketcall", EOL
syslog  db  "syslog", EOL
setitimer  db  "setitimer", EOL
getitimer  db  "getitimer", EOL
stat  db  "stat", EOL
lstat  db  "lstat", EOL
fstat  db  "fstat", EOL
olduname  db  "olduname", EOL
iopl  db  "iopl", EOL
vhangup  db  "vhangup", EOL
idle  db  "idle", EOL
vm86old  db  "vm86old", EOL
wait4  db  "wait4", EOL
swapoff  db  "swapoff", EOL
_sysinfo  db  "sysinfo", EOL
ipc  db  "ipc", EOL
fsync  db  "fsync", EOL
sigreturn  db  "sigreturn", EOL
clone  db  "clone", EOL
setdomainname  db  "setdomainname", EOL
uname  db  "uname", EOL
modify_ldt  db  "modify_ldt", EOL
adjtimex  db  "adjtimex", EOL
mprotect  db  "mprotect", EOL
sigprocmask  db  "sigprocmask", EOL
create_module  db  "create_module", EOL
init_module  db  "init_module", EOL
delete_module  db  "delete_module", EOL
get_kernel_syms  db  "get_kernel_syms", EOL
quotactl  db  "quotactl", EOL
getpgid  db  "getpgid", EOL
fchdir  db  "fchdir", EOL
bdflush  db  "bdflush", EOL
sysfs  db  "sysfs", EOL
personality  db  "personality", EOL
afs_syscall  db  "afs_syscall", EOL
setfsuid  db  "setfsuid", EOL
setfsgid  db  "setfsgid", EOL
_llseek  db  "_llseek", EOL
getdents  db  "getdents", EOL
_newselect  db  "_newselect", EOL
flock  db  "flock", EOL
msync  db  "msync", EOL
readv  db  "readv", EOL
writev  db  "writev", EOL
getsid  db  "getsid", EOL
fdatasync  db  "fdatasync", EOL
_sysctl  db  "_sysctl", EOL
mlock  db  "mlock", EOL
munlock  db  "munlock", EOL
mlockall  db  "mlockall", EOL
munlockall  db  "munlockall", EOL
sched_setparam  db  "sched_setparam", EOL
sched_getparam  db  "sched_getparam", EOL
sched_setscheduler  db  "sched_setscheduler", EOL
sched_getscheduler  db  "sched_getscheduler", EOL
sched_yield  db  "sched_yield", EOL
sched_get_priority_max  db  "sched_get_priority_max", EOL
sched_get_priority_min  db  "sched_get_priority_min", EOL
sched_rr_get_interval  db  "sched_rr_get_interval", EOL
nanosleep  db  "nanosleep", EOL
mremap  db  "mremap", EOL
setresuid  db  "setresuid", EOL
getresuid  db  "getresuid", EOL
vm86  db  "vm86", EOL
query_module  db  "query_module", EOL
poll  db  "poll", EOL
nfsservctl  db  "nfsservctl", EOL
setresgid  db  "setresgid", EOL
getresgid  db  "getresgid", EOL
prctl  db  "prctl", EOL
rt_sigreturn  db  "rt_sigreturn", EOL
rt_sigaction  db  "rt_sigaction", EOL
rt_sigprocmask  db  "rt_sigprocmask", EOL
rt_sigpending  db  "rt_sigpending", EOL
rt_sigtimedwait  db  "rt_sigtimedwait", EOL
rt_sigqueueinfo  db  "rt_sigqueueinfo", EOL
rt_sigsuspend  db  "rt_sigsuspend", EOL
pread  db  "pread", EOL
pwrite  db  "pwrite", EOL
chown  db  "chown", EOL
getcwd  db  "getcwd", EOL
capget  db  "capget", EOL
capset  db  "capset", EOL
sigaltstack  db  "sigaltstack", EOL
sendfile  db  "sendfile", EOL
getpmsg  db  "getpmsg", EOL
putpmsg  db  "putpmsg", EOL
vfork  db  "vfork", EOL
ugetrlimit  db  "ugetrlimit", EOL
mmap2  db  "mmap2", EOL
truncate64  db  "truncate64", EOL
ftruncate64  db  "ftruncate64", EOL
stat64  db  "stat64", EOL
lstat64  db  "lstat64", EOL
fstat64  db  "fstat64", EOL
lchown32  db  "lchown32", EOL
getuid32  db  "getuid32", EOL
getgid32  db  "getgid32", EOL
geteuid32  db  "geteuid32", EOL
getegid32  db  "getegid32", EOL
setreuid32  db  "setreuid32", EOL
setregid32  db  "setregid32", EOL
getgroups32  db  "getgroups32", EOL
setgroups32  db  "setgroups32", EOL
fchown32  db  "fchown32", EOL
setresuid32  db  "setresuid32", EOL
getresuid32  db  "getresuid32", EOL
setresgid32  db  "setresgid32", EOL
getresgid32  db  "getresgid32", EOL
chown32  db  "chown32", EOL
setuid32  db  "setuid32", EOL
setgid32  db  "setgid32", EOL
setfsuid32  db  "setfsuid32", EOL
setfsgid32  db  "setfsgid32", EOL
pivot_root  db  "pivot_root", EOL
mincore  db  "mincore", EOL
madvise  db  "madvise", EOL
madvise1  db  "madvise1", EOL
getdents64  db  "getdents64", EOL
fcntl64  db  "fcntl64", EOL

%ifdef __LINUX__
syscall_table:
  dd  exit
  dd  fork
  dd  read
  dd  write
  dd  open
  dd  close
  dd  waitpid
  dd  creat
  dd  link
  dd  unlink
  dd  execve
  dd  chdir
  dd  time
  dd  mknod
  dd  chmod
  dd  lchown
  dd  break
  dd  oldstat
  dd  lseek
  dd  getpid
  dd  mount
  dd  umount
  dd  setuid
  dd  getuid
  dd  stime
  dd  ptrace
  dd  alarm
  dd  oldfstat
  dd  pause
  dd  utime
  dd  stty
  dd  gtty
  dd  access
  dd  nice
  dd  ftime
  dd  sync
  dd  kill
  dd  rename
  dd  mkdir
  dd  rmdir
  dd  dup
  dd  pipe
  dd  _times
  dd  prof
  dd  brk
  dd  setgid
  dd  getgid
  dd  signal
  dd  geteuid
  dd  getegid
  dd  acct
  dd  umount2
  dd  _lock
  dd  ioctl
  dd  fcntl
  dd  mpx
  dd  setpgid
  dd  ulimit
  dd  oldolduname
  dd  umask
  dd  chroot
  dd  ustat
  dd  dup2
  dd  getppid
  dd  getpgrp
  dd  setsid
  dd  sigaction
  dd  sgetmask
  dd  ssetmask
  dd  setreuid
  dd  setregid
  dd  sigsuspend
  dd  sigpending
  dd  sethostname
  dd  setrlimit
  dd  getrlimit
  dd  getrusage
  dd  gettimeofday
  dd  settimeofday
  dd  getgroups
  dd  setgroups
  dd  select
  dd  symlink
  dd  oldlstat
  dd  readlink
  dd  uselib
  dd  swapon
  dd  reboot
  dd  readdir
  dd  mmap
  dd  munmap
  dd  truncate
  dd  ftruncate
  dd  fchmod
  dd  fchown
  dd  getpriority
  dd  setpriority
  dd  profil
  dd  statfs
  dd  fstatfs
  dd  ioperm
  dd  socketcall
  dd  syslog
  dd  setitimer
  dd  getitimer
  dd  stat
  dd  lstat
  dd  fstat
  dd  olduname
  dd  iopl
  dd  vhangup
  dd  idle
  dd  vm86old
  dd  wait4
  dd  swapoff
  dd  _sysinfo
  dd  ipc
  dd  fsync
  dd  sigreturn
  dd  clone
  dd  setdomainname
  dd  uname
  dd  modify_ldt
  dd  adjtimex
  dd  mprotect
  dd  sigprocmask
  dd  create_module
  dd  init_module
  dd  delete_module
  dd  get_kernel_syms
  dd  quotactl
  dd  getpgid
  dd  fchdir
  dd  bdflush
  dd  sysfs
  dd  personality
  dd  afs_syscall
  dd  setfsuid
  dd  setfsgid
  dd  _llseek
  dd  getdents
  dd  _newselect
  dd  flock
  dd  msync
  dd  readv
  dd  writev
  dd  getsid
  dd  fdatasync
  dd  _sysctl
  dd  mlock
  dd  munlock
  dd  mlockall
  dd  munlockall
  dd  sched_setparam
  dd  sched_getparam
  dd  sched_setscheduler
  dd  sched_getscheduler
  dd  sched_yield
  dd  sched_get_priority_max
  dd  sched_get_priority_min
  dd  sched_rr_get_interval
  dd  nanosleep
  dd  mremap
  dd  setresuid
  dd  getresuid
  dd  vm86
  dd  query_module
  dd  poll
  dd  nfsservctl
  dd  setresgid
  dd  getresgid
  dd  prctl
  dd  rt_sigreturn
  dd  rt_sigaction
  dd  rt_sigprocmask
  dd  rt_sigpending
  dd  rt_sigtimedwait
  dd  rt_sigqueueinfo
  dd  rt_sigsuspend
  dd  pread
  dd  pwrite
  dd  chown
  dd  getcwd
  dd  capget
  dd  capset
  dd  sigaltstack
  dd  sendfile
  dd  getpmsg
  dd  putpmsg
  dd  vfork
  dd  ugetrlimit
  dd  mmap2
  dd  truncate64
  dd  ftruncate64
  dd  stat64
  dd  lstat64
  dd  fstat64
  dd  lchown32
  dd  getuid32
  dd  getgid32
  dd  geteuid32
  dd  getegid32
  dd  setreuid32
  dd  setregid32
  dd  getgroups32
  dd  setgroups32
  dd  fchown32
  dd  setresuid32
  dd  getresuid32
  dd  setresgid32
  dd  getresgid32
  dd  chown32
  dd  setuid32
  dd  setgid32
  dd  setfsuid32
  dd  setfsgid32
  dd  pivot_root
  dd  mincore
  dd  madvise
  dd  madvise1
  dd  getdents64
  dd  fcntl64
%endif

hextostr:
		std
		push edi
		add edi, 0x7
		mov edx, 0x8
.Lloop:
		mov al, cl
		and al, 0xf
		add al, '0'
		cmp al, '9'
		jng .Lstos
		add al, 0x27
.Lstos:
		stosb
		shr ecx, 0x4
		jz .Lout
		dec edx
		jnz .Lloop
.Lout:
		cld
		mov esi, edi
		pop edi
		dec edi
		mov ecx, edx
		lea eax, [edx-0x9]
		neg eax
		lea ecx, [eax+1]
		repnz movsb
		mov byte [edi+eax],0
		ret

		foo	db	"Hello", __n
START:
		pop ecx
		lea ebp, [esp+ecx*4+4]
		dec ecx
		jz near .Lexit
		pop esi

		sys_fork

		mov [pid], eax
		or   eax, eax
		js   near .Lexit
		jz   near .trace

.Lnext:
		sys_wait4 -1, NULL, NULL, NULL
		or eax, eax
		js near .Lexit
		sys_ptrace PTRACE_SYSCALL, [pid], 0x1, NULL

.wait_loop:
		sys_wait4 -1, NULL, NULL, NULL
		or eax, eax
		js near .Lexit
		sys_ptrace PTRACE_GETREGS, [pid], NULL, regs

		mov ecx, [regs.orig_eax]
		mov edi, [syscall_table+ecx*4-4]
		xor eax, eax
		xor ecx, ecx
		dec ecx
		repnz scasb
		lea edi, [edi+ecx+1]
		not ecx
		dec ecx
		sys_write STDOUT, edi, ecx
		sys_write STDOUT, pfeil, 4

		sys_ptrace PTRACE_SYSCALL, [pid], 0x1, NULL
		sys_wait4 -1, NULL, NULL, NULL

		sys_ptrace PTRACE_GETREGS, [pid], NULL, regs
		mov edi, buf+80
		mov ecx, [regs.eax]
		call hextostr
		sys_write STDOUT, buf+80, eax
		sys_write STDOUT, nl,  1
		sys_ptrace PTRACE_SYSCALL, [pid], 0x1, NULL
		jmp .wait_loop

.trace:
		sys_ptrace PTRACE_TRACEME, NULL, NULL, NULL
		xor ecx, ecx

		mov esi, [esp]
		cmp byte [esi], '/'
		jz .Ldirect_exec
		cmp byte [esi], '.'
		jz .Ldirect_exec
.Lexecvp:
		mov esi, [ebp+ecx*4]
		or esi, esi
		jz near .Lexit
		lodsd
		inc ecx
		cmp eax, 'PATH'
		jnz .Lexecvp
		lodsb
		cmp al, '='
		jnz .Lexecvp
		xor eax, eax
		xor ecx, ecx
		dec ecx
		mov edi, esi
		repnz scasb
		mov edx, ecx
		xor ecx, ecx
		dec ecx
		mov edi, [esp]
		repnz scasb
		add ecx, edx

.Lexecv_next:
		lea edi, [esp+ecx]
.Lcopy_loop:
		lodsb
		cmp al, ':'
		jz .Lpath_end
		stosb
		or al, al
		jnz .Lcopy_loop
.Lpath_end:
		push esi
		mov esi, [esp+4]
		mov al, '/'
		stosb

.Lcopy_loop2:
		lodsb
		stosb
		or al, al
		jnz .Lcopy_loop2
		lea ebx, [esp+ecx+4]
		mov edi, ecx
		pop esi
		sys_execve ebx, esp, ebp
		mov ecx, edi
		jmp .Lexecv_next

.Ldirect_exec:
		sys_execve esi, esp, ebp

.Lexit:
		sys_exit 0x1

nl	db	__n
pfeil	db	" -> "

UDATASEG
pid	ULONG	1
buf	UCHAR	800
%ifdef __LINUX__
regs	B_STRUC	user_regs,.ebx,.ecx,.edx,.eax,.orig_eax,.eip
%endif
END
