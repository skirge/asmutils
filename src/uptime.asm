; Copyright (C) 2002 Thomas M. Ogrisegg
;
; $Id: uptime.asm,v 1.1 2002/03/26 05:25:29 konst Exp $
;
; hacker's uptime
;
; usage: uptime

; 03/25/02	-	initial version

%include "system.inc"

struc sysinfo
.uptime     LONG    1
.loads      ULONG   3
.totalram   ULONG   1
.freeram    ULONG   1
.sharedram  ULONG   1
.bufferram  ULONG   1
.totalswap  ULONG   1
.freeswap   ULONG   1
.procs      USHORT  1
.totalhigh  ULONG   1
.freehigh   ULONG   1
.mem_unit   ULONG   1
.pad        CHAR    8
endstruc

CODESEG

%assign UTMP_RECSIZE 384

%macro mdiv 1
	xor edx, edx
	mov ebx, %1
	idiv ebx
%endmacro

ltostr1:
		xor edx, edx
		mov ebx, 0xa
		idiv ebx
		or eax, eax
		jz .Lnext
		add al, '0'
		stosb
.Lnext:
		lea eax, [edx+'0']
		stosb
		ret

ltostr2:
		xor edx, edx
		mov ebx, 0xa
		idiv ebx
		add al, '0'
		stosb
		lea eax, [edx+'0']
		stosb
		ret

average:
		shr eax, 0x5
		add eax, 0xa
		push eax
		sar eax, 0xb
		call ltostr1
		mov al, '.'
		stosb
		pop eax
		and eax, 0x7ff
		imul eax, eax, 100
		sar eax, 0xb
		call ltostr2
		ret

START:
		sys_gettimeofday esp, NULL
		mov eax, [esp]
		mov edi, buf+1
		mov byte [edi-1], ' '
		xor ebp, ebp
		mdiv 31536000
		mov eax, edx
		mdiv 86400
		mov eax, edx
		mdiv 3600
		cmp eax, 0xc
		jng .pm
		sub eax, 0xc
		inc ebp
.pm:
		push edx
		call ltostr1
		mov al, ':'
		stosb
		pop eax
		mdiv 60
		call ltostr2
		or ebp, ebp
		mov ax, 'am'
		jz .Lam
		mov ax, 'pm'
.Lam:
		stosw
		mov eax, '  up'
		stosd
		mov ax, '  '
		stosw
		sys_sysinfo esp
		mov eax, [esp]				; uptime
		mdiv 31536000
		mov eax, edx
		mdiv 86400
		push edx
		or eax, eax
		jz .Lnext2
		call ltostr1
		mov eax, ' day'
		stosd
		mov eax, 's,  '
		stosd
.Lnext2:
		pop eax
		mdiv 3600
		push edx
		call ltostr1
		mov al, ':'
		stosb
		pop eax
		mdiv 60
		call ltostr2
		mov ax, ', '
		stosw
		xor ebp, ebp
		sys_open utmpfile, O_RDONLY
		or eax, eax
		js .Lno_utmp
		mov [ufd], eax
		sub esp, UTMP_RECSIZE
.Lread_next:
		sys_read [ufd], esp, UTMP_RECSIZE
		cmp long [esp+utmp.ut_type], USER_PROCESS
		jnz .Lnext
		inc ebp
.Lnext:
		or eax, eax
		jnz .Lread_next
.Lno_utmp:
		add esp, UTMP_RECSIZE
		mov eax, ebp
		call ltostr1
		mov long [edi+0x00], ' use'
		mov long [edi+0x04], 'rs, '
		mov long [edi+0x08], 'load'
		mov long [edi+0x0c], ' ave'
		mov long [edi+0x10], 'rage'
		mov word [edi+0x15], ': '
		add edi, 0x17
		mov eax, [esp+sysinfo.loads]
		call average
		mov ax, ', '
		stosw
		mov eax, [esp+sysinfo.loads+4]
		call average
		mov ax, ', '
		stosw
		mov eax, [esp+sysinfo.loads+8]
		call average
		mov al, __n
		stosb
		sys_write STDOUT, buf, 80
		sys_exit eax

utmpfile	db	_PATH_UTMP, EOL

UDATASEG
buf	UCHAR	80
ufd	ULONG	1
END
