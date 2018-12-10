write "..\BldEnt\program.com"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			Hello World
;
;	Show a hello world message, then read a key
;	From the keyboard and show it.
;
;	Screen and keyboard ops use Enterprise OS calls
;	by opening 'stream' devices to the Keyboard and
;	screen
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




ORG &00F0
	DB 0,5			   ;type 5 - Binary Program
	DW FileEnd-FileStart	   ;File length
	DB 0,0,0,0,0,0,0,0,0,0,0,0 ;Spacer
; org &0100
FileStart:
	LD SP,&100	;set the Stack to a safe place
	di

	ld c,MODE_VID		;Set text mode
	ld d,0
	call ENT_Writevar

	ld c,COLR_VID		;Set 2 color
	ld d,0
	call ENT_Writevar


	ld c,X_SIZ_VID		; 40 Chars Wide
	ld d,40
	call ENT_Writevar

	ld c,Y_SIZ_VID		;24 chars tall
	ld d,24
	call ENT_Writevar

	ld de,ENT_Screenname 	;Open Screen as stream 10
	ld a,10
	call ENT_OpenStream	

	;Display the just opened screen
	ld a,10	; A channel number (1..255)
	ld b,1	; B @@DISP (=1) (special function code)
	ld c,1	; C 1st row in page to display (1..size)
	ld d,24  ; D number of rows to display (1..27)
	ld e,1  ; E row on screen where first row should appear (1..27)
	call ENT_SpecialFunc


	ld de,ENT_Keboardname	; Open the keyboard as stream 11
	ld a,11
	call ENT_OpenStream
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			INIT Done
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ld hl,Message
	call PrintString	;Print Hello world message

	call NewLine		

	call WaitChar		;Wait for a keypress

	push af
		ld hl,Message2	;Print 'You Pressed' message
		call PrintString
	pop af
	call PrintChar		;print the char the user pressed
	call NewLine

	di
	halt	;stop execution - I've not figured out how to return to basic!


Message: db 'Hello World!',255
Message2: db 'Key Pressed:',255

PrintString:
	ld a,(hl)
	cp 255
	ret z
	inc hl
	call PrintChar
jr PrintString

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		Functions for controling EXOS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MODE_VID  equ 22	;Enterprise OS variable numbers
COLR_VID  equ 23
X_SIZ_VID equ 24
Y_SIZ_VID equ 25	


ENT_OpenStream:
	;Open stream A from device string DE 
	;DE should point to a string like...  db 6,'VIDEO;'  or db 9,'KEYBOARD;' (replace ; with a colon)
	rst 6
	db 1 	;open stream
ret
WaitChar:
	push de
	push hl
	push bc
		ld a,11
		rst 6
		db 5 	;read from channel - result in b
		ld a,b
	pop bc
	pop hl
	pop de
ret
PrintChar:
	push de
	push hl
	push bc
		ld b,a
		ld a,10
		rst 6
		db 7 	;write to channel a
	pop bc
	pop hl
	pop de
ret

NewLine:
	ld a,13
	call PrintChar
	ld a,10
	call PrintChar
ret
ENT_readvar:		;readvar C from enterprise OS 
	ld b,0
	rst 6
	db 16
ret

ENT_Writevar:		;WriteVar C=D to Enterprise OS
	ld b,1
	rst 6
	db 16
ret

ENT_SpecialFunc:	;Special Function (for displaying screen)
	rst 6
	db 11
ret
;Device names db [length],'name;'
ENT_Screenname: db 6,'VIDEO:'
ENT_Keboardname: db 9,'KEYBOARD:'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FileEnd: