; Copyright (C) 2001 Stanislav Ryabenkiy <stani@ryabenkiy.com>
; Licensed (of course) under the GPL, version 2. 
;
; $Id: mknod.asm,v 1.1 2001/07/20 07:04:18 konst Exp $
;
; hackers' mknod/mkfifo
;
; This program is free software; you can redestribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful, 
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
; GNU General Public License for more details.
; 
; NOTES
; no modes are set. hey, wtf do you think we have chmod for? :-)
; otherwise, syntax identical to GNU mknod/mkfifo
;
; bear with me, this is my first asm prog :-)
; please email me any comments/suggestions/flames
;
;0.5:	16-Jul-2001	initial release (didn't make it to my outbox)
;0.6:	18-Jul-2001	size improvements (8 bytes)
;
;syntax: mknod NAME b|u|c|p MAJ MIN
;	 mkfifo NAME
; 
;ex:	 mknod /dev/null c 1 3
;	 mkfifo pipe
;
	 
%include "system.inc"

CODESEG

START:
	pop	edi		; argc	
	pop	esi		; argv[0], progname
	pop	edi		; argv[1], NAME
	test	edi,edi
	jz	near .exit
.n1:				; how are we called?
	lodsb
	or	al,al
	jnz	.n1
	cmp	dword [esi-7], 'mkfif'
	jz	near .mkfifo

	;; parse argv[2], ie. wtf are we gonna do?

	pop	ebx		; argv[2], type
	test	ebx,ebx
	jz	near .exit

	cmp	byte [ebx], "p"
	jnz	.skip0
.mkfifo:
	mov 	word [type], S_IFIFO
	jmp	.dirty 		; skip all the stuff that we won't need
.skip0:
	cmp	byte [ebx], "c"
 	jnz	.skip1
	mov	word [type], S_IFCHR	
	jmp	.majmin
.skip1:	
 	cmp	byte [ebx], "u"
 	jnz	.skip2
	mov	word [type], S_IFCHR	
	jmp	.majmin
.skip2:	
 	cmp	byte [ebx], "b"
 	jnz	.exit
	mov	word [type], S_IFBLK	

.majmin:	
	pop	ecx		; argv[3], maj
	test	ecx,ecx
	jz	.exit
	pop	edx		; argv[4], min
	test	edx,edx
	jz	.exit		

	;; translate strings for maj/min
	mov	esi,ecx
 	call	.atoi
 	mov	ecx,eax
 	mov	esi,edx
  	call	.atoi
 	mov	edx,eax

	;; construct dev_t from maj/min
	shl	ecx, 8
	or	ecx,edx
.dirty:
	;; create node. ecx will be ignored if S_IFIFO
	sys_mknod edi, [type],ecx
	jmp	short .exit		


	
.exit:
	sys_exit eax

.atoi:			; 'borrowed' from jonathan leto's chown :-)
			; (hey, my first asm prog, what do you want?)
	xor	eax,eax
	xor	ebx,ebx
.next:
	lodsb			; argument is in esi 
	test	al,al
	jz	.done
	sub	al,'0'
	imul	ebx,10
	add	ebx,eax
	jmp	.next		
.done:
	xchg	ebx,eax
	ret			; return value is in eax

		
UDATASEG			; I just couldn't keep it on one segment..

type:	resb	2

END



















