ScrWid256 equ 1
org &8000




ifdef ScrWid256
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
endif
ld hl,0




ld bc,&0001
Scrollagain:
push bc
	ld a,b
	and %11111100
	rrca
	rrca
	ld b,a

	ld a,c
	and %11111100
	rrca
	rrca
	ld c,a

	call DefineCurrentGrid

pop bc
push bc

;	ld a,c
;	and %00001111
;	ld c,a

;	ld a,b
;	and %00000011
;	ld b,a

	call SetOffset

	call show
pop bc

	ld a,1
	add b
	ld b,a

	ld a,1
	add c
	ld c,a


jp Scrollagain
ret






DefineCurrentGrid:
	ld hl,Map
	ld d,0
	ld e,b		;Xpos
	add hl,de


	ld e,80

	ld a,c		;Ypos
	or a
	jp z,DefineCurrentGrid_Ydone
DefineCurrentGrid_YStart
	add hl,de	
	dec a
	jp nz,DefineCurrentGrid_YStart
DefineCurrentGrid_Ydone:
	ex hl,de


ld iy,TileGrid
ld b,13

nextGridline:
push de
push bc
	ld ixl,20
	ld a,(de)
	ld ixh,a

	ld h,a
	ld l,0
	rr h
	rr l

	rr h
	rr l




	ld (iy),l
	inc iy
	ld (iy),h
	inc iy
SetGridAgain:
	inc de
	ld a,(de)
	ld b,a
	sub ixh
	ld ixh,b
	ld h,a
	and %10000000
	ld a,%00000011
	scf
	jr nz,SetGridAgainOK
	xor a
SetGridAgainOK:

	ld l,a

	rr h
	rr l

	rr h
	rr l
;	rl l
;	rl h	

	ld bc,-4
	add hl,bc
	ld (iy),l
	inc iy
	ld (iy),h
	inc iy
dec ixl
jp nz,SetGridAgain
pop bc
pop hl
	inc iy
	inc iy
	ld de,80
	add hl,de
	ex hl,de
djnz nextGridline














SetOffset:	
	;b=x offset 0-3
	;c=y offset 0-15

;	inc c
;	dec c
;	ld a,13
;	jr z,SetTileNum
;	inc a
;SetTileNum:
;	ld (TileCount_Plus1-1),a
	ld a,c
	and %00000011
	rlca
	rlca
	neg
	add 16

;	ld a,16
;	sub c
;	ld (FirstTileLines_Plus1-1),a
	ld a,c
	and %00000011
	rlca
	rlca
ifdef ScrWid256
	sub 16
;	ld (LastTileSizeEXT_Plus2-2),a
else
	add 8
	cp 17
	jr c,NoExtraTile
	sub 16
	ld (LastTileSizeEXT_Plus2-2),a


	ld a,16
	ld (LastTileSize_Plus2-2),a

	ld a,14
	jr ExtraTileB
	
NoExtraTile:

	ld (LastTileSize_Plus2-2),a
	ld a,13

ExtraTileB:
	ld (TileCount_Plus1-1),a
endif
	ld hl,TileGrid
	ld (TileYoffset_Plus2-2),hl




	ld h,&90
	ld a,c
	and %00000011
	rlc a
	rlc a
	rlc a
	rlc a
	ld d,a

	ld a,b
	and %00000011
	add d

	ld l,a


	ld (Voffset_Plus2-2),hl

	ld hl,Changex1
	ld de,Changex2

	ld a,b
	and %00000011
	neg
	add 3

	jr z,FillPart2
	ld ixh,a

Fill0Again:
	ld a,&ED
	ld (hl),a
	inc hl
	ld a,&A0
	ld (hl),a
	inc hl

	ld a,&0
	ld (de),a
	inc de
	ld a,&0
	ld (de),a
	inc de

	dec ixh
	jr nz,Fill0Again
FillPart2:
	ld a,b
	or a
	ret z
	ld ixh,a

Fill1Again:
	ld a,&0
	ld (hl),a
	inc hl
	ld a,&0
	ld (hl),a
	inc hl

	ld a,&ED
	ld (de),a
	inc de
	ld a,&a0
	ld (de),a
	inc de

	dec ixh
	jr nz,Fill1Again

ret

Show:
	ld ixh,13	:TileCount_Plus1	;Tiles per screen
	ld de,&C000

	di
	ld (spRestore_Plus2-2),sp

	ld ixl,16	:FirstTileLines_Plus1

DoAgain:
	ld hl,12*0+&9000	:Voffset_Plus2

	ld sp,TileGrid  :TileYoffset_Plus2

	


	pop bc
	add hl,bc

