;Copyright (C) 1999 Indrek Mandre <indrek.mandre@tallinn.ee>
;
;$Id: httpd.asm,v 1.6 2000/12/10 08:20:36 konst Exp $
;
;hackers' sub-1K httpd
;
;syntax: httpd document-root port
;
;example:	httpd /htdocs/ 8888
;		lynx http://localhost:8888/
;
; when / is the last symbol in request, appends index.html
; in case of error just closes connection
; takes 16kb + 16kb for every request in memory, forks on every request,
; good enough to serve basic documentation.
; I tried to make it as secure as possible, there should be no buffer overflows
; I at least tryed not to make any. It ignores requests with '..' in.
; please, pelase send me e-mail and tell what you think
; this is my fifth assembler program (on x86 & nasm), the first I wrote
; yesterday
;
; Here I did a bit testing and it served about 214.8688524590 pages
; a second ;) maybe I'm wrong though, but this was the statistics
;
; Changelog:
;     added shutdown and read of socket before closing
;     quick filled structs in CODESEG, saved some space
;     now the process forks and exits with code 0 (in other cases with 1)
;     fixed one return status bug
;     netscape old fool wants an ending newline to data, he gets it now
;
;0.01: 17-Jun-1999	initial release (IM)
;0.02: 04-Jul-1999	fixed bug with 2.0 kernel, minor changes (KB)
;0.03: 29-Jul-1999	size improvements (KB)
;0.04: 09-Feb-2000	portability fixes (KB)
;0.05: 25-Feb-2000	heavy rewrite of network code, size improvements,
;			portability fixes (KB)
;0.06: 05-Apr-2000	finally works on FreeBSD! (KB)
;0.07: 30-Jun-2000	Added support for custom 404 error message
;			(by default in /etc/httpd/404.html)
;			thanks to Mooneer Salem <mooneer@earthlink.net>
;0.08: 10-Sep-2000	squeezed few more bytes (KB)

%include "system.inc"

;%define	ERR404

CODESEG

%ifdef	ERR404
msg404	db	"/etc/httpd/404.html",EOL
len404	equ	$ - msg404
%endif

nl	db	0xa
setsockoptvals	dd	1

START:
	pop	esi
	cmp	esi,byte 3		;3 arguments must be there
	jnz	false_exit

	pop	esi ; our own name

	pop	dword [document]
	pop	esi		;port number

; this code was written by Konstantin Boldyshev
;<ESI -string
;>EAX - result

	xor	eax,eax
	xor	ecx,ecx
	_mov	ebx,10
.next:
        mov	cl,[esi]
	sub	cl,'0'
	jb	.done
	cmp	cl,9
	ja	.done
	mul	bx
	add	eax,ecx
;	adc edx,0
.nextsym:
	inc	esi
	jmps	.next
.done:
	push	eax
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
	sys_bind ebp,bindsockstruct,16	;bind ( s, struct sockaddr *bindsockstruct, 16 );
	or	eax,eax
	jnz	false_exit

;listen ( s, 0xff )

	sys_listen ebp,0xff
	or	eax,eax
	jnz	false_exit

	sys_fork	;fork after everything is done and exit main process
	or	eax,eax
	jz	acceptloop

true_exit:
	_mov	ebx,0
	jmps	real_exit

acceptloop:

;accept ( s, struct sockaddr *arg1, int *arg2 )

	mov	dword [arg2],16		;sizeof (struct sockaddr_in)
	sys_accept ebp,arg1,arg2
	test	eax,eax
	js	acceptloop
	mov	edi,eax ; our descriptor

;wait4 ( pid, status, options, rusage )

	sys_wait4	0xffffffff,NULL,WNOHANG,NULL
	sys_wait4

;there must be 2 wait4 calls! Without them zombies can stay on the system

	sys_fork	;we now fork, child goes his own way, daddy goes back to accept
	or	eax,eax
	jz	.forward
	sys_close edi
	jmp	acceptloop
.forward:
	sys_read edi,filebuf,0xfff
	cmp	eax,byte 7		;in request there must be at least 7 symbols
	jb	near endrequest
.endrequestnot3:
	push	eax
	mov	ebx,finalpath
	mov	ecx,[document]
.back:
;at first copy the document root
	mov	al,[ecx]
	mov	byte [ebx],al
	inc	ebx
	inc	ecx
	cmp	byte [ecx],0
	jne	.back

	sub	ecx,[document]
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
	mov	byte [ebx],0;
index:
	sys_open finalpath,O_RDONLY
	test	eax,eax
%ifdef	ERR404
	js	error404
%else
	js	endrequest
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
	sys_write edi,nl,1

endrequest:
;	sys_read ebp,filebuf,0xff
;	sys_shutdown ebp,1	;shutdown ( sock, how )
;	sys_close ebp
	jmp	true_exit

%ifdef	ERR404
error404:
	pusha
	_mov	ecx,len404
	_mov	esi,msg404
	_mov	edi,finalpath
	rep	movsb
	popa
	jmp	index
%endif

UDATASEG

arg1	resb	0xff
arg2	resb	0xff
document	resb	0x04
finalpath	resb	0x1010	;10 is for safety
filebuf		resb	0x1010
bindsockstruct	resd	4

END
