nolist

;Uncomment one of the lines below to select your compilation target

;BuildCPC equ 1	; Build for Amstrad CPC
;BuildMSX equ 1 ; Build for MSX
;BuildTI8 equ 1 ; Build for TI-83+
;BuildZXS equ 1  ; Build for ZX Spectrum
;BuildENT equ 1 ; Build for Enterprise
BuildSAM equ 1 ; Build for SamCoupe

UseHardwareKeyMap equ 1 	; Need the Keyboard map
;BitmapFont_LowercaseOnly equ 1	; Minimal font - Uppercase only


ScrColor16 equ 1
HalfWidthFont equ 1
ScrWid256 equ 1


read "..\SrcALL\V1_BitmapMemory_Header.asm"
read "..\SrcALL\V1_Header.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	Call DOINIT	; Get ready

	call CLS

ReadAgain:
	ld hl,Message2
	call printstring
	ld hl,TestString
	ld b,20


	call WaitString
	
	inc hl
	ld (hl),255

	ld hl,TestString	;Convert to Uppercase
	call ToUpper

	ld d," "		;Swap Spaces to Char 255, so we can look at words separately
	ld e,255	
	ld hl,TestString
	call ReplaceChar

	call NewLine	;Newline command

	ld hl,WordList		;Array of strings
	ld de,TestString	;String to test
	call ScanList
	call showhex		;A=found string... 255 if not found

	ld bc,255		;Bytecount 255
	ld a,c			;Search for 255 too!
	ld hl,TestString
	cpir			;Find the next string (after the space, which has been converted to a 255)

	dec hl
SkipSpaces:
	inc hl
	ld a,(hl)		;skip spare 'middle spaces'

	inc a			;spaces have been converted to 255
	jp z,SkipSpaces	

	ex hl,de		;HL is the wordlist, DE is the word to check
	ld hl,WordList
	call ScanList
	
	call showhex
	call NewLine	;Newline command
	



jp ReadAgain

	CALL SHUTDOWN ; return to basic or whatever
ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


ScanList:		;HL=ListAddress... returns B=match
	ld (ScanListString_Plus2-2),de
	ld b,0
ListAgain:
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl

	ld a,e 	;AND A and B, and see if the result is 255
	and d
	inc a	;if both were 255 return
	jr z,ListDoneNotFound
	push hl
		ld hl,TestString	:ScanListString_Plus2
		call CompareString
	pop hl
	jr nc,ListDoneFound
	inc b
	jp ListAgain
ListDoneNotFound:
	ld b,255
ListDoneFound:
	ld a,b
ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CompareString:
	ld a,(de)
	cp (hl)
	jr nz,CompareString_Fail	;Do both chars match? - no then fail

	or (hl)				;has either reached the end
	cp 255
	jr z,CompareString_END

	inc hl
	inc de
jp CompareString
CompareString_END:

	and (hl)			;have both reached the end?
	inc a;cp 255
	ret z			;Return No-Carry if matched
CompareString_Fail:
	scf			;Return Carry if failed
ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ReplaceChar:			;Replace D with E in string starting at (HL)
	ld a,(hl)
	cp 255
	ret z			;End if we found a char255

	cp d
	jr nz,ReplaceChar_OK
	ld (hl),e
ReplaceChar_OK:
	inc hl
	jr ReplaceChar

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



TestString: defs 255

WordList:		;Pointers to strings in the wordlist
defw CmpString0
defw CmpString1
defw CmpString2
defw CmpString3
defw CmpString4
defw CmpString5
defw CmpString6defw CmpString7
defw CmpString8
defw &FFFF		;DW &FFFF = end of list

cmdNorth equ 0		;Number of each string in the list
cmdSouth equ 1
cmdLook equ 2
cmdTake equ 3
cmdLick equ 4
cmdSell equ 5
cmdPie equ 6
cmdSpoon equ 7 
cmdC64 equ 8

CmpString0: db "NORTH",255		;Strings to match
CmpString1: db "SOUTH",255
CmpString2: db "LOOK",255
CmpString3: db "TAKE",255
CmpString4: db "LICK",255
CmpString5: db "SELLONEBAY",255
CmpString6: db "PIE",255
CmpString7: db "SPOON",255
CmpString8: db "C64",255

ifdef BuildTI8
	Message2: db 'C>',255
else
	Message2: db 'Chibi:>',255
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BitmapFont:
ifdef BitmapFont_LowercaseOnly
	incbin "..\ResALL\Font64.FNT"
else
	incbin "..\ResALL\Font96.FNT"
endif

;read "..\SrcAll\Multiplatform_Monitor.asm"
read "..\SrcAll\Multiplatform_MonitorSimple.asm"
read "..\SrcAll\Multiplatform_ShowHex.asm"


align 16
	KeyboardScanner_KeyPresses  ds 16,255 ;Player1

read "..\SrcALL\Multiplatform_ScanKeys.asm"
read "..\SrcALL\Multiplatform_KeyboardDriver.asm"

read "..\SrcAll\MultiPlatform_Stringreader.asm"		;*** read a line in from the keyboard
read "..\SrcAll\Multiplatform_StringFunctions.asm"	;*** convert Lower>upper and decode hex ascii

read "..\SrcALL\V1_BitmapMemory.asm"
read "..\SrcALL\Multiplatform_BitmapFonts.asm"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

read "..\SrcALL\V2_Functions.asm"
read "..\SrcALL\V1_Footer.asm"
