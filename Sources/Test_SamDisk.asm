nolist

;UNREM ONLY ONE OF THESE

;BuildCPC equ 1	; Build for Amstrad CPC
;BuildMSX equ 1 ; Build for MSX
;BuildZXS equ 1  ; Build for ZX Spectrum
;BuildENT equ 1 ; Build for Enterprise
BuildSAM equ 1 ; Build for SamCoupe

read "..\SrcALL\V1_Header.asm"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	Call DOINIT	; Get ready

;	ld de,UIFA
;	ld a,19
;	ld (de),a
;	inc de
;	ld hl,fail
;	ld (&5BC0),hl

;	ld hl,MusicFile
;	ld bc,9
;	ldir
;	inc de
;	xor a
;	ld (de),a
;	di
	ld hl,UIFA
	ld de,&C000
	ld bc,128
	ldir

	ld c,0
	ld de,1
	ld ix,&C000
	rst 1
	db 129
	
	ld de,&7800


di
halt
Fail:
di
halt


UIFA:
db 19
db "MUSIC                       "

ds 128
DIFA:
ds 48
;5BC0H - REPLACE THIS WITH MY OWN ERROR HANDLER!


;0  	STATUS/FILE TYPE.
;1-14  	FILENAME. 14 characters are allocated to allow for device
;	identification, for example D1;filenamexx. SAMDOS will strip
;	off the device identifier, so the maximum length of a filename
;	is still ten characters.
;15  	FLAGS
;16-26  If the file type is 17 or 18 then these bytes contain the
;	type/length byte and the name.
;16  	If the file type is 20 then this byte contains the screen
;	mode.
;16-18  If the file type is 16 then these bytes contain the program
;	length excluding variables.
;19-21  If the file type is 16 then these bytes contain the program
;	length plus the numeric variables.
;22-24  If the file type is 16 then these bytes contain the program
;	length plus the numeric variables and the gap length before
;	the character variables.
;27-30  SPARE 4 BYTES (Reserved)
;31  	16K PACE NUMBER START
;32-33  PAGE OFFSET (8000-BFFFH) LSB/MSB
;34  	NUMBER OF PAGES IN LENGTH



;We need to align our Music and SFX files to the locations we entered when we exported them from arkostracker, using a different destination
;will not work

AlignedBlock:						;Align the file to the position copied into bank 7 (Second screen)
	defs &9000-AlignedBlock
Akuyou_MusicPos:
;incbin "..\resALL\MusicTest9000.bin"


;read "..\SrcCPC\CPC_V1_DiskDriver.asm"
;read "..\SrcMSX\MSX_V1_DiskDriver.asm"
;read "..\SrcENT\ENT_V1_DiskDriver.asm"
read "..\SrcSAM\SAM_V1_DiskDriver.asm"

ifdef BuildBasicDisk
	BuildLang equ ''
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

ifdef BuildCPC


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
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ifdef BuildENT
null:
ret

MusicFile: db 9,'MUSIC.BIN'
TestFile: db 8,'TEST.BIN'
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ifdef BuildSAM

null:
ret

MusicFile: db 'MUSIC.BIN'
TestFile: db 'TEST.BIN'
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

read "..\SrcALL\V1_Functions.asm"
read "..\SrcALL\V1_Footer.asm"
