;Copyright (C) 1999 Indrek Mandre <indrek.mandre@tallinn.ee>
;
;$Id: httpd.asm,v 1.11 2002/01/05 11:07:07 konst Exp $
;
;hackers' sub-1K httpd
;
;syntax: httpd document-root port [logfile [err404file]]
;
;example:	httpd /htdocs/ 8888
;		lynx http://localhost:8888/
;
;		httpd /htdocs/ 8888 /htdocs/httpd.log /htdocs/404.html
;
; - when / is the last symbol in request, appends index.html
; - in case of error just closes connection
; - takes 16kb + 16kb for every request in memory, forks on every request,
; - good enough to serve basic documentation.
;
;I tried to make it as secure as possible, there should be no buffer overflows.
;I at least tried not to make any. It ignores requests with included '..'.
;Here I did a bit testing and it served about 214.8688524590 pages per second.
;Perhaps I am wrong though, but this was the statistics :)
;
;Note that starting from version 0.02 IM no longer maintains httpd.
;Actually it was heavily rewritten since 0.04 and is now maintained by KB;
;however you can still find original IM code and notes throughout the source.
;
;0.01: 17-Jun-1999	initial release (IM)
;0.02: 04-Jul-1999	fixed bug with 2.0 kernel, minor changes (KB)
;0.03: 29-Jul-1999	size improvements (KB)
;0.04: 09-Feb-2000	portability fixes (KB)
;0.05: 25-Feb-2000	heavy rewrite of network code, size improvements,
;			portability fixes (KB)
;0.06: 05-Apr-2000	finally works on FreeBSD! (KB)
;0.07: 30-Jun-2000	added support for custom 404 error message,
;			enabled by %define ERR404 (KB)
;			thanks to Mooneer Salem <mooneer@earthlink.net>
;0.08: 10-Sep-2000	squeezed few more bytes (KB)
;0.09: 16-Jan-2001	added support for "Content-Type: text/plain"
;			for .text, .txt, .log and no-extension files,
;			enabled by %define SENDHEADER (KB)
;0.10  05-Jan-2002      added logging (IP||HEADER),
;			added err404file command line argument,
;			more content types (RM),
;			added extension-content type table.
;			fixed endless loop if err404file is missing (KB)

%include "system.inc"

;Most useful option is SENDHEADER. It could be implemented using external file
;(like usual http servers do), but static implementation has advantages too.
;
;when both LOG and ERR404 are enabled:
;	logfile is 3rd command-line argument and err404file is 4th
;when only one of {LOG,ERR404} is enabled:
;	corresponding filename is 3rd command-line argument
;so, you must know compile-time configuration; weird, but better than nothing.

;%define	SENDHEADER
;%define	LOG
;%define	ERR404

%ifdef	LOG
%define	LOG_HEADER
%endif

CODESEG

setsockoptvals	dd	1

START:
	pop	ebp
	cmp	ebp,byte 3	;at least 2 arguments must be there
%ifdef ERR404
	jb	near false_exit
%else
	jb	false_exit
%endif
	pop	esi		;our own name

	pop	dword [root]	;document root
	pop	esi		;port number

%ifdef LOG
	sub	ebp,byte 3
	jz	.n1
%elifdef ERR404
	sub	ebp,byte 3
	jz	.n1
%endif

%ifdef LOG
	pop	eax
	sys_open eax,O_WRONLY|O_APPEND|O_CREAT,S_IRUSR|S_IWUSR
	test	eax,eax
	js	.n0
	mov	[logfd],eax
.n0:
%ifdef ERR404
	dec	ebp
	jz	.n1
%endif
%endif

%ifdef ERR404
	pop	eax
	or	eax,eax
	jz	.n4
	mov	[err404],eax
	xor	ecx,ecx
.n2:
	cmp	byte [eax],0
	jz	.n3
	inc	eax
	inc	ecx
	jmps	.n2
.n3:
	or	ecx,ecx
	jz	.n4
	inc	ecx
	mov	[err404len],ecx
.n4:
%endif

.n1:
	xor	eax,eax
	xor	ebx,ebx
