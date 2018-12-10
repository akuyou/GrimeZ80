org &8000

tilewidth equ 17;equ 9;17
tileheight equ 13;equ 7;13
YResetMove equ -192*8;-tileheight+1*16*8;-192*8

Start:
	ld hl,crtc_vals
	ld bc,&bc00
	set_crtc_vals:
	out (c),c
	inc b
	ld a,(hl)
	out (c),a
	dec b
	inc hl
	inc c
	ld a,c
	cp 14
	jr nz,set_crtc_vals





DoAgain:
	ld bc,&0303 :TileFlipTest_Plus1
	call DefineCurrentGrid


ShowAgain:
	ld (TileSPRestore_Plus2-2),sp
	di


	ld hl,&C000;+&10

	ld a,tilewidth
	ld (TileXCounter_Plus1-1),a
	ld sp,TileGrid
	ld bc,&c008	;Jumps and Junk

TileAgainX:
	ld a,4	:FirstLineSize_Plus1
	ld iyh,tileheight
	
TileAgainY:

	pop de
	pop ix

	ld (TileDERestore_Plus2-2),sp


	dec iyh
	jr nz,NotLastLine
	ld a,2:LastLineSize_Plus1
	or a
	jr z,TileYDone
NotLastLine:
	inc iyh
	ex hl,de
	jp (hl)
TiledrawResume:		
	ld sp,&0000:TileDERestore_Plus2
	ld a,4	;TileHeight

	dec iyh
	jp nz,TileAgainY
TileYDone:
	pop de
	add hl,de


	ld a,tilewidth :TileXCounter_Plus1
	dec a
	ld (TileXCounter_Plus1-1),a
	jp nz,TileAgainX
	
TileFinish:
	ld a,(TileFlipTest_Plus1-2)
	add 1
	ld (TileFlipTest_Plus1-2),a
	ld a,(TileFlipTest_Plus1-1)
	add 1
	ld (TileFlipTest_Plus1-1),a

	ld sp,&0000:TileSPRestore_Plus2
	ei
;ret
jp DoAgain

NoTile:
pop de
jp TileFinish


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
XfillerLookup:

	defw NoTile	;r
	defw TileFill	;c
	defw TileFill	;l

	defw TileFill1
	defw TileFill
	defw TileFill3L

	defw TileFill2
	defw TileFill
	defw TileFill2L

	defw TileFill3
	defw TileFill
	defw TileFill1L


	defw null
	defw null
	defw null
	defw null

	defw NoTile
	defw FloodFill
	defw FloodFill

	defw FloodFill1
	defw FloodFill
	defw FloodFill3

	defw FloodFill2
	defw FloodFill
	defw FloodFill2

	defw FloodFill3
	defw FloodFill
	defw FloodFill1

	defw null
	defw null
	defw null
	defw null

	defw NoTile
	defw GradientFill
	defw GradientFill

	defw GradientFill1
	defw GradientFill
	defw GradientFill3

	defw GradientFill2
	defw GradientFill
	defw GradientFill2

	defw GradientFill3
	defw GradientFill
	defw GradientFill1







DefineCurrentGrid:
	;BC=XY

	ld a,c
	and %00000011

	push af
		ld (LastLineSize_Plus1-1),a
		neg
		add 3
		inc a
		ld (FirstLineSize_Plus1-1),a
	pop af
	rlca
	rlca
	rlca
	rlca
	ld (FirstLineOffset_Plus1-1),a

	ld a,b
	and %00000011
	push af
		ld hl,XfillerLookup
		rlca
		ld d,0
		ld e,a
		add hl,de
		add hl,de
		add hl,de
	pop af

	neg
	add 4
	ld (XposTileOffset_Plus1-1),a



	ld (XFiller2_Plus2-2),hl



;	ld hl,Map
;	ld d,0
	ld a,c
	and %11111100
	rrca
	rrca
	add tilewidth
	ld (CXpos_Plus1-1),a
;	ld e,a		;Xpos
;	add hl,de
;

;	ld e,80

	ld a,b		;Ypos
	and %11111100
	rrca
	rrca
	add tileheight
	ld (CYpos_Plus1-1),a

;	jp z,DefineCurrentGrid_Ydone
;DefineCurrentGrid_YStart
;	add hl,de	
;	dec a
;	jp nz,DefineCurrentGrid_YStart
;DefineCurrentGrid_Ydone
;	ex hl,de

ld (GridSPRestore_Plus2-2),sp
di
ld sp,TileGrid+2
;ld iy,TileGrid
;ld b,tilewidth
ld iyl,tilewidth
nextGridline:


	ld a,0:FirstLineOffset_Plus1
	ld (SPPosOffsetB_Plus1-1),a
	
	ld ixl,tileheight
SetGridAgain:
;	push bc
		ld hl,map
		ld a,tileheight	:CYpos_Plus1
		sub ixl;y

		ld b,a
		and %00011100	;8 blocks vertically
		rlca
		rlca
		rlca		;8 block Shift Left
		ld e,a
		ld a,b
		and %00000011
		ld ixh,a
		ld a,tilewidth	:CXpos_Plus1
		sub iyl;x

		ld c,a
		and %11111100

		rrca
		rrca
		ld d,a


		rr d
		rr e

		rr d
		rr e

		rr d
		rr e

		rr d
		rr e

		rr d
		rr e

		add hl,de	;TileBlock
		ld a,(hl)
		ld d,0
		ld e,a	
		rl e		;16 bytes to a tileblock def
		rl d
		rl e
		rl d
		rl e
		rl d
		rl e
		rl d			
		ld hl,TileDefs
		add hl,de


		ld d,0
		ld a,c;iyl
		and %00000011
		rlca
		rlca
		ld e,a
		ld a,b;ixl
		and %00000011
		or e
		ld e,a
		add hl,de
		ex hl,de
		
SetGridAgainSameY:

		ld a,(de)		;00=normal
		and %11000000		;01=Fill
		rrca

		ld h,0
		ld l,a

;	pop bc
	ld a,iyl
;	push bc
;	ld (BCrestore_Plus2-2),bc

	ld bc,TileFill1				:XFiller2_Plus2

	cp 1
	jr z,SetGridAgainTilePicked
	inc bc
	inc bc
;;	ld bc,TileFill				XFiller0_Plus2
	cp tilewidth
	jr nz,SetGridAgainTilePicked

	inc bc
	inc bc
;	ld bc,TileFill3L			XFiller1_Plus2


SetGridAgainTilePicked:
	add hl,bc
	ld c,(hl)
	inc hl
	ld b,(hl)

	push bc
	pop bc
	pop bc
;	inc sp
;	inc sp
;	inc sp
;	inc sp

;	ld (iy),c
;	inc iy
;	ld (iy),b
;	inc iy

	ld a,(de)
	and %00111111


	ld h,a
	ld l,0
	
	or a

	rr h
	rr l

	rr h
	rr l




	ld a,&90
	add h
	ld h,a



	ld a,(de)
	and %11000000
	cp 128
	jr z,GridGradient
	cp 64
	jr nz,NotFilled

	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	jr GridModsDone
GridGradient:
	ld a,(SPPosOffsetB_Plus1-1)
	rrca
	rrca
	add l
	ld l,a
	jr GridModsDone
NotFilled:
	ld a,0	:SPPosOffsetB_Plus1
	add l
	ld l,a
GridModsDone:

;	ld (iy),l
;	inc iy
;	ld (iy),h
;	inc iy

	push hl
	pop hl
	pop hl
;	inc sp
;	inc sp
;	inc sp
;	inc sp

	xor a
	ld (SPPosOffsetB_Plus1-1),a
	
	dec ixl
	jr z,GridYdone
;	ld a,ixl
;	and %00000011
	dec ixh
	jr z,setGridAgainSameY

;	pop bc
;	ld bc,&0000BCrestore_Plus2
	inc de
jp SetGridAgain
GridYdone:
	ld hl,YresetMove+4


	ld a,iyl
	cp tilewidth
	jr nz,NextLineShift
	ld l,00+3			:XposTileOffset_Plus1
NextLineShift:

;	ld (iy),l
;	inc iy
;	ld (iy),h
;	inc iy

	push hl
	pop hl
	pop hl
;	inc sp
;	inc sp
;;	inc sp
;	inc sp

	
	ld hl,80-tileheight
	add hl,de
	ex hl,de

	dec iyl
jp nz, nextGridline
ld sp,&0000:GridSPRestore_Plus2
ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


TileFill:
	ld iyl,a
	ex hl,de
	ld sp,ix
TileFillAgain:
	pop de
	ld (hl),e		;1
	inc l
	ld (hl),d
	inc l
	pop de
	ld (hl),e
	inc l
	ld (hl),d


	ld a,h
	add c
	ld h,a

	pop de
	ld (hl),e		;2
	dec l
	ld (hl),d
	dec l
	pop de
	ld (hl),e
	dec l
	ld (hl),d

	ld a,h
	add c
	ld h,a

	pop de
	ld (hl),e		;3
	inc l
	ld (hl),d
	pop de
	inc l
	ld (hl),e
	inc l
	ld (hl),d


	ld a,h
	add c
	ld h,a

	pop de
	ld (hl),e		;4
	dec l
	ld (hl),d
	dec l
	pop de
	ld (hl),e
	dec l
	ld (hl),d

	ld a,h
	add c
	ld h,a
	bit 7,h
	jp nz,Tile_GetNextLineDone2

		ld c,&40
		add hl,bc
		ld c,&08
Tile_GetNextLineDone2:

	dec iyl
	jp nz,TileFillAgain
jp TiledrawResume
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


TileFill3:
	rlca
	ld iyl,a

	ex hl,de
	ld sp,ix
Tile3FillAgain:
	pop de
	ld (hl),e		;1
	inc l
	ld (hl),d
	inc l
	pop de
	ld (hl),e
;	inc l
;	ld (hl),e


	ld a,h
	add c
	ld h,a

	pop de
	ld (hl),d		;2
	pop de
	dec l
	ld (hl),e
	dec l

	ld (hl),d
;	dec l
;	ld (hl),d

	ld a,h
	add c
	ld h,a
	bit 7,h
	jp nz,Tile3_GetNextLineDone2
		ld c,&40
		add hl,bc
		ld c,&08
Tile3_GetNextLineDone2:

	dec iyl
	jp nz,Tile3FillAgain

jp TiledrawResume
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


TileFill3L:
	rlca
	ld iyl,a

	ex hl,de
	ld sp,ix
Tile3LFillAgain:
	pop de
	ld (hl),d		;1
	inc l
	pop de
	ld (hl),e
	inc l

	ld (hl),d
;	inc l
;	ld (hl),e


	ld a,h
	add c
	ld h,a

	pop de
	ld (hl),e
	dec l
	ld (hl),d
	dec l
	pop de
	ld (hl),e
;	dec l
;	ld (hl),d

	ld a,h
	add c
	ld h,a
	bit 7,h
	jp nz,Tile3L_GetNextLineDone2
		ld c,&40
		add hl,bc
		ld c,&08
Tile3L_GetNextLineDone2:

	dec iyl
	jp nz,Tile3LFillAgain
jp TiledrawResume
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TileFill2L:
	rlca
	ld iyl,a

	ex hl,de
	ld sp,ix
Tile2LFillAgain:
	pop de
	pop de
	ld (hl),e		;1
	inc l
	ld (hl),d




	ld a,h
	add c
	ld h,a


	pop de
	ld (hl),e		;2
	dec l
	ld (hl),d
;	dec l
	pop de
;	ld (hl),e
;	dec l
;	ld (hl),d

	ld a,h
	add c
	ld h,a
	bit 7,h
	jp nz,Tile2L_GetNextLineDone2
		ld c,&40
		add hl,bc
		ld c,&08
Tile2L_GetNextLineDone2:

	dec iyl
	jp nz,Tile2LFillAgain
jp TiledrawResume
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


TileFill2:
	rlca
	ld iyl,a

	ex hl,de
	ld sp,ix
Tile2FillAgain:
	pop de
	ld (hl),e		;1
	inc l
	ld (hl),d
;	inc l
	pop de

	ld a,h
	add c
	ld h,a
	pop de
	pop de
	ld (hl),e		;2
	dec l
	ld (hl),d

	ld a,h
	add c
	ld h,a
	bit 7,h
	jp nz,Tile2_GetNextLineDone2
		ld c,&40
		add hl,bc
		ld c,&08
