; Copyright (C) 2002 Thomas M. Ogrisegg
;
; $Id: nm.asm,v 1.1 2002/02/14 17:46:22 konst Exp $
;
; nm - list symbols from ELF binary
;
; syntax:
;        nm [file-list]
;
; If filename is omitted "a.out" will be listed
;
; License           :       GNU General Public License
; Author            :       Thomas Ogrisegg
; E-Mail            :       tom@rhadamanthys.org
; Version           :       0.5
; Release-Date      :       02/02/02
; Last updated      :       02/12/02
; SuSV2-Compliant   :       no
; GNU-compatible    :       no
;

%include "system.incc

%assign SHT_SYMTAB 0x2

struc elf_hdr
.e_ident	UCHAR	16
.e_type		USHORT	1
.e_mach		USHORT	1
.e_version	LONG	1
.e_entry	LONG	1
.e_phoff	LONG	1
.e_shoff	LONG	1
.e_flags	LONG	1
.e_ehsize	SHORT	1
.e_phsize	SHORT	1
.e_phnum	SHORT	1
.e_shentsz	SHORT	1
.e_shnum	SHORT	1
.e_strndx	SHORT	1
endstruc
;; sizeof(elf_hdr) = 52 ;;

struc elf_shdr
.sh_name	LONG	1
.sh_type	LONG	1
.sh_flags	LONG	1
.sh_addr	LONG	1
.sh_offset	LONG	1
.sh_size	LONG	1
.sh_link	LONG	1
.sh_info	LONG	1
.sh_addal	LONG	1
.sh_entsz	LONG	1
endstruc
;; sizeof(elf_shdr) = 40 ;;

struc elf_sym
.st_name	LONG	1
.st_value	LONG	1
.st_size	LONG	1
.st_info	UCHAR	1
.st_other	UCHAR	1
.st_shndx	USHORT	1
endstruc
;; sizeof(elf_sym) = 16 ;;

CODESEG

;; %ecx <-
;; %edi ->
hextostr:
		std
		add edi, 0x7
		mov edx, 0x8
.Lloop:
		mov al, cl
		and al, 0xf
		add al, '0'
		cmp al, '9'
		jng .Lstos
		;; 0x7 = Uppercase, 0x27 = Lowercase ;;
		add al, 0x27
.Lstos:
		stosb
		shr ecx, 0x4
		dec edx
		jnz .Lloop
		cld
		ret

aout	db	"a.out", EOL

START:
		pop ecx
		pop esi
		dec ecx
		jnz argv_loop
		mov esi, aout
		jmp open
argv_loop:
		pop esi
		or esi, esi
		jz near exit
open:
		sys_open esi, O_RDONLY
		or eax, eax
		js near _error
		mov [fd], eax
		sys_lseek eax, 0, SEEK_END
		sys_mmap NULL, eax, PROT_READ | PROT_WRITE, MAP_PRIVATE, [fd], 0
		mov [ptr], eax
		mov esi, eax
		mov cx, [eax+elf_hdr.e_shnum]
		add eax, [eax+elf_hdr.e_shoff]
		sub eax, 40
		;; search symtab entry ;;
.Lsrch_symtab:
		add eax, 40
		dec ecx
		jz argv_loop
		cmp byte [eax+elf_shdr.sh_type], SHT_SYMTAB
		jnz .Lsrch_symtab
		;; found symtab entry  ;;
.Lfound_symtab:
		push eax
		push ecx
		mov [shdr], eax
		mov ebx, [eax+elf_shdr.sh_offset]
		mov ecx, [eax+elf_shdr.sh_size]
		shr ecx, 0x4		; sizeof(elf_sym)=16
		inc ecx
		add ebx, [ptr]
		sub ebx, 16
.Lsrch_symbols:
		dec ecx
		jz near .Lback
		add ebx, 0x10
		cmp long [ebx+elf_sym.st_name], 0x0
		jz .Lsrch_symbols
.Lfound:
		pusha
		mov edx, [eax+elf_shdr.sh_link]
		imul edx, 40
		mov eax, [ptr]
		add eax, [eax+elf_hdr.e_shoff]
		add eax, edx
		mov edx, [eax+elf_shdr.sh_offset]
		add edx, [ptr]
		add edx, [ebx+elf_sym.st_name]
		
		mov esi, edx
		mov ecx, edx
		mov ecx, [ebx+elf_sym.st_value]
		mov edi, buf
		call hextostr
		add edx, 0x8
		add edi, edx
		inc edi
		mov al, ' '
.Lstrlen:
		stosb
		lodsb
		inc edx
		or al, al
		jnz .Lstrlen

		mov al, __n
		stosb
		mov ecx, edi
		sub ecx, edx
		sys_write STDOUT, ecx, edx
		popa
		jmp .Lsrch_symbols
.Lback:
		pop ecx
		pop eax
.Lreturn:
		jmp .Lsrch_symtab

exit:
		sys_exit ebp

_error:
		sys_write STDOUT, errstr, errlen
		mov edi, esi
		xor al, al
		xor ecx, ecx
		dec ecx
		repnz scasb
		dec edi
		mov al, __n
		stosb
		not ecx
		sys_write STDOUT, esi, ecx
		inc ebp
		jmp argv_loop

errstr	db	"Error opening file: ", EOL
errlen equ $ - errstr -1
NL	db	__n

UDATASEG
buf	UCHAR	100
fd	LONG	1
ptr	LONG	1
shdr	LONG	1
link	LONG	1
END

%ifdef __VIM__
vi:syntax=nasm
%endif
