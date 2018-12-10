; Learn Multi platform Z80 Assembly Programming... With Vampires!

;Please see my website at	www.chibiakumas.com/z80/
;for the 'textbook', useful resources and video tutorials

;File		CPC Firmware Functions
;Version	V1.0b
;Date		2018/3/20
;Content	Provides basic text functions using Firware calls

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



PrintChar 	equ &BB5A	
WaitChar  	equ &BB06	

CLS:
		ld a,1
		call &BC0E	;SCR SET MODE

	ret
Locate:
	push hl
		inc h		;CPC expects top corner to be 1,1
		inc l
		call &BB75	;SetCursor firmware call ... X,Y - top corner= (0,0)
	pop hl
	ret

GetCursorPos:
	push af
		call &BB78; TXT GET CURSOR
		dec h	;	CPC returned top corner as 1,1... but we want 0,0!
		dec l	;
	pop af
	ret

NewLine:
	push af
	ld a,13		;Carriage return
	call PrintChar
	ld a,10		;Line Feed 
	call PrintChar
	pop af
	ret

PrintString:
	ld a,(hl)	;Print a '255' terminated string 
	cp 255
	ret z
	inc hl
	call PrintChar
	jr PrintString


DOINIT:
	ret
SHUTDOWN:
	ret