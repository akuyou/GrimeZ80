KeyboardScanner_LineCount equ 11
KeyboardScanner_LineWidth equ 8


KeyboardScanner_AllowJoysticks:
	xor a
	ld (KeyboardScanner_NoJoy_Plus1-1),a
	ret


Read_Keyboard:
KeyboardScanner_Read:	;lets read the keyboard!
	di
	ld hl,KeyboardScanner_KeyPresses
	ld b,0
	ld c,&B5		;Keyboard/joy is on port &B5 - write to select  key/joy row, read to get keypresses (not Joy)
keynextline:
	out	(c),b
	in	a,(c)		;read row into A
	ld (hl),a
	inc hl
	inc b			;Move to next row
	ld a,b	
	cp 10			;We're reading rows 0-9
	jp nz,keynextline

	ret 
KeyboardScanner_NoJoy_Plus1:

	ld b,0
keynextlineJoy2:
	ld c,0
keynextlineJoyFire:
	ld a,b			;(0 or 5)
	out	(&B5),a
	in	a,(&B6)		;read row into A
	rr a			;Read 3 fires
	rl c			;they are on bits 0,1,2 on port BB6, lines 0 and 5	
	rr a
	rl c	
	rr a
	rl c	
	inc b

keynextlineJoy:
	ld a,b
	out	(&B5),a
	in	a,(&B6)		;read row into A
	rr a			;Read a joy button
	rl c	
	inc b
	ld a,b
	cp 5
	jr z,keynextJoy			;Start processing next joystick
	cp 10
	jr nz,keynextlineJoy	;Process next UDLR buton line
keynextJoy:
	ld a,c
	or %10000000	;No 8th button!
	ld (hl),a		;Save the joy buttons
	inc hl 
	ld a,b
	cp 10			;If we're not at the end of the joylines
	jr c,keynextlineJoy2;repeat for the next joystick

	ei
	ret



	ifdef UseHardwareKeyMap
HardwareKeyMap:
		db "N","\","B","C","V","X","Z","s"
		db "H","?","G","D","F","S","A","c"
		db "U","Q","Y","R","T","E","W","t"
		db "7","1","6","4","5","3","2","x"
		db "4","8","3","6","5","7","2","1"
		db "8"," ","9","-","0","^",KeyChar_Backspace," "
		db "J"," ","K",";","L",":","["," " 
		db "s","d","r","u","h","l",KeyChar_Enter,"a"	
		db "M","d",",","/",".","r"," ","i"
		db "I"," ","0","@","P","["," ","I" 
	endif





 ;EP keyboard matrix &B5

 ;        b7    b6    b5    b4    b3    b2    b1    b0
 ;Row    80H   40H   20H   10H   08H   04H   02H   01H
 ; 0   L.SH.     Z     X     V     C     B     \     N
 ; 1    CTRL     A     S     F     D     G  LOCK     H
 ; 2     TAB     W     E     T     R     Y     Q     U
 ; 3     ESC     2     3     5     4     6     1     7
 ; 4      F1    F2    F7    F5    F6    F3    F8    F4
 ; 5         ERASE     ^     0     -     9           8
 ; 6             ]     colon L     ;     K           J
 ; 7     ALT ENTER   LEFT  HOLD   UP   RIGHT DOWN  STOP
 ; 8     INS SPACE R.SH.     .     /     ,   DEL     M
 ; 9                   [     P     @     0           I


;B6						    
;0 Joy1 Fire , F2 , F3
;1 Joy1 UP
;2 Joy1 Down
;3 Joy1 Left
;4 Joy1 Right
;5 Joy2 Fire , F2 , F3
;6 Joy2 Up
;7 Joy2 Down
;8 Joy2 Left
;9 Joy2 Right