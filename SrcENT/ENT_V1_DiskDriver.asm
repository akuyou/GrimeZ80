
DBASIC	EQU &F37D
FOPEN	EQU &0F
FCLOSE	EQU &10
CREATE	EQU &16
BLWRITE	EQU &26
BLREAD	EQU &27
SETDMA	EQU &1A ;Disk transfer address (Destination/source)
BDOS_INIT		EQU &1B
BDOS_RESET		EQU &00
BDOS_DiskRESET		EQU &0D
BDOS_DefaultDrive 	EQU &0E
BDOS_GetDefaultDrive 	EQU &19

;defw &0000 DiscDestRelocateCall_Plus2;not implemented yet!





DiskDriver_Save:
;This doesn't seem to work with FILEIO ; - maybe some kind of protection?

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		Create a new file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	push bc
	push de
		ex hl,de
;		ld de,ENT_Filename2 	;Create a new file
		ld a,12
		;call ENT_CreateStream	
		rst 6
		db 2 		;open stream
	pop de
	pop bc

	ld a,12
;	ld bc,3
;	ld de,&0
	;call ENT_WriteBlock	;Write 3 bytes
	rst 6
	db 8

	ld a,12
	;call ENT_CloseStream	;Close the file
	rst 6
	db 3 		;close stream
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



DiskDriver_LoadDirect:
	push hl
		ld hl,null
		ld (DiscDestRelocateCall_Plus2-2),hl
	pop hl
DiskDriver_Load:

	in a,(&B1)
	ld (BankRestore_Plus1-1),a

	push de
		ex hl,de

		ld a,12
		;call ENT_OpenStream	
		rst 6
		db 1
	
		or a 
		jr nz,diskerrb

		ld a,12
		ld c,0
		ld de,FileInfoblock
		rst 6
		db 10



		or a 
		jr nz,diskerrb

		ld bc,(FileInfoblock+4)
	pop de
	;push bc
		ex hl,de
		call null:DiscDestRelocateCall_Plus2
		ex hl,de
	;pop bc

	;&B0 - Ram page 0 (0000-4000)
	;&B1 - Ram page 1 (4000-8000)
	;&B2 - Ram page 2 (8000-C000)
	;&B3 - Ram page 3 (C000-FFFF)

	ld a,&F8 :DiskLoadBank_Plus1
	out (&B1),a
	
	;all data copying is going to &4000-&8000, via bank swapping
	ld a,d
	and %00111111
	or  %01000000
	ld d,a



	ld a,12
;	call ENT_ReadBlock	;Read 1k to &1000
	rst 6
	db 6

	or a 
	jr nz,diskerr

	ld a,12
;	call ENT_CloseStream	
	rst 6
	db 3 		;close stream






LoadDone:
		scf
		; OK!
LoadDone2:
		ld a,&F8 :BankRestore_Plus1
		out (&B1),a
		ret
diskerrb:
	pop de

diskerr:

;		or a	;Clear the carry frlag
		ld de,FileInfoblock
		rst 6
		db 28
		di
		halt
		jr LoadDone2


DiskReader_LoadProcessor:
			ld de,&0000:FileDestination_Plus2
			ldir
			ld (FileDestination_Plus2-2),de
ret

FileInfoblock:

ds 4;  Byte  0 ... 3  -  File pointer value (32 bits)
ds 4;         4 ... 7  -  File size (32 bits)
ds 1;               8  -  Protection byte (yet to be defined)
ds 7;         9 .. 15  -  Zero (reserved for future expansion)
