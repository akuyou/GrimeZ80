;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FillAreaWithTiles:
	;BC = X,Y)
	;HL = W,H)
	;DE = Start Tile

	ld a,h
	add b
	ld (zIXH),a

	ld a,l
	add c
	ld (zIXL),a
FillAreaWithTiles_Yagain:
	push bc
		
		push bc
			ld a,c
			ld c,b
			ld b,a
			
			ld	hl, $9800
			xor a
		
			rr b
			rra
			rr b
			rra
			rr b
			rra
			or c
			ld c,a
			add hl,bc
			
		pop bc
		
			
FillAreaWithTiles_Xagain:
		ld a,e
		ld (hl),a
		inc hl
		;ld a,d
		;out (vdpData),a

		inc de
		inc b
		ld a,(zIXH)
		cp b
		jr nz,FillAreaWithTiles_Xagain
	pop bc

	inc c
	ld a,(zIXL)
	cp c
	jr nz,FillAreaWithTiles_Yagain
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetVDPScreenPos:
	ld a,c
	ld c,b
	ld b,a
	
	ld	hl, $9800
	xor a

	rr b
	rra
	rr b
	rra
	rr b
	rra
	or c
	ld c,a
	add hl,bc
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
DefineTiles:
	ld a,(hl)
	ld (de),a
	inc hl
	inc de
	dec bc
	ld a,b
	or c
	jp nz,DefineTiles
	ret