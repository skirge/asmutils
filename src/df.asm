;Copyright (C) 1999 Alexandr Gorlov <winct@mail.ru>
;Portions Copyright (C) 1999 Kir Smirnov <ksm@mail.ru>
;
;$Id: df.asm,v 1.1 2000/01/26 21:19:22 konst Exp $
;
;hackers' df
;
;0.01: 29-Jul-1999	initial release
;
;syntax: df --help
;
;example: df 

%include "system.inc"

CODESEG

START:
	pop	esi
	pop	esi

.args:
	pop	esi
	or	esi,esi
	jz	.main50

	cmp	word [esi], "--"
	je	.main10
	jmp	short .main50
	
.main10:
	cmp	dword [esi+2], "help"
	jne	.main11
	sys_write STDOUT, msg_usage, len_msg_usage
	jmp	exit
.main11:
	cmp	dword [esi+2], "vers"
	jne	near exit
	sys_write STDOUT, msg_version, len_msg_version
	jmp	exit
	
.main50:
; Тут я начал пытаться открыть /etc/mtab и прочитать инфу о смонтированных ФС
;============================================================================
	
	sys_write STDOUT,msg_info,len_msg_info


	sys_open mtab, O_RDONLY	;В eax дескриптор !!!
	cmp eax, -1
	jne .main60		;Не смог открыть /etc/mtab
	sys_write STDERR,mtab_open,len_mtab_open
	sys_exit
.main60:
	push eax
	
	mov ebx, eax
	xor ecx, ecx
	mov edx, 2

	sys_lseek
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
	jnz .main65
	sys_exit		;!!!Ошибка выделения памяти
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
	
	mov ecx, dword [r_buf]
	sys_read 

	cmp eax, -1		;проверка на ошибку
	jne .main70
	sys_exit		;Ошибка: неверный дескриптор

.main70:

	mov ecx, eax		;Счетчик длинны строки
	cld			

	mov esi, dword [r_buf]		;!!!!!!!?
	jmp short FindSpace
	
;1.Ищем новую строку
FindString:
	cld
	mov al, 0Ah
	repne scasb		;edi указывает на начало новой строки
	mov esi, edi
	or ecx, ecx
	jne FindSpace
	sys_exit		;!!!Выход с ошибкой.

;2.Ищем первый пробел	 
FindSpace:

	mov al,' '
	mov edi, dev

.sub1:
	or ecx, ecx 		
	jne .sub
	sys_exit
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
	jne .main85
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
	mov ebx, m_point
	mov ecx, statfs
	sys_statfs

;Выводим полученные данные	

	mov	edi, dev		;Партиция
	call	StrLen			;в edx длинна
	push 	edx			;сохраним
	mov	ecx, edi
	sys_write STDOUT

	mov	eax, [f_blocks]
	sar	dword [f_bsize], 10
	mul	dword [f_bsize]
	
	mov 	edi, testline
	call	BinNumToAscii

	pop	edx
	mov 	ecx, 30			
	sub	cl, byte [length]
	sub	cl, dl
	mov 	edi, dev
	call	Space
	mov 	edx, ecx
	sys_write STDOUT,dev

	xor	edx, edx
	mov	dl, byte [length]
	sys_write STDOUT,testline

;Теперь Used (f_blocks - f_bfree)

	mov	eax, [f_blocks]
	sub	eax, dword [f_bfree]
	mul     dword [f_bsize]
	
	mov	edi, testline
		
	call	BinNumToAscii

	mov	ecx, 10
	sub	cl, byte [length]
	mov	edi, dev
	call	Space
	mov	edx, ecx
	sys_write STDOUT, dev

	xor	edx, edx
	mov	dl, byte [length]
	sys_write	STDOUT, testline
;Avail (f_blocks - f_bfree)

	mov	eax, [f_bavail]
	mul	dword [f_bsize]

	mov	edi, testline

	call	BinNumToAscii

	mov	ecx, 10
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

	mov	eax, [f_blocks]
;	push	eax
	or	eax, eax			;Типа /proc если 0
	jne	.main90
	mov	dword [length],1
	mov	word [testline],'- '
	jmp short .main100
	
.main90:
	sub	eax, [f_bavail]
	mov	ebx,	100
	mul	ebx
	div	dword [f_blocks]		;в eax теперь результат ;)
;	pop	ecx 			
	mov	ecx, [f_blocks]
	sar	ecx, 1				;b/2
	cmp	edx, ecx			;
	jb	.main95				; остаток >= (b/2) то inc eax
	inc eax
	
.main95:
	mov	edi, testline
	call	BinNumToAscii

	add	edi, [length]
	mov	byte [edi], '%'

.main100:
        mov     ecx, 4
        sub     cl, byte [length]
        mov     edi, dev
        call    Space
        mov     edx, ecx
        sys_write STDOUT, dev
	
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




exit:
	sys_exit

error_exit:
	
;	sys_write STDERR,warning,len_warning
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
	mov	ebx, 10
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
	
DATASEG

space	equ	0x20
lf	equ	0x0A

mtab	db	'/etc/mtab',0

msg_usage	db	'Usage: df [OPTIONS]... [FILE]...', lf
		db	'Show information about the filesystem on which each FILE resides,',lf
		db	'or all filesystems by default.',lf,lf
		db	'	--help		display this help and exit', lf
		db	'	--version	output version information and exit',lf
len_msg_usage	equ $ - msg_usage

msg_version	db	'df (asmutils) 0.01', lf
len_msg_version	equ $ - msg_version

msg_info	db	'Filesystem           1k-blocks      Used Available Use% Mounted on',lf
len_msg_info	equ $ - msg_info


statfs:		;структура для системного вызовы statfs
f_type		dd	0	;тип файловой системы
f_bsize		dd	0	;оптимальный размер блока для передачи
f_blocks	dd	0	;общее количество блоков данных на фс
f_bfree		dd	0	;количество свободных блоков фс
f_bavail	dd	0	;количество блоков доступных для не-рута
f_files		dd	0	;возможное количество узлов(файлов) фс
f_free		dd	0	;свободное количество узлов(файлов) фс
f_fsid		dd	0	;идентефикатор фс
f_namelen	dd	0	;максимальная длинна имени файла
f_reserv	dd  0,0,0,0,0	;зарезервированно 

reserv		dd	5

;======Errors========

mtab_open	db	'Error: Can not open /etc/mtab',lf
len_mtab_open	equ	$ - mtab_open

UDATASEG	
r_buf		resd 1
testline	resb 10
length		resb 1
dev		resb 30
m_point		resb 30
flags		resb 1

END
