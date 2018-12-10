
SetPalette:
	cp 8
	jr nc,SkipENTPalette	;Can only set first 8 palettes on ENT in 16color mode

	push af

		ld a,l
		and &F0
		ld b,a	 ;R
		
		ld a,l
		and &0F  ;B
		rrca
		rrca
		rrca
		rrca
		ld l,a

		ld a,h	;G
		rrca
		rrca
		rrca
		rrca
		ld h,a
		xor a	;We need data in format: g0 | r0 | b0 | g1 | r1 | b1 | g2 | r2 | - x0 = lsb 

		rl b	;r2
		rra
		rl h	;g2
		rra
		rl l	;b1
		rra

		rl b	;r1
		rra
		rl h	;g1
		rra
		rl l	;b0
		rra

		rl b	;r0
		rra
		rl h	;g0
		rra
		
		ld c,a
	pop af
	ld hl,ENT_PALETTE-LPT+&FF00
	
	add l
	ld l,a		;We write the palette entry to the memory location in the LPT into the correct location
	ld (hl),c
SkipENTPalette:
	ret