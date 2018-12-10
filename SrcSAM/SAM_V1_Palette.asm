SetPalette:
	cp 16		;Ignore palette entries over 16
	ret nc
	
				;Bit 0 BLUO least significant bit of blue.
				;Bit 1 REDO least significant bit of red.
				;Bit 2 GRNO least significant bit of green.
				;Bit 3 BRIGHT  half bit intensity on all colours.
				;Bit 4 BLU1 most significant bit of blue.
				;Bit S RED1 most significant bit of red.
				;Bit 6 GRN1 most significant bit of green

				;Sam palette is annoying... it has one 'bright' bit which increases brightness of all other colors
	
	push af
		ld c,0
		ld a,l
		and &F0
		ld b,a	 ;R
		
		and %00100000
		ld c,a	;We set the bright bit if bit 5 is set in ALL other colors.


		ld a,l
		and &0F  ;B
		rrca
		rrca
		rrca
		rrca
		ld l,a
		and c
		ld c,a


		ld a,h	;G
		rrca
		rrca
		rrca
		rrca
		ld h,a
		and c
		ld c,a
		
		rl c	;Shift our 'Bright bit' to the correct location
		rl c

		xor a

		rl h	;g1
		rla
		rl b	;r1
		rla
		rl l	;b1
		rla

		rl c	;Bright
		rla		

		rl h	;g0
		rla
		rl b	;r0
		rla
		rl l	;b0
		rla
		
	pop bc		;Palette entry number is now in B
		ld c,248
		out (c),a
	ret