;Copyright (C) 2001 Rudolf Marek <marekr2@fel.cvut.cz>, <ruik@atlas.cz>
;
;$Id: tar.asm,v 1.1 2001/10/02 06:00:52 konst Exp $
;
;hackers' tar
;
;Version 0.1 - 2001-Sep-25
;
;Syntax tar [OPT] FILENAME
;OPT: -t list archive
;     -x extracet archive 
;Note: no owner change yet, no time/date update yet

;All comments/feedback welcome.

%include "system.inc"


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
%assign TSUID	04000
%assign TSGID	02000
%assign TSVTX	01000
%assign TUREAD	00400
%assign TUWRITE	00200
%assign TUEXEC	00100
%assign TGREAD	00040
%assign TGWRITE	00020
%assign TGEXEC	00010
%assign TOREAD	00004
%assign TOWRITE	00002
%assign TOEXEC	00001

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
;*************************
tar_list_files:
.next:
	sys_read [tar_handle],tar,0512 
	or 	eax,eax
	jz 	.list_done
	cmp 	dword [tar.magic],'usta'
	jnz 	.next
	xor 	edx,edx
	lea 	ecx,[tar.name]
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
	;sys_write STDOUT,tar.name,0100
	xor 	eax,eax
	cmp 	byte [tar.version],' '
	jz 	.ver_ok
	xor 	ebx,ebx
	ret
.ver_ok:
	cmp 	dword [tar.magic],'usta'
	jnz 	 .error_magic
	cmp	byte [tar.prefix],0
	jz 	.ok
	int 3 ;we dont handle the prefix extension yet
.ok:
;	mov 	eax,tar.typeflag
;	cmp 	byte [eax],REGTYPE
;	jz  	near .create_file
;	cmp  	byte [eax],AREGTYPE
;	jz 	near .create_file
;	cmp  	byte [eax],DIRTYPE
;	jz 	near .create_dir
;	cmp  	byte [eax],LNKTYPE
;	jz 	near .create_hardlink
;	cmp  	byte [eax],SYMTYPE
;	jz 	near .create_symlink
;	cmp  	byte [eax],CHRTYPE
;	jz 	near .create_char
;	cmp  	byte [eax],BLKTYPE
;	jz 	near .create_block
;	cmp  	byte [eax],FIFOTYPE
;	jz 	near .create_fifo
;	cmp 	 byte [eax],CONTTYPE
;	jz 	.create_contigous
;	jmp  .error
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
;    sys_chown tar.name,[tar.uid],[tar.gid]
	jmps 	.read_next	
.error_magic:
	lea 	eax,[0xDEADDEAD]
.error:
	neg 	ebx
.exit:
	ret


.create_contigous:
	int 3 ;NYI
.create_dir:
	call convert_numbers
	sys_mkdir tar.name,[tar.mode]
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
	sys_mknod tar.name,[tar.mode],EMPTY
	ret
.create_file:
	call convert_size
	sys_open tar.name, O_CREAT|O_WRONLY|O_TRUNC,[tar.mode]  ;todo: other flags   
	test 	eax,eax
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
 END                                                                     