; Learn Multi platform Z80 Assembly Programming... With Vampires!

;Please see my website at	www.chibiakumas.com/z80/
;for the 'textbook', useful resources and video tutorials

;File		TI-83 Firmware Functions
;Version	V1.0c
;Date		2018/3/25
;Content	Provides basic text functions using Firware calls

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;Note - BCALL is a 'far call' it pages in ROM then does call.

CLS:
	rst 40		;BCALL
	dw &4546	;ClrScrnFull ;Clear screen firmware functiuon

	ld hl,&0000	;Execute the locate command to clear the screen
;ret

Locate:; X=h , Y=L	On the TI we just save to a memory pos!
	ld (&844B),hl
;	ld a,l
;	ld (&844B),a 	;Y is stored in memory here
;	ld a,h
;	ld (&844C),a 	;X is stored in memory here
	ret

GetCursorPos:		;get HL back from the same memory address!
	ld hl,(&844B)
	ret

PrintChar:
	push hl
	push bc
	push de
		rst 40		;BCALL
		dw &4504	;PutC firmware function
	pop de
	pop bc
	pop hl
	ret	

WaitChar:
	push hl
	push bc
	push de
		rst 40		;BCALL 
		dw &4972	;_getkey firmware function
	pop de
	pop bc
	pop hl
	cp &99
	jr z,WaitCharSpace

	cp &8E		;Less than '0'
	ret c	
	cp &97+1	;Less than '9'+1
	jr c,WaitCharNum
	cp &9A		;Less than 'A'
	ret c	
	cp &B3+1	;Less than 'Z'+1
	jr c,WaitCharLetter

	ret	
WaitCharNum:
	sub &8E
	add '0'
	ret
WaitCharLetter:
	sub &9A
	add 'A'
	ret
WaitCharSpace:
	ld a,' '
	ret
	

NewLine:
	push hl
	push bc
	push de
		rst 40		;BCALL
		dw &452E	;_newline firmware function
	pop de
	pop bc
	pop hl
	ret

PrintString:
	ld a,(hl)	;Char 255 terminated string
	cp 255
	ret z
	inc hl
	call PrintChar
	jr PrintString

DOINIT:
	ret
SHUTDOWN:
	ret


Keylookup:
	defb '0'