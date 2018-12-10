
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		Create a new file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ld (FileErrorSpRestore_Plus2-2),sp

	push af
		push bc
		push de
			ld de,diskerr	;Error handler
			ld (&5BC0),de	;This is called EVERY return from a Dos call (if error occured or not!)

			ld de,&4B00
			ld a,19
			ld (de),a
			inc de
			ld bc,14
			ldir
		pop de
		pop bc

		ld ix,&4B00
;	ld a,d
;	and %110000
	pop af
	ld (ix+31),a	;31  	16K PACE NUMBER START

	ld (ix+32),e	;32-33  PAGE OFFSET (8000-BFFFH) LSB/MSB
	ld a,d
	and %00111111
	or  %10000000
	ld (ix+33),a

	xor a		;34  	NUMBER OF PAGES IN LENGTH
	ld (ix+34),a

	ld (ix+35),c	;35-36  MODULO 0 TO 16383 LENGTH ie file length MOD 16384.
	ld (ix+36),b

	ld (ix+37),a	;37  	EXECUTE PAGE NUMBER if applicable

	ld (ix+38),a	;38-39  EXECUTE OFFSET (8000-BFFFH) LSB/MSB if applicable
	ld (ix+39),a

	xor a		;Before using this hook poke &5BB9  with 0 to overite existing file.
	ld (&5BB9),a	

	ld ix,&4B00
	rst 1
	db 132	;HSAVE - Save file using IX pointed UIFA
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



DiskDriver_LoadDirect:
	push hl
		ld hl,null					;Disable the relocate
		ld (DiscDestRelocateCall_Plus2-2),hl
	pop hl
DiskDriver_Load:


	ld (FileErrorSpRestore_Plus2-2),sp

	push de
		ld de,diskerr	;Error handler
		ld (&5BC0),de	;This is called EVERY return from a Dos call (if error occured or not!)
				;note - we're not setting this on WRITE command, we're assuming one read command will happen first!

		ld de,&4B00	;This points to the UIFA in ram bank 00 - SAMDOS doesn't seem to work right if it's anywhere else!
		ld a,19		;This means CODE FILE
		ld (de),a
		inc de
		ld bc,14	;copy the 14 char file name from HL - must be padded with spaces!
		ldir
	
 		ld ix,&4B00
		rst 1
		db 129 		; HGTHD - Get the file header (loads to IX+80

		ld bc,(&4B00+80+35)	;Get the file size

		ld a,%00111111		;For some reason the file sizes seems to be too high, it should be a less than 16384
		and b			;It may be my mistake!
		ld b,a
	pop hl


	;This is used when the file is compressed.
;	ex hl,de	
	call null:DiscDestRelocateCall_Plus2
;	ex hl,de
	push hl
	push bc

		ld bc,251	;HMPR - High Memory Page Register (251 dec)
		in a,(c)
		ld (DiskRestoreBank_Plus1-1),a
		push bc
			ld de,&4F00
			ld hl,DoActualLoad
			ld bc,DoActualLoad_BlockEnd-DoActualLoad
			ldir
			
			ld de,diskerrSpec-DoActualLoad+&4F00	;Error handler
			ld (&5BC0),de	;This is called EVERY return from a Dos call (if error occured or not!)
		pop bc
	pop de
	pop hl
	jp &4F00
DoActualLoad:
	and %11100000
	or 0:DiskLoadBank_Plus1
	out (c),a
	ld c,0
	ld ix,&4B00
	rst 1				
	db 130				;HLOAD - Load the file
LoadDone:
		scf		; OK! set carry flag
LoadDone2:
		ret
DoLoadFromBankB:	
diskerrSpec:
		push af
			ld bc,251	;HMPR - High Memory Page Register (251 dec)
			ld a,0	:DiskRestoreBank_Plus1
			out (c),a
		pop af
diskerr:
		
		or a	;Clear the carry frlag
		ret z 	; no error
		ld sp,&0000:FileErrorSpRestore_Plus2
		jr LoadDone2

DoActualLoad_BlockEnd:
;UIFA
;db 19
;db "music.bin                        "
;
;ds 80+48
;DIFA
;ds 48
;5BC0H - REPLACE THIS WITH MY OWN ERROR HANDLER!

;UIFA and DIFA have the same format, 
;UIFA is provided by user at IX, DIFA is returned by the disk at IX+80 

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
;35-36  MODULO 0 TO 16383 LENGTH ie file length MOD 16384.
;37  	EXECUTE PAGE NUMBER if applicable
;38-39  EXECUTE OFFSET (8000-BFFFH) LSB/MSB if applicable
;40-47  SPARE 8 BYTES (Comment Field

