nolist

;UNREM ONLY ONE OF THESE

BuildCPC equ 1	; Build for Amstrad CPC
;BuildMSX equ 1 ; Build for MSX
;BuildZXS equ 1  ; Build for ZX Spectrum
;BuildENT equ 1 ; Build for Enterprise
;BuildSAM equ 1 ; Build for SamCoupe

list
read "..\SrcALL\V1_Header.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ld a,&C9
	ld (&0038),a		;Quick dummy interrupt handler

	Call DOINIT	; Get ready
	call Music_Restart
	call PLY_SFX_Init

	ld d,20
Repeatr:
	call PLY_Play	;Play music






	ei	;Wait for an interrupt
	halt
ifdef BuildCPC
	ei	;Interrupts happen 6x faster on CPC so wait 5 more times
	halt
	ei
	halt
	ei
	halt
	ei
	halt
	ei
	halt
endif

ifdef BuildENT
    ld   a,&30			;The enterprise needs this doing, or the interrupt will not clear
    out  (&b4),a
endif

	

	ld a,40 :SfxTime_plus1	;We're going to play a sfx beep one time in 40 
	dec a
	jr nz,DontPlaySFX

	ld a,70 		;frequency
	ld l,1 			;Sfx_Note_Plus1
	call PLY_SFX_Play	;Play the sound 

	ld a,40
DontPlaySFX:
	ld (SfxTime_plus1-1),a

	jp Repeatr


;We need to align our Music and SFX files to the locations we entered when we exported them from arkostracker, using a different destination
;will not work

AlignedBlock:						;Align the file to the position copied into bank 7 (Second screen)
	defs &9000-AlignedBlock
Akuyou_MusicPos:
incbin "..\resALL\MusicTest9000.bin"

AlignedBlock2:	
	defs &9500-AlignedBlock2

Akuyou_SfxPos:
incbin "..\resALL\SFXTest9500.bin"

;This is my modded arkostracker.
read "..\SrcALL\Multiplatform_ArkosTrackerLite.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

read "..\SrcALL\V1_Functions.asm"
read "..\SrcALL\V1_Footer.asm"
