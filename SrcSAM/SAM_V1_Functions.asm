; Learn Multi platform Z80 Assembly Programming... With Vampires!

;Please see my website at	www.chibiakumas.com/z80/
;for the 'textbook', useful resources and video tutorials

;File		SAM coupe Firmware Functions
;Version	V1.0
;Date		2018/4/1
;Content	Provides basic text functions using Firware calls

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


PrintChar:
	push de
	push bc
	push hl
	push af
		rst 16	;RST 2 will print a character to screen
	pop af
	pop hl
	pop bc
	pop de
	ret

WaitChar:
	push de
	push bc
	push hl
WaitChar_WaitingForKeypress:
	call &0169	;JREADKEY - poll the keyboard - return NZ if we get a key
	JR Z,WaitChar_WaitingForKeypress

	ld c,100
	ld b,255	;Wait a moment for key release - otherwise we'll get crazy repeating!
WaitChar_WaitForRelease:
	nop
	nop
	nop
	nop
	djnz WaitChar_WaitForRelease
	dec c
	jr nz,WaitChar_WaitForRelease

	pop hl
	pop bc
	pop de
	ret


CLS:
	push af
		xor a		; if A=0 the entire screen will clear
		call &014E 	;JCLSBL - clear screen 

		ld a,0		;Set screen MODE that is in the A register (0-3 is mode 1-4)
		call &015A	;JMODE

		ld a,&FE	;FEH=channel 'S' (Upper Screen I/0)
		call &0112	;JSETSTRM - Set the stream to A
	pop af
	ret

Locate:
	push hl
		ld a,h 
		ld (&5A6C),a	;&5A6C - SPOSNU - Upper window position as column/row.
		ld a,l
		ld (&5A6d),a
	pop hl
	ret

GetCursorPos:
	push af
			ld a,(&5A6C)		;&5A6C - SPOSNU - Upper window position as column/row.
			cp &F0			;The Sam seems to return a weird X location (&FE) after a NewLine command, so this fixes it!
			jr c,GetCursorPosXok
			xor a
GetCursorPosXok:
			ld h,a

			ld a,(&5A6d)
			ld l,a
	pop af
	ret

NewLine:
	push af
		ld a,13		;Carriage return only
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

SHUTDOWN:
	di		;Can't return to basic on a cartridge
	halt


DOINIT:
	ld a,1
	ld (&5ABB),a	;SPROMPT -If non-Zero no "scroll?" prompts are given.

	call CLS	;Initial screen setup
	ret