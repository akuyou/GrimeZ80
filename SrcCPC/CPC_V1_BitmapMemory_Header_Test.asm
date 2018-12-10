ifdef ScrColor16
	CharByteWidth equ 4
else
	CharByteWidth equ 2
endif

ifndef ScrWid256

	macro NextScrByte
		inc hl
	mend
else
	macro NextScrByte
		inc l
	mend


endif


macro SetScrByte newbyte
	ld (hl),newbyte
	NextScrByte
mend

ifndef ScrColor16
	macro SetScrBytebw
	push af
		and %11110000
		ld (hl),a
		NextScrByte
	pop af
	push af
		and %00001111
		rrca
		rrca
		rrca
		rrca
		ld (hl),a
		NextScrByte
	pop af
	mend
else
	macro SetScrBytebw
	push bc
ifdef HalfWidthFont
		
		ld c,a
		
		and %10100000
		rrca
		ld b,a
		ld a,c
		and %01010000
		or b
		rrca
		rrca
		rrca
		rrca
		ld b,0
		rra
		rr b
		rra
		rra
		rr b
		ld (hl),b
		NextScrByte

		ld b,0
		ld a,c
		and %00001010
		rrca
		ld b,a
		ld a,c
		and %00000101
		or b

		ld b,0
		rra
		rr b
		rra
		rra
		rr b

		ld (hl),b
		NextScrByte


		ld a,c
else
		ld c,a
		and %11000000
		ld (hl),a
		NextScrByte

		ld a,c
		and %00110000
		rlca
		rlca
		ld (hl),a
		NextScrByte

		ld a,c
		and %00001100
		rlca
		rlca
		rlca
		rlca
		ld (hl),a
		NextScrByte

		ld a,c
		and %00000011
		rrca
		rrca
		ld (hl),a
		NextScrByte
		ld a,c
endif
	pop bc
	mend
endif
