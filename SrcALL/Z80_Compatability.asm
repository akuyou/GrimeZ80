	macro z_ex_sphl
		ex (SP),HL
	endm
	macro z_ex_dehl
		ex de,hl
	endm
	macro z_ldir
		ldir
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_halt
		halt
	endm	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	ifndef vasm
		macro z_djnz addr
			djnz addr
		endm
	else 
		macro z_djnz,addr
			djnz \addr
		endm	
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_ld_a_r
		LD a,r
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	macro z_ld_a_iyl
		ld a,iyl
	endm
	macro z_ld_a_iyh
		ld a,iyh
	endm
	
	macro z_ld_a_ixl
		ld a,ixl
	endm
	macro z_ld_a_ixh
		ld a,ixh
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_ld_iyl_a
		ld iyl,a
	endm
	macro z_ld_iyh_a
		ld iyh,a
	endm
	
	macro z_ld_ixl_a
		ld ixl,a
	endm
	macro z_ld_ixh_a
		ld ixh,a
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_cp_iyl
		cp iyl
	endm
	macro z_cp_iyh
		cp iyh
	endm
	
	macro z_cp_ixl
		cp ixl
	endm
	macro z_cp_ixh
		cp ixh
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_dec_ixl
		dec ixl
	endm
	macro z_dec_ixh
		dec ixh
	endm
	macro z_dec_iyl
		dec iyl
	endm
	macro z_dec_iyh
		dec iyh
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_inc_ixl
		inc ixl
	endm
	macro z_inc_ixh
		inc ixh
	endm
	macro z_inc_iyl
		inc iyl
	endm
	macro z_inc_iyh
		inc iyh
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_inc_iy
		inc iy
	endm	
	macro z_dec_iy
		dec iy
	endm	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_inc_ix
		inc ix
	endm	
	macro z_dec_ix
		dec ix
	endm	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_sbc_hl_de
		sbc hl,de
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_sbc_hl_bc
		sbc hl,bc
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef vasm
		macro z_ld_bc_from,addr
			ld bc,(\addr)
		endm
		macro z_ld_de_from,addr
			ld de,(\addr)
		endm
		macro z_ld_hl_from,addr
			ld hl,(\addr)
		endm
		macro z_ld_bc_to,addr
			ld (\addr),bc
		endm
		macro z_ld_de_to,addr
			ld (\addr),de
		endm
		macro z_ld_de_hl,addr
			ld (\addr),hl
		endm
	else
		macro z_ld_bc_from addr
			ld bc,(addr)
		endm
		macro z_ld_de_from addr
			ld de,(addr)
		endm
		macro z_ld_hl_from addr
			ld hl,(addr)
		endm
		macro z_ld_bc_to addr
			ld (addr),bc
		endm
		macro z_ld_de_to addr
			ld (addr),de
		endm
		macro z_ld_de_hl addr
			ld (addr),hl
		endm
	endif
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro gb_swapa
		rr a
		rr a
		rr a
		rr a
	endm
	macro gb_swapb
		rr b
		rr b
		rr b
		rr b
	endm
	macro gb_swapc
		rr c
		rr c
		rr c
		rr c
	endm
	macro gb_swapd
		rr d
		rr d
		rr d
		rr d
	endm
	macro gb_swape
		rr e
		rr e
		rr e
		rr e
	endm
	macro gb_swapf
		rr f
		rr f
		rr f
		rr f
	endm
	macro gb_swaph
		rr h
		rr h
		rr h
		rr h
	endm
	macro gb_swapl
		rr l
		rr l
		rr l
		rr l
	endm
	macro gb_swaphl
		rr (hl)
		rr (hl)
		rr (hl)
		rr (hl)
	endm