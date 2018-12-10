SetPalette:
	ifdef BuildGBC
	push hl
		add a
		ld c,a

		ld a,l
		and %00001111 	;Blue
		rlca
		ld d,a
				
		ld a,l
		and %11110000 	;Red
		rrca
		rrca
		rrca			;Gameboy has 5 bits, but we only have 4
		ld e,a

		ld a,h			;Green
		swap a		;GBC command, equivalent of 4x rlca
		
		rla		
		rl d	;Two green bits needed with blue
		rla
		rl d
		
		or e
		ld e,a
		
		;Setting Palettes on GBC:
		;Background Write Specification (BCPS) FF68  (select palette)
		;Background Write Data 		    (BCPD) FF69 

		;Palette select:
		;a-pppccb		b=byte (1=high) cc=color ppp=palette a=autoinc palette number
		
		;;      xBBBBBGG GGGRRRRR
		LD	HL,$FF68	; Palette select register
		LD	A,C			; Load A with the palette+color number
		LDI	(HL),A		; Select the palette and INC HL (now pointing at Data register)
		LD	A,E			; 
		LDI	(HL),A		; Send the Low byte color info
		LD	HL,$FF68	; palette select register
		LD	A,C			; Load A with the palette+color number
		INC	A			; add 1, setting bit 0 (1=high)
		LDI	(HL),A		; Select the palette and INC HL (now pointing at Data register)
		LD	A,D			; 
		LDI	(HL),A		; Send the High byte color info
		
	pop hl
	endif
	ret