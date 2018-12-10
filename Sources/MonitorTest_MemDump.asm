nolist

;Uncomment one of the lines below to select your compilation target

BuildCPC equ 1	; Build for Amstrad CPC
;BuildMSX equ 1 ; Build for MSX
;BuildTI8 equ 1 ; Build for TI-83+
;BuildZXS equ 1  ; Build for ZX Spectrum
;BuildENT equ 1 ; Build for Enterprise
;BuildSAM equ 1 ; Build for SamCoupe
 
read "..\SrcALL\V1_Header.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	Call DOINIT		; Get ready
	call CLS

	call Monitor_MemDump	;Dump a number of bytes from a location
	db 24			;Bytes to dump - only do 24 bytes on a TI
	dw ProgramOrg		;Location to dump

Again:
	ld hl,TestString	;Destination for entered text
	push hl
		ld b,4			;Max 4 characters
		call WaitString
	pop hl
		ld a,(hl)
		inc a			;quick version of CP 255 - modifies A
		jr z,Abandon		;If no characters were entered then we're done
	push hl

	
		call NewLine
	
		call ToUpper		;Our hex processor can only deal with uppercase
	pop hl

	call AsciiToHexPair	;First Two characters
	ld d,a

	call AsciiToHexPair	;Second Two characters
	ld e,a

	ex hl,de		;HL=MemLoc
ifdef BuildTI8
	ld c,24			;24 bytecount
else
	ld c,128		;128 bytecount
endif

	call Monitor_MemDumpDirect	;Do a memory dump from HL and C
jr Again

Abandon:
	CALL SHUTDOWN 		; return to basic or whatever
ret

TestString: defs 16		;Define a 16 character buffer for read strings

;;;;;;;;;;;;;;;;;;;;;;;;;;
;debugger
;;;;;;;;;;;;;;;;;;;;;;;;;
Monitor_Full equ 1				;*** FULL monitor takes more ram, but shows all registers
Monitor_Pause equ 1 				;*** Pause after showing debugging info

read "..\SrcAll\Multiplatform_Monitor.asm"		;*** Full monitor
read "..\SrcAll\Multiplatform_MonitorSimple.asm"	;*** PushRegister and Breakpoint support

read "..\SrcAll\Multiplatform_ShowHex.asm"		;*** Monitor functions require ShowHex support
read "..\SrcAll\Multiplatform_MonitorMemdump.asm"

read "..\SrcAll\MultiPlatform_Stringreader.asm"		;*** read a line in from the keyboard
read "..\SrcAll\Multiplatform_StringFunctions.asm"	;*** convert Lower>upper and decode hex ascii




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

read "..\SrcALL\V1_Functions.asm"
read "..\SrcALL\V1_Footer.asm"
