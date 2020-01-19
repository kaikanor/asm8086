.model small
.stack 100h
.data
.code
begin:	
	mov ax, @data
	mov ds, ax
	mov al, 10110110b
	out 43h, al
	in al, 61h
	or al, 3
	out 61h, al


	
	
	mov bx, 200
	call timer

	mov di, 659
	mov bx, 200
	call zvuk

	mov di, 699
	mov bx, 200
	call zvuk

	mov di, 659
	mov bx, 600
	call zvuk
	

	mov di, 659
	mov bx, 200
	call zvuk


	mov di, 440
	mov bx, 200
	call zvuk

	mov di, 494
	mov bx, 200
	call zvuk


	mov di, 523
	mov bx, 600
	call zvuk


	mov di, 523
	mov bx, 200
	call zvuk



	mov di, 587
	mov bx, 200
	call zvuk


	mov di, 523
	mov bx, 200
	call zvuk



	mov di, 494
	mov bx, 600
	call zvuk


	mov di, 494
	mov bx, 200
	call zvuk


	mov di, 523
	mov bx, 200
	call zvuk


	mov di, 494
	mov bx, 200
	call zvuk


	mov di, 440
	mov bx, 600
	call zvuk

	mov di, 440
	mov bx, 200
	call zvuk


	mov di, 415
	mov bx, 200
	call zvuk


	mov di, 440
	mov bx, 200
	call zvuk

	mov di, 699
	mov bx, 600
	call zvuk

	mov di, 699
	mov bx, 200
	call zvuk

	mov di, 659
	mov bx, 200
	call zvuk

	mov di, 622
	mov bx, 200
	call zvuk

	mov di, 659
	mov bx, 600
	call zvuk


	mov di, 659
	mov bx, 200
	call zvuk


	mov di, 523
	mov bx, 200
	call zvuk

	mov di, 440
	mov bx, 200
	call zvuk

	mov di, 330
	mov bx, 200
	call zvuk

	mov di, 311
	mov bx, 200
	call zvuk

	mov di, 330
	mov bx, 200
	call zvuk

	mov di, 523
	mov bx, 400
	call zvuk

	mov di, 494
	mov bx, 200
	call zvuk

	mov di, 440
	mov bx, 600
	call zvuk

	mov di, 440
	mov bx, 200
	call zvuk


	mov bx, 400
	call timer



	mov ah, 4ch
	int 21h

zvuk proc
	mov dx, 12h
	mov ax, 2870h
	div di

	
	out 42h, al
	mov al, ah
	out 42h, al		



	mov ax, bx
	call timer

ret
endp


timer proc
	mov bh, 55
	div bh
	mov bl, al
	mov ah, 0
	int 1ah
	add bl, dl
timesearch:
	mov ah, 0
	int 1ah
	cmp dl, bl
	jz timeend
	jmp timesearch
timeend:
ret
endp


end begin