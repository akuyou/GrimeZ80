



GetColMemPos:
	push bc

		ld a,c
		and %11111000
		rrca
		rrca
		rrca
		or &20	;Colors start at &2000
		ld h,a
		ld a,b
		and %00011111
		rlca	
		rlca
		rlca
		ld b,a
		ld a,c
		and %00000111
		or b
		ld l,a

		call VDP_SetWriteAddress
	pop bc
	ret
	
	
CopyToVDP:
	push bc
	push hl
		ex de,hl
		call VDP_SetWriteAddress
	pop hl
	pop bc
	inc b
	inc c
CopyToVDP2:
	ld a,(hl)
	out (VdpOut_Data),a
	inc hl
	dec c
	jr nz,CopyToVDP2
	dec b
	jr nz,CopyToVDP2
	ret

ScreenINIT:
	ret
DOINIT:

	ld a, %00000010			;mode 2
	out (VdpOut_Control),a
	ld a,128+0				;0	-	-	-	-	-	-	M2	EXTVID
	out (VdpOut_Control),a

	ld a, %10000000+64		;(show screen)
	out (VdpOut_Control),a
	ld a,128+1				;1	4/16K	BL	GINT	M1	M3	-	SI	MAG
	out (VdpOut_Control),a

	ld a, %10011111			;Color table address ;%10011111=tile mode ; %11111111= bitmap mode
	out (VdpOut_Control),a
	ld a,128+3				;3	CT13	CT12	CT11	CT10	CT9	CT8	CT7	CT6
	out (VdpOut_Control),a
;in mode 2 control register #3 has a different meaning. Only bit 7 (CT13) sets the CT address. 
;Somewhat like control register #4 for the PG, bits 6 - 0 are an ANDmask over the top 7 bits of the character number.

	ld a, %00000000			;Pattern table address
	out (VdpOut_Control),a
	ld a,128+4				;4	-	-	-	-	-	PG13	PG12	PG11
	out (VdpOut_Control),a
;in mode 2 Only bit 2, PG13, sets the address of the PG (so it's either address 0 or 2000h). Bits 0 and 1 are an AND mask over the character number. The character number is 0 - 767 (2FFh) and these two bits are ANDed over the two highest bits of this value (2FFh is 10 bits, so over bit 8 and 9). So in effect, if bit 0 of control register #4 is set, the second array of 256 patterns in the PG is used for the middle 8 rows of characters, otherwise the first 256 patterns. If bit 1 is set, the third array of patterns is used in the PG, otherwise the first.
	ld a, &F0				;Text color
	out (VdpOut_Control),a
	ld a,128+7				;7	TC3	TC2	TC1	TC0	BD3	BD2	BD1	BD0
	out (VdpOut_Control),a

	ld	hl, BitmapFont
	ld	de, &0000 		; $8000
	ld	bc, 8*96		; the ASCII character set: 256 characters, each with 8 bytes of display data
	call	CopyToVDP	; load tile data	
	
	
CLS:
	ld hl,&1800
	call VDP_SetWriteAddress
	ld bc,&17FF
	;ld d,0
FillRpt:
	xor a;ld a,d
	out (VdpOut_Data),a
	dec bc
	;inc d

	ld a,b
	or c
	jr nz, FillRpt


	ld hl,&2000
	call VDP_SetWriteAddress
	ld a,0
	ld bc,&17FF
FillRptnb:
	ld a,&F0
	out (VdpOut_Data),a
	dec bc
	ld a,b
	or c
	jr nz, FillRptnb
	ret
	
VDP_SetReadAddress:
	ld C,0			;Bit 6=0 when reading, 1 when writing
	jr VDP_SetAddress
prepareVram:
VDP_SetWriteAddress:
	ld C,64
VDP_SetAddress:
	ld      a, l
        out     (VdpOut_Control), a
        ld      a, h
        or      C
        out     (VdpOut_Control), a
	ret            
