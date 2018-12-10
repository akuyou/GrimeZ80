

;Uncomment one of the lines below to select your compilation target

;BuildCPC equ 1	; Build for Amstrad CPC
;BuildMSX equ 1 ; Build for MSX
;BuildTI8 equ 1 ; Build for TI-83+
;BuildZXS equ 1  ; Build for ZX Spectrum
;BuildENT equ 1 ; Build for Enterprise
;BuildSAM equ 1 ; Build for SamCoupe
 
BuildMSX_MSX1 equ 1

;ScrColor16 equ 1		;Use 16 color mode on the ENT and CPC
;ScrWid256 equ 1		;Use 256 pixel wide mode on the ENT and CPC

;ScrTISmall equ 1		;Use narrow fonts on the TI

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef vasm
		include "..\SrcALL\VasmBuildCompat.asm"
	else
		read "..\SrcALL\WinApeBuildCompat.asm"
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	read "..\SrcALL\V1_Header.asm"
	read "..\SrcALL\V1_BitmapMemory_Header.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

	Call DOINIT		;Get ready

	call ScreenINIT		;Enable the Bitmap Screen

	ld bc,&0000		;X byte - Y line
	call GetScreenPos
	ld b,255		;We're going to dump every possible byte to screen 
Again:
		SetScrByte b	;Put the byte onscreen
		dec b
		ld a,b
		and %00000111	

		jr nz,Again

	call GetNextLine	;Every 7 bytes we move to a new line

	ld a,b
	or a
	jp nz,Again


	ld bc,&0120		;X byte 1 - Y line 20
	call GetScreenPos

	ld de,Letter
BitmapAgain:
	ld a,(de)
	

	SetScrByteBW ;Draw a letter A
	SetScrByteBW ;Draw a letter A
	SetScrByteBW ;Draw a letter A

	inc de
	call GetNextLine	;Move down a line

	or a			
	jp nz,BitmapAgain	;Keep writing until we 
		
	ifdef BuildZXS			;On the spectrum we have to do colors differently,
		ld bc,&0120		;X Byte-char (0-32),Y line (0-191)
		call GetColMemPos
		ld (hl),1*8 +64+ 7	;Foreground 7 (White)....  Background 1 (Blue) *8... +64 = bright
	endif

	ifdef BuildMSX_MSX1			;On the spectrum we have to do colors differently,
		ld bc,&0120		;X Byte-char (0-32),Y line (0-191)
		call GetColMemPos
		
			call GetColMemPos
			ld a,&70
			out (VdpOut_Data),a
			nop
			out (VdpOut_Data),a
			nop
			out (VdpOut_Data),a
			nop
			out (VdpOut_Data),a
			nop
			out (VdpOut_Data),a
			nop
			out (VdpOut_Data),a
			nop
			out (VdpOut_Data),a
			nop
			out (VdpOut_Data),a
			nop
		
	endif

	
	
	di
	halt

	CALL SHUTDOWN ; return to basic or whatever
	ret
PaletteText:
	db "-GRB",255

TestString: defs 16




Letter:
	db %00011100		;Here is a letter A in Bits
	db %00100110
	db %01000011
	db %01000011
	db %01111111
	db %01000011
	db %01000011
	db %00000000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	read "..\SrcALL\V1_BitmapMemory.asm"

	read "..\SrcALL\V1_Functions.asm"
	read "..\SrcALL\V1_Footer.asm"
