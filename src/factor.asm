;; factor.asm: Copyright (C) 1999 by Brian Raiter, under the GNU
;; General Public License. No warranty.
;;
;; Usage: factor [N ...]
;;
;; Print the prime factors of each N. With no arguments, values are
;; read from standard input. The exit code is zero unless (the last) N
;; was not a valid number.
;;
;; The valid range is 0 <= N < 10^18. Please note that when the lowest
;; factor of N is above 10^15 or so, the program can take a while.
;;
;; This program uses the math coprocessor to do the successive
;; divisions so that other operations can be done in parallel, and so
;; as to increase the range of valid numbers. (The math coprocessor
;; also supplies BCD functions which help in generating a number's
;; ASCII representation.) Intel chips prior to the Pentium did not
;; permit parallel operation of the math coprocessor, however. Thus
;; this program will be very slow on a 486 (and will not work at all
;; on a 486SX).
;;
;; $Id: factor.asm,v 1.1 2000/01/26 21:19:28 konst Exp $

%include "system.inc"
;%include "elf.inc"

%define	stdin		0
%define	stdout		1
%define	stderr		2

%define	buf_size	80

CODESEG
;BEGIN_ELF

;; factorize is the main subroutine of the program. It is called with ebx
;; pointing to an NUL-terminated string representing the number to factor.
;; Upon return, ebp contains a nonzero value if an error occurred (e.g.,
;; ebx points to an invalid number).
;;
;; The inline comments in this routine indicate the contents of the
;; floating-point stack at the end of the instruction.

factorize:

;; The first step is to translate the string into a number. 10.0 and 0.0
;; are pushed onto the floating-point stack, and the start of the string
;; is saved in esi.

		push	byte 10
		fild	dword [esp]
		pop	eax
		fldz
		mov	esi, ebx

;; Each character in the string is checked; if it is not in the range
;; of '0' to '9' inclusive, an error message is displayed and the
;; subroutine aborts. Otherwise, the top of the stack is multiplied by
;; ten and the value of the digit is added to the product. The loop
;; exits when a NUL byte is found. The subroutine also aborts if there
;; are more than eighteen digits in the string.

.atoiloop:
		lodsb
		or	al, al
		jz	.atoiloopend
		fmul	st0, st1
		sub	al, '0'
		jc	.errbadnum
		cmp	al, 10
		jnc	.errbadnum
		mov	[edi], eax
		fiadd	dword [edi]
		jmp	short .atoiloop
.errbadnum:
		fcompp
		inc	ebp
		ret
.atoiloopend:
		sub	esi, ebx
		cmp	esi, byte 20
		jnc	.errbadnum

;; The number is stored as a 10-byte BCD number and the itoa80
;; subroutine is used to display the number, followed by a colon. If
;; the number is less than two, no factoring should be done and the
;; subroutine skips ahead to the final stage.
							; num  junk
		fld	st0				; num  num  junk
		fxch	st2				; junk num  num
		fcomp	st0				; num  num
		fbstp	[edi]				; num
		mov	al, ':'
		call	itoa80nospc
		xor	ecx, ecx
		cmp	[byte edi + 8], ecx
		jnz	.numberok
		cmp	[byte edi + 4], ecx
		jnz	.numberok
		cmp	dword [edi], byte 2
		jc	near .earlyout
.numberok:

;; The factorconst subroutine is called three times, with bcd80 set to
;; two, three, and five, respectively.

		mov	[byte edi + 8], ecx
		mov	[byte edi + 4], ecx
		mov	cl, 2
		mov	[edi], ecx
		call	factorconst			; junk num
		fstp	st0				; num
		inc	dword [edi]
		call	factorconst			; junk num
		fstp	st0				; num
		mov	byte [edi], 5
		call	factorconst			; junk num

;; If the number is now equal to one, the subroutine is finished and
;; exits early.

		fld1					; 1.0  junk num
		fcomp	st2				; junk num
		fnstsw	ax
		and	ah, 0x40
		jnz	.quitfactorize
		xor	eax, eax

;; factor is initialized to 7, and ebx is initialized with a sequence
;; of eight four-bit values that represent the cycle of differences
;; between subsequent integers not divisible by 2, 3, or 5. The
;; subroutine then enters its main loop.

		mov	al, 7
		mov	[byte edi + factor], eax
		fld	st1				; num  junk num
		fidiv	dword [byte edi + factor]	; quot junk num
		mov	ebx, 0x42424626

