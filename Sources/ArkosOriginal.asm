nolist

;UNREM ONLY ONE OF THESE

BuildCPC equ 1	; Build for Amstrad CPC


read "..\SrcALL\V1_Header.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ld a,&C9
	ld (&0038),a




	Call DOINIT	; Get ready

	ld de,Akuyou_MusicPos		;Initialise music
	call PLY_Init

	ld de,Akuyou_SfxPos		;Initilise SFX
	call PLY_SFX_Init

;	ld de,Akuyou_MusicPos		;If you don't need the SFX, you still need to INIT it,
;	call PLY_SFX_Init		;Just point it to your music file insead


Repeatr:

	call PLY_Play





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

	ld a,40 :SfxTime_plus1
	dec a
	jr nz,DontPlaySFX

	ld a,70 ;frequency
	ld l,1 ;Sfx_Note_Plus1
	

	ld a,1;A = No Channel (0,1,2)
	ld l,1;L = SFX Number (>0)
	ld h,&F;H = Volume (0...F)
	ld e,70;E = Note (0...143) (0 is the lowest, 143 the highest)
	ld d,0;D = Speed (0 = As original, 1...255 = new Speed (1 is the fastest))
	ld bc,0;BC = Inverted Pitch (-&FFFF -> &FFFF). 0 is no pitch (=the original sound). The higher the pitch, the lower the sound.
	call PLY_SFX_Play
	ld a,40
DontPlaySFX:
	ld (SfxTime_plus1-1),a


	jp Repeatr




read "..\SrcCPC\Arkos\ArkosTrackerPlayer_CPCStable_MSX.asm"


AlignedBlock:		
	defs &9000-AlignedBlock
Akuyou_MusicPos:
incbin "..\resALL\MusicTest9000.bin"

AlignedBlock2:	
	defs &9500-AlignedBlock2

Akuyou_SfxPos:
incbin "..\resALL\SFXTest9500.bin"




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

read "..\SrcALL\V1_Functions.asm"
read "..\SrcALL\V1_Footer.asm"
