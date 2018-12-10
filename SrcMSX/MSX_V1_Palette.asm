;VdpOut_Data equ &98
;VdpOut_Control equ &99


SetPalette:
	cp 16		;Ignore palette entries over 16
	ret nc	
	ifdef V9K
		push af
			ld a,14
			out (Vdp9k_RegSel),a
		pop af
		rlca
		rlca
		out (Vdp9k_RegData),a
		
		
		ld a,l
		and  %11110000
		rrca
		rrca
		rrca
		out (Vdp9k_Palette),a
		ld a,h
		and  %00001111
		rlca
		out (Vdp9k_Palette),a
		ld a,l
		and  %00001111
		rlca
	;	rlca
		out (Vdp9k_Palette),a
	
	else
		ifndef BuildMSX_MSX1

										;-----ggg-rrr-bbb	
		
			out (VdpOut_Control),a		;Send palette number to the VDP
			ld a,128+16					;Copy Value to Register 16 (Palette)
			out (VdpOut_Control),a

			ld a,l
			and %11101110				;We only want 3 bits for the MSX2 (V9k takes all 4)
			rrca
			out (VdpOut_Palette),a

			ld a,h
			and %11101110
			rrca
			out (VdpOut_Palette),a
		endif
	endif
	ret
;EndIF
