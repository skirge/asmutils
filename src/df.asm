;Copyright (C) 1999-2000 Alexandr Gorlov <winct@mail.ru>
;Partial copyright (c) 1999 Kir Smirnov <ksm@mail.ru>
;
;$Id: df.asm,v 1.2 2000/03/02 08:52:01 konst Exp $
;
;hackers' df
;
;0.01: 29-Jul-1999	initial release
;0.02: 11-Feb-2000	bugfixes 
;
;syntax: df --help
;
;example: df 

%include "system.inc"

space	equ	0x20
lf	equ	0x0A

CODESEG

block_size	dd	1024		; default value 

mtab	db	'/etc/mtab',EOL

msg_usage	db	'Usage: df [OPTIONS]... [FILE]...', lf
		db	'Show information about the filesystem on which each FILE resides,',lf
		db	'or all filesystems by default.',lf,lf
		db	'	--help		display this help and exit', lf
		db	'	--version	output version information and exit',lf
len_msg_usage	equ $ - msg_usage

msg_version	db	'df (asmutils) 0.02', lf
len_msg_version	equ $ - msg_version

msg_info	db	'Filesystem           1k-blocks      Used Available Use% Mounted on',lf
len_msg_info	equ $ - msg_info



;======Errors========

mtab_open	db	'Error: Can not open /etc/mtab',lf
_l1	equ	$ - mtab_open
%assign	len_mtab_open _l1
brk_err		db	'Error: Can not allocate memory.',lf
_l2	equ	$ - brk_err
%assign	len_brk_err _l2
read_err	db	'Error: reading failed.',lf
_l3	equ	$ - read_err
%assign	len_read_err _l3


START:
;============= Parse command line =====================
	pop	esi
	pop	esi


.args:
	pop	esi
	or	esi,esi
	jz	.main50

	cmp	word [esi], "--"
	jne	.main50
	
.main10:
	cmp	dword [esi+2], "help"
	jne	.main11
	_mov	ecx,msg_usage
	_mov	edx,len_msg_usage
	jmp	error_exit
.main11:
	cmp	dword [esi+2], "vers"
	jne	near _exit
	_mov	ecx,msg_version
	_mov	edx,len_msg_version
	jmp	error_exit
	
.main50:
; Тут я начал пытаться открыть /etc/mtab и прочитать инфу о смонтированных ФС
;============================================================================
	
	sys_write STDOUT,msg_info,len_msg_info

	sys_open mtab, O_RDONLY	;В eax дескриптор !!!
	test	eax,eax
	jns	.main60		;Не смог открыть /etc/mtab
	_mov	ecx,mtab_open
	_mov	edx,len_mtab_open
	jmp	error_exit

.main60:
	push eax
	sys_lseek eax,0,SEEK_END

	push eax
	push eax
	xor ebx, ebx
	sys_brk
	mov dword [r_buf], eax
	pop ebx
	add ebx, eax
	inc ebx
	sys_brk
	or eax, eax
	jnz .main65		;!!!Ошибка выделения памяти
	_mov	ecx,brk_err
	_mov	edx,len_brk_err
	jmp	error_exit
.main65:

	

; Теперь надо прочитать строчку за строчкой

;0. Считываем первую строку в r_buf
Read:

	
	pop edx		;длинна ф
	pop ebx		;дескриптор

	push edx
	push ebx
	xor ecx, ecx
	xor edx, edx
	sys_lseek
	pop ebx
	pop edx
	
	sys_read EMPTY,[r_buf]
	test	eax,eax		;проверка на ошибку
	jns	.main70
		;Ошибка: неверный дескриптор
	_mov	ecx,read_err
	_mov	edx,len_read_err
	jmp	error_exit

.main70:

	mov ecx, eax		;Счетчик длинны строки
	cld			

	mov esi, dword [r_buf]		;!!!!?
	jmp short FindSpace
	
;1. Ищем новую строку
FindString:
	cld
	mov al, 0xa
	repne scasb		;edi указывает на начало новой строки
	mov esi, edi
	or ecx, ecx
	je near _exit		;!!!Выход с ошибкой.

