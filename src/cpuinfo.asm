;-====================================================================;
;- Copyright (C) 2000 H-Peter Recktenwald, Berlin <phpr@snafu.de>
;-
;- $Id: cpuinfo.asm,v 1.1 2000/04/07 18:36:01 konst Exp $
;-
;-  file  	: cpuinfo.asm
;-  created	: 18-jan-2000
;-  modified	: 12-mar-2000
;-  version	: 0.17 04-04-00 .bss-'trick' eliminated
;-		: 0.16 31-03-00 <start>,<cpurg>,<p_num> shorter
;-		: 0.14 25-03-00 text output, w.o. macros, shorter
;-		: 0.13 16-03-00 text output level 1; 'long' only
;-		; 0.12 15-03-00 again intel 2nd level correction
;-		: 0.11 12-03-00 more intel 2nd level correction
;-		: 0.10 10-03-00 arbitrary intel flag correction
;-		: 0.09 08-03-00 1st release
;-  assembler	: nasm 0.98
;-  description	: short form i486+ cpuid output, sedecimal register
;-		: values, and text output if invoked with (any)
;-		: argument. self adjusting to cpuid stepping, and
;-		: lines numbering scheme added for easier evaluation.
;-		: output:
;-		: leading "0x" for standard level queries,
;-		:	  "1x" intel cache description,
;-		:	  "8x" amd extended levels (eax=0x80000000+)
;-		:	where "x" is the corresponding level number,
;-		: followed by 8 digits sedecimal eax..edx values/line
;-  author	: H-Peter Recktenwald, Berlin <phpr@snafu.de>
;-  comment	: cpl: <Makefile> of asmutils 0.08 will work,
;-		: 'long' text output treated as ascii, no conversion
;-		: nor checks done, thus output might get corrupted
;-		: if any chars found which sys_write doesn't catch.
;-  source	: AMD no. 218928F/0 Aug 1999, pg 3 f.
;-====================================================================;
;-

;-
;- result can be processed,
;- for instance, to extracting the processor signature:
;-	signature=0x`cpuinfo|grep "^01 "|cut -d\  -f2`
;- further,
;-	vtype	=$(((${signature}&0x03000)>>12))
;-	family  =$(((${signature}&0x00f00)>>8))
;-	model   =$(((${signature}&0x000f0)>>4))
;-	stepping=$(((${signature}&0x0000f)))
;-

%include "system.inc"

BS  equ 8
LF  equ 10
CR  equ 13
DEL equ 127

;====================================================================;

%ifndef jr		; lazy typing.. (z80)
%define jr jmp short
%endif

; --------------------

	CODESEG

no_cpuid:
    db "no 'cpuid'"
crlf:
    db LF,0

; --

START:
    lea esi,[lflg]	; short/long output flag
    pop eax
    dec eax
    mov [esi],al		;16;
    pushfd
    pop eax
    mov ebx,eax
    xor eax,1<<21
    push eax
    popfd
    pushfd
    pop eax
    cmp eax,ebx
    jz cpuid_ni		; <cpuid> not present
; - standard levels -
    xor eax,eax
    cpuid
    push eax		; save no. of standard levels
    call idpt		; standard features
; - AMD xt'd -
    mov eax,0x80000000
    cpuid
    test eax,eax
    jns .i		; try intel 2nd level		;11;
    call idpt		; amd extended features
.i:
    pop eax
    cmp eax,byte 2
    jc syx		; no additional standard config data
; - intel level 2 cache cfg -
    mov al,2
    cpuid
    dec al
    jle syx		; none/1st level already done	;12; <- re AP-485, 3.4, pg 12
    movzx eax,al	; counter is just l.s.b		;11;
    or eax,0x10000000	; 'intel' output flag
    call idpt		; cache description
syx:
    sys_exit 0

cpuid_ni:
    lea ecx,[no_cpuid]
    call p_string
    jr syx

; - display all of one level mode -
idpt:
    push ax
    mov edi,eax
    xor di,di
.l:
    mov eax,edi
    call cpurg		; output a line of register values
    inc di
    dec word[esp]
    jns .l		; loop through all levels
    pop ax
    ret

; - display one line of regs -
cpurg:
    mov ebx,eax			;16;14;
    rol eax,8		; merge top nib. into lo byte
    or al,ah
    call p_b		; print packed levelflag & number
    mov eax,ebx
    and eax,0xefffffff	; mask intel-2nd-level flag	;10;
    cpuid
    call p_num
    xchg eax,ebx	; a:=b b:=a	;16;
    call p_num
    xchg eax,ecx	; a:=c b:=a c:=b
    call p_num
    xchg eax,edx	; a:=d b:=a c:=b d:=c
    call p_num
    test byte[esi],-1
    jng .r		; no text
; - regs text representation -
    test di,di		; count
    jnz .o
    xchg eax,edx	; #1: xg for name stg.
.o:
    push ecx
    lea ecx,[byte esi-lflg+rbuf+1]
    mov dword[ecx]," '"
    call p_string
    dec ecx		; leave terminating <nul>
    mov [ecx],ebx	; a
    call p_string
    pop dword[ecx]	; b
    call p_string
    mov [ecx],edx	; c
    call p_string
    mov [ecx],eax	; d
    call p_string
    mov word[ecx],"'"
    call p_string
.r:
    lea ecx,[crlf]			;14;17;
; <p_string>
; print string {ecx} to stdout
; all regs preserved
p_string:
    pushad
    mov edx,ecx
    dec edx
.l:
    inc edx
    cmp byte[edx],LF
    jnl .l
    sub edx,ecx
syswrite:
    sys_write STDOUT
    popad
    ret

; print sedecimal number {edx} to stdout
; all regs preserved
; <p_b> l.s.byte
; <p_num> dword
p_num:			; 8 digits
    pushad
    push byte 8			;16;
.n:
    mov edx,eax			;16;
    pop ebx
    xor eax,eax
    lea ecx,[byte esi-lflg+rbuf+8]
    mov byte[ecx],' '
    push ebx
.p:
    mov al,15
    and al,dl
    shr edx,4
    dec ecx
    add al,0x90
    daa
    adc al,0x40
    daa
    mov [ecx],al
    dec bl
    jg .p
    pop edx
    inc edx		; trailing blank
    jr syswrite

p_b:			; 2 digits
    pushad
    push byte 2			;16;
    jr p_num.n

    UDATASEG

rbuf:
    resd 2		; 8 digits
    resw 1		; <bl>,<eol>
lflg:
    resw 1		; text output flag

    END
;-								
;-====================================================================
;- cpuinfo.asm <eof>
