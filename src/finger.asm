; Copyright (c) 2001 Thomas M. Ogrisegg
;
; $Id: finger.asm,v 1.3 2002/02/14 13:38:15 konst Exp $
;
; finger - user information lookup program
;
; usage:
;      finger
;
; License          :     GNU General Public License
; Author           :     Thomas Ogrisegg
; E-Mail           :     tom@rhadamanthys.org
; Created          :     12/02/01
; Processor        :     i386+
; SusV2-compliant  :     no
; GNU-compatible   :     no
; Feature-Complete :     no
;
; BUGS: 
;      probably many
;
; TODO: 
;      add individual user lookup
;

%include "system.inc"

CODESEG

init_data:
	sys_open utmpfile, O_RDONLY
	mov [utmpfd], eax
	sys_chdir devdir
	sys_open passwd, O_RDONLY
	mov [pwdfd], eax
	sys_fstat eax, statbuf
	sys_mmap 0, [statbuf.st_size], PROT_READ, MAP_PRIVATE, [pwdfd], 0
	mov [pwptr], eax
	sys_time ctime
	ret

START:
	call init_data
	sys_write STDOUT, banner, bannerlen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
read_next_utmp:
	sys_read [utmpfd], utmpbuf, 384
	or eax, eax
	jz near do_exit
	cmp long [utmpbuf.ut_type], USER_PROCESS
	jnz read_next_utmp
	mov edi, buf
	lea esi, [utmpbuf.ut_user]
	mov ecx, 11
	lodsb
.un_copy_loop:
	stosb
	dec ecx
	lodsb
	or al, al
	jnz .un_copy_loop

	mov al, ' '
	push ecx
	repnz stosb

	pop ecx
	neg ecx
	add ecx, 11
	call getusername
	sub ecx, 22
	neg ecx
	mov al, ' '
	repnz stosb

	mov esi, utmpbuf.ut_line
	mov ecx, 8

	lodsb
.tty_copy_loop:
	stosb
	dec ecx
	lodsb
	or al, al
	jnz .tty_copy_loop
	mov al, ' '
	repnz stosb

	sys_stat utmpbuf.ut_line, statbuf
	or eax, eax
	js near _write
	mov eax, [ctime]
	sub eax, [statbuf.st_atime]
	cmp eax, 60
	jng near nidle

	xor edx, edx
	mov ebx, 86400 ; 60*60*24
	idiv ebx
	or eax, eax
	jz _next1
	call lstr
	jmp _next2
_next1:
	xchg edx, eax
	mov long [edi], '    '
_next2:
	add edi, 3

	mov ebx, 3600
	idiv ebx
	or eax, eax
	jz _next3
	call lstr
	jmp _next4
_next3:
	xchg edx, eax
	mov long [edi], '    '
_next4:
	add edi, 3
	mov ebx, 60
	idiv ebx
	call lstr
	add edi, 2

end_idle:
	mov esi, utmpbuf.ut_host
	lodsb
	or al, al
	jz lnext
	mov long [edi],   '    '
	mov long [edi+4], '    '
	add edi, 4

uth_cp_loop:
	stosb
	lodsb
	or al, al
	jnz uth_cp_loop
lnext:
	mov byte [edi], __n
	mov byte [edi+1], 0
_write:
	mov edi, buf
	xor eax, eax
	mov ecx, 80
	repnz scasb
	sub ecx, 80
	not ecx
	sys_write STDOUT, buf, ecx
	jmp read_next_utmp
	jmp do_exit

nidle:
	mov long [edi],   '    '
	mov long [edi+4], '    '
	mov word [edi+6], '  '
	mov byte [edi+7], '-'
	add edi, 8
	jmp end_idle

;;;;;;;;;;;;;;;;;;;;;;;;;;;lstr;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Converts a long into a two-byte string
;; <- eax (long to convert)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lstr:
	push edx
	xor edx, edx
	mov ebx, 10
	idiv ebx
	add dl, '0'
	add al, '0'
	mov byte [edi],   al
	mov byte [edi+1], dl
	mov byte [edi+2], ':'
	xor edx, edx
	pop eax
	ret

;;;;;;;;;;;;;;;;;;;;;;getusername;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Parses /etc/passwd and copys the realname to the outbuffer
;; <- ecx (length of username)
;; -> ecx (length of Realname - 0 on error)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getusername:
	push edi
	mov esi, [pwptr]
	xor eax, eax

rn_search_loop:
	lodsb
	cmp al, [utmpbuf.ut_user]
	jz rn_fc_match

rn_nextline:
	lodsb
	cmp al, __n
	jz rn_search_loop
	or al, al
	jnz rn_nextline
	sys_exit 42                 ; Hopefully never reached

rn_fc_match:
	mov edx, ecx
	dec esi
	mov edi, utmpbuf.ut_user
	repz cmpsb
	or ecx, ecx
	jnz rn_prep_sl
	cmp byte [esi], ':'
	jz rn_found

rn_prep_sl:
	mov ecx, edx
	jmp rn_search_loop

rn_found:
	mov ecx, 4
rn_lloop:
	lodsb
	or al, al
	jz do_exit
	cmp al, ':'
	jnz rn_lloop
	dec ecx
	jnz rn_lloop
	dec ecx

rn_laloop:
	lodsb
	inc ecx
	cmp al, ':'
	jz rn_copy
	cmp al, ','
	jnz rn_laloop

rn_copy:
	pop edi
	sub esi, ecx
	dec esi
	push ecx
	repnz movsb
	pop ecx
	ret

do_exit:
	sys_exit 0x0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

utmpfile db _PATH_UTMP, EOL
passwd db "/etc/passwd", EOL
banner db "Login      Name                  Tty         Idle    Where",__n
bannerlen equ $ - banner
devdir db "/dev",EOL

UDATASEG

ctime	LONG	1
utmpfd  LONG    1
pwdfd   LONG    1
pwptr   LONG    1

statbuf B_STRUC Stat,.st_size,.st_atime
utmpbuf B_STRUC utmp,.ut_type,.ut_line,.ut_user,.ut_host,.ut_tv

buf	LONG    0x1000

END

%ifdef __VI__
vi:syntax=nasm
%endif