Tile2_GetNextLineDone2:

	dec iyl
	jp nz,Tile2FillAgain
jp TiledrawResume
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


TileFill1L:
	rlca
	ld iyl,a

	ex hl,de
	ld sp,ix
Tile1LFillAgain:
	pop de
	pop de
	ld (hl),d		;1



	ld a,h
	add c
	ld h,a
	pop de
	ld (hl),e		;1


	pop de

	ld a,h
	add c
	ld h,a
	bit 7,h
	jp nz,Tile1L_GetNextLineDone2
		ld c,&40
		add hl,bc
		ld c,&08
Tile1L_GetNextLineDone2:

	dec iyl
	jp nz,Tile1LFillAgain
jp TiledrawResume
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


TileFill1:
	rlca
	ld iyl,a

	ex hl,de
	ld sp,ix
Tile1FillAgain:
	pop de
	ld (hl),e		;1
	pop de

	ld a,h
	add c
	ld h,a

	pop de
	pop de
	ld (hl),d		;2

	ld a,h
	add c
	ld h,a
	bit 7,h
	jp nz,Tile1_GetNextLineDone2
		ld c,&40
		add hl,bc
		ld c,&08
Tile1_GetNextLineDone2:

	dec iyl
	jp nz,Tile1FillAgain
jp TiledrawResume
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FloodFill:
	ld iyl,a
	ex hl,de
	ld d,ixh
	ld e,ixl
FloodFillAgain:

	ld (hl),d		;1
	inc l
	ld (hl),d
	inc l
	ld (hl),d
	inc l
	ld (hl),d


	ld a,h
	add c
	ld h,a

	ld (hl),e		;2
	dec l
	ld (hl),e
	dec l
	ld (hl),e
	dec l
	ld (hl),e

	ld a,h
	add c
	ld h,a

	ld (hl),d		;3
	inc l
	ld (hl),d
	inc l
	ld (hl),d
	inc l
	ld (hl),d


	ld a,h
	add c
	ld h,a

	ld (hl),e		;4
	dec l
	ld (hl),e
	dec l
	ld (hl),e
	dec l
	ld (hl),e


	ld a,h
	add c
	ld h,a
	bit 7,h
	jp nz,Fill_GetNextLineDone
		ld c,&40
		add hl,bc
		ld c,&08
Fill_GetNextLineDone:
	dec iyl
	jp nz,FloodFillAgain

jp TiledrawResume

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FloodFill2:
	rlca
	ld iyl,a

	ex hl,de
	ld d,ixh
	ld e,ixl
FloodFillAgain2:


	ld (hl),d		;1
	inc l
	ld (hl),d
;	inc l
;	ld (hl),d
;	inc l
;	ld (hl),e


	ld a,h
	add c
	ld h,a

	ld (hl),e		;2
	dec l
	ld (hl),e
;	dec l
;	ld (hl),e
;	dec l
;	ld (hl),d

	ld a,h
	add c
	ld h,a
	bit 7,h
	jp nz,Fill_GetNextLineDone2
		ld c,&40
		add hl,bc
		ld c,&08
Fill_GetNextLineDone2:
	dec iyl
	jp nz,FloodFillAgain2

jp TiledrawResume

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FloodFill1:
	rlca
	ld iyl,a

	ex hl,de

	ld d,ixh
	ld e,ixl
FloodFillAgain1:



	ld (hl),d		;1
;	inc l
;	ld (hl),e
;	inc l
;	ld (hl),d
;	inc l
;	ld (hl),e


	ld a,h
	add c
	ld h,a

	ld (hl),e		;2
;	dec l
;	ld (hl),d
;	dec l
;	ld (hl),e
;	dec l
;	ld (hl),d

	ld a,h
	add c
	ld h,a
	bit 7,h
	jp nz,Fill_GetNextLineDone1
		ld c,&40
		add hl,bc
		ld c,&08
Fill_GetNextLineDone1:
	dec iyl
	jp nz,FloodFillAgain1

jp TiledrawResume

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FloodFill3:

	rlca
	ld iyl,a

	ex hl,de

	ld d,ixh
	ld e,ixl

FloodFillAgain3:

	ld (hl),d		;1
	inc l
	ld (hl),d
	inc l
	ld (hl),d
