;Copyright (C) 2001 Rudolf Marek <marekr2@fel.cvut.cz>, <ruik@atlas.cz>
;
;$Id: tar.asm,v 1.3 2002/08/06 17:57:56 konst Exp $
;
;hackers' tar
;
;Syntax tar [OPT] FILENAME
;OPT: -t list archive
;     -x extracet archive 
;Note: no owner change yet, no time/date update yet

;All comments/feedback welcome.

;0.1	25-Sep-2001	initial release (RM)
;0.2	04-Aug-2002	added contiguous (append) files, chown/grp,
;			prefix processing,  "tar -xf -" for stdin,
;			selection of only certain filenames for "tar -x" (JH)


%include "system.inc"

;------ Build configuration
%define TAR_PREFIX
%define TAR_CHOWN
%define TAR_MATCH
;%define TAR_CREAT           ; Not yet implemented
			     ; Will be someday


;A tar archive consists of 512-byte blocks.
;  Each file in the archive has a header block followed by 0+ data blocks.
;   Two blocks of NUL bytes indicate the end of the archive.  */
;
; The fields of header blocks:
;   All strings are stored as ISO 646 (approximately ASCII) strings.
;
;  Fields are numeric unless otherwise noted below; numbers are ISO 646
;   representations of octal numbers, with leading zeros as needed.
;
;  linkname is only valid when typeflag==LNKTYPE.  It doesn't use prefix;
;   files that are links to pathnames >100 chars long can not be stored
;  in a tar archive.
;
;   If typeflag=={LNKTYPE,SYMTYPE,DIRTYPE} then size must be 0.
;
;   devmajor and devminor are only valid for typeflag=={BLKTYPE,CHRTYPE}.
;
;   chksum contains the sum of all 512 bytes in the header block,
;   treating each byte as an 8-bit unsigned value and treating the
;   8 bytes of chksum as blank characters.

;  uname and gname are used in preference to uid and gid, if those
;   names exist locally.

;   Field Name	Byte Offset	Length in Bytes	Field Type
;   name	0		100		NUL-terminated if NUL fits
;   mode	100		8
;   uid		108		8
;   gid		116		8
;   size	124		12
;   mtime	136		12
;   chksum	148		8
;   typeflag	156		1		see below
;   linkname	157		100		NUL-terminated if NUL fits
;   magic	257		6		must be TMAGIC (NUL term.)
;   version	263		2		must be TVERSION
;   uname	265		32		NUL-terminated
;   gname	297		32		NUL-terminated
;   devmajor	329		8
;   devminor	337		8
;   prefix	345		155		NUL-terminated if NUL fits

;   If the first character of prefix is '\0', the file name is name;
;   otherwise, it is prefix/name.  Files whose pathnames don't fit in that
;  length can not be stored in a tar archive.  */

;/* The bits in mode: */
%assign TSUID	04000q
%assign TSGID	02000q
%assign TSVTX	01000q
%assign TUREAD	00400q
%assign TUWRITE	00200q
%assign TUEXEC	00100q
%assign TGREAD	00040q
%assign TGWRITE	00020q
%assign TGEXEC	00010q
%assign TOREAD	00004q
%assign TOWRITE	00002q
%assign TOEXEC	00001q

;/* The values for typeflag:
;   Values 'A'-'Z' are reserved for custom implementations.
;   All other values are reserved for future POSIX.1 revisions.  */

%assign REGTYPE		'0'	;/* Regular file (preferred code).  */
%assign AREGTYPE	0	;/* Regular file (alternate code).  */
%assign LNKTYPE		'1'	;/* Hard link.  */
%assign SYMTYPE		'2'	;/* Symbolic link (hard if not supported).  */
%assign CHRTYPE		'3'	;/* Character special.  */
%assign BLKTYPE		'4'	;/* Block special.  */
%assign DIRTYPE		'5'	;/* Directory.  */
%assign FIFOTYPE	'6'	;/* Named pipe.  */
%assign CONTTYPE	'7'	;/* Contiguous file */

; /* (regular file if not supported).  */
;
;/* Contents of magic field and its length.  */
%define TMAGIC	'ustar'
%assign TMAGLEN	6

;/* Contents of the version field and its length.  */
%define TVERSION	" ",0
%assign TVERSLEN	2

%assign BUFF_DIV  011
%assign BUFF_SIZE 2<<(BUFF_DIV-1)

%ifdef TAR_PREFIX
 %define FILENAME tarname
%else
 %define FILENAME tar.name
%endif

CODESEG

START:
	pop     ebx
	pop	ebx
.next_arg:
	pop 	ebx
	or 	ebx,ebx
	jz .usage
	cmp 	word [ebx],'-t'
	jz .list_archive
	cmp 	word [ebx],'-x'
	jz .extract_archive	
