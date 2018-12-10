CPCPLUS_INIT:
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
	ei
	ret

PlusInitSequence:	;This is a special sequence to unock the CPC+ Asic... it's intentionally random!
	defb &ff,&00,&ff,&77,&b3,&51,&a8,&d4,&62,&39,&9c,&46,&2b,&15,&8a,&cd,&ee

SetPalette:
	ld bc,&7fb8	;Page in PLUS registers	(alt rambank at &4000-&7FFF)
	out (c),c				
	ex de,hl	;Swap the palette to DE

	ld hl,&6400	;start of CPC Plus Palette
	
	add a		;Double palette number (2 bytes per entry)
	add l
	ld l,a

	ld (hl),e	;Write the palette our
	inc hl
	ld (hl),d
 
	ex de,hl
	ld bc,&7fa0	;Page out PLUS registers
	out (c),c
	ret
