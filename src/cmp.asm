; Copyright (C) 2002 Thomas M. Ogrisegg
;
; $Id: cmp.asm,v 1.1 2002/02/14 17:46:22 konst Exp $
;
; cmp - compare two files
;
; syntax:
;        cmp [ -l | -s ] file1 file2
;
; Note: -l and -s are currently ignored
;
; License           :       GNU General Public License
; Author            :       Thomas Ogrisegg
; E-Mail            :       tom@rhadamanthys.org
; Version           :       0.9
; Release-Date      :       02/12/02
; Last updated      :       02/12/02
; SuSV2-Compliant   :       not yet
; GNU-compatible    :       not yet
;

%include "system.inc"

CODESEG

ltostr:
		mov ebx, 0x0a
		mov ecx, 0x10
		mov edi, esi
		add esi, ecx
.Ldiv:
		xor edx, edx
		idiv ebx
		add dl, '0'
		mov byte [esi+ecx], dl
		dec ecx
		or  eax, eax
		jnz .Ldiv

		add esi, ecx
		sub ecx, 0x10
		neg ecx
		inc esi
		repnz movsb
		ret

lstrcpy:
		lodsb
.Llabel:
		stosb
		lodsb
		or al, al
		jnz .Llabel
		mov al, ' '
		stosb
		ret

START:
		pop ecx
		cmp ecx, 0x2
		jng near syntax_error
		pop esi
		xor ebp, ebp

		sys_brk 0x0
		mov [cbrk], eax

.Larg_loop:
		pop esi
		or esi, esi
		jz near .Lcommit
		lodsb
		cmp al, '-'
		jnz .Lopen_file
		lodsb
		or al, al
		jz .Lopen_term
		cmp al, 's'
		jz .Lset_s
		cmp al, 'l'
		jnz near syntax_error
		or long [opts], 0x10
		jmp .Larg_loop
.Lset_s:
		or long [opts], 0x8
		jmp .Larg_loop
.Lopen_term:
		sub esi, 2
		mov long [fname1+ebp*4], esi
		or ebp, ebp
		jnz .Lcommit
		inc ebp
		jmp .Larg_loop
.Lopen_file:
		dec esi
		mov long [fname1+ebp*4], esi
		sys_open esi, O_RDONLY
		or eax, eax
		js near syntax_error
		mov [ffd1+ebp*4], eax
		or ebp, ebp
		jnz .Lcommit
		inc ebp
		jmp .Larg_loop
.Lread_to_mem:
		xor ecx, ecx
		push long [cbrk]
.Lalloc:
		mov eax, [cbrk]
		mov edx, 0x10000
		add eax, edx
		sys_brk eax
		mov [cbrk], eax
.Lread:
		sys_read STDIN, eax, 0x10000
		add ecx, eax
		sub edx, eax
		or edx, edx
		jz .Lalloc
		or eax, eax
		jnz .Lread
		pop ecx
		ret

.Lcommit:
		xor ebp, ebp
		dec ebp
.Lloop2:
		inc ebp
		sys_lseek [ffd1+ebp*4], 0, SEEK_END
		or eax, eax
		jns .Lmmap
		call .Lread_to_mem
		mov [map1+ebp*4], ecx
.Lmmap:
		mov [len1+ebp*4], eax
		push	ebp
		mov	edi,[ffd1+ebp*4]
		xor	ebp,ebp
		sys_mmap NULL, eax, PROT_READ, MAP_PRIVATE
		pop	ebp
		or eax, eax
		js .Lnext
		mov [map1+ebp*4], eax
.Lnext:
		or ebp, ebp
		jz .Lloop2
		
		push long map1
		mov esi, [map1]
		mov edi, [map2]
		mov ecx, [len1]
		cmp ecx, [len2]
		jnge .Lnext2
		pop ecx
		push long map2
		mov ecx, [len2]
.Lnext2:
		repz cmpsb
		mov edx, ecx
		or ecx, ecx
		jnz .Lnope

		mov ecx, [len1]
		cmp ecx, [len2]
		jz near .Lexit_ok
		jmp .Lcheck_next

.Lnope:
		pop edi

		mov ecx, [edi+8]
		sub ecx, edx
		push ecx
		mov edi, [edi]
		mov al, __n
		xor ebx, ebx

.Lfind_crs:
		inc ebx
		repnz scasb
		or ecx, ecx
		jnz .Lfind_crs

		mov edi, buffer
		mov esi, [fname1]
		call lstrcpy
		mov esi, [fname2]
		call lstrcpy
		mov esi, differ
		call lstrcpy
		pop eax
		push ebx
		mov esi, edi
		call ltostr
		mov esi, line
		call lstrcpy
		pop eax
		mov esi, edi
		call ltostr
		mov al, __n
		stosb
		sub edi, buffer
		sys_write STDOUT, buffer, edi
		jmp .Lexit_err

.Lcheck_next:
		mov edi, [edi-0x10]
		push edi
		xor eax, eax
		xor ecx, ecx
		dec ecx
		repnz scasb
		neg ecx
		mov al, __n
		stosb
		push ecx
		sys_write STDOUT, EOF, eoflen
		pop ecx
		pop edi
		sys_write STDOUT, edi, ecx
.Lexit_err:
		sys_exit 0x1

.Lexit_ok:
		sys_exit 0x0

syntax_error:
		sys_exit 0x2

EOF	db	"cmp: EOF on "
eoflen	equ $ - EOF
differ	db	"differ: char", EOL
line	db	", line", EOL

UDATASEG

fname1	LONG	1
fname2	LONG	1
ffd1	LONG	1
ffd2	LONG	1
map1	LONG	1
map2	LONG	1
len1	LONG	1
len2	LONG	1
cbrk	LONG	1
opts	LONG	1
buffer	UCHAR	0x200

END

%ifdef __VIM__
vi:syntax=nasm
%endif
