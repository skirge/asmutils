;Copyright (C) 1999 Indrek Mandre <indrek.mandre@tallinn.ee>
;
;$Id: httpd.asm,v 1.1 2000/01/26 21:19:30 konst Exp $
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
;0.01: 17-Jun-1999	initial release
;0.02: 04-Jul-1999	fixed bug with 2.0 kernel, minor changes
;0.03: 29-Jul-1999	size improvements

%include "system.inc"

CODESEG
;these structs are for size optimisation :)
    socketargs		db	2,0,0,0,1,0,0,0,6,0,0,0x0
    setsockoptargs	db	0,0,0,0,1,0,0,0,2,0,0,0,0,0,0,0,4,0,0,0x0
    setsockoptvals	db	1,0,0,0x0
    bindsockstruct	db	2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0x0
    nl			db	0xA


START:
	pop	esi
	cmp	esi,byte 3		;3 arguments must be there
	jnz	.exit

	pop	esi ; our own name

	pop	dword [document]
	pop	esi		;port number

; this code was written by Konstantin Boldyshev
;<ESI -string
;>EAX - result

%if KERNEL=20
	_mov	eax,0
	_mov	ebx,10
	_mov	ecx,0
%elif KERNEL=22
	mov	bl,10
%endif
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
	jmp short .next
.done:
	push	eax

;socket ( PF_INET, SOCK_STREAM, IPPROTO_TCP )

	sys_socketcall 1,socketargs

	test	eax,eax
	js	.exit
	mov	edx,eax		;socket descriptor

	mov	dword [setsockoptargs],edx			;fd
	mov	dword [setsockoptargs+12],setsockoptvals	;optval

; setsockopt ( s, SOL_SOCKET, SO_REUSEADDR, &optval, 4);

	sys_socketcall 0x0E,setsockoptargs

	or	eax,eax
	jz	.continue1
.exit:
	sys_exit_false

.continue1:
	mov	dword [Buf], edx	;fd
	pop	eax
	mov	byte [bindsockstruct + 2],ah
	mov	byte [bindsockstruct + 3],al
	mov	dword [Buf+4], bindsockstruct	;struct sockaddr_in
	mov	dword [Buf+8], 16		;sizeof (struct sockaddr_in)

;bind ( s, struct sockaddr *bindsockstruct, 16 );

	sys_socketcall 0x02,Buf

	or	eax,eax
	jnz	.exit

	mov	dword [Buf+4],0xff	;backlog

;listen ( s, 0xff )

	sys_socketcall	0x04

	or	eax,eax
	jnz	.exit

	sys_fork	;fork after everything is done and exit main process
	or	eax,eax
	jz	.continue5
.true_exit:
	sys_exit_true

.continue5
	mov	dword [Buf+4],arg1	;struct sockaddr_in *
	mov	dword [Buf+8],arg2	;int *addrlen
.acceptloop
	mov	dword [arg2],16		;sizeof (struct sockaddr_in)

;accept ( s, struct sockaddr *arg1, int *arg2 )

	sys_socketcall 0x05,Buf

	mov	edi,eax ; our descriptor

;wait4 ( pid, status, options, rusage )

	sys_wait4	-1,NULL,WNOHANG,NULL
	sys_wait4

;there must be 2 wait4 calls! Without them zombies can stay on the system

	sys_fork	;we now fork, child goes his own way, daddy goes back to accept
	or	eax,eax
	jz	.forward
	sys_close edi
	jmp	short .acceptloop
.forward:
	sys_read edi,filebuf,0xfff
	cmp	eax,byte 7		;in request there must be at least 7 symbols
	jb near .endrequest
.endrequestnot3
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
	ja near .endrequest

.endrequestnot2:

;now append the demanded

	mov	ecx,filebuf+4
.loopme:
	mov	al,[ecx]
	mov	byte [ebx],al
	cmp	word [ecx], '..'
	jz near .endrequest	;security error, can't have '..' in request
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
	cmp	dl,0x0D
	jz	.loopout
	cmp	dl,0x0A
	jnz	.loopme
.loopout:
	cmp	byte [ebx-1],'/'		;append index.html :)
	jne	.noindex
	mov	dword [ebx],'inde'
	mov	dword [ebx+4],'x.ht'
	mov	dword [ebx+8],0x6e006c6d	;'ml'
	jmp	short .index
.noindex:
	mov	byte [ebx],0;
.index:
	sys_open finalpath,O_RDONLY
	test	eax,eax
	js	.endrequest
	mov	ebx,eax
	mov	esi,eax
	mov	ecx,filebuf
.writeloop:
	mov	edx,0xfff
	sys_read
	test	eax,eax
	js	.endread
	mov	ebx,edi
	mov	edx,eax
	sys_write
	mov	ebx,esi
	test	eax,eax
	jz	.endread
	jns	.writeloop
.endread:
	sys_close

	mov	ebx,edi	;due the stupidity of netscape we need to send another packet
	mov	edx,0x1	;newline \n, so it can handle one line data
	mov	ecx,nl	;but I'm afraid it might break something, so watch this
	sys_write	;code carefully in the future

.endrequest:
	mov	dword [arg1],edi		;sock
	mov	dword [arg1+4],0x00000001	;how = 1

;shutdown ( sock, how )

	sys_socketcall 0x0D,arg1

	mov	ebx,edi
	mov	edx,0xff
	sys_read
	sys_close
	jmp	.true_exit

UDATASEG

Buf	resb	0xff
arg1	resb	0xff
arg2	resb	0xff
document	resb	0x04
finalpath	resb	0x1010	;10 is for safety
filebuf		resb	0x1010

END