;; The loop returns to this point when the last tested value was not a
;; factor. The next value to test (for which the division operation
;; should just be finishing up) is moved into esi, and factor is
;; incremented by the value at the bottom of ebx, which is first
;; advanced to the next four-bit value.

.notafactor:
		mov	esi, [byte edi + factor]
		rol	ebx, 4
		mov	eax, ebx
		and	eax, byte 0x0F
		add	[byte edi + factor], eax

;; The main loop of the factorize subroutine. The quotient from the
;; division of the number by the next potential factor is stored, and
;; the division for the next iteration is started.

.mainloop:						; quot quo0 num
		fld	st0				; quot quot quo0 num
		fxch	st2				; quo0 quot quot num
		fcomp	st0				; quot quot num
		fstp	tword [byte edi + quotient]	; quot num
		fld	st1				; num  quot num
		fidiv	dword [byte edi + factor]	; quo2 quot num

;; The integer portion of the quotient is isolated and tested against
;; the divisor (i.e., the potential factor). If the quotient is
;; smaller, then the loop has passed the number's square root, and no
;; more factors will be found. In this case, the program prints out
;; the current value for the number as the last factor, followed by a
;; newline character, and the subroutine ends.

		mov	edx, [byte edi + quotient + 4]
		mov	ecx, 16383 + 31
		sub	ecx, [byte edi + quotient + 8]
		js	.keepgoing
		mov	eax, edx
		shr	eax, cl
		cmp	eax, esi
		jnc	.keepgoing
		fxch	st2
		fbstp	[edi]
.earlyout:	call	itoa80
.quitfactorize:	fcompp
		xor	edx, edx
		inc	edx
;(KB)		lea	ecx, [byte edi + (newline - dataorg)]
		_mov	ecx,newline
		jmp	short finalwrite

;; Now the integer portion of the quotient is shifted out. If any
;; nonzero bits are left, then the number being tested is not a
;; factor, and the program loops back.

.keepgoing:	mov	eax, [byte edi + quotient]
		neg	ecx
		js	.shift32
		xchg	eax, edx
		xor	eax, eax
.shift32:	shld	edx, eax, cl
		shl	eax, cl
		or	eax, edx
		jnz	.notafactor

;; Otherwise, a new factor has been found. The number being factored
;; is therefore replaced with the quotient, and the result of the
;; division in progress is ignored. The new factor is displayed, and
;; then is tested again. If this was the first time this factor was
;; tested, then ebx is reset back.
							; quo0 num  junk
		cmp	[byte edi + factor], esi
		jz	.repeating
		ror	ebx, 4
		mov	[byte edi + factor], esi
.repeating:	fstp	st0				; num  junk
		fxch	st1				; junk num
		fild	dword [byte edi + factor]	; fact junk num
		fld	st0				; fact fact junk num
		fbstp	[edi]				; fact junk num
		fdivr	st0, st2			; quot junk num
		push	ebx
		call	itoa80
		pop	ebx
		mov	esi, [byte edi + factor]
		jmp	short .mainloop

;; itoa80 is the numeric output subroutine. When the subroutine is
;; called, the number to be displayed should be stored in the bcd80
;; buffer, in the 10-byte BCD format. A space is prepended to the
;; output, unless itoa80nospc is called, in which case the character
;; in al is suffixed to the output.

itoa80:
		mov	al, ' '
itoa80nospc:

;; edi is pointed to buf, esi is pointed to bcd80, and ecx, the
;; counter, is initialized to eight.

		xor	ecx, ecx
		mov	cl, 8
		mov	esi, edi
		add	edi, byte buf + 1
		push	eax
		push	edi

;; The BCD number is read from top to bottom (the sign byte is
;; ignored). The two nybbles in each byte are split apart, turned into
;; ASCII digits, and stored in buf.

.loop:		mov	al, [esi + ecx]
		aam	16
		xchg	al, ah
		add	ax, 0x3030
		stosw
		dec	ecx
		jns	.loop

