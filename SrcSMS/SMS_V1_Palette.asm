	;The gamegear has a better palette than the SMS, but other than that they are pretty much the  same system.

SetPalette:
	push hl
		ifdef BuildSGG
		add a				;on the GG we have 2 bytes per palette, only 1 on SMS
		endif
		ld l,a
		ld h, &c0;00	    ; set VRAM write address to CRAM (palette) at &C000
		call prepareVram
	pop hl

	ifdef BuildSGG		;-GRB to  ----BBBBGGGGRRRR
		ld a,l			;RB
		ld b,a
		ld c,a

		ld a,h			;-G
		rl b			;shift 4 R bits into A
		rl a
		rl b
		rl a
		rl b
		rl a
		rl b
		rl a
		out (vdpData),a
		
		ld a,c
		and %00001111		;remove any junk
		out (vdpData),a		;-B
	endif
	
	ifdef BuildSMS ;-grb to  --BBGGRR
		ld a,l
		and %11000000		;R
		rlca
		rlca
		ld d,a
		
		ld a,l
		and %00001100		;B
		rlca
		rlca
		or d
		ld d,a
		
		ld a,h				
		and %00001100		;G
		or d
		out (vdpData),a
	endif
	ret