;	inc l
;	ld (hl),e


	ld a,h
	add c
	ld h,a

	ld (hl),e		;2
	dec l
	ld (hl),e
	dec l
	ld (hl),e
;	dec l
;	ld (hl),d

	ld a,h
	add c
	ld h,a
	bit 7,h
	jp nz,Fill_GetNextLineDone3
		ld c,&40
		add hl,bc
		ld c,&08
Fill_GetNextLineDone3:
	dec iyl
	jp nz,FloodFillAgain3

jp TiledrawResume

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GradientFill:
	ld iyl,a
	ex hl,de
	ld sp,ix
GradientFillAgain:
	pop de
	ld (hl),e		;1
	inc l
	ld (hl),e
	inc l
	ld (hl),e
	inc l
	ld (hl),e


	ld a,h
	add c
	ld h,a

	ld (hl),d		;2
	dec l
	ld (hl),d
	dec l
	ld (hl),d
	dec l
	ld (hl),d

	ld a,h
	add c
	ld h,a

	pop de
	ld (hl),e		;3
	inc l
	ld (hl),e
	inc l
	ld (hl),e
	inc l
	ld (hl),e


	ld a,h
	add c
	ld h,a

	ld (hl),d		;4
	dec l
	ld (hl),d
	dec l
	ld (hl),d
	dec l
	ld (hl),d

	ld a,h
	add c
	ld h,a
	bit 7,h
	jp nz,GradientFill_GetNextLineDone
		ld c,&40
		add hl,bc
		ld c,&08
GradientFill_GetNextLineDone:
	dec iyl
	jp nz,GradientFillAgain

jp TiledrawResume
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GradientFill3:
	rlca
	ld iyl,a
	ex hl,de
	ld sp,ix
GradientFill3Again:
	pop de
	ld (hl),e		;1
	inc l
	ld (hl),e
	inc l
	ld (hl),e
;	inc l
;	ld (hl),e


	ld a,h
	add c
	ld h,a

	ld (hl),d		;2
	dec l
	ld (hl),d
	dec l
	ld (hl),d
;	dec l
;	ld (hl),d

	ld a,h
	add c
	ld h,a
	bit 7,h
	jp nz,GradientFill3_GetNextLineDone
		ld c,&40
		add hl,bc
		ld c,&08
GradientFill3_GetNextLineDone:
	dec iyl
	jp nz,GradientFill3Again

jp TiledrawResume

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GradientFill2:
	rlca
	ld iyl,a
	ex hl,de
	ld sp,ix
GradientFill2Again:
	pop de
	ld (hl),e		;1
	inc l
	ld (hl),e
;	inc l
;	ld (hl),e
;	inc l
;	ld (hl),e


	ld a,h
	add c
	ld h,a

	ld (hl),d		;2
	dec l
	ld (hl),d
;	dec l
;	ld (hl),d
;	dec l
;	ld (hl),d

	ld a,h
	add c
	ld h,a
	bit 7,h
	jp nz,GradientFill2_GetNextLineDone
		ld c,&40
		add hl,bc
		ld c,&08
GradientFill2_GetNextLineDone:
	dec iyl
	jp nz,GradientFill2Again

jp TiledrawResume

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GradientFill1:
	rlca
	ld iyl,a
	ex hl,de
	ld sp,ix
GradientFill1Again:
	pop de
	ld (hl),e		;1
;	inc l
;	ld (hl),e
;	inc l
;	ld (hl),e
;	inc l
;	ld (hl),e


	ld a,h
	add c
	ld h,a

	ld (hl),d		;2
;	dec l
;	ld (hl),d
;	dec l
;	ld (hl),d
;	dec l
;	ld (hl),d

	ld a,h
	add c
	ld h,a
	bit 7,h
	jp nz,GradientFill1_GetNextLineDone
		ld c,&40
		add hl,bc
		ld c,&08
GradientFill1_GetNextLineDone:
	dec iyl
	jp nz,GradientFill1Again

jp TiledrawResume


