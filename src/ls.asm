;Copyright (C) 1999 Dmitry Bakhvalov <dl@gazeta.ru>
;
;$Id: ls.asm,v 1.2 2000/02/10 15:07:04 konst Exp $
;
;hackers' ls
;
;0.01: 15-Oct-1999	initial release
;0.02: 18-Oct-1999	added support for symlinks. Added checks for trailing
;			'/' in the arguments
;0.03: 10-Feb-2000	symlinks listing bugfix, thanks to
;			Franck Lesage <lesage@nexus.pulp.eu.org>
;
;syntax: ls [option] [dir, dir, dir...]
;        The only supported option by now is -l which is, as you might have 
;	 guessed, used for verbose output :)
;
;returns -1 on error, 0 on success
; 
; Please keep in mind that this is a hackers' ls, in other words it doesnt
; do any fancy columned output, it doesnt highlight, doesnt sort, etc :)
; Feel free to extend it's functionality to suit your needs. 
; There is one drawback in the current version:
; - you must give only directories in the command line. No files so far.
; 
; I hope to fix it in the next version :)
;
; Send me any feedback,suggestions,additional code, etc.
; 

		
		%include "system.inc"
		
		CODESEG
		
		LINK_BUF_LEN	equ	260

		%define	D_RECLEN	8
		%define D_FILENAME	10


START:
		; Assume current dir		
		mov	ebx,srcdir
		mov	dword [ebx],0x2F2E

		pop	eax			; get argc
		dec	eax		
		jz	open_file
		pop	eax			; get argv[0]
		
get_next_arg:
		pop	ebx			; get next arg off the stack
		test	ebx,ebx			; got more?
		jz	near no_more_args

		cmp	word [ebx],"-l"
		jnz	not_an_opt
		inc	byte [long_form]
		jmp	get_next_arg

not_an_opt:		
		mov	edi,srcdir		; save filename in srcdir 
		mov	esi,ebx
		call	strcpy
		
		; add '/' at the end of the filename if needed
		xor	eax,eax
		mov	ecx,eax
		inc	ch			; ecx=256
		repnz	scasb
		mov	al,'/'
		dec	edi
		cmp	byte [edi-1],al
		jz	open_file
		stosw
		
open_file:

		sys_open EMPTY,O_RDONLY
		
		test	eax,eax
		js	near error

		mov 	ebp,eax			; ebp will hold filehandle

do_it_again:

		sys_getdents ebp,buf,buf_size
		
		test	eax,eax
		js	near error
		jz	near get_next_arg

		mov	edi,ecx			; edi = buf (sys_getdents sets ecx to buf)
		mov	ecx,eax			; rc
next_dentry:
		push	ecx			; save rc
		
		; now mess with the -rwxrwxrwx stuff
		
		cmp	byte [long_form],1
		jnz	near print_names_only

		push	edi			; save pointer to getent buffer
		
		lea	eax,[edi+D_FILENAME]	; filename from getent buff
		push	eax			; save it
		
		mov	esi,srcdir
		mov	edi,fname		; prepare dirname
		call	strcpy
		
		pop	esi			; esi = saved filename 
						; edi = fname
		call	strcat

		sys_lstat edi,stat_buf		
		
		test	eax,eax
		js	near error

		; get rwx field
		mov	bx,[st_mode]
		mov	ecx,f_mode
		lea	edi,[ecx+9]		; make edi point to the end of f_mode
		call	make_rwx
				
		; print it ( ecx already holds f_mode )
		call	print
		
		xor	eax,eax
		mov	esi,st_nlink
		mov	edi,num_buf
		mov	ecx,edi
		
		mov	bl,3
		
		; get st_nlink,st_uid,st_gid and print them
go_on:		
		lodsw
		call	bin_to_dec
		call	print
		dec	bl
		jnz	go_on
		
		; print file size
		mov	eax,[st_size]
		call	bin_to_dec
		call	print
	
		pop	edi			; restore pointer to getdent buffer
		
print_names_only:		
		
		; print filename 
		lea	ecx,[edi+D_FILENAME]
		call	print
		
		
		mov	ax,word [long_form]
		; [long_form] must be true AND first byte of [f_mode] must
		; be 'l' (which indicates a symlink)
		cmp	ax,0x6C01
		jnz	short_form
		
		mov	ebx,fname

		; reset [link_buf] so that we don't
		; print characters of a previous symlink
		; we could optimize it with by storing
		; the previous strlen in a word.
		; Franck Lesage <lesage@nexus.pulp.eu.org>
		push	eax
		push	ecx
		push	edi
		xor	eax,eax
		mov	edi,link_buf
		mov	ecx,LINK_BUF_LEN/4
		rep	stosd
		pop	edi
		pop	ecx
		pop	eax

		mov	ecx,link_buf+4
		xor	edx,edx
		inc	dh
		sys_readlink
		
		test	eax,eax
		js	short_form
		
		sub	cl,4
		mov	dword [ecx]," -> "
		call	print

