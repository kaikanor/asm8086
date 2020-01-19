.model small
.stack 100h
.data
mesto db 4096 dup('1')
filename db 'kkkk.bmp', 0		; Имя файла
handle dw ?				; Итендификатор файла
cn dw ?
strr dw ?
sizee dw ?
kbyte dw ?
msg db '1','$'
.code
start:
	mov ax, @data
	mov ds, ax
	
;;;;;;;;;; откроем файл ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	mov ah, 3Dh			; код открытия
	lea dx, filename		; имя файла
	mov al, 02			; открыть на все права
	int 21h				; вызов процедуры
	mov handle, ax			; записать итендификатор в память
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; считаем оттуда информацию о файле ;;;;;;;;;;;;;;

	mov cx, 3Eh			; количество байт
	lea dx, mesto			; адрес места
	mov bx, handle			; итендификатор файла
	mov ah, 3Fh			; процедура чтения
	int 21h				; вызов процедуры
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;; Считаем из информации нужные данные ;;;;;;;;;;	
	lea di, mesto
	add di, 12h
	mov dl, ds:[di]
	inc di
	mov dh, ds:[di]
	mov cn, dx 
	
	lea di, mesto
	add di, 16h
	mov dl, ds:[di]
	inc di
	mov dh, ds:[di]
	mov strr, dx
	
	lea di, mesto
	add di, 2h
	mov dl, ds:[di]
	inc di
	mov dh, ds:[di]
	mov sizee, dx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; запишем количество байт на строку ;;;;;;;;;;;;;;;
;для этого надо из размера отнять информационные байты
;поделить результат на количество строк 
;взять полученое число как количество байт
;пока остаток от деления на 4 не будет равен 0
; прибавлять единицу
	mov ax, sizee
	sub ax, 3Eh
	mov bx, strr
	xor dx, dx
	div bx
	mov kbyte, ax
	
m1:
	mov ax, kbyte
	mov bx, 4
	xor dx, dx
	div bx
	cmp dx, 00
	je m2
	inc kbyte
	jmp m1
	
m2:	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;устанавливаем видеорежим;;;;;;;;;;;;;;;;;;;;;
	mov ah, 00
	mov al, 13h
	int 10h
;	mov ah, 0bh
;	mov bh, 00		; установить фон
;	mov bl, 00		; чёрным
;	int 10h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;считываем остальную часть файла;;;;;;;;;;;;;
	mov cx, 65535			; количество байт
	lea dx, mesto			; адрес места
	mov bx, handle			; итендификатор файла
	mov ah, 3Fh			; процедура чтения
	int 21h				; вызов процедуры
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;рисовать начинаем с последней строки. 
;поэтому устанавливаем курсор на начало этой строки;;;
; И далее рисуем
xor ax, ax
dec cn
	mov bx, 00
	mov dx, strr
	inc dx			; На всякий случай рисуем на пиксель ниже
	mov cx, 00
	lea di, mesto
	mov si, di
	mov bl, 15
	mov bh, 7

	mov al, ds:[di]
	push ax

m3:	
	pop ax
	push ax
	
	push cx
	mov cl, bh
	shr al, cl
	
	pop cx
	
	and al, 00000001b 
	dec bh
	cmp bh, 255d
	jne m4
	mul bl
	mov ah, 0ch
	int 10h
	inc cx
	mov bh, 7
	inc di
	mov al, ds:[di]
	push ax
	cmp cx, cn
	je m5
	jmp m3
	
m4:
	mul bl
	mov ah, 0ch
	int 10h
	inc cx
	cmp cx, cn
	jne m3
m5:	dec dx 
	cmp dx, 1
	je endd
	mov cx, 0
	add si, kbyte
	mov di, si
	mov bh, 7
	
	jmp m3
	
	
endd:
;;;;; закрываем файл и выходим из программы;;;;;;;;;;;;

	mov ah, 3Eh			; код данной процедуры
	mov bx, handle			; итендификатор изначального файла
	int 21h				; вызов процедуры
	
	mov ah, 4Ch			; Выйти из
	int 21h
	

prov proc				; процедура проверки
	mov ah, 9
	mov dx, offset(msg) 
	int 21h			
	ret				; вернуться в программу
endp
	
end start