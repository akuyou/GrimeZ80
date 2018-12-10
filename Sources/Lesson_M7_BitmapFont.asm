	nolist

;Uncomment one of the lines below to select your compilation target

;BuildCPC equ 1	; Build for Amstrad CPC
;BuildMSX equ 1 ; Build for MSX
;BuildZXS equ 1  ; Build for ZX Spectrum
;BuildENT equ 1 ; Build for Enterprise
;BuildSAM equ 1 ; Build for SamCoupe
;BuildTI8 equ 1 ; Build for Ti 83
	
;ScrColor16 equ 1
ScrWid256 equ 1

;ScrTISmall equ 1

	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef vasm
		include "..\SrcALL\VasmBuildCompat.asm"
	else
		read "..\SrcALL\WinApeBuildCompat.asm"
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	read "..\SrcALL\V1_Header.asm"
	read "..\SrcALL\V1_BitmapMemory_Header.asm"

;BMP_UppercaseOnlyFont equ 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

	Call DOINIT	; Get ready
	call ScreenINIT


	call BMP_CLS
	di

	
	ld bc,&0000		;move drawing cursor to top corner
	call GetScreenPos


	ld de,RawBitmap
	ld c,48				;Lines
AgainY:
	ld b,48/8*BmpByteWidth		;Width in bytes

AgainX:
		ld a,(de)
		SetScrByte a		;Send the bytes to screen
		inc de
		djnz AgainX
		call GetNextLine
	dec c
	jp nz,AgainY

	ld hl,&107			;Move text cursor
	call BMP_Locate

	ld hl,HelloMsg
	call BMP_PrintString		;Print message


	
	;Fill a 6x6 character grid in Pink foreground / Black background on the Speccy
	ifdef BuildZXS
		ld c,0
ZXRowAgain:
		ld b,0
ZXColAgain:
		push bc
			call GetColMemPos
			ld (hl),0*8 +64+ 3
		pop bc

		inc b			;Xpos is in Chars (Bytes)
		ld a,b
		cp 6
		jr nz,ZXColAgain

		ld a,c			;Ypos is in lines
		add 8
		ld c,a
		cp 6*8
		jr nz,ZXRowAgain
	endif

	di
	halt

	CALL SHUTDOWN ; return to basic or whatever
	ret


HelloMsg: db "Goodbye World!?",255


BitmapFont:
	ifdef BMP_UppercaseOnlyFont
		incbin "..\ResALL\Font64.FNT"			;Font bitmap, this is common to all systems
	else
		incbin "..\ResALL\Font96.FNT"			;Font bitmap, this is common to all systems
	endif
RawBitmap:
	if BuildCPCv+BuildENTv
		ifdef ScrColor16
			incbin "..\ResALL\Sprites\RawCPC16.RAW"		;16 color sprite for CPC/ENT
		else
			incbin "..\ResALL\Sprites\RawCPC.RAW"		;4 color sprite for CPC/ENT
		endif
	endif
	if BuildZXSv+BuildTI8v
		incbin "..\ResALL\Sprites\RawZX.RAW"			;2 bit sprite for Speccy
	endif
	if BuildMSXv+BuildSAMv
		incbin "..\ResALL\Sprites\RawMSX.RAW"			;16 color sprite for MSX/SAM
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

	read "..\SrcAll\MultiPlatform_Stringreader.asm"		;*** read a line in from the keyboard
	read "..\SrcAll\Multiplatform_StringFunctions.asm"	;*** convert Lower>upper and decode hex ascii

	;read "..\SrcCPC\CPCPLUS_V1_Palette.asm"
	;read "..\SrcCPC\CPC_V1_Palette.asm"

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;
	;			End of Your program
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	read "..\SrcALL\V1_BitmapMemory.asm"
	read "..\SrcALL\Multiplatform_BitmapFonts.asm"

	read "..\SrcALL\V1_Functions.asm"
	read "..\SrcALL\V1_Footer.asm"
