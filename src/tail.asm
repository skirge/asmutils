;Copyright (C) 2001 Jani Monoses <jani@vitrualro.ic.ro>
;
;$Id: tail.asm,v 1.1 2001/05/16 09:47:01 konst Exp $
;
;hackers' tail
;
;syntax: tail [-n lines] [FILE]
	
%include "system.inc"

%assign BUFSIZE		0x4000		;16K - the maximum guarranteed size of the tail 

CODESEG
START:		
		mov	byte [lines],10 ;default line count
		_mov	ebp,STDIN	;default input file
		pop	ecx		;argc
		dec	ecx
		jz	.go		;if no args assume defaults
		pop	ebx		;program name
		pop 	ebx
		cmp	word[ebx],"-n"	;option or filename?
		jne	.file	
		pop	esi		;line count

;put line count from ascii representation in ebx
	
		xor	ebx,ebx
		xor	eax,eax
.nextchar:
		lodsb
		sub	al,'0'
		jb	.endconvert
		imul	ebx,byte 10
		add	ebx,eax	
		jmp	short .nextchar
.endconvert:	
		mov	[lines],ebx	

		dec	ecx		;eat two args 
		dec	ecx
		jz	.go		;no file name just options (tail -n 77) assume STDIN
		pop	ebx		;file name (last argument)
.file:
		sys_open	ebx,O_RDONLY
		test	eax,eax
		js	.exit
		mov	ebp,eax		;save file descriptor

;if regular file seek to last BUFSIZE bytes.Especially good for large files.
.go:	
		sys_fstat ebp,statbuf
		test	dword[statbuf.st_mode],S_IFREG		
		jz	.gogo				;if no regular file	
		mov	ebx,[statbuf.st_size]
		sub	ebx,BUFSIZE
		jbe	.gogo				;or size < BUFSIZE
		sys_lseek ebp,ebx,SEEK_SET
.gogo:							;just read
		mov	ecx,buf

;reads the input in BUFSIZE sized chunks
;and moves the buffers to prevent overflow 
.readinput:
		sys_read ebp,ecx,BUFSIZE		
		test	eax,eax
		js	.exit
		jz	.writebuffer
		add	ecx,eax
		cmp	ecx,safety
		jle	.readinput

.bufcopy:
		push	ecx
		mov	edi,buf
		mov	esi,buf2
		sub	ecx,esi
		rep	movsb
		pop	ecx
		sub	ecx,BUFSIZE
		jmps	.readinput	

.exit:		
		sys_exit
;walk through the buffer from end to beginning and stop 
;when enough newlines are encountered
.writebuffer:	
		cmp	ecx,buf
		jz	.exit
		mov	edx,ecx
		mov	ebx,[lines]
		inc	ebx
		dec	ecx

.nl:		
		dec	ebx
		jz	.tail
.searchnl:
		dec	ecx
		cmp	ecx,buf			;start of buffer reached?
		jz	.endbuf
		cmp	byte[ecx],10		;is it a newline char ?
		jz	.nl
		jmp	short .searchnl		
.tail:
		inc	ecx
.endbuf:
		sub	edx,ecx
		sys_write	STDOUT,ecx,edx 
		jmps	.exit
UDATASEG
	lines	resd	1	
	buf	resb	BUFSIZE
	buf2	resb	BUFSIZE
	safety	resb	BUFSIZE
	statbuf	B_STRUC	stat,.st_mode,.st_size
END
