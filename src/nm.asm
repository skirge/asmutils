; Copyright (C) 2002 Thomas M. Ogrisegg
;
; $Id: nm.asm,v 1.3 2002/02/16 17:54:03 konst Exp $
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
; Version           :       0.6
; Release-Date      :       02/02/02
; Last updated      :       02/16/02
; SuSV2-Compliant   :       no
; GNU-compatible    :       no
;

%include "system.inc"

%include "elfheader.inc"

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
		pop ebx
		dec ecx
		mov [argc],ecx
		jnz argv_loop
		mov ebx, aout
		jmps open

do_error:
		sys_write STDOUT, errstr, errlen
		xor edx,edx
		call write_fname
		inc ebp

argv_loop:
		pop ebx
		or ebx, ebx
		jnz open

do_exit:
		sys_exit ebp

open:
		mov [fname], ebx
		sys_open EMPTY, O_RDONLY
		or eax, eax
		js do_error
		mov [fd], eax
		sys_lseek eax, 0, SEEK_END
		push ebp
		sys_mmap NULL, eax, PROT_READ | PROT_WRITE, MAP_PRIVATE, [fd], 0
		pop ebp
		mov [ptr], eax
		mov esi, eax

		cmp [argc],byte 2
		jb .cont
		call write_nl
		mov dl,':'
		call write_fname
.cont:
		movzx ecx, word [eax+ELF32_Ehdr.e_shnum]
		add eax, [eax+ELF32_Ehdr.e_shoff]
		sub eax, byte 40
		;; search symtab entry ;;
.Lsrch_symtab:
		add eax, byte 40
		dec ecx
		jz argv_loop
		cmp byte [eax+ELF32_Shdr.sh_type], SHT_SYMTAB
		jnz .Lsrch_symtab
		;; found symtab entry  ;;
.Lfound_symtab:
		push eax
		push ecx
		mov [shdr], eax
		mov ebx, [eax+ELF32_Shdr.sh_offset]
		mov ecx, [eax+ELF32_Shdr.sh_size]
		shr ecx, 0x4		; sizeof(elf_sym)=16
		inc ecx
		add ebx, [ptr]
		sub ebx, byte 0x10
.Lsrch_symbols:
		dec ecx
		jz near .Lback
		add ebx, byte 0x10
		cmp long [ebx+ELF32_Sym.st_name], 0x0
		jz .Lsrch_symbols
.Lfound:
		pusha
		mov edx, [eax+ELF32_Shdr.sh_link]
		imul edx, 40
		mov eax, [ptr]
		add eax, [eax+ELF32_Ehdr.e_shoff]
		add eax, edx
		mov edx, [eax+ELF32_Shdr.sh_offset]
		add edx, [ptr]
		add edx, [ebx+ELF32_Sym.st_name]
		
		mov esi, edx
		mov ecx, edx
		mov ecx, [ebx+ELF32_Sym.st_value]
		mov edi, buf
		call hextostr
		add edx, byte 0x8
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

write_fname:
		pusha
		mov esi, [fname]
		mov edi, esi
		xor al, al
		xor ecx, ecx
		dec ecx
		repnz scasb
		not ecx
		or dl,dl
		jz .write
		dec edi
		mov al,dl
		stosb
.write:
		sys_write STDOUT, esi, ecx
		call write_nl
		popa
		ret

write_nl:
	pusha
	sys_write STDOUT,.nl,1
	popa
	ret
.nl:	db	__n

errstr	db	"Error opening file: ", EOL
errlen equ $ - errstr -1

UDATASEG

argc	DWORD	1
fname	DWORD	1
buf	UCHAR	100
fd	LONG	1
ptr	LONG	1
shdr	LONG	1
link	LONG	1

END

%ifdef __VIM__
vi:syntax=nasm
%endif