Changex1:	ldi
	ldi
	ldi
	ldi
	pop bc
	add hl,bc
	ldi
	ldi
	ldi
	ldi
	pop bc
	add hl,bc
	ldi
	ldi
	ldi
	ldi
	pop bc
	add hl,bc
	ldi
	ldi
	ldi
	ldi
	pop bc
	add hl,bc
	ldi
	ldi
	ldi
	ldi
	pop bc
	add hl,bc
	ldi
	ldi
	ldi
	ldi
	pop bc
	add hl,bc
	ldi
	ldi
	ldi
	ldi
	pop bc
	add hl,bc
	ldi
	ldi
	ldi
	ldi
	pop bc
	add hl,bc
	ldi
	ldi
	ldi
	ldi
	pop bc
	add hl,bc
	ldi
	ldi
	ldi
	ldi
	pop bc
	add hl,bc
	ldi
	ldi
	ldi
	ldi
	pop bc
	add hl,bc
	ldi
	ldi
	ldi
	ldi
	pop bc
	add hl,bc
	ldi
	ldi
	ldi
	ldi
	pop bc
	add hl,bc
	ldi
	ldi
	ldi
	ldi
	pop bc
	add hl,bc
	ldi
	ldi
	ldi
	ldi
	pop bc
	add hl,bc
	ldi
	ldi
	ldi
	ldi
	pop bc
	add hl,bc
ifndef ScrWid256
	ldi
	ldi
	ldi
	ldi
	pop bc
	add hl,bc
	ldi
	ldi
	ldi
	ldi
	pop bc
	add hl,bc
	ldi
	ldi
	ldi
	ldi
	pop bc
	add hl,bc
	ldi
	ldi
	ldi
	ldi
	pop bc
	add hl,bc
endif

Changex2:	
	nop
	nop
	nop
	nop
	nop
	nop

ifdef ScrWid256
	pop bc
	pop bc
	pop bc
	pop bc
endif

	ex hl,de
ifdef ScrWid256
		ld bc,&0800-&40
else
		ld bc,&0800-&50
endif
		add hl,bc

		bit 7,h
		jp nz,GetNextLineDone
ifdef ScrWid256
			ld bc,&c040
else
			ld bc,&c050
endif

			add hl,bc

GetNextLineDone:
		ld a,(Voffset_Plus2-2)
		add 4
		and %00111111
		ld (Voffset_Plus2-2),a

	ex hl,de
	dec ixl
	jp nz,DoAgain

	ld hl,(TileYoffset_Plus2-2)
	ld bc,22*2
	add hl,bc
	ld (TileYoffset_Plus2-2),hl

	pop bc

	ld ixl,c

	dec ixh
	jp nz,DoAgain

	ld sp,&0000:spRestore_Plus2
	ei
ret

align 256
TileGrid:
;21 wide x 14 high
dw 0,1*64-4,2*64-4,-4,-1*64-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,1*64-4,-4,-4,-1*64-4,-1*64-4,-4,-4		,16
dw 0,1*64-4,1*64-4,-4,-1*64-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4				,16
dw 0,1*64-4,2*64-4,-4,-1*64-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,1*64-4,-4,-4,-1*64-4,-1*64-4,-4,-4		,16
dw 0,1*64-4,1*64-4,-4,-1*64-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4				,16
dw 0,1*64-4,1*64-4,-4,-1*64-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4				,16
dw 0,1*64-4,1*64-4,-4,-1*64-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4				,16

dw 0,1*64-4,1*64-4,-4,-1*64-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4				,16
dw 0,1*64-4,1*64-4,-4,-1*64-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4				,16
dw 0,1*64-4,1*64-4,-4,-1*64-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4				,16
dw 0,1*64-4,1*64-4,-4,-1*64-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4				,16
dw 0,1*64-4,1*64-4,-4,-1*64-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4				,16
dw 0,1*64-4,2*64-4,-4,-1*64-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,1*64-4,-4,-4,-1*64-4,-1*64-4,-4,-4		,16	:LastTileSize_Plus2

dw 0,1*64-4,1*64-4,-4,-1*64-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4				,0	:LastTileSizeEXT_Plus2
dw 0,1*64-4,2*64-4,-4,-1*64-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,1*64-4,-4,-4,-1*64-4,-1*64-4,-4,-4		,0



Map:
  ;0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9
db 0,1,1,1,2,2,1,2,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,0,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,0,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1
db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,0,2,2,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,0,0,0,2,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,0,0,2,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,0,2,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,2,2,2,2,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


org &8F00
incbin "..\ResCPC\test-tiles.SPR"





ifdef ScrWid256
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
endif