org &9000
incbin "..\ResCPC\test-tiles.SPR"





	crtc_vals:
	defb &3f					;; R0 - Horizontal Total
	defb 32	      					;; R1 - Horizontal Displayed  (32 chars wide)
	defb 42						;; R2 - Horizontal Sync Position (centralises screen)
	defb &86					;; R3 - Horizontal and Vertical Sync Widths
	defb 38						;; R4 - Vertical Total
	defb 0						;; R5 - Vertical Adjust
	defb 24						;; R6 - Vertical Displayed (24 chars tall)
	defb 31						;; R7 - Vertical Sync Position (centralises screen)
	defb 0						;; R8 - Interlace
	defb 7						;; R9 - Max Raster 
	defb 0						;; R10 - Cursor (not used)
	defb 0						;; R11 - Cursor (not used)
	defb &30  					;; R12 - Screen start (start at &c000)
	defb &00  					;; R13 - Screen start



TileGrid:
defs 4*17*13	;space for addresses
	
defs 17*2	;space for line corrections


null:
ret

org &9600
Map:
db 4,4,4,4,0,0,0,0
db 4,2,1,4,1,2,1,2
db 4,0,0,0,0,0,0,0
db 4,2,1,2,1,2,1,2
db 4,0,0,0,0,0,0,0
db 4,2,1,2,1,2,1,2
db 4,0,0,0,0,0,0,0
db 4,0,0,0,0,0,0,0







org &9700
TileDefs:
db 1,1,1,1
db 1,0,0,1
db 1,0,0,1
db 1,1,1,1

db 0,0,0,0
db 0,2,2,0
db 0,2,2,0
db 0,0,0,0


db 0,1,1,0
db 1,2,1,1
db 1,1,2,1
db 0,1,1,0

db 64+64+3,64+64+3,64+64+3,64+64+3
db 64+64+3,64+64+3,64+64+3,64+64+3
db 64+64+3,64+64+3,64+64+3,64+64+3
db 64+64+3,64+64+3,64+64+3,64+64+3

db 64+0,64+0,64+0,64+0
db 64+0,64+0,64+0,64+0
db 64+0,64+0,64+0,64+0
db 64+0,64+0,64+0,64+0


db 64+3,128+4,1,1,2,2,1,2,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,64+3,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,64+3,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1
db 1,64+64+3,64+64+3,64+64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,64+3,64+3,64+3,64+3,64+3
db 1,64+3,2,2,64+3,64+3,64+3,64+3,1,1,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,128+4,1,1,2,2,1,2,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,64+3,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,64+3,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1
db 1,64+64+3,64+64+3,64+64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,64+3,64+3,64+3,64+3,64+3
db 1,64+3,2,2,64+3,64+3,64+3,64+3,1,1,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,128+4,1,1,2,2,1,2,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,64+3,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,64+3,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1
db 1,64+64+3,64+64+3,64+64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,64+3,64+3,64+3,64+3,64+3
db 1,64+3,2,2,64+3,64+3,64+3,64+3,1,1,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,128+4,1,1,2,2,1,2,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,64+3,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,64+3,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1
db 1,64+64+3,64+64+3,64+64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,64+3,64+3,64+3,64+3,64+3
db 1,64+3,2,2,64+3,64+3,64+3,64+3,1,1,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,128+4,1,1,2,2,1,2,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,64+3,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,64+3,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1
db 1,64+64+3,64+64+3,64+64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,64+3,64+3,64+3,64+3,64+3
db 1,64+3,2,2,64+3,64+3,64+3,64+3,1,1,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,128+4,1,1,2,2,1,2,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,64+3,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,64+3,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1
db 1,64+64+3,64+64+3,64+64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,64+3,64+3,64+3,64+3,64+3
db 1,64+3,2,2,64+3,64+3,64+3,64+3,1,1,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,128+4,1,1,2,2,1,2,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,64+3,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,64+3,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1
db 1,64+64+3,64+64+3,64+64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,64+3,64+3,64+3,64+3,64+3
db 1,64+3,2,2,64+3,64+3,64+3,64+3,1,1,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,128+4,1,1,2,2,1,2,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,64+3,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,64+3,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1
db 1,64+64+3,64+64+3,64+64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,64+3,64+3,64+3,64+3,64+3
db 1,64+3,2,2,64+3,64+3,64+3,64+3,1,1,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3
db 64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3,64+3