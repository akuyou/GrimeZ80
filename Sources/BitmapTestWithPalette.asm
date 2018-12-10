nolist

;Uncomment one of the lines below to select your compilation target

;BuildCPC equ 1	; Build for Amstrad CPC
;BuildMSX equ 1 ; Build for MSX
;BuildENT equ 1 ; Build for Enterprise
BuildSAM equ 1 ; Build for SamCoupe
 

;CpcPlus equ 1

ScrColor16 equ 1
;ScrWid256 equ 1
;HalfWidthFont equ 1

;ScrTISmall equ 1

read "..\SrcALL\V1_Header.asm"
read "..\SrcALL\V1_BitmapMemory_Header.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

	Call DOINIT	; Get ready


	call ScreenINIT




	ld bc,&0000
	call GetScreenPos
	ld b,255
Again:
		SetScrByte b
		dec b
		ld a,b
		and %00000111

	jr nz,Again

	call GetNextLine

	ld a,b
	or a
	jp nz,Again



	ld de,RawBitmap
	ld c,48
AgainY:
if BuildCPCv+BuildENTv
	ld b,48/4
endif
if BuildZXSv+BuildTI8v
	ld b,48/8
endif
if BuildMSXv+BuildSAMv
	ld b,48/2
endif
AgainX:
		ld a,(de)

		SetScrByte a
		inc de
		djnz AgainX
		call GetNextLine
	dec c
	jp nz,AgainY


ifdef BuildZXS
	ld bc,&0120
	call GetColMemPos
	ld (hl),1*8 +64+ 7
endif

ifdef BuildCPC
	ifdef CpcPlus
		call CPCPLUS_Init
	endif
endif

	;      
	ld hl,&0FFF

	ld hl,Palette
	ld b,16
PaletteAgain:
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	push hl

	ex hl,de
	push bc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	ld a,16
	sub b

	call SetPalette



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	pop bc
	pop hl

	dec b
	jp nz,PaletteAgain


	ifdef buildENT
		ifdef ScrColor16
			di		;Interrupt handler seems to reset bias
			ld a,0
EntTest:
			out (&80),a	;&80 - Fixbias	b0..b4 	Colour bias to be used for top 5 bits of palette colours 8-15. 
		
			push af
			ld ix,&FFFF
EntTestPause:
			dec ix
			ld a,ixl
			or ixh
			jr nz,EntTestPause
		
			pop af
			inc a
			cp %00100000	
			jr nz,EntTest
		endif
	endif



	di
	halt

	CALL SHUTDOWN ; return to basic or whatever
	ret
PaletteText:
	db "-GRB",255

TestString: defs 16

Palette:
	;   -grb
	dw &0000
	dw &0099
	dw &0E0F
	dw &0FFF
	dw &000F
	dw &004F
	dw &008F
	dw &00AF
	dw &00FF
	dw &04FF
	dw &08FF
	dw &0AFF
	dw &0CCC
	dw &0AAA
	dw &0888
	dw &0444


RawBitmap:
	if BuildCPCv+BuildENTv
		ifdef ScrColor16
			incbin "..\ResALL\Sprites\RawCPC16.RAW"
		else
			incbin "..\ResALL\Sprites\RawCPC.RAW"
		endif
	endif
	if BuildZXSv+BuildTI8v
		incbin "..\ResALL\Sprites\RawZX.RAW"
		
	endif
	if BuildMSXv+BuildSAMv
		incbin "..\ResALL\Sprites\RawMSX.RAW"
		
	endif

;;;;;;;;;;;;;;;;;;;;;;;;;;
;debugger
;;;;;;;;;;;;;;;;;;;;;;;;;
Monitor_Full equ 1				;*** FULL monitor takes more ram, but shows all registers
Monitor_Pause equ 1 				;*** Pause after showing debugging info

	;read "..\SrcAll\Multiplatform_Monitor.asm"		;*** Full monitor
	;read "..\SrcAll\Multiplatform_MonitorSimple.asm"	;*** PushRegister and Breakpoint support

	;read "..\SrcAll\Multiplatform_ShowHex.asm"		;*** Monitor functions require ShowHex support
	;read "..\SrcAll\Multiplatform_MonitorMemdump.asm"

	read "..\SrcAll\Multiplatform_Palette.asm"

	read "..\SrcAll\MultiPlatform_Stringreader.asm"		;*** read a line in from the keyboard
	read "..\SrcAll\Multiplatform_StringFunctions.asm"	;*** convert Lower>upper and decode hex ascii

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	read "..\SrcALL\V1_BitmapMemory.asm"

	read "..\SrcALL\V1_Functions.asm"
	read "..\SrcALL\V1_Footer.asm"
	