;Copyright (C) H-Peter Recktenwald <phpr@snafu.de>
;
;$Id: extname.asm,v 1.1 2000/04/07 18:36:01 konst Exp $
;
;hackers' extname (return extension or postfix of a given filename)
;
;0.01: 25-mar-2000	initial release
;0.02: 02-apr-2000	scan basename part only
;
;syntax: extname filename [delimiter]
;	 delimiter is "." by default or,
;	 optionally 1st char of any length argument stg.
;
;if delimiter found:
;	ret. part of filename's basename after delimiter
;if delimiter not found:
;	ret. empty string
;
;exitcode:
;	1 if no argument given, 0 otherwise
;


%include "system.inc"

;uncomment to saveing a few bytes if
; 	no pathnames will be passed to <extname> or,
;	delimiter is at some position, unknown but valid
;%define BASENAME


ddir: equ '/'	; maxlen delimiter (directory marker)
dext: equ '.'	; default extension delimiter


    CODESEG


START:
    pop	ebx
    dec ebx
    jz .r
    mov ah,dext	; default dlm
    pop	edi	; name
    pop edi	; 1st arg
    dec ebx
    jz .a	; no more
    pop eax	; get delimiter
    mov ah,byte[eax]
.a:
    cld		; scan incrementing
; find string
    xor ecx,ecx
    dec ecx
    xor al,al
    repnz scasb
    mov edx,ecx
    std		; scan back
    not ecx
    mov edx,ecx
%ifndef BASENAME
; discriminate basename
    mov al,ddir	; dirname delimiter
    dec edi
    dec edx
    repnz scasb
    jz .b
    dec edi	; full length
.b:
    sub edx,ecx	; maxlen
    mov ecx,edx
    lea edi,[2+edx+edi]	; basename
%endif
    mov al,ah	; delimiter
    dec edi	; pts to before dlm, if found
    dec edx
    repnz scasb
    jz .f
    mov ecx,edx	; ret empty
.f:
    sub edx,ecx
    lea ecx,[edi+2]	; compensate for dlm & <nul>
    mov [ecx+edx],byte __n
    inc edx
    sys_write STDOUT
    xor ebx,ebx
    dec ebx
.r:
    inc	ebx
    sys_exit

END
