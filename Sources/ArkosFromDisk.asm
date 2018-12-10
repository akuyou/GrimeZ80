	nolist

;UNREM ONLY ONE OF THESE

;BuildCPC equ 1	; Build for Amstrad CPC
;buildCPC_Tap equ 1
;RomDisk equ 1
;BuildMSX equ 1 ; Build for MSX
;BuildZXS equ 1  ; Build for ZX Spectrum
;BuildENT equ 1 ; Build for Enterprise
;BuildSAM equ 1 ; Build for SamCoupe

BuildZXS_TRD equ 1
;BuildZXS_DSK equ 1
;BuildZXS_TAP equ 1


;BuildBasicDisk equ 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef vasm
		include "..\SrcALL\VasmBuildCompat.asm"
	else
		read "..\SrcALL\WinApeBuildCompat.asm"
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	ld a,255
;	out (&B3),a


	read "..\SrcALL\V1_Header.asm"

	Call DOINIT	; Get ready

	ifdef BuildZXS
		ld sp,&8000
		call Firmware_Restore
	endif

;	ld de,UIFA
;	ld a,19
;	ld (de),a
;	inc de


;	ld hl,MusicFile
;	ld bc,9
;	ldir
;	inc de
;	xor a
;	ld (de),a
;	di

	ifdef BuildBasicDisk
		ld de,Akuyou_MusicPos
		ld hl,MusicFile
		call DiskDriver_LoadDirect
	endif

	ifndef BuildBasicDisk

	ifdef BuildENT
		ld a,&F9	;Bank
	endif
	ifdef BuildSAM
		ld a,1
	endif

		ld hl,&01C1	;Filename
		ld c,1		;Disk
		ld de,&9000	;Destination
		ld ix,&9000+&400;Compess destination
		call LoadDiscSectorZ
	endif




	ifdef BuildSAM
		ld a,1
	endif

	ld hl,TestFile
	ld de,&8000
	ld bc,&0064
	call DiskDriver_Save


	ld a,&C9
	ld (&0038),a		;Quick dummy interrupt handler

	call Music_Restart
	call PLY_SFX_Init

	ld d,20
Repeatr:

	di
	push iy
	call PLY_Play	;Play music
	pop iy
	ei





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

	

	ld a,40 ;<-- SM ***
SfxTime_plus1:	;We're going to play a sfx beep one time in 40 
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

	NewOrg &9000
Akuyou_MusicPos:
;incbin "..\resALL\MusicTest9000.bin"

	NewOrg &9500

Akuyou_SfxPos:
	incbin "..\resALL\SFXTest9500.bin"

;This is my modded arkostracker.
	read "..\SrcALL\Multiplatform_ArkosTrackerLite.asm"


;read "..\SrcMSX\MSX_V1_DiskDriver.asm"



	ifndef BuildBasicDisk
BuildLangE equ 1
		read "..\SrcALL\Multiplatform_FileLoader.asm"
		DiskRemap: db 1,2,3,4

CSprite_SetDisk equ 0
CSprite_Loading equ 0
		ShowCompiledSprite:
		SpriteBank_Font2:
		DrawText_LocateAndPrintStringUnlimited:
		KeyboardScanner_WaitForKey:
	endif

	ret
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef BuildCPC
		ifndef RomDisk
			read "..\SrcCPC\CPC_V1_DiskDriver.asm"
		else
			read "..\SrcALL\Multiplatform_RomDisk.asm"
		endif

MusicFile:
	db "MUSIC   .BIN"
	   ;12345678.123
TestFile:
	db "Test    .Tst"
	   ;12345678.123

null:
BankSwitch_C0:
BankSwitch_C0_Reset:
		ret
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef BuildMSX

MusicFile:
	db "MUSIC   BIN"
   ;12345678.123
TestFile:
	db "Test    Tst"
   ;12345678.123


null:
Bankswapper_FullRam:
Bankswapper_RestoreFirmware:
		ret
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef BuildENT
	read "..\SrcENT\ENT_V1_DiskDriver.asm"

null:
	ret

MusicFile: db 9,'MUSIC.BIN'
TestFile: db 8,'TEST.BIN'
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef BuildSAM
		read "..\SrcSAM\SAM_V1_DiskDriver.asm"

			   ;12345678901234
		MusicFile: db 'MUSIC.BIN      '
		TestFile:  db 'D0:TEST.BIN       '
null:
		ret
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef BuildZXS
	read "..\SrcZX\ZX_V1_DiskDriver.asm"

	       ;12345678901234
MusicFile:
	ifdef buildZXS_DSK
		db "MUSIC.C",&ff
	endif

	;MusicFile db 'MUSIC.BIN      '
;	  db 'D0TEST.BIN       '

TestFile:

	ifdef buildZXS_DSK
		db "TEST.C",&ff
	endif
	ifdef buildZXS_TRD
		db "TEST0000C"
	endif 
	ifdef buildZXS_TAP
		;Can't save to tape
	endif
DrawText_CharSprite:
DrawText_LocateSprite:
Firmware_Kill:
Bankswapper_Reset:
Bankswapper_Copy:
	null:
	ifndef buildZXS_DSK
Bankswapper_Set:
Firmware_Restore:
Firmware_Apply:
	endif
	ret
out7ffdBak equ &5B5C	
out1FFDBak equ &5B67	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef buildZXS_DSK

Bankswapper_Set:
        ld   c,a
        ld   a,(out7ffdBak)  ;BANKM (23388)
        and  %11111000
        or   c
        ld   bc,&7ffd   ;32765
        out  (c),a
        ld  (out7ffdBak),a  ;BANKM (23388)
        ret
Firmware_Restore:			; Disk mode

	ld iy,&5C3A	;Do this - or suffer the concequences! - should always be set when firmware interrupts may run!

	ifdef buildZXS_DSK
		ld d,%00000100
		ld e,0
	endif


	ifdef buildZXS_TRD
		ld d,%00000000			; Rom 1
		ld e,%00010000
	endif
	ifdef buildZXS_TAP
		ld d,%00000100			;NEED ROM 3 on PLUS, 1 on 128k, 0 on 48k
		ld e,%00010000
	endif
	im 1
Firmware_Apply:
	ld a,(out1FFDBak)
	and  %11111011
	or d
        ld   bc,&1ffd   ;32765
        out  (c),a
	ld (out1FFDBak),a
        ld   a,(out7ffdBak)  ;BANKM (23388)
        and  %11101111
	or e
        ld   bc,&7ffd   ;32765
        out  (c),a
        ld   (out7ffdBak),a
	ret
	endif

	endif
	list

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	read "..\SrcALL\V1_Functions.asm"
	read "..\SrcALL\V1_Footer.asm"