;2. Ищем первый пробел	 
FindSpace:

	mov al,' '
	mov edi, dev

.sub1:
	or ecx, ecx 		
	je near _exit
.sub:
	dec ecx
	movsb			;[esi] -> [edi]
	cmp al, byte [esi]	
	jne .sub1	

	mov byte [edi], 0	;

	inc esi			
	dec ecx		


;2.1 Начинаем копировать в строку m_point 
.main75:
	mov edi, m_point 
	
.main80:
	or ecx, ecx
	jne	.main85
	sys_exit		;!!!Временная заглушка
				;jmp Read;??? Буфер кончился надо еще прочесть
.main85:
	dec ecx
	movsb			;[esi] -> [edi]
	cmp al, byte [esi]	;в al пробел
	jne .main80

	mov byte [edi], 0	;0 в конец строки
				;в esi -> на строку надо сохранить!

	push ecx		;Сохраним ecx ???
	push esi		;строку r_buf
	
;============================================================================	
	sys_statfs m_point, sfs

;Выводим полученные данные	

	mov	edi, dev		;Партиция
	call	StrLen			;в edx длинна
	push 	edx			;сохраним
	sys_write STDOUT,edi

;11.02.2000 Замечание: размер блока бывает не только 1024 байт
;следовательно этот код не правильный ??!!

	xor	edx, edx
	mov	eax, [sfs.f_blocks]
	mul	dword [sfs.f_bsize]
	div	dword [block_size]
	
	mov 	edi, testline
	call	BinNumToAscii

	pop	edx
	_mov 	ecx, 30			
	sub	cl, byte [length]
	sub	cl, dl
	mov 	edi, dev
	call	Space
	sys_write STDOUT,dev,ecx

	xor	edx, edx
	mov	dl, byte [length]
	sys_write STDOUT,testline

;Теперь Used (f_blocks - f_bfree)

	mov	eax, [sfs.f_blocks]
	sub	eax, dword [sfs.f_bfree]
	mul     dword [sfs.f_bsize]
	div	dword [block_size]
	
	mov	edi, testline
		
	call	BinNumToAscii

	mov	ecx, 10
	sub	cl, byte [length]
	mov	edi, dev
	call	Space
	sys_write STDOUT, dev, ecx

	xor	edx, edx
	mov	dl, byte [length]
	sys_write	STDOUT, testline
;Avail (f_blocks - f_bfree)

	mov	eax, [sfs.f_bavail]
	mul	dword [sfs.f_bsize]
	div	dword [block_size]

	mov	edi, testline

	call	BinNumToAscii

	_mov	ecx, 10
	sub	cl, byte [length]
	mov	edi, dev
	call	Space
	mov	edx, ecx
	sys_write STDOUT, dev

	xor	edx, edx
	mov	dl, byte [length]
	sys_write	STDOUT, testline
	
;Use% = (f_blocks - f_bavail)*100
;	-------------------------
;       	f_blocks 

	mov	eax, [sfs.f_blocks]
;	push	eax
	or	eax, eax			;Типа /proc если 0
	jne	.main90
	mov	dword [length],1
	mov	word [testline],'- '
	jmp short .main100
	
.main90:
	sub	eax, [sfs.f_bavail]
	_mov	ebx,100
	mul	ebx
	div	dword [sfs.f_blocks]		;в eax теперь результат ;)
;	pop	ecx 			
	mov	ecx, [sfs.f_blocks]
	sar	ecx, byte 1			;b/2
	cmp	edx, ecx			;
	jb	.main95				; остаток >= (b/2) то inc eax
	inc eax
	
.main95:
	mov	edi, testline
	call	BinNumToAscii

	add	edi, [length]
	mov	byte [edi], '%'

.main100:
        _mov     ecx, 4
        sub     cl, byte [length]
        mov     edi, dev
        call    Space
        sys_write STDOUT, dev, ecx
	
        xor     edx, edx
        mov     dl, byte [length]
	inc	dl
        sys_write	STDOUT, testline

