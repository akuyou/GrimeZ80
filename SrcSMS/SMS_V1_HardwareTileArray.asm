
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
		out (vdpData),a
		ld a,d
		out (vdpData),a

		inc de
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
	out (vdpData),a
	inc hl
	dec bc
	ld a,b
	or c
	jp nz,DefineTiles
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetVDPScreenPos:	;B=Xpos, C=Ypos
	push bc
	
		ld hl,&3800		;(32x32 - 2 bytes per cell = &800)
		ld a,b
		ifdef BuildSGG
			add 6
		endif
		ld b,c
		ld c,a
	
	ifdef BuildSGG
		ld a,b
		add 3
		ld b,a
	endif

		xor a
		rr b
		rra
		rr b
		rra
;		rr b
;		rra
		rlc c
		or c
		ld c,a
		add hl,bc
		call prepareVram
	pop bc
		
	ret