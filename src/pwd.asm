;Copyright (C) 1999-2000 Konstantin Boldyshev <konst@linuxassembly.org>
;Copyright (C) 1999 Yuri Ivliev <yuru@black.cat.kazan.su>
;
;$Id: pwd.asm,v 1.3 2000/03/02 08:52:01 konst Exp $
;
;hackers' pwd
;
;0.01: 05-Jun-1999	initial release (KB)
;0.02: 17-Jun-1999	size improvements (KB)
;0.03: 04-Jul-1999	kernel 2.0 support added (YI)
;0.04: 18-Sep-1999	elf macros support (KB)
;0.05: 17-Dec-1999	size improvements (KB)
;0.06: 08-Feb-2000	(KB)
;
;syntax: pwd

%include "system.inc"

%assign	lPath 0xff

CODESEG

START:

%if __KERNEL__ = 20

%assign	lBackPath	0x00000040

;;getting root's inode and block device
	sys_lstat	Root.path,st		;get stat for root
	mov	ax,[ecx+stat.st_dev]
	mov	[Root.st_dev],ax
	mov	eax,[ecx+stat.st_ino]
	mov	[Root.st_ino],eax
;;data initialization
	mov	ebp,BackPath		;ebp - current position in BackPath
	mov	dword [ebp],'./'	;we are starting from current dir
	mov	edi, Path+lPath-1	;edi - current position in Path - 1
	mov	byte [edi], 0x0A	;NL at the end of Path
	dec	edi
;;the begin of up to root loop
.up:
	sys_lstat	BackPath,st	;get stat for current location
	test	eax,eax
	js	.exit
	mov	byte [edi],'/'
	dec	edi
	mov	ax,[ecx+stat.st_dev]
	cmp	ax,[Root.st_dev]	;is our block device roots'?
	jne	.continue		;no
	mov	eax,[ecx+stat.st_ino]
	cmp	eax,[Root.st_ino]	;is our inode roots'?
	jne	.continue		;no
;;the begin of exit pwd
	inc	edi			;yes, pwd comptete
	mov	esi,Path+lPath-2
	mov	edx,esi
	sub	edx,edi			;is "/" our current dir?
	jz	.print			;yes
	mov	byte [esi],0x0A		;no, remove leading slash
	dec	edx
.print:
	inc	edx
	inc	edx
	sys_write STDOUT,edi		;print work dir
.exit:
	sys_exit_true			;and go out
;; the end of exit pwd
.continue:
	mov	dword [ebp],'../'	;move current location up
	lea	ebp, [ebp+3] 
	mov	ax,[ecx+stat.st_dev]
	mov	[Dev], ax		;remember block device for prev location
	mov	eax,[ecx+stat.st_ino]
	mov	[Inode], eax		;remember inode for prev location
	sys_open BackPath,O_RDONLY	;open current location
	test	eax, eax
	js	.exit
	mov	edx,eax
	mov	esi, de			;esi - pointer to dirent
	xor	ecx, ecx		;we start from first dirent
	mov	[esi+dirent.d_off], ecx
;; the begin of get directory entry loop
.next_de:
;;;;;;;;	sys_lseek edx,[esi+dirent.d_off],SEEK_SET
	mov	ebx,edx
	mov	ecx,[esi+dirent.d_off]
	xor	edx,edx
	sys_lseek				;seek to next dirent
	test	eax,eax
	js	.exit
	sys_getdents EMPTY,esi,dirent_size	;get current dirent
	test	eax,eax
	js	near .exit
	jz	near .exit
	mov	edx,ebx
	;concatenate current location and current dirent name
;;;;	mov	ecx,ebp
;;;;	lea	ebx,[esi+dirent.d_name]
	mov	ebx,ebp
	xor	ecx,ecx
.next.d_name.1
;;;;	mov	al,[ebx]
;;;;	inc	ebx
	mov	al,[esi+ecx+dirent.d_name]
;;;;	mov	[ecx],al
	mov	[ebx+ecx],al
	inc	ecx
	or	al,al
	jnz	.next.d_name.1
	sys_lstat BackPath,st		;get stat for current dirent
	test	eax, eax
	js	near .exit
	mov	ax,[ecx+stat.st_dev]
	cmp	ax,[Dev]		;is this block device ours'
	jne	near .next_de		;no, try next dirent
	mov	eax,[ecx+stat.st_ino]
	cmp	eax,[Inode]		;is this inode ours'
	jne	near .next_de		;no, try next dirent
;; the end of get directory entry loop
	sys_close	edx		;close current location
	mov	[ebp],al
	lea	esi,[esi+dirent.d_name]
;;;;	mov	ebx,esi
	xor	ecx,ecx
.next.d_name.2:
;;;;	inc	esi
;;;;	cmp	al,[esi]
	inc	ecx
	cmp	al,[esi+ecx]
	jc	.next.d_name.2
;;;;	mov	ecx,esi
;;;;	sub	ecx,ebx
;;;;	dec	esi
	lea	esi,[esi+ecx-1]
	std
	rep
	movsb
	jmp	.up

;; the end of up to root loop

Root.path	db	'/',EOL

%elif __KERNEL__ = 22

	sys_getcwd Path,lPath

	mov	esi,ebx
	xor	edx,edx
.next:
	inc	edx
	lodsb
	or	al,al
	jnz	.next
	mov	byte [esi-1],0x0A
	sub	esi,edx
	sys_write	STDOUT,esi
	sys_exit_true
%endif


UDATASEG

Path	CHAR	lPath		;path buffer

%if __KERNEL__ = 20

BackPath	CHAR	lBackPath	;back path buffer

de		I_STRUC dirent	;buffer for directory scanning
			.d_ino		ULONG	1
			.d_off		ULONG	1
			.d_reclen	USHORT	1
			.d_name		CHAR	ld_name
		I_END
st		I_STRUC stat		;buffer for stat information
			.st_dev		USHORT	1
			.__pad1		USHORT	1
			.st_ino		ULONG	1
			.st_mode	USHORT	1
			.st_nlink	USHORT	1
			.st_uid		USHORT	1
			.st_gid		USHORT	1
			.st_rdev	USHORT	1
			.__pad2		USHORT	1
			.st_size	ULONG	1
			.st_blksize	ULONG	1
			.st_blocks	ULONG	1
			.st_atime	ULONG	1
			.__unused1	ULONG	1
			.st_mtime	ULONG	1
			.__unused2	ULONG	1
			.st_ctime	ULONG	1
			.__unused3	ULONG	1
			.__unused4	ULONG	1
			.__unused5	ULONG	1
		I_END

Inode		UINT	1
Dev		USHORT	1
Root.st_dev	USHORT	1
Root.st_ino	USHORT	1
%endif

END