short_form:		
		mov	ecx,cr		; CR
		call	print
		
		pop	ecx		; restore rc
		
		movzx	eax,word [edi+D_RECLEN]
		
		sub	ecx,eax		; rc-=d_reclen
		add	edi,eax		; dp=(char*)dp+d_reclen
		test	ecx,ecx
		jz	near do_it_again
		jmp	next_dentry
		

error:
		xor	ebx,ebx
		dec	ebx
		jmp	do_exit
no_more_args:
		xor	ebx,ebx
do_exit:		
		sys_exit

;
; ----------------------------- subroutines -----------------------------------
;


; ebx=st_mode  edi=pointer to the end of buffer where to store rwx stuff
; -
make_rwx:
		pushad
		
		xor	ecx,ecx
		mov	cl,3
		push	edi		; save for special bits
		
.next_rwx:	
		mov	esi,rwx
		mov	ch,3
.next_bit:
		mov	al,'-'
		test	bl,1
		jz	.put_minus
		mov	al,byte [esi]
.put_minus:
		mov	byte [edi],al
		dec	edi
		inc	esi
		shr	bx,1
		dec	ch
		jnz	.next_bit

		loop	.next_rwx
		
		; now fill all those set[uid,gid], sticky, etc fields
		
		mov	cl,3
		; by this time esi points to set_id
		pop	edi		; restore pointer to the end of rwx field
.test_special:
		lodsb
		test	bl,1
		jz	.next_try
		stosb
		dec	edi
.next_try:	
		sub	edi,3
		shr	bx,1
		loop	.test_special

		; is it a directory or a file or a pipe etc
		
		mov	cl,7
.next_file_mask:
		lodsw
		cmp	bl,ah
		loopne	.next_file_mask

		stosb		
		
		popad
		ret


; ecx=string to print
print:
		pushad
				
		mov	esi,ecx
		call	strlen
	
		; ecx already holds string, edx holds strlen
		sys_write STDOUT

		popad		
		ret

; esi=string
; edx=strlen
strlen:
		push	eax
		push	esi
		
		xor	eax,eax
		mov	edx,eax
		dec	edx
.do_strlen:
		inc	edx
		lodsb
		test	al,al
		jnz	.do_strlen
		
		pop	esi
		pop	eax
		ret

; esi=source  edi=dest
; -
strcpy:
		pushad
				
		call	strlen
		inc	edx		; copy NULL too
		mov	ecx,edx
		rep	movsb
		
		popad
		ret

; esi=source  edi=dest
; -
strcat:
		pushad
				
		xchg	esi,edi
		call	strlen
		
		xchg	esi,edi
		add	edi,edx
		
		call	strlen
		inc	edx		; copy NULL byte too
		rep 	movsb		; copy
		
		popad
		ret
	

; eax=number	edi=buf to store string
; -
bin_to_dec:
		pushad
		
		xor	ecx,ecx		
		mov	ebx,ecx
		mov	bl,10
.div_again:		
		xor	edx,edx
		div	ebx
		add	dl,'0'
		push	edx
		inc	ecx
		test	eax,eax
		jnz	.div_again
.keep_popping:		
		pop	eax
		stosb
		loop	.keep_popping
		
		; put \t\x0
		mov	ax,0x009
		stosw
		
		popad
		ret	

		DATASEG
	
cr		db	10,0
rwx		db	"xwr"
set_id		db	"tss"
file_types	db	'p',1q,'c',2q,'d',4q,'b',6q,'-',10q,'l',12q,'s',14q
long_form	db 	0
f_mode		db	"-rwxrwxrwx",9,0


		UDATASEG

buf:
	d_ino:		resd	1
	d_off:		resd	1
	d_reclen:	resw	1
	d_name:		resb	256
	buf_size:	equ	$-buf
	
stat_buf:
	st_dev		resw	1
	__pad1 		resw 	1
	st_ino 		resd	1
	st_mode 	resw	1
	st_nlink 	resw 	1
	st_uid 		resw 	1
	st_gid 		resw 	1
	st_rdev 	resw 	1
	__pad2 		resw 	1
	st_size 	resd 	1
	st_blksize 	resd 	1
	st_blocks 	resd 	1
	st_atime 	resd 	1
	__unused1 	resd 	1
	st_mtime 	resd 	1
	__unused2 	resd 	1
	st_ctime 	resd 	1
	__unused3 	resd 	1
	__unused4 	resd 	1
	__unused5 	resd 	1	

fhandle:
			resd	1
fname:	
			resb	1024
srcdir:	
			resb	256
link_buf:
			resb	LINK_BUF_LEN
num_buf:
			resb	16

		END			
		
