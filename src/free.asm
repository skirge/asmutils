; Copyright (C) 2002 Thomas M. Ogrisegg
;
; $Id: free.asm,v 1.1 2002/03/26 05:25:29 konst Exp $
;
; hacker's free
;
; usage: free

; 03/25/02	-	initial version

%include "system.inc"

%if __KERNEL__ = 22
struc sysinfo
.uptime     LONG	1
.loads		ULONG	3
.totalram	ULONG	1
.freeram	ULONG	1
.sharedram	ULONG	1
.bufferram	ULONG	1
.totalswap	ULONG	1
.freeswap	ULONG	1
.procs		USHORT	1
.pad		CHAR	22
endstruc
%elif __KERNEL__ = 24
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
.totalhigh	ULONG	1
.freehigh	ULONG	1
.mem_unit	ULONG	1
.pad        CHAR    8
endstruc
%endif

CODESEG

;; <- %eax (number to convert)
;; -> %edi (output written to (edi))
ltostr:
		mov ebx, 0x0a
		mov ecx, 0x7
		or eax, eax
		jnz .Ldiv
		mov byte [edi+ecx], '0'
		dec ecx
		jmp .Lout
.Ldiv:
		or eax, eax
		jz .Lout
		xor edx, edx
		idiv ebx
		add dl, '0'
		mov byte [edi+ecx], dl
		dec ecx
		jnz .Ldiv
.Lout:
		add edi, ecx
		inc ecx
		std
		mov al, ' '
		repnz stosb
		cld
		add edi, 0x9
		mov ecx, 0x3
		repnz stosb
		ret

START:
		sys_write STDOUT, header, headerlen
		mov ebp, esp
		sys_sysinfo ebp
		sub esp, 80
		mov edi, esp
		mov eax, [ebp+sysinfo.totalram]
		shr eax, 0xa		; div 1024
		call ltostr
		mov eax, [ebp+sysinfo.totalram]
		sub eax, [ebp+sysinfo.freeram]
		shr eax, 0xa
		call ltostr
		mov eax, [ebp+sysinfo.freeram]
		shr eax, 0xa
		call ltostr
		mov eax, [ebp+sysinfo.sharedram]
		shr eax, 0xa
		call ltostr
		mov eax, [ebp+sysinfo.bufferram]
		shr eax, 0xa
		call ltostr
		mov byte [edi], __n
		mov edi, esp
		sys_write STDOUT, edi, 60
		sys_write STDOUT, header2, header2len
		mov eax, [ebp+sysinfo.totalswap]
		shr eax, 0xa
		call ltostr
		mov eax, [ebp+sysinfo.totalswap]
		sub eax, [ebp+sysinfo.freeswap]
		shr eax, 0xa
		call ltostr
		mov eax, [ebp+sysinfo.freeswap]
		shr eax, 0xa
		call ltostr
		mov byte [edi], __n
		mov edi, esp
		sys_write STDOUT, edi, 34
		sys_exit 0x0

tab	db	__t
header	db	"             total       used       free     shared    buffers", __n, "Mem:      "
headerlen	equ	$ - header

header2	db	"Swap:     "
header2len	equ	$ - header2

END
