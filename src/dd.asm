;Copyright (C) 2001 Rudolf Marek <marekr2@feld.cvut.cz>
;
;$Id: dd.asm,v 1.4 2002/04/16 02:53:26 konst Exp $
;
;hackers' dd
;
;syntax: dd if= of= count= skip= bs= seek=
;
;number can be also 1k=1*1024 etc k=1024 b=512 w=2
;
;0.1: 2001-Feb-21	initial release
;0.2: 2002-Apr-15	added O_LARGEFILE for input file
;
;All comments/feedback welcome.

%include "system.inc"

%ifdef	__LINUX__
%define LARGE_FILES
%endif

CODESEG

usage	db	"usage: dd as you know except ibs= obs= conv=",__n
_ul	equ	$-usage
%assign	usagelen _ul

START:  
	_mov 	ebp,STDOUT
	_mov 	edi,STDIN 
        pop     eax                     ;argc
        dec     eax
        pop     eax                     ;argv[0], program name
        jnz      .continue

	sys_write ebp,usage,usagelen
	sys_exit 0

.continue:
	
	mov	byte [bs+1],0x2		;bs = 512 - default block size
	
.next_arg:
	pop	esi
	or 	esi,esi
	jz 	near .no_next_arg

.we_have_arg:
	push 	dword .next_arg

	cmp 	word [esi],'of'
	jz 	.parse_output_file
	cmp 	word [esi],'if'
	jz 	.parse_input_file
	mov	edx,count
	cmp 	dword [esi],'coun'
	jz 	.update_fields	
	add	edx,byte 4
	cmp 	word [esi],'bs'
	jz 	.update_fields	
	add	edx,byte 4
	cmp 	dword [esi],'skip'
	jz 	.update_fields	
	add	edx,byte 4
	cmp 	dword [esi],'seek'
	jz 	.update_fields	

	ret  ;ignore unknown opt

;.parse_output_file:
	;call  	.check
	;sys_open esi,O_WRONLY|O_CREAT|O_TRUNC,S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH ;dd feeds 666
	;test 	eax,eax
	;js 	.error
	;mov 	ebp,eax
	;ret
;.parse_input_file:
;	call 	.check
;	sys_open esi,O_RDONLY
;	test 	eax,eax
;	js 	.error
;	mov 	edi,eax
;	ret

.parse_input_file:		;I always wanted to xchange .. :)
	_mov	ecx,(O_RDONLY|O_LARGEFILE)
	xchg	edx,ebp
	call	.open
	xchg	edi,ebp
	xchg	edx,ebp
	ret

.parse_output_file:
	_mov	ecx,(O_WRONLY|O_CREAT|O_TRUNC|O_LARGEFILE)
	_mov	edx,(S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH) ;dd feeds _always_ 666
.open:	
	call 	.check
	xchg 	ebx,esi
	sys_open
	test 	eax,eax
	js 	.error
	xchg 	ebp,eax
	ret

.update_fields:
	call 	.check
	call 	.ascii_to_num
	mov 	[edx],eax
	ret
.check:
	lodsb
	or 	al,al
	jz	.do_error
.ok:
	cmp 	al,'='
	jnz 	.check
	ret
.do_error:
.error:
	sys_exit 1

.no_next_arg:			;now we should have opened files - ready to copy
	mov 	eax,[bs]
	push	eax
	add	eax,buf
	sys_brk eax            ;get some mem
	pop	eax
	mul 	dword [skip]   ;EDX:EAX seek

%ifdef LARGE_FILES
	push    edi
	mov     ebx,edi
	mov     ecx,edx
	mov     edx,eax
	_mov     esi,result
	_mov     edi,SEEK_SET
	sys_llseek
	;pop	edi
%else	
	or 	edx,edx		;file bigger than 4Gb cannot skip more use llseek instead ?
	jnz 	.do_error	
	sys_lseek edi, eax, SEEK_SET
%endif
	mov 	eax,[bs]
	mul 	dword [seek]
%ifdef LARGE_FILES
	mov     ebx,ebp
	mov     ecx,edx
	mov     edx,eax
	;push    edi
	;mov     esi,result
	;mov     edi,SEEK_SET
	sys_llseek
	pop	edi
%else
	or 	edx,edx
	jnz 	.do_error	
	sys_lseek ebp,eax,SEEK_SET
%endif
	mov 	esi,[count]
.next_block:
	sys_read edi,buf,[bs]
	test 	eax,eax
	jz 	.no_more_data
	js 	near .do_error
	mov 	ebx,ebp
	mov 	edx,eax
	sys_write
	dec 	esi
	jnz	.next_block
;	jz 	.no_more_data
;	cmp 	edx,[bs]
;	jz 	.next_block
;	jmp short .next_block ;should be here because of reding from STDIN
.no_more_data:	
	sys_close edi
	sys_close ebp
	sys_exit 0	
;---------------------------------------stolen from renice.asm
; esi = string
; eax = number 
.ascii_to_num:
	;push	esi
        xor     eax,eax                 ; zero out regs
        xor     ebx,ebx
	
	;cmp     [esi], byte '-'
        ;jnz     .next_digit
        ;lodsb

.next_digit:
        lodsb                           ; load byte from esi
        or    al,al
        jz      .done
	cmp 	al,'9'
	ja  	.multiply  
        sub     al,'0'                  ; '0' is first number in ascii
        imul    ebx,10
        add     ebx,eax
        jmp     short .next_digit

.done:
        xchg    ebx,eax
	;pop	esi
        ;cmp     [esi], byte '-'
        ;jz     .done_neg
        ret
;.done_neg:
;	neg	eax			;if first char is -, negate
;	ret
.multiply:
	cmp 	al,'w'
	jz	 .mul_2
	cmp 	al,'b'
	jz 	.mul_512
	cmp 	al,'k'
	jnz	near .error		;we don't know others yet

.mul_1024:
	shl	ebx,1
.mul_512: 
	shl	ebx,8
.mul_2:
	shl	ebx,1
	jmp	short .done
		
;---------------------------------------	

UDATASEG

count	resd	1
bs	resd	1
skip	resd	1
seek	resd	1

result	resq	1
buf	resb	1	;here will our buff start

END
