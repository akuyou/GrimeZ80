nolist

;UNREM ONLY ONE OF THESE

;BuildCPC equ 1	; Build for Amstrad CPC
;BuildMSX equ 1 ; Build for MSX
;BuildTI8 equ 1 ; Build for TI-83+
;BuildZXS equ 1  ; Build for ZX Spectrum
;BuildENT equ 1 ; Build for Enterprise
;BuildSAM equ 1 ; Build for SamCoupe

;If we need ALL registers in our interrupt handler - not just the shadow ones, enable this

;CpcPlus equ 1



;Interrupts_NeedAllRegisters equ 1		;If your interrupt handler needs more than shadow registers enable this
;Interrupts_ProtectShadowRegisters equ 1		;If your program needs shadow registers enable this

;Interrupts_UseIM2 equ 1				;Use interrupt mode 2 instead of IM1 (need free &200 byte block at &8000)

;Interrupts_AllowStackMisuse equ 1		;Use shadow stack to allow interrupts during misusing the stack
;Interrupt_ShadowStack equ &8200

read "..\SrcALL\V1_Header.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



	Call DOINIT	; Get ready
ifndef CpcPlus
	call ReadPlusPalette
endif

ifdef CpcPlus
	di
	ld b,&bc
	ld hl,PlusInitSequence
	ld e,17
PlusInitLoop:
	ld a,(hl)
	out (c),a
	inc hl
	dec e
	jr nz,PlusInitLoop
endif

ifdef Interrupts_UseIM2

	jp SkipInterruptBlock
	InterruptBlock:
	ifdef Interrupt_ShadowStack
		defs &8200-InterruptBlock
	else
		defs &8190-InterruptBlock
	endif

endif
SkipInterruptBlock:

	call Interrupts_Install
	ei


infinite:
jp infinite






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Stack Abuse Test
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		program Finish
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	call Interrupts_Uninstall
	call Music_Stop
	CALL SHUTDOWN ; return to basic or whatever
ret

AlignedBlock:						;Align the file to the position copied into bank 7 (Second screen)
	defs &9000-AlignedBlock
Akuyou_MusicPos:
Akuyou_SfxPos:
incbin "..\resALL\MusicTest9000.bin"
read "..\SrcALL\Multiplatform_ArkosTrackerLite.asm"

read "..\SrcALL\Multiplatform_Interrupts.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		Interrupt driver
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
read "..\SrcALL\Multiplatform_Interrupt_Start.asm"

Interrupts_FastTick:
ifndef CPCPlus
	ld hl,RasterColors :IH_RasterColor_Plus2

	ld      b,&f5
	in      a,(c)

	rra   
	jp nc,InterruptHandlerOk

	ld hl,RasterColors

InterruptHandlerOk:
	ld bc,&7f00      
	out (c),c   

	outi		;OUTI does not work right on the CPC
	inc b		;So we need to do INC B
	
	inc c		;inc C - to change the next color
	out (c),c	;Set the Color number

	outi		;OUTI does not work right on the CPC
	inc b		;So we need to do INC B
	
	inc c		;inc C - to change the next color
	out (c),c	;Set the Color number

	outi		;OUTI does not work right on the CPC
	inc b		;So we need to do INC B
	
	inc c		;inc C - to change the next color
	out (c),c	;Set the Color number

	outi		;OUTI does not work right on the CPC

	ld (IH_RasterColor_Plus2-2),hl
endif

ifdef CPCplus

;; page-in asic registers to &4000-&7fff
	ld bc,&7fb8					;; [3]
	out (c),c					;; [4]
	ld c,%11000000 +0 ; Reset ram banks
	out (c),c

	ld hl,PlusRasterPalette :NextPlusRasterSetting_Plus2
	ld a,0:ThisPlusRaster_Plus1
	or a
	jr nz,PlusRasterSaveSetting
	ld hl,PlusRasterPalette



PlusRasterSaveSetting:

	ld a,(hl)						;; line 100
	inc hl
	ld (ThisPlusRaster_Plus1-1),a

	ld de,&6800
	ld (de),a
;	or a
;	jr z,InterruptPlaySoundB;PlusRasterFinish

	ld d,&64	;Palette port at &6400
	
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ld (NextPlusRasterSetting_Plus2-2),hl

	;; page-out asic registers
	ld bc,&7fa0
	out (c),c
endif
read "..\SrcALL\Multiplatform_Interrupt_End.asm"

ReadPlusPalette:

	ld iy,RasterColors+4
	ld hl,PlusRasterPalette+9
	ld c,5
ReadPlusPaletteNextBlock:
	ld b,4
	inc hl
ReadPlusPaletteNextPal:
	push bc
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ex hl,de
		call SetPalette
	ex hl,de

	ld (iy),a
	inc iy
	pop bc
	djnz ReadPlusPaletteNextPal

	ld de,9
	add hl,de

	dec c
	jr nz,ReadPlusPaletteNextBlock
ret




	

read "..\SrcCPC\CPC_V1_Palette.asm"
RasterColors:
	db &4C,&43,&52,&5C	;Change 1
	db &52,&5C,&4C,&43	;Change 2
	db &4C,&43,&52,&5C	;Change 3
	db &52,&5C,&4C,&43	;Chance 4
	db &4C,&43,&52,&5C	;Change 5
	db &52,&5C,&4C,&43	;Change 6

PlusRasterPalette:
defb 20	;next split
defw &000F
defw &0010
defw &0000
defw &0000
defb 40		;next split
defw &00FC
defw &0020
defw &0000
defw &0000
defb 60	;next split
defw &0F0A
defw &0030
defw &0000
defw &0000
defb 80	;next split
defw &0008
defw &0040
defw &0000
defw &0000
defb 100		;next split
defw &00F6
defw &0050
defw &0000
defw &0000
defb 120		;next split
defw &0F02
defw &0060
defw &0000
defw &0000
defb 140		;next split
defw &000F
defw &0070
defw &0000
defw &0000
defb 160	;next split
defw &0000
defw &0080
defw &0000
defw &0000
defb 180	;next split
defw &0FEC
defw &0090
defw &0000
defw &0000
defb 200		;next split
defw &0FFF
defw &00a0
defw &0000
defw &0000

defb 0		;next split


PlusInitSequence:
defb &ff,&00,&ff,&77,&b3,&51,&a8,&d4,&62,&39,&9c,&46,&2b,&15,&8a,&cd,&ee


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

read "..\SrcALL\V1_Functions.asm"
read "..\SrcALL\V1_Footer.asm"
