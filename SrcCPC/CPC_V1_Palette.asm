;(g*9)+(r*3)+B
;down red
SetPalette:		;-GRB

	ifdef V9K
		cp 16		;Ignore palette entries over 16
		ret nc	
		
		push bc
			ld b,AmsDap
			push af
				ld a,14
				ld c,Vdp9k_RegSel
				out (c),a
			pop af
			rlca
			rlca
			ld c,Vdp9k_RegData
			out (c),a
			
			
			ld a,l
			and  %11110000
			rrca
			rrca
			rrca
			ld c,Vdp9k_Palette
			out (c),a
			ld a,h
			and  %00001111
			rlca
			out (c),a
			ld a,l
			and  %00001111
			rlca
		;	rlca
			out (c),a
		pop bc
	else

		ld c,a
		ld b,&7f
		push bc
			ld a,l
			and %11110000
			call CPCcolconv
			ld b,a	 				;R
		
			ld a,l
			and %00001111  			;B

			call CPCcolconvR
			ld l,a

			ld a,h					;G
			and %00001111
			call CPCcolconvR
			ld h,a
			xor a

			add h					;Add Green x9
			add h
			add h
			add h
			add h
			add h
			add h
			add h
			add h
			
			add b					;Add Red x3
			add b
			add b

			add l					;Add Blue x1
		
			ld b,0
			ld c,a

			ld hl,CpcPalette_Map
			add hl,bc
			ld a,(hl)

		pop bc

		out (c),c               
		out (c),a
	endif
	ret
CPCcolconvR:			;We need to shift the Red color bits
	rrca
	rrca
	rrca
	rrca
CPCcolconv:				;We need to limit our returned value to 0,1 or 2
	cp &50
	jr c,CPCcolconv0	
	cp &A0
	jr c,CPCcolconv1
	ld a,2
	ret
CPCcolconv0:	
	xor a
	ret
CPCcolconv1:	
	ld a,1
	ret
CpcPalette_Map:
	Ifdef PaletteFirmware
		db 0,1,2		;Firmware palette numbers
		db 3,4,5
		db 6,7,8

		db 9,10,11
		db 12,13,14
		db 15,16,17

		db 18,19,20				
		db 21,22,23
		db 24,25,26
	else
		db &54,&44,&55	;Hardware palette numbers
		db &5C,&58,&5D
		db &4C,&45,&4D
		
		db &56,&46,&57
		db &5E,&40,&5F
		db &4E,&47,&4F

		db &52,&42,&53
		db &5A,&59,&5B
		db &4A,&43,&4B
	endif