.usage:
	sys_write STDOUT,use,use_len
	sys_exit 0	

.list_archive:
	pop 	ebx
	call tar_archive_open
	call tar_list_files
	call tar_archive_close
	xor  	ebx,ebx
	jmps .exit
.extract_archive:
	pop 	ebx
	call tar_archive_open
%ifdef TAR_MATCH
	mov	[tar_match], esp
%endif
	call tar_archive_extract
	push 	ebx
	call tar_archive_close
	pop 	ebx
.exit:
	sys_exit EMPTY

;*************************************************
;SUBS:
;*************************************************

octal_to_int:             ;stolen from chmod.asm
	push   	esi
	mov    	edi,esi
	add 	edi,012
	xor 	ecx,ecx
	xor 	eax,eax
	_mov	ebx,8         ;esi ptr to str
.next:
	mov	cl,[esi]
	or	cl,cl
	jz	.done_ok
	cmp 	cl,' ' 
	jz	.add
	sub	cl,'0'
	jb	.done_err
	cmp	cl,7
	ja	.done_err
	mul	ebx
	add	eax,ecx
.add:
	inc	esi
	cmp 	esi,edi
	jb 	.next
	jmps	.done_ok
.done_err:
	sys_exit 253
.done_ok:
	pop 	esi
	ret	

convert_size:
	lea 	esi,[tar.size]
	call 	octal_to_int
	mov 	dword [esi],eax
	jmps 	convert_numbers
convert_block:
	lea 	esi,[tar.devmajor]
	call 	octal_to_int
	mov 	dword [esi],eax
	lea 	esi,[tar.devminor]
	call 	octal_to_int
	mov 	dword [esi],eax
convert_numbers:
	lea 	esi,[tar.mode]
	call 	octal_to_int
	mov 	dword [esi],eax
	lea 	esi,[tar.uid]
	call 	octal_to_int
	mov 	dword [esi],eax
	lea 	esi,[tar.gid]
	call 	octal_to_int
	mov 	dword [esi],eax
	ret

%ifdef TAR_PREFIX
pref_tran:
	pusha
	mov	edi, FILENAME
	mov	esi, tar.prefix
	xor	ecx, ecx
	mov	cl, 0156		; Stop one byte AFTER end of prefix
.prefc:	lodsb
	stosb
	or	al, al
	loopnz	.prefc
	dec	edi
	mov	esi, tar.name
	mov	cl, 100
.main:	lodsb
	stosb
	or	al, al
	loopnz	.main
	mov	al, 0
	stosb
	popa
	ret
%endif

;*************************
tar_list_files:
.next:
	sys_read [tar_handle],tar,0512 
	or 	eax,eax
	jz 	.list_done
	cmp 	dword [tar.magic],'usta'
	jnz 	.next
%ifdef TAR_PREFIX
	call	pref_tran
%endif
	xor 	edx,edx
	lea 	ecx,[FILENAME]
.next_byte:
	cmp 	byte [ecx+edx],1
	inc 	edx
	jnc 	.next_byte
	mov 	word [ecx+edx-1],0x000a
	sys_write STDOUT,EMPTY,EMPTY
	lea 	edi,[tar.typeflag]
	cmp byte [edi],SYMTYPE
	jz .prnlink
	cmp byte [edi],LNKTYPE
	jz .prnlink
	jmps 	.next
.prnlink:
	sys_write EMPTY,arrow,5
	xor 	edx,edx
	mov 	ecx,tar.linkname
	mov  byte [edi],0
	jmps .next_byte	
.list_done:
  ret

tar_archive_open:
	xor	eax, eax
	cmp	[ebx], word '-'
	je	.ok
	sys_open EMPTY,O_RDONLY
	test 	eax,eax
	jns 	.ok
	sys_exit 255
.ok:
	mov 	[tar_handle],eax   
	ret
tar_archive_close:
	sys_close [tar_handle]
	ret

tar_archive_extract:
.read_next:
	sys_read [tar_handle],tar,0512 
	;sys_write STDOUT, tar.name, 0100
	xor 	eax,eax
	cmp 	byte [tar.version],' '
	jz 	.ver_ok
	xor 	ebx,ebx
	ret
.ver_ok:
	cmp 	dword [tar.magic],'usta'
	jnz 	.error_magic
%ifdef TAR_PREFIX
	call	pref_tran
%else
	cmp	byte [tar.prefix],0
	jz 	.ok
	int 3 ;we dont handle the prefix extension yet
.ok:
%endif
%ifdef TAR_MATCH
	mov	ebp, [tar_match]
	mov	edi, [ebp]
	or	edi, edi
	jz	.gotmatch
.trynext:
	mov	esi, FILENAME
	mov	edi, [ebp]
	or	edi, edi
	jz	.notmatch
	add	ebp, byte 4
