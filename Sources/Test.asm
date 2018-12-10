nolist

;Uncomment one of the lines below to select your compilation target

;BuildCPC equ 1	; Build for Amstrad CPC
;BuildMSX equ 1 ; Build for MSX
;BuildTI8 equ 1 ; Build for TI-83+
;BuildZXS equ 1  ; Build for ZX Spectrum
BuildENT equ 1 ; Build for Enterprise
;BuildSAM equ 1 ; Build for SamCoupe

UseHardwareKeyMap equ 1 	; Need the Keyboard map
BitmapFont_LowercaseOnly equ 1	; Minimal font - Uppercase only




read "..\SrcALL\V1_BitmapMemory_Header.asm"
read "..\SrcALL\V1_Header.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	Call DOINIT	; Get ready

	call CLS
	ld de,PaletteDest
	ld hl,&FF00;LPT in ram


	ld iyl,0
	ld ixh,8
NextPalBlock:





	ld ixl,4

	ld a,iyl
	ld iyh,a

	ld a,(de)	;linenum
	sub iyl
	neg
	ld (hl),a
	ld a,(de)	;linenum
	ld iyl,a


	inc de

	ld bc,4
	add hl,bc
	ex hl,de		
	push hl

		ld hl,0
		ld a,iyh



		or a
		jr z,EntLineAddAgainSkip

	push af
	call Monitor_PushedRegister

	push bc
		ld bc,80
EntLineAddAgain:
		add hl,bc
		dec a
	jr nz,EntLineAddAgain
	pop bc
EntLineAddAgainSkip:
	push hl
	call Monitor_PushedRegister

		ld a,l
		ld (de),a
		inc de
		ld a,h
		ld (de),a



	pop hl
	ex hl,de
	


	ld bc,3
	add hl,bc
NextPalentry:
	ld a,(de)	;Paletteentry
	ld c,a
	inc de
	ld a,(de)
	ld b,a
	inc de


	call ParsePaletteBC
	ld (hl),a
	inc hl

	push hl
	call Monitor_PushedRegister


;	push bc
;	call Monitor_PushedRegister

	dec ixl
	jr nz,NextPalentry


	Call Newline

	ld bc,4
	add hl,bc

	dec ixh
	jr nz,NextPalBlock


	Call Newline

	ld de,KeyboardScanner_KeyPresses
	rst 6
	db 20
	ld de,KeyboardScanner_KeyPresses
	ld b,8
StatAgain:
	ld a,(de)
	call ShowHex
	djnz StatAgain
	Call Newline


	ld a,(VIDS)
	push af	
	call Monitor_PushedRegister
	Call Newline
	ld b,8
GetAgain:
	push bc
		rst 6	;Segment please!
		db 24
                JP NZ,GetFail	;if not available then exit
		push bc
		call Monitor_PushedRegister
		push de
		call Monitor_PushedRegister
		Call Newline
	pop bc
	djnz,GetAgain
	di
	halt
GetFail:
		push bc
		call Monitor_PushedRegister
		push de
		call Monitor_PushedRegister
		Call Newline
	di
	halt
	
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

read "Test_EntBmpMemory.asm"
read "..\SrcALL\Multiplatform_BitmapFonts.asm"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PaletteDest:	;The 'Normal' level palette
	     ;0GRB
	defb 25
PlusSink6:	defw &0000
	defw &008F
	defw &08F3
	defw &0FFB
	defb 50
PlusSink5:	defw &0000
	defw &006E
	defw &08F3
	defw &0FFD
	defb 75
PlusSink4:	defw &0000
	defw &004D
	defw &0A02
	defw &0FFF
	defb 100
PlusSink3:	defw &0000
	defw &0084
	defw &0C00
	defw &0EFF
	defb 125
PlusSink2:	defw &0000
	defw &00A4
	defw &0E44
	defw &0EFF
	defb 140
PlusSink1:	defw &0000
	defw &040C
	defw &0C4A
	defw &0EFF
	defb 160
	defw &0006
	defw &040A
	defw &0B0A
	defw &0FCF
	defb 200
	defw &0006
	defw &040A
	defw &0F0F
	defw &0FDF


ParsePaletteBC:
	push de
	ld a,c
	and &F0
	ld d,a	 ;R
	
	ld a,c
	and &0F  ;B
	rrca
	rrca
	rrca
	rrca
	ld c,a

	ld a,b
	rrca
	rrca
	rrca
	rrca
	ld b,a

	;Green in H

	xor a	; g0 | r0 | b0 | g1 | r1 | b1 | g2 | r2 | - x0 = lsb 

	rl d	;r2
	rra
	rl b	;g2
	rra
	rl c	;b1
	rra

	rl d	;r1
	rra
	rl b	;g1
	rra
	rl c	;b0
	rra

	rl d	;r0
	rra
	rl b	;g0
	rra
	pop de
ret



read "..\SrcALL\V2_Functions.asm"
read "..\SrcALL\V1_Footer.asm"