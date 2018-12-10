;Uncomment one of the lines below to select your compilation target

;BuildCPC equ 1	; Build for Amstrad CPC
;BuildMSX equ 1 ; Build for MSX
;BuildTI8 equ 1 ; Build for TI-83+
;BuildZXS equ 1  ; Build for ZX Spectrum
;BuildENT equ 1 ; Build for Enterprise
;BuildSAM equ 1 ; Build for SamCoupe


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef vasm
		include "..\SrcALL\VasmBuildCompat.asm"
	else
		read "..\SrcALL\WinApeBuildCompat.asm"
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

	read "..\SrcALL\V1_Header.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	Call DOINIT	; Get ready

	call CLS

ReadAgain:
	ld hl,InputPrompt		;show Chibi> message
	call PrintString

	ld hl,TestString	;Read up to 20 chars into Teststring
	ld b,20
	call WaitString

	inc hl			;Create a dummy 2nd command, in case the user didn't actually enter one
	ld (hl),0
	inc hl			;Put a second Char255 at the end of the string for saftey
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
	call ShowHex		;A=found string... 255 if not found

	ld bc,255		;Bytecount 255
	ld a,c			;Search for 255 too!
	ld hl,TestString
	cpir			;Find the next string (after the space, which has been converted to a 255)

	dec hl
SkipSpaces:			;the user may have entered multiple spaces 
	inc hl
	ld a,(hl)		;skip spare 'middle spaces'

	inc a			;spaces have been converted to 255
	jp z,SkipSpaces	

	ex de,hl		;HL is the wordlist, DE is the word to check
	ld hl,WordList
	call ScanList
	
	call ShowHex
	call NewLine	;Newline command
	



	jp ReadAgain

	CALL SHUTDOWN ; return to basic or whatever
	ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


ScanList:					;HL=ListAddress... returns B=match
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
		ld hl,TestString;<--SM
ScanListString_Plus2:
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



TestString: defs 255

CmpString0: db "NORTH",255		;Strings to match
CmpString1: db "SOUTH",255
CmpString2: db "LOOK",255
CmpString3: db "TAKE",255
CmpString4: db "LICK",255
CmpString5: db "SELLONEBAY",255
CmpString6: db "PIE",255
CmpString7: db "SPOON",255
CmpString8: db "C64",255

WordList:				;Pointers to strings in the wordlist
	defw CmpString0
	defw CmpString1
	defw CmpString2
	defw CmpString3
	defw CmpString4
	defw CmpString5
	defw CmpString6	defw CmpString7
	defw CmpString8
	defw &FFFF				;DW &FFFF = end of list



cmdNorth equ 0				;Number of each string in the list
cmdSouth equ 1
cmdLook equ 2
cmdTake equ 3
cmdLick equ 4
cmdSell equ 5
cmdPie equ 6
cmdSpoon equ 7 
cmdC64 equ 8

	ifdef BuildTI8
InputPrompt: db 'C>',255
	else
InputPrompt: db 'Chibi:>',255
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	;read "..\SrcAll\Multiplatform_Monitor.asm"
	read "..\SrcAll\Multiplatform_MonitorSimple.asm"
	read "..\SrcAll\Multiplatform_ShowHex.asm"


	read "..\SrcAll\MultiPlatform_Stringreader.asm"		;*** Uppercase function
	read "..\SrcAll\Multiplatform_StringFunctionsB.asm"	;*** Replace Char, and String compare

	read "..\SrcAll\Multiplatform_StringFunctions.asm"	;*** convert Lower>upper and decode hex ascii

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	read "..\SrcALL\V1_Functions.asm"
	read "..\SrcALL\V1_Footer.asm"