.scmp:	lodsb
	mov	cl, [edi]
	inc	edi
	cmp	al, cl
	jnz	.notmatch
	or	al, cl
	jnz	.scmp
.gotmatch:
%endif
	xor 	eax,eax
	mov 	al,[tar.typeflag]
	or 	al,al
	jz 	.done_sel
	cmp 	al,CONTTYPE
	ja  	.error
	sub 	al,'0'
	jb  	.error
.done_sel:
	call [.lookup_table+eax*4]
	test 	eax,eax
	xchg 	eax,ebx
	js   	.error
%ifdef TAR_CHOWN
	sys_lchown tar.name,[tar.uid],[tar.gid]
%endif
	jmp	.read_next	
.error_magic:
	lea 	eax,[0xDEADDEAD]
.error:
	neg 	ebx
.exit:
	ret

%ifdef TAR_MATCH
.notmatch:
	call	convert_size
	mov	ebp,	[tar.size]
	add	ebp,	511
	and	ebp,	~511
	shr	ebp,	BUFF_DIV
	jz	.rd
	mov	ebx,	[tar_handle]
	mov	ecx,	buffer
	_mov	edx,	512
.readj	sys_read		; [tar_handle], buffer, 512
	dec	ebp
	jnz	.readj
.rd	jmp	.read_next
%endif

.create_contigous:
%ifdef TAR_CONTIG
	call convert_size
	sys_open FILENAME, O_CREAT|O_APPEND|O_WRONLY,[tar.mode]
	jmp	.crc		; Reenter create file code!
%else
	int 3		; Disabled
%endif
.create_dir:
	call convert_numbers
	sys_mkdir FILENAME,[tar.mode]
	xor eax,eax ;always OK
	ret

.create_hardlink:
	call convert_numbers
	sys_link tar.linkname,tar.name
	ret
.create_symlink:
	call convert_numbers
	sys_symlink tar.linkname,tar.name
	ret
.create_fifo:
	call convert_numbers
	lea 	ecx,[tar.mode]
	or 	dword [ecx],S_IFIFO
	sys_mknod tar.name,[ecx],EMPTY
	ret
.create_char:
	call convert_block
        or dword [tar.mode],S_IFCHR
	jmps .create_nod
.create_block:
	call convert_block
	or dword [tar.mode],S_IFBLK
.create_nod:
	mov ecx,[tar.devmajor]
	shl ecx,8
	mov edx,[tar.devminor]
	or  edx,ecx
	sys_mknod FILENAME,[tar.mode],EMPTY
	ret
.create_file:
	call convert_size
	sys_open FILENAME, O_CREAT|O_WRONLY|O_TRUNC,[tar.mode]  ;todo: other flags   
.crc	test 	eax,eax
	js 	near .error_open
	mov 	[file_handle],eax
	xchg 	ebx,eax
	mov 	edi,[tar.size]
	mov 	edx,edi
	xor 	dl,dl
	and 	dh,11111110b
	add 	edx,0x200
	cmp 	edx,BUFF_SIZE
	jbe 	.fit_whole
	mov 	ecx,edi
	shr 	ecx,BUFF_DIV
.copy_loop:
	push 	ecx
	sys_read [tar_handle],buffer,BUFF_SIZE
	sys_write [file_handle],EMPTY,EMPTY
	pop 	ecx
	loop 	.copy_loop
	mov 	edx,edi
	shr 	edx,BUFF_DIV
	shl 	edx,BUFF_DIV
	sub 	edi,edx
	mov 	edx,edi
	xor 	dl,dl
	and 	dh,11111110b
	add 	edx,0x200
.fit_whole:
	sys_read [tar_handle],buffer,EMPTY
	sys_write [file_handle],EMPTY,edi
	sys_close EMPTY
.error_open:
	ret

.lookup_table dd .create_file,.create_hardlink,.create_symlink,.create_char
              dd .create_block,.create_dir,.create_fifo,.create_contigous
use: db "Usage: tar [OPT] FILENAME",__n
     db "            -t list tar archive",__n
     db "            -x extract tar arcive",__n
use_len equ $-use  
arrow db " |-> "

UDATASEG

tar_handle resd 1
file_handle resd 1

%ifdef TAR_PREFIX
 FILENAME	resb	256
%endif
%ifdef TAR_MATCH
 tar_match	resd	1
%endif

tar:
.name		resb 0100
.mode		resb 0008
.uid		resb 0008
.gid		resb 0008
.size		resb 0012
.mtime		resb 0012
.chksum		resb 0008
.typeflag 	resb 0001
.linkname	resb 0100		
.magic		resb 0006		
.version	resb 0002		
.uname		resb 0032		
.gname		resb 0032
.devmajor	resb 0008
.devminor	resb 0008
.prefix		resb 0155		

buffer resb BUFF_SIZE

END
