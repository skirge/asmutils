;Copyright (C) 1999 Indrek Mandre <indrek.mandre@tallinn.ee>
;
;$Id: basename.asm,v 1.3 2000/09/03 16:13:54 konst Exp $
;
;hackers' basename	[GNU replacement]
;
;0.01: 17-Jun-1999	initial release
;0.02: 04-Jul-1999	bugfixes
;0.03: 29-Jul-1999	size improvements
;
;syntax: basename path [suffix]
;
;example: basename /bin/basename
;         basename /kala.xxx xxx
;
; in case of error exits with code 256, 0 otherwise
;
; Changelog:
;       added printing of '\n';
;       sufix cant be equal in length to name, must be smaller always
;       in case of single character print out anyway
;       in case of name/ print name
;       fixed error return status
;       in case of ////////// as path it printed out "basename", fixed that

%include "system.inc"

CODESEG

lf	db	0x0A

START:
	pop	eax
	mov	edi,eax		;edi holds argument count
        dec	edi
	jz	.error
	cmp	edi,byte 2		;must be not more than two arguments
	jng	.noerror
.error:
	sys_exit_false
.noerror:
	pop	eax		;skip our name
	pop	eax		;the path
	mov	ebx,eax		;mark the beginning of path
	xor	edx,edx
	cmp	byte [eax],EOL
	je	.printout
.loopone:
	inc	eax
	cmp	byte [eax],EOL
	jne	.loopone
	mov	edx,eax		;mark the end
.backwego:
	dec	eax
	cmp	eax,ebx
	jnl	.empty
	xor	edx,edx
	jmp short .printout
.empty:
	cmp	byte [eax],'/'
	je	.backwego
	inc	eax
	mov	edx,eax
.looptwo:
	dec	eax
	cmp	byte [eax],'/'
	je	.endlooptwoinceax
	cmp	eax,ebx
	je	.endlooptwo
	jmp short .looptwo

.endlooptwoinceax:
	inc	eax

.endlooptwo:
	mov	ecx,eax
	sub	edx,eax
	dec	edi
	jz	.printout	;we have no suffix to remove
	pop	eax
	push	ecx
	push	edx
	add	ecx,edx
  
;now we check for suffix
	mov	ebx,eax		;save start of suffix

	cmp	byte [eax],EOL
	je	.goaftersuffix	;there was nothing in suffix string, so nothin to remove
.suffixloop:
	inc	eax
	cmp	byte [eax],EOL
	jne	.suffixloop
.endsuffixloop:
	sub	eax,ebx		;we have length of suffix here now
	cmp	eax,edx		;in case suffix is longer jump out
	jge	.goaftersuffix
	add	eax,ebx

	push	eax

;now comes the comparing part
.sloop:
	dec	eax
	dec	ecx

	mov	dl,[eax]
	cmp	[ecx],dl
	jne	.goaftersuffixpopeax	;not equal

	cmp	eax,ebx
	jne	.sloop

;we got here, that means sufix matched

	pop	eax
	sub	eax,ebx		;we have here the all famous length
	pop	edx
	pop	ecx
	sub	edx,eax		;decrement the length by suffix
	jmp short .printout	;and print it out

;end of checkinf of suffix

.goaftersuffixpopeax:
	pop	eax
.goaftersuffix:
	pop	edx
	pop	ecx

.printout:
	sys_write STDOUT
	sys_write EMPTY,lf,1;
.exit:
	sys_exit_true		;exit 0

END
