;-====================================================================;
;- Copyright (C) 2000 H-Peter Recktenwald, Berlin <phpr@snafu.de>
;-
;- $Id: cpuspeed.asm,v 1.1 2000/04/07 18:36:01 konst Exp $
;-
;-  file  	: cpuspeed.asm
;-  created	: 06-apr-2000
;-  modified	:
;-  version	:
;-		: 0.01 06-04-00 1st release
;-  assembler	: nasm 0.98
;-  description	: count & display cpu timing in clocks/second
;-		: idle(!) environment deviation ca. 0,001%,
;-		: %define <ms> to display scaled down (below).
;-  author	: H-Peter Recktenwald, Berlin <phpr@snafu.de>
;-  comment	: cpl: <Makefile> of asmutils 0.08 will work,
;-		: default measurement interval 1 sec,
;-		: define <e2sec> for other timings (below).
;-  source	: 'cpuspeed.cpp' by AMD
;-====================================================================;
;-

;-
;-

%include "system.inc"

;====================================================================;

%ifndef jr
%define jr jmp short
%endif

; --------------------

	CODESEG

;%define ms 1000000	; clocks per micro second
;%define ms 1000   	; clocks per ms
%define e2sec 0		; timing interval (exp 2)
req:
    dd 1<<e2sec,0

; --

START:
    pushfd
    pop eax
    mov edx,eax
    xor eax,1<<21
    push eax
    popfd
    pushfd
    xor ebx,ebx
    pop eax
    cmp eax,edx
    setz bl
    jz syx		; <cpuid> not present
    rdtsc
    push eax
    lea ecx,[rem]	; syscall answer space
    sys_nanosleep req	; sleep ({e2sec}^2)
    rdtsc
    pop edx
    sub eax,edx
%if e2sec>0
    shr eax,e2sec	; take 1s average of ({e2sec}^2)s
%endif
%ifdef ms
    mov ebx,ms		; scale to factor {ms}
    xor edx,edx
    div ebx
%endif
    call p_num
    sys_write STDOUT,nl,1
    xor ebx,ebx
syx:
    sys_exit

nl	db	__n

; print decimal number {eax} to stdout
; all regs preserved
; <p_b> l.s.byte
; <p_num> dword
p_num:
    pushad
    xor ebx,ebx
    push ebx		; length counter
    mov bl,10		; radix
.l:
    dec ecx		; numbuf-
    inc dword[esp]
    xor edx,edx		; hi dword for div
    div ebx
    or dl,'0'
    mov [ecx],dl
    test eax,eax
    jnz .l
    pop edx		; count
syswrite:
    sys_write STDOUT
    popad
    ret

    UDATASEG

rbuf:
    resd 3		; 12 digits
rem:
    resd 2		; nanosleep answer
    
    END
;-								
;-====================================================================
;- cpuspeed.asm <eof>
