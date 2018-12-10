
	
ShowTile:	;A=Tilenum, BC=XYpos
	
	rlc c
	rlc c 
	rrc b
	
	push ix

		call GetScreenPos
	pop ix
	
		ld h,0
		ld a,ixh
		ld l,a
		or a

		;rl l
		;rl h
		rl l
		rl h
		rl l
		rl h
		ld de,RawBitmap
		add hl,de
		push hl
		
			ld h,0
			ld a,ixl
			ld l,a
			or a

			;rl l
			;rl h
			rl l
			rl h
			rl l
			rl h
			ld de,RawBitmap
			add hl,de
			ex de,hl
		pop ix
		
		
		ld c,4
AgainY:
		
		ld a,(ix)
		inc ix
		and %11110000
		ld b,a
		
		ld a,(de)
		inc de
		and %11110000
		rrca
		rrca
		rrca
		rrca
		or b
		
		SetScrByte a
		
		call GetNextLine
		
		dec c
		jp nz,AgainY
	
	
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;