; Learn Multi platform Z80 Assembly Programming... With Vampires!

;Please see my website at	www.chibiakumas.com/z80/
;for the 'textbook', useful resources and video tutorials

;File		Enterprise Firmware Functions
;Version	V1.0c
;Date		2018/3/20
;Content	Provides basic text functions using Firware calls

;Changes	PrintString updated to protect BC
;changes	PrintChar was corrupting de
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; Note RST6 is our EXOS call.	


PrintChar:
	push af
	push de
	push bc
		ld b,a
		ld a,10 ;Screen is channel 10
		rst 48
		db 7 	;write to channel a
	pop bc
	pop de
	pop af
	ret

PrintString:
	push de
	push bc
PrintStringAgain:
		ld a,(hl)	;Print a 255 terminated character to screen
		cp 255
		jr z,PrintStringDone
		inc hl
		ld b,a
		ld a,10	;Screen is channel 10
		rst 48
		db 7 	;write to channel a
		jr PrintStringAgain
PrintStringDone:
	pop bc
	pop de
	ret


NewLine:
	push af
	push de
	push bc
		ld a,10
		ld bc,2
		ld de,ENT_NewLine_Command
		call ENT_WriteBlock
	pop bc
	pop de
	pop af
	ret
ENT_NewLine_Command:	db 13,10

WaitChar:
	push bc
		ld a,11 ; Keyboard is channel 11
		rst 48	;EXOS call
		db 5 	; Read from channel - result in b
		ld a,b
	pop bc
	ret



CLS:
	ld a,10
	ld bc,2
	ld de,ENT_CLS_Command
	call ENT_WriteBlock
	ret
ENT_CLS_Command: db &1B,&1A ; ESC ^Z - clear screen command

ENT_WriteBlock:	;A=Channel ; BC = number of bytes ; DE=Source string 
	rst 48
	db 8
	ret


Locate:
	push bc
	push de
	push hl
				
	ld de,ENT_Locate_Command+2	;We use a predefined string to speed things up (maybe!)
	ld a,l
	add &21				;Modify our string Y - we have to add &21 to meet ENT requirements!
	ld (de),a
	inc de

	ld a,h
	add &21				;Modify our string X
	ld (de),a

 	ld a,10
	ld bc,4
	ld de,ENT_Locate_Command
	call ENT_WriteBlock		;Send our string

	pop hl
 	pop de
	pop bc
	ret
; &1b is the esc character... = means 'Change cursor position' 0,0 is Y,X destination position
; but wei'll modify that before we use it!
ENT_Locate_Command: db &1B,'=',0,0



GetCursorPos:
; Cursor reasing is super wierd on the ENT... we send "esc ?" to the screen... then open a stream for reading!
;the two characters we read in are the Y X co-ordinates!... strange, but perfectly usable!
;
	push bc
	push de
	push af
	 	ld a,10
		ld bc,2
		ld de,ENT_GetPos_Command
		call ENT_WriteBlock		;Send our string

		ld a,10
		rst 48	;EXOS call
		db 5 	; Read from channel - result in b

		ld a,-&21	;Like above, we have to subtract &21 to get our expected 0,0 default
		add b
		ld l,a

		ld a,10
		rst 48	;EXOS call
		db 5 	; Read from channel - result in b
		ld a,-&21
		add b
		ld h,a
	pop af
 	pop de
	pop bc

	ret
ENT_GetPos_Command: db &1B,'?'



SHUTDOWN:
	di
	halt
DOINIT:
	di
TextInit:
	ld c,22			;MODE_VID
	ld d,0			;Set text mode
	call ENT_Writevar

	ld c,23			;COLR_VID
	ld d,0			;Set 2 color
	call ENT_Writevar


	ld c,24			;X_SIZ_VID
	ld d,40			; 40 Chars Wide
	call ENT_Writevar

	ld c,25			;Y_SIZ_VID
	ld d,24			;24 chars tall
	call ENT_Writevar

	ld de,ENT_Screenname
	ld a,10			;Open Screen as stream 10
	call ENT_OpenStream


	ld a,10	; A channel number (1..255)
	ld b,1	; B @@DISP (=1) (special function code)
	ld c,1	; C 1st row in page to display (1..size)
	ld d,24  ; D number of rows to display (1..27)
	ld e,1  ; E row on screen where first row should appear (1..27)
	call ENT_SpecialFunc

	ld de,ENT_Keboardname
	ld a,11			; Open the keyboard as stream 11
	call ENT_OpenStream
	ret


ENT_OpenStream:
	;Open stream A from device string DE 
	;DE should point to a string like...  db 6,'VIDEO;'  or db 9,'KEYBOARD;' (replace ; with a colon)
	rst 48
	db 1 	;open stream
	ret

ENT_KillStream: 	;Delete new File Stream A
	rst 48
	db 4 		;open stream
	ret

ENT_ReadBlock:
	rst 48
	db 6
	ret


ENT_readvar:		;readvar C from enterprise OS 
	ld b,0
	rst 48
	db 16
	ret

ENT_Writevar:		;WriteVar C=D to Enterprise OS
	ld b,1
	rst 48
	db 16
	ret
ENT_SpecialFunc:	;Special Function (for displaying screen)
	rst 48
	db 11
	ret
ENT_Screenname: db 6,'VIDEO:'
ENT_Keboardname: db 9,'KEYBOARD:'