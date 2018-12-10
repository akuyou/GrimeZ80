
DefineTiles:
CopyTilesToVdp:
	push de
	push bc
		ld a,(hl)
		push hl
			ld (Tile_MyHMMCByte),a
			
				ld a,e
				and %00011111
				rlca
				rlca
				rlca
				ld (Tile_MyHMMC_DX),a
				ld a,e
				and %11100000
				rr d
				rr a
				rr d
				rr a
				ld (Tile_MyHMMC_DY),a
			

			di
			call VDP_FirmwareSafeWait	
			ld hl,Tile_MyHMMC
			call VDP_HMMC_Generated
			ei

		pop hl
	pop bc
	pop de
	
	inc hl
	dec bc
CopyTilesToVdp_Again:		
	ld a,(hl)
	out (Vdp_SendByteData),a
	
	inc hl
	dec bc
	ld a,b
	or c
	ret z

	ld a,c
	and %00011111
	jr z,CopyTilesToVdp_NextTile

	jp CopyTilesToVdp_Again
CopyTilesToVdp_NextTile
	inc de
	jp CopyTilesToVdp

CopyBWTilesToVdp:		;HL=source,DE=XY dest (in 8x8 tiles),bc=bytes

	push de
	push bc
		ld b,(hl)
		xor a
		rl b
		rla
		rlca
		rlca
		rlca
		rl b
		rl a
		ld c,a
		rlca
		or c
		rlca
		or c
		rlca
		or c
				
				
		
		push hl
			ld (Tile_MyHMMCByte),a
			
				ld a,e
				and %00011111
				rlca
				rlca
				rlca
				ld (Tile_MyHMMC_DX),a
				ld a,e
				and %11100000
				rr d
				rr a
				rr d
				rr a
				ld (Tile_MyHMMC_DY),a
			
			di
			call VDP_FirmwareSafeWait	
			ld hl,Tile_MyHMMC
			call VDP_HMMC_Generated
			ei

		pop hl
	pop bc
	
	push bc
			ld b,(hl)
			; ld b,a				;2 pixels per byte - so lots of shifting!
			; xor a
			 rl b
			; rla
			; rlca
			; rlca
			; rlca
			 rl b
			; rl a
			; ld c,a
			; rlca
			; or c
			; rlca
			; or c
			; rlca
			; or c
			; out (VdpOut_Data),a
			
			xor a
			rl b
			rla
			rlca
			rlca
			rlca
			rl b
			rl a
			ld c,a
			rlca
			or c
			rlca
			or c
			rlca
			or c
			out (Vdp_SendByteData),a
			xor a
			rl b
			rla
			rlca
			rlca
			rlca
			rl b
			rl a
			ld c,a
			rlca
			or c
			rlca
			or c
			rlca
			or c
			out (Vdp_SendByteData),a
			xor a
			rl b
			rla
			rlca
			rlca
			rlca
			rl b
			rl a
			ld c,a
			rlca
			or c
			rlca
			or c
			rlca
			or c
			out (Vdp_SendByteData),a
	pop bc
	pop de
	inc hl
	dec bc
CopyBWTilesToVdp_Again:		
	push de
	push bc
			ld b,(hl)
			
			xor a
			rl b
			rla
			rlca
			rlca
			rlca
			rl b
			rl a
			ld c,a
			rlca
			or c
			rlca
			or c
			rlca
			or c
			out (Vdp_SendByteData),a
			xor a
			rl b
			rla
			rlca
			rlca
			rlca
			rl b
			rl a
			ld c,a
			rlca
			or c
			rlca
			or c
			rlca
			or c
			out (Vdp_SendByteData),a
			xor a
			rl b
			rla
			rlca
			rlca
			rlca
			rl b
			rl a
			ld c,a
			rlca
			or c
			rlca
			or c
			rlca
			or c
			out (Vdp_SendByteData),a
			xor a
			rl b
			rla
			rlca
			rlca
			rlca
			rl b
			rl a
			ld c,a
			rlca
			or c
			rlca
			or c
			rlca
			or c
			out (Vdp_SendByteData),a
	pop bc
	pop de
	
	
	inc hl
	dec bc
	ld a,b
	or c
	ret z
	
	
	ld a,c
	and %00000111
	jr z,CopyBWTilesToVdp_NextTile

	jp CopyBWTilesToVdp_Again
CopyBWTilesToVdp_NextTile:
	inc de
	jp CopyBWTilesToVdp

Tile_MyHMMC:
Tile_MyHMMC_DX:	defw &0000 ;DX 36,37
Tile_MyHMMC_DY:	defw &0200 ;DY 38,39
Tile_MyHMMC_NX:	defw &0008 ;NX 40,41
Tile_MyHMMC_NY:	defw &0008 ;NY 42,43
Tile_MyHMMCByte:	defb 255   ;Color 44
	defb 0     ;Move 45
	defb %11110000 ;Command 46	

CopyTileToScreen:	;HL=Tilenum -> DE=XY

	ld a,L
	and %00011111
	rlca
	rlca
	rlca
	ld (Tile_MyHMMM_SX),a
	ld a,l
	and %11100000
	rr h
	rr a
	rr h
	rr a
	ld (Tile_MyHMMM_SY),a
	ld a,d
	rlca
	rlca
	rlca
	ld (Tile_MyHMMM_DX),a
	
	ld a,e
	rlca
	rlca
	rlca
	ld (Tile_MyHMMM_DY),a
	di
	call VDP_FirmwareSafeWait	
	ld hl,Tile_MyHMMM
	call VDP_HMMM
	ei
	ret
	
	
Tile_MyHMMM:
Tile_MyHMMM_SX:	defw &0000 ;SY 32,33
Tile_MyHMMM_SY:	defw &0200 ;SY 34,35
Tile_MyHMMM_DX:	defw &0000 ;DX 36,37
Tile_MyHMMM_DY:	defw &0000 ;DY 38,39
Tile_MyHMMM_NX:	defw &0008 ;NX 40,41 
Tile_MyHMMM_NY:	defw &0008 ;NY 42,43
		defb 0     ;Color 44 - unused
Tile_MyHMMM_MV:	defb 0     ;Move 45
		defb %11010000 ;Command 46	


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

		
			
FillAreaWithTiles_Xagain:
		push bc
		push de
		push hl
			ld 	h,0
			ld  l,e
			ld  d,b
			ld  e,c
			call CopyTileToScreen
		pop hl
		pop de
		pop bc

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