.next_digit:
	lodsb
	sub	al,'0'
	jb	.done
	cmp	al,9
	ja	.done
	imul	ebx,byte 10
	add	ebx,eax
	jmps	.next_digit
.done:
	push	ebx
	sys_socket PF_INET,SOCK_STREAM,IPPROTO_TCP
	mov	ebp,eax		;socket descriptor
	test	eax,eax
	js	false_exit

	sys_setsockopt ebp,SOL_SOCKET,SO_REUSEADDR,setsockoptvals,4
	or	eax,eax
	jz	bind

false_exit:
	_mov	ebx,1
real_exit:
	sys_exit

bind:
	pop	eax
	mov	dword [bindsockstruct],AF_INET
	mov	byte [bindsockstruct + 2],ah
	mov	byte [bindsockstruct + 3],al
	sys_bind ebp,bindsockstruct,16	;bind(s, struct sockaddr *bindsockstruct, 16)
	or	eax,eax
	jnz	false_exit

	sys_listen ebp,0xff		;listen(s, 0xff)
	or	eax,eax
	jnz	false_exit

	sys_fork			;fork after everything is done and exit main process
	or	eax,eax
	jz	acceptloop

true_exit:
	_mov	ebx,0
	jmps	real_exit

acceptloop:
	mov	dword [arg2],16		;sizeof(struct sockaddr_in)
	sys_accept ebp,arg1,arg2	;accept(s, struct sockaddr *arg1, int *arg2)
	test	eax,eax
	js	acceptloop
	mov	edi,eax			;our descriptor

;wait4(pid, status, options, rusage)
;there must be 2 wait4 calls! Without them zombies can stay on the system

	sys_wait4	0xffffffff,NULL,WNOHANG,NULL
	sys_wait4

%ifdef LOG
;	mov	edx,arg3
;        mov	byte [edx],0x10
;	sys_getpeername edi,filebuf,arg3
	mov	eax,[arg1+4]
	push	edi
	mov	edi,filebuf+020
	mov	esi,edi
	xchg	ah,al	
	ror	eax,16
	xchg	ah,al
	call	i2ip
	sub	esi,edi
	inc	edi
	mov	ebx,eax
	sys_write [logfd],edi,esi
	pop	edi
%endif

	sys_fork		;we now fork, child goes his own way, daddy goes back to accept
	or	eax,eax
	jz	.forward
	sys_close edi
	jmp	acceptloop
.forward:
	sys_read edi,filebuf,0xfff
	cmp	eax,byte 7	;there must be at least 7 symbols in request 
	jb	near endrequest
.endrequestnot3:
	push	eax
%ifdef LOG_HEADER
	sys_write [logfd],filebuf,eax
%endif
	mov	ebx,finalpath
	mov	ecx,[root]
.back:
;first, copy the document root
	mov	al,[ecx]
	mov	byte [ebx],al
	inc	ebx
	inc	ecx
	cmp	byte [ecx],0
	jne	.back

	sub	ecx,[root]
	pop	eax
	add	ecx,eax
	cmp	ecx,0xfff
	ja	near endrequest

.endrequestnot2:

;now append the demanded

	mov	ecx,filebuf+4
.loopme:
	mov	al,[ecx]
	mov	byte [ebx],al
	cmp	word [ecx],".."
	jz	near endrequest	;security error, can't have '..' in request
.endrequestnot:
	inc	ebx
	inc	ecx
	mov	dl,[ecx]
	or	dl,dl
	je	.loopout
	cmp	dl,' '
	jz	.loopout
	cmp	dl,'?'
	jz	.loopout
	cmp	dl,0xd
	jz	.loopout
	cmp	dl,0xa
	jnz	.loopme
.loopout:
	cmp	byte [ebx-1],'/'		;append index.html :)
	jne	noindex
	mov	dword [ebx],'inde'
	mov	dword [ebx+4],'x.ht'
	mov	dword [ebx+8],0x6e006c6d	;'ml'
	jmps	index
noindex:
	mov	byte [ebx],0
index:
	sys_open finalpath,O_RDONLY
	test	eax,eax
%ifdef	ERR404
	js	error404
%else
	js	endrequest
%endif

%ifdef SENDHEADER
	call	sendheader
%endif
	mov	ebx,eax
	mov	esi,eax
	mov	ecx,filebuf
.writeloop:
	sys_read EMPTY,EMPTY,0xfff
	test	eax,eax
	js	.endread

	sys_write edi,EMPTY,eax
	mov	ebx,esi
	test	eax,eax
	jz	.endread
	jns	.writeloop
.endread:
	sys_close

;due the stupidity of netscape we need to send another packet newline \n,
;so it can handle one line data but I'm afraid it might break something,
;so watch this code carefully in the future
;	sys_write edi,nl,1

endrequest:
;	sys_read ebp,filebuf,0xff
;	sys_shutdown ebp,1		;shutdown(sock, how)
;	sys_close ebp
	jmp	true_exit

;nl	db	0xa

%ifdef	ERR404
error404:
	pusha
	mov	ecx,[err404len]
	or	ecx,ecx
	jz	.end

	mov	esi,[err404]
	mov	edi,finalpath

	push	ecx		;save values
	push	esi
	push	edi
	
	rep	cmpsb		;check if we can't open ourself
	jz	.end0

	pop	edi
	pop	esi
	pop	ecx
	rep	movsb		;copy to finalpath

	popa
	jmp	index

.end0:
	add	esp,byte 4*3
.end:
	popa
	jmp	endrequest

%endif

%ifdef	LOG
i2ip:
	std
	mov	byte [edi],__n
	dec	edi
.next:	
	mov	ebx,eax
	call	.conv
	xchg	eax,ebx
	mov	al,'.'
	stosb
	shr	eax,8
	jnz	.next
	cld
	inc	edi
	mov	byte [edi],' '
	ret
.conv:
	mov	cl,010
.divide:
	xor	ah,ah	
	div	cl     ;ah=reminder
	xchg	ah,al
	add	al,'0'
	stosb	
	xchg	ah,al
	or	al,al
	jnz	.divide
	ret
%endif

%ifdef	SENDHEADER

h1	db	"HTTP/1.1 200 OK",__n
	db	"Server: asmutils httpd",__n
	db      "Content-Type: "
_lenh1	equ	$ - h1
%assign	lenh1 _lenh1

c_plain	db	"text/plain",EOL
c_html	db	"text/html",EOL
c_jpeg	db	"image/jpeg",EOL
c_png	db	"image/png",EOL
c_gif	db	"image/gif",EOL

ending	db	__n,__n

extension_tab:
	dd	"text",	c_plain
	dd	"txt",	c_plain
	dd	"log",	c_plain
	dd	"html",	c_html
	dd	"htm",	c_html
	dd	"jpeg",	c_jpeg
	dd	"jpg",	c_jpeg
	dd	"png",	c_png
	dd	0

sendheader:
	pusha

	mov	esi,finalpath
	mov	ebx,esi
.cc1:
	lodsb
	or	al,al
	jnz	.cc1
.cc2:
	cmp	esi,ebx
	jz	.return
	dec	esi
	cmp	byte [esi],'.'
	jnz	.cc2
	mov	eax,[esi + 1]
	mov	edx,extension_tab - 8
.cc3:
	add	edx,byte 8
	mov	ecx,[edx]
	or	ecx,ecx
	jz	.return
	cmp	eax,ecx
	jnz	.cc3

.write_content:

	push	edx
	sys_write edi,h1,lenh1	;header
	pop	edx

	mov	ecx,[edx + 4]
	mov	edx,ecx
	dec	edx
.cc5:
	inc	edx
	cmp	[edx],byte EOL
	jnz	.cc5

	sub	edx,ecx
	
	sys_write		;write content type
	sys_write EMPTY,ending,2

.return:
	popa
	ret

%endif

UDATASEG

%ifdef	ERR404
err404len	resd	1	;filename length
err404		resd	1	;pointer
%endif
%ifdef	LOG
logfd	resd	1
%endif

arg1	resb	0xff
arg2	resb	0xff

root	resd	1

bindsockstruct	resd	4

finalpath	resb	0x1010	;10 is for safety
filebuf		resb	0x1010

END