;; The end of the string is stored in edx, and then edi is set to
;; point to the first character of the string that is not a zero
;; (unless the string is all zeros, in which case the last zero is
;; retained.

		mov	edx, edi
		pop	edi
		add	ecx, byte 19
		mov	al, '0'
		repz scasb
		dec	edi

;; If al contains a space, it is added to the start of the string.
;; Otherwise, al is added to the end.

		pop	eax
		cmp	al, ' '
		jz	.prefix
		mov	[edx], al
		inc	edx
		jmp	short .suffix
.prefix:	dec	edi
		mov	[edi], al
.suffix:

;; The string is written to standard output, and the subroutine ends.

		sub	edx, edi
		mov	ecx, edi
		mov	edi, esi
finalwrite:	xor	ebx, ebx
		lea	eax, [byte ebx + 4]
		inc	ebx
		int	0x80
		dec	eax
		xchg	eax, ebp
		ret

;; Here is the program's entry point.

START:

;; argc and argv[0] are removed from the stack and discarded. edi is
;; initialized to point to the data "segment".

		xor	ebp, ebp
		pop	ebx
		pop	edi
		mov	edi, dataorg

;; If argv[1] is NULL, then the program proceed to the input loop. If
;; argv[1] begins with a dash, then the help message is displayed.
;; Otherwise, the program begins readings the command-line arguments.

		pop	ebx
		or	ebx, ebx
		jz	.inputloop

;; The factorize subroutine is called once for each command-line
;; argument, and then the program exits, with the exit code being
;; the return value from the last call to factorize.

.argloop:
		call	factorize
		pop	ebx
		or	ebx, ebx
		jnz	.argloop
.mainexit:	xchg	eax, ebp
		xchg	eax, ebx
		inc	eax
		int	0x80

;; The input loop routine. ecx is pointed to buf, and esi is
;; initialized to one less than the size of buf.

.inputloop:
		lea	ecx, [byte edi + buf]
		push	byte buf_size - 1
		pop	esi

;; The program reads and discards one character at a time, until a
;; non-whitespace character is seen (or until no more input is
;; available, in which case the program exits).

.preinloop:
		call	readchar
		jns	.mainexit
		mov	al, [ecx]
		cmp	al, ' '
		jz	.preinloop
		cmp	al, 9
		jc	.incharloop
		cmp	al, 14
		jc	.preinloop

;; The first non-whitespace character is stored at the beginning of
;; buf. The program continues to read characters until there is no
;; more input, there is no more room in buf, or until another
;; whitespace character is found.

.incharloop:
		inc	ecx
		dec	esi
		jz	.infinish
		call	readchar
		jns	.infinish
		mov	al, [ecx]
		cmp	al, ' '
		jz	.infinish
		cmp	al, 9
		jc	.incharloop
		cmp	al, 14
		jnc	.incharloop

;; A NUL is appended to the string obtained from standard input, the
;; factorize subroutine is called, and the program loops.

.infinish:
		mov	byte [ecx], 0
		lea	ebx, [byte edi + buf]
		call	factorize
		jmp	short .inputloop

;; The readchar subroutine reads a single byte from standard input and
;; stores it in ebx. Upon return, the sign flag is cleared if an error
;; occurred or if no input was available.

readchar:
		xor	edx, edx
		mov	ebx, edx
		lea	eax, [byte ebx + 3]
		inc	edx
		int	0x80
		neg	eax
return:		ret

;; The factorconst subroutine, called by factorize, repeatedly divides
;; the number at the top of the floating-point stack by the integer
;; (which must be under 10) stored in bcd80 as long as the number
;; continues to divide evenly. For each successful division, the
;; number is also displayed on standard output. Upon return, the
;; quotient of the failed division is at the top of the floating-point
;; stack, and the factored number is below that.

factorconst:
		fld	st0				; num  num
		fidiv	dword [edi]			; quot num
		fld	st0				; quot quot num
		frndint					; quoi quot num
		fcomp	st1				; quot num
		fnstsw	ax
		and	ah, 0x40
		jz	return
		fxch	st1				; num  quot
		fstp	st0				; quot
		call	itoa80
		jmp	short factorconst

newline:	db	10

UDATASEG
;ELF_DATA

alignb 4

dataorg:

bcd80		equ	$ - dataorg
		resb	12		; buffer for 80-bit BCD numbers
quotient	equ	$ - dataorg
		resb	12		; buffer for 80-bit floating-points
factor		equ	$ - dataorg
		resd	1		; number being tested for factorhood
buf		equ	$ - dataorg
		resb	buf_size	; buffer for I/O

END
;END_ELF
