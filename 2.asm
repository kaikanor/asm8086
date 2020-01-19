;;; функция, которая считывает первые 80*8 байт в <место> и ставит указатель --
;;; -- на 80 байт
;;; функция, которая создаёт новый файл и заполняет его первыми байтами
;;; Считать из <места> информацию о файле и заполнить:
;;;	<колво строк>, <колво байт в строке>, <колво байт в файле>, <>, <>
;;; функция, которая считывает определённое количество байт по алгоритму и --
;;; -- заносит их в <строка> 
;;; сначала можно просто попробовать перевернуть <строку> и записать в файл
;;; если байты в файле закончились, то 
;;; считать оставшиеся байты в <место> и записать их в новый файл
;;; закрыть старый и новый файл

.model small
.stack 100h
.data 
filename db 'q.pcx', 0
strkol dw ?
cnkol dw ?
strkolc dw ?
cnkolc dw ?
stroka db 2048 dup('1')
strokanew db 2048 dup('2')
mesto db 4096 dup('3')
handle dw ?
filenew db 'qnew.pcx', 0
handlenew dw ?
tekbyte db ?
msg db '1','$'
strokarle db 2048 dup('4')
cnkolreal dw ?
.code
start:
	mov ax, @data
	mov ds, ax
;;;;;;;;;;;; открыть файл и прочитать в mesto 128 байт ;;;;;;;;;;;;;;;;
					; процедуры открытия файла
	mov ah, 3Dh			; код открытия
	lea dx, filename		; имя файла
	mov al, 02			; открыть на все права
	int 21h				; вызов процедуры
	mov handle, ax			; записать итендификатор в память

					; макрос чтения из файла некоторого количества байт в некоторое место
	mov cx, 80h			; количество байт
	lea dx, mesto			; адрес места
	mov bx, handle			; итендификатор файла
	mov ah, 3Fh			; процедура чтения
	int 21h				; вызов процедуры

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;; создать новый файл и записать в него из mesto 128 байт ;;;;;;;;;;

	mov ah, 3ch			; Код создания
	mov cx, 00			; атрибут обычного файла
	lea dx, filenew			; Имя нового файла
	int 21h				; вызов процедуры
	mov handlenew, ax		; записать итендификатор
	mov ah, 40h			; код записи в файл
	mov bx, handlenew		; итендификатор файлы
	mov cx, 80h			; записать 128 байт
	lea dx, mesto			; начиная с адреса mesto
	int 21h				; вызов процедуры
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;; взять информацию о файле;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	lea di, mesto
	add di, 42h
	mov al, ds:[di]
	inc di
	mov ah, ds:[di]	
	mov cnkol, ax
	mov cnkolc, ax
	
	lea di, mesto
	add di, 8
	mov al, ds:[di]
	inc al
	inc di
	mov ah, ds:[di]	
	mov cnkolreal, ax
	
	lea di, mesto
	add di, 10
	mov al, ds:[di]
	inc al
	inc di
	mov ah, ds:[di]
	mov strkol, ax
	mov strkolc, ax
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;чтение строки;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nachalo:
	lea si, strokanew
	add si, 2000d

	mov ax, cnkol
	mov cnkolc, ax
	lea di, stroka	
	jmp m1
mensh:
	mov ah, tekbyte
	mov ds:[di], ah
	inc di
	dec cnkolc
	
	dec si
	mov ds:[si], ah
	
;;;;;;;;;;;;;; макрос чтения из файла одного байта на tekbyte
m1:
	cmp cnkolc, 0
	je endstr

	mov cx, 1h			; количество байт
	lea dx, tekbyte			; адрес места
	mov bx, handle			; итендификатор файла
	mov ah, 3Fh			; процедура чтения
	int 21h				; вызов процедуры
	
	mov al, tekbyte
		
	cmp al, 192d
	
	jb mensh

	dec si
	dec si
	mov ds:[si], al
	
	mov ds:[di], al
	inc di
	
	sub al, 192d
	sub cnkolc, ax
	
	mov cx, 1h			; количество байт
	lea dx, tekbyte			; адрес места
	mov bx, handle			; итендификатор файла
	mov ah, 3Fh			; процедура чтения
	int 21h				; вызов процедуры

	mov al, tekbyte
	mov ds:[di], al
	inc di

	inc si
	mov ds:[si], al
	dec si
	
	cmp cnkolc, 0
	je endstr	
	
	jmp m1
	
endstr:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;записать в новую строку конечные символы и "удалить" их из начала;;;

	mov dx, cnkol
	sub dx, cnkolreal
	add si, dx				; в si у меня начало новой строки
	lea di, strokanew
	add di, 2000d
m22:
	cmp dx, 0
	je m21
	
	mov ah, 0
	mov ds:[di], ah
	dec dx
	jmp m22
	
m21:	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;свернуть её (strokanew) по алгоритму rle и записать (strokarle);;;;
; макрос записи некоторого количества байт в файл из некоторого места
	mov ah, 40h					; код процедуры
	mov bx, handlenew			; итендификатор файла
	lea cx, strokanew
	add cx, 2000d
	sub cx, si
	mov dx, cnkol
	sub dx, cnkolreal	
	add cx, dx					; количество байт
	mov dx, si				; место откуда пишем
	int 21h						; вызов процедуры
;;;;;;;;;;;;;;;;закончили работу со строкой;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
	dec strkolc
	cmp strkolc, 0
	je endprog	
	jmp nachalo
	
endprog:
;;;;;;;;;;перенести оставшиеся байты из старого файла в новый;;;;;;;;;;;
	

	mov cx, 7680d				; количество байт
	lea dx, mesto			; адрес места
	mov bx, handle			; итендификатор файла
	mov ah, 3Fh			; процедура чтения
	int 21h				; вызов процедуры
	
	push ax		; тут находится количество реально считаных байт

	mov ah, 40h			; код процедуры
	mov bx, handlenew		; итендификатор файла
	pop cx
	;	mov cx, 768d				; количество байт
	lea dx, mesto			; место откуда пишем
	int 21h				; вызов процедуры
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;; закрыть оба файла;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	mov ah, 3Eh			; код данной процедуры
	mov bx, handle			; итендификатор изначального файла
	int 21h				; вызов процедуры
	mov bx, handlenew		; итендификатор нового файла
	int 21h				; вызов процедуры


	mov ah, 4Ch			; Выйти из
	int 21h				; программы

	
	
prov proc				; процедура проверки
	mov ah, 9
	mov dx, offset(msg) 
	int 21h			
	ret				; вернуться в программу
endp					; конец описания процедуры

end start