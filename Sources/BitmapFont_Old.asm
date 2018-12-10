nolist

;Uncomment one of the lines below to select your compilation target

BuildCPC equ 1	; Build for Amstrad CPC
;BuildMSX equ 1 ; Build for MSX
;BuildTI8 equ 1 ; Build for TI-83+
;BuildZXS equ 1  ; Build for ZX Spectrum
;BuildENT equ 1 ; Build for Enterprise
;BuildSAM equ 1 ; Build for SamCoupe
 


;ScrColor16 equ 1
;ScrWid256 equ 1

;ScrTISmall equ 1

read "..\SrcALL\V1_Header.asm"
read "..\SrcALL\V1_BitmapMemory_Header.asm"

BMP_UppercaseOnlyFont equ 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

	Call DOINIT	; Get ready


	call ScreenINIT
	
	call BMP_CLS

	ld bc,&0000
	call GetScreenPos


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

	ld bc,&0120
	call GetScreenPos



	ld hl,HelloMsg
	call BMP_PrintString

di
halt
	
ifdef BuildZXS
	ld bc,&0120
	call GetColMemPos
	ld (hl),1*8 +64+ 7
endif

ifdef BuildCPC
;	call CPCPLUS_Init
endif
	


ifdef Disabled

;      
	ld hl,&0FFF

PaletteAgain:
	ld hl,PaletteText
	call PrintString


	ld hl,TestString	;Destination for entered text
	push hl
		ld b,4			;Max 4 characters
		call WaitString
	pop hl
	push hl

	
		call NewLine
	
		call ToUpper		;Our hex processor can only deal with uppercase
	pop hl

	call AsciiToHexPair	;First Two characters
	ld d,a

	call AsciiToHexPair	;Second Two characters
	ld e,a

	ex hl,de		;HL=MemLoc



;call CPCPLUS_SetPalette
call SetPalette

ifdef BuildMSX


	ld a,1
	out (VdpOut_Control),a
	ld a,128+16			;Copy Value to Register 16 (Palette)
	out (VdpOut_Control),a

	ld a,l
	and %11101110
	rrca
	out (VdpOut_Palette),a

	ld a,h
	and %11101110
	rrca
	out (VdpOut_Palette),a
EndIF

ifdef BuildENT
	ld a,l
	and &F0
	ld b,a	 ;R
	
	ld a,l
	and &0F  ;B
	rrca
	rrca
	rrca
	rrca
	ld l,a

	ld a,h
	rrca
	rrca
	rrca
	rrca
	ld h,a

	;Green in H

	xor a	; g0 | r0 | b0 | g1 | r1 | b1 | g2 | r2 | - x0 = lsb 

	rl b	;r2
	rra
	rl h	;g2
	rra
	rl l	;b1
	rra

	rl b	;r1
	rra
	rl h	;g1
	rra
	rl l	;b0
	rra

	rl b	;r0
	rra
	rl h	;g0
	rra

	ld (ENT_PALETTE-LPT+&FF00),a
endif
ifdef BuildSAM
	ld c,0
ld a,l
	and &F0
	ld b,a	 ;R
	and %00100000
	ld c,a


	ld a,l
	and &0F  ;B
	rrca
	rrca
	rrca
	rrca
	ld l,a
	and c
	ld c,a


	ld a,h
	rrca
	rrca
	rrca
	rrca
	ld h,a
	and c
	ld c,a
	
	rl c
	rl c

	;Green in H

	xor a	; g0 | r0 | b0 | g1 | r1 | b1 | g2 | r2 | - x0 = lsb 

	rl l	;b1
	rla
	rl b	;r1
	rla
	rl h	;g1
	rla

	rl c
	rla	;Bright

	rl l	;b0
	rla
	rl b	;r0
	rla
	rl h	;g0
	rla
	ld bc,248
	out (c),a
endif
endif
	di
	halt

	CALL SHUTDOWN ; return to basic or whatever
ret
PaletteText:
	db "-GRB",255

TestString: defs 16

HelloMsg: db "Hello World",255


BitmapFont:
	incbin "..\ResALL\Font96.FNT"
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