;Теперь m_point
	sys_write	STDOUT, dev, 1

	mov	edi, m_point
	call	StrLen
	mov	byte [edi+edx], lf
	inc	edx
	sys_write	STDOUT,m_point

	pop edi
	pop ecx
	jmp FindString			;Показываем следующую партицию

error_exit:
	sys_write STDERR

_exit:
	sys_exit

;============================================================================
;Тут начались вспомогательные процедурки ;-)
;===========================================================================
;1. Для перевода бинарных цифирь в аски(читаемые)
;---------------------------------------------------------------------------
; HexDigit Преобразовывает 4-битовое значение в ASCII цыфру
;---------------------------------------------------------------------------
; Вход:
; dl = значение в диапазоне 0..15
; Выход:
; dl = шестнадцатеричный эквивалент ASCII цифры
; Регистры:
; dl
;---------------------------------------------------------------------------
HexDigit:
        cmp	dl, 10
        jb      .aa
        add     dl,'A'-10
        ret
.aa:
        or      dl,'0'
        ret

;---------------------------------------------------------------------------
; BinNumToASCII Преобразует беззнаковое двоичное значение в ASCII (dec)
;---------------------------------------------------------------------------
BinNumToAscii:
	pushad
	_mov	ebx, 10
	jmp	short na5
;---------------------------------------------------------------------------
; NumToASCII Преобразует беззнаковое двоичное значение в ASCII
;---------------------------------------------------------------------------
; Вход:
; eax = 32 - битовое преобразуемое значение
; ebx = основание результата (2=двоичный,10=десятичный,16= шестнадцатиричный)
; edi = адрес строки с результатом
; Замечание: подразумевается , что результат должен поместится в строку
; Замечание: подразумевается (2<=ebx<=???)
; Выход:
; отсутствует
; Регистры:
; -
;---------------------------------------------------------------------------
NumToAscii:

        pushad
na5:
        xor	esi, esi
.na10:
        xor	edx, edx             ; EDX = 0
        div	ebx                  ; EDX:EAX / EBX = EAX
                                     ; остаток  в  EDX
        call	HexDigit             ; преобразуем dl в шестн эквив. ASCII цифры
        push	edx                  ; сохраняем в стеке
        inc	esi                  ; SI = SI + 1
        test	eax, eax             ; ax = 0 ?
	jnz	.na10
.na20:
        cld
	mov	[length], esi
.na30:
        pop	eax
	stosb
	dec	esi
	test	esi, esi
	jnz	.na30

	popad
        ret

;
;Return string length
;
;>EDI
;<EDX
;Regs: none ;)
StrLen:
        push    edi
        mov     edx,edi
        dec     edi
.l1:
        inc     edi
        cmp     [edi],byte 0
        jnz     .l1
        xchg    edx,edi
        sub     edx,edi
        pop     edi
        ret

;Заполнить пробелами
;ecx - кол-во пробелов
;edi - строка

Space:
	push eax
	push ecx
	push edi
	
	cld
	mov	al,' '
	rep stosb
	
	pop edi
	pop ecx
	pop eax
	ret
	

UDATASEG	

r_buf		resd 1
testline	resb 10
length		resb 1
dev		resb 30
m_point		resb 30
flags		resb 1

sfs I_STRUC statfs		;структура для системного вызовы statfs
.f_type		LONG	1	;тип файловой системы
.f_bsize	LONG	1	;оптимальный размер блока для передачи
.f_blocks	LONG	1	;общее количество блоков данных на фс
.f_bfree	LONG	1	;количество свободных блоков фс
.f_bavail	LONG	1	;количество блоков доступных для не-рута
.f_files	LONG	1	;возможное количество узлов(файлов) фс
.f_free		LONG	1	;свободное количество узлов(файлов) фс
.f_fsid		LONG	1	;идентефикатор фс
.f_namelen	LONG	1	;максимальная длинна имени файла
.f_reserv	LONG  	6	;зарезервированно 
I_END

END
