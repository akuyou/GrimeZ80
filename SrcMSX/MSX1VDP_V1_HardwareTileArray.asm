
FillAreaWithTiles:
	;BC = X,Y)
	;HL = W,H)
	;DE = Start Tile

	
	ld a,h
	add b
	ld h,a
	
	ld a,l
	add c
	ld l,a
FillAreaWithTiles_Yagain:
	push bc

		push de
		push hl
			call GetVDPScreenPos
		pop hl
		pop de
			
FillAreaWithTiles_Xagain:
		ld a,e
		out (VdpOut_Data),a
		inc e
		inc b
		ld a,b
		cp h
		jr nz,FillAreaWithTiles_Xagain
	pop bc

	inc c
	ld a,c
	cp l
	jr nz,FillAreaWithTiles_Yagain

	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DefineTiles:
;RawSpriteFill
	ld a,(hl)
	out (VdpOut_Data),a
	inc hl
	dec bc
	ld a,b
	or c
	jp nz,DefineTiles
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetVDPScreenPos:	;B=Xpos, C=Ypos
	push bc
		ld h,0
		ld l,c
		or a
		rl l
		rl h
		rl l
		rl h
		rl l
		rl h
		rl l
		rl h
		rl l
		rl h
		ld a,l
		or b
		ld l,a
		ld a,h
		or &18
		ld h,a
		call VDP_SetWriteAddress
	pop bc
		
	ret