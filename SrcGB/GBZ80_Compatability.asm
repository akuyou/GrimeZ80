;Fake registers at FFFx-
r_ixl equ &DFF0	
r_ixh equ &DFF1
	
r_ix  equ &DFF0
	
r_iyl equ &DFF2
r_iyh equ &DFF3
	
r_iy  equ &DFF2

r_r  equ &DFF4

	macro z_ex_sphl		;ex (SP),HL
		push de
			ld d,h
			ld e,l
			
			inc sp
			inc sp
			
			pop hl
			push de
			
			dec sp
			dec sp
		pop de
	endm
	
	macro z_ex_dehl
		push hl
		push de
		pop hl
		pop de
	endm
	
	macro z_ldir
	inc b
	push af
 \@Ldirb:
		ldi a,(hl)
		ld (de),a
		;inc hl
		inc de
		dec c
		jr nz, \@Ldirb
		dec b
		jr nz, \@Ldirb
	pop af
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;BUG:When interrupts are disabled with DI, HALT will not lock the cpu... GBZ80 skips it, but The instruction immediately following the  HALT instruction is "skipped" on all except the GBC. As a result, always put a NOP after the HALT instruction.
	macro z_halt
		halt
		nop
	endm	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_djnz,addr
		dec b
		jp nz,\addr
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_ld_a_r
		LD a,(r_r)
		inc a
		xor h
		xor l
		rlca
		xor b
		xor c
		rlca
		xor d
		xor e
		ld (r_r),a
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_ld_a_iyl
		LD a,(r_iyl)
	endm
	macro z_ld_a_iyh
		LD a,(r_iyh)
	endm
	
	macro z_ld_a_ixl
		LD a,(r_ixl)
	endm
	macro z_ld_a_ixh
		LD a,(r_ixh)
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_ld_iyl_a
		LD (r_iyl),a
	endm
	macro z_ld_iyh_a
		LD (r_iyh),a
	endm
	
	macro z_ld_ixl_a
		LD (r_ixl),a
	endm
	macro z_ld_ixh_a
		LD (r_ixh),a
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_cp_iyl
		push hl
			ld hl,r_iyl
			cp (hl)
		pop hl
	endm
	macro z_cp_iyh
		push hl
			ld hl,r_iyh
			cp (hl)
		pop hl
	endm
	
	macro z_cp_ixl
		push hl
			ld hl,r_ixl
			cp (hl)
		pop hl
	endm
	macro z_cp_ixh
		push hl
			ld hl,r_ixh
			cp (hl)
		pop hl
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_inc_ixl
		push hl
		
			ld hl,r_ixl
			inc (hl)
		pop hl
	endm
	macro z_inc_ixh
		push hl
			ld hl,r_ixh
			inc (hl)
		pop hl
	endm
	macro z_inc_iyl
		push hl
			ld hl,r_iyl
			inc (hl)
		pop hl
	endm
	macro z_inc_iyh
		push hl
			ld hl,r_iyh
			inc (hl)
		pop hl
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_dec_ixl
		push hl
		
			ld hl,r_ixl
			dec (hl)
		pop hl
	endm
	macro z_dec_ixh
		push hl
			ld hl,r_ixh
			dec (hl)
		pop hl
	endm
	macro z_dec_iyl
		push hl
			ld hl,r_iyl
			dec (hl)
		pop hl
	endm
	macro z_dec_iyh
		push hl
			ld hl,r_iyh
			dec (hl)
		pop hl
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	macro z_inc_iy
		push de
		push hl
			ld hl,r_iy
			ld e,(hl)
			inc hl
			ld d,(hl)
			inc de
			ld (hl),d
			dec hl
			ld (hl),e
		pop hl
		pop de
	endm	
	macro z_dec_iy
		push de
		push hl
			ld hl,r_iy
			ld e,(hl)
			inc hl
			ld d,(hl)
			dec de
			ld (hl),d
			dec hl
			ld (hl),e
		pop hl
		pop de
	endm	
		macro z_inc_ix
		push de
		push hl
			ld hl,r_ix
			ld e,(hl)
			inc hl
			ld d,(hl)
			inc de
			ld (hl),d
			dec hl
			ld (hl),e
		pop hl
		pop de
	endm	
	macro z_dec_ix
		push de
		push hl
			ld hl,r_ix
			ld e,(hl)
			inc hl
			ld d,(hl)
			dec de
			ld (hl),d
			dec hl
			ld (hl),e
		pop hl
		pop de
	endm	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_sbc_hl_de
	
	push de
		push af
			ld a,d
			cpl
			ld d,a
			ld a,e
			cpl
			ld e,a
		pop af
		push af
			jr c, \@z_sbc_hl_de	
			inc de
 \@z_sbc_hl_de:
			add hl,de
		pop af
	pop de 
	
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_sbc_hl_bc
	push bc
		push af
			ld a,b
			cpl
			ld b,a
			ld a,c
			cpl
			ld c,a
		pop af
		jr c,.z_sbc_hl_de	
		inc bc
.z_sbc_hl_de
		add hl,bc
	pop bc
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_ld_bc_from,addr
	push hl
		ld hl,\addr
		ld c,(hl)
		inc hl
		ld b,(hl)
	pop hl
	endm
	macro z_ld_de_from,addr
	push hl
		ld hl,\addr
		ld c,(hl)
		inc hl
		ld b,(hl)
	pop hl
	endm
	macro z_ld_hl_from,addr
	push af
		ld hl,\addr
		ld a,(hl)
		inc hl
		ld h,(hl)
		ld l,a
	pop af
	endm
	macro z_ld_bc_to,addr
	push hl
		ld hl,\addr
		ld (hl),c
		inc hl
		ld (hl),b
	pop hl
	endm
	macro z_ld_de_to,addr
	push hl
		ld hl,\addr
		ld (hl),e
		inc hl
		ld (hl),d
	pop hl
	endm
	macro z_ld_de_hl,addr
	push af
	push hl
		ld de,\addr
		ld a,l
		ld (de),a
		inc de
		ld a,h
		ld (de),a
	pop hl
	pop af
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro gb_swapa
		swap a
	endm
	macro gb_swapb
		swap b
	endm
	macro gb_swapc
		swap c
	endm
	macro gb_swapd
		swap d
	endm
	macro gb_swape
		swap e
	endm
	macro gb_swapf
		swap f
	endm
	macro gb_swaph
		swap h
	endm
	macro gb_swapl
		swap l
	endm
	macro gb_swaphl
		swap (hl)
	endm