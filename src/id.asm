;Copyright (C) 1999 Dmitry Bakhvalov <dl@hrg.dhtp.kiae.ru>
;
;$Id: id.asm,v 1.1 2000/01/26 21:19:31 konst Exp $
;
;hackers' id
;
;0.01: 25-Oct-1999	initial release
;
;syntax: id
;        No options so far.
;	 
;	 Always returns 0
;
		%include "system.inc"
		
		CODESEG
		
START:
		xor	eax,eax
		mov	al,__NR_getuid		; get_uid
		mov	ebx,"uid="
		call	print_stuff
		
		mov	al,__NR_getgid		; get_gid
		mov	bl,'g'			; ebx="gid="
		call	print_stuff
		
		mov	cl,10			; print "\n"
		push	ecx
		mov	ecx,esp
		xor	edx,edx
		inc	dl
		sys_write STDOUT
		pop	ecx
		
		sys_exit_true

print_stuff:
		pushad
		
		__syscall
		test	eax,eax
		js	.error

		mov	edi,num_buf
		push	edi			; save num_buf
		push	ebx			; save "uid="

		; bin_to_dec		
		xor	ecx,ecx		
		mov	ebx,ecx
		mov	bl,10
.div_again:		
		xor	edx,edx
		div	ebx
		add	dl,'0'
		push	edx
		inc	ecx
		test	eax,eax
		jnz	.div_again
.keep_popping:		
		pop	eax
		stosb
		loop	.keep_popping
		mov	ax,9
		stosw		
		
		pop	ebx			; restore "uid="
		
		push	ebx			; put "uid=" on the stack
		mov	ecx,esp			; point ecx to it
		mov	dl,4			; len=4
		sys_write STDOUT		; write
		pop	ebx			; restore stack

		pop	esi			; restore num_buf
		
		mov	ecx,esi			; save it in ecx
		xor	eax,eax
		mov	edx,eax
		dec	edx
.do_strlen:
		inc	edx
		lodsb
		test	al,al
		jnz	.do_strlen
		
		; ecx already holds string, edx holds strlen
		sys_write STDOUT

.error:	
		popad
		ret


		UDATASEG
num_buf:	resb	16
		
		END
