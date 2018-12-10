
VScreen_MinY equ 32
VScreen_MinX equ 40

VScreen_MaxY equ 224
VScreen_MaxX equ 168


;***************************************************************************************************
; Virtual Screen pos

	; Input 	B=VitrualX ;C=VirtualY

	; output 	B=ScreenByteX ;C=ScreenY	Y=255 if ofscreen
	;		H X bytes to skip	L	X bytes to remove
	;		D Y lines to skip	E	Y lines to remove
;***************************************************************************************************


; The virtual screen has a resolution of 160x200, with a 24 pixel border, which is used for clipping
; Y=0 is used by the code to denote a 'dead' object which will be deleted from the list
VirtualPosToScreenByte:


	ld HL,&0000
	ld D,h
	ld e,h

	; we use a virtual screen size
	; X width is 208	(160 onscreen - 2 per byte)
	; Y height is  248	(200 onscreen - 1 per line)

	; this is to allow for partially onscreen sprites	
	; and to keep co-ords in 1 byte
	; X<24 or x>=184 is not drawn
	; Y<24 or Y>=224 is not drawn
	;
	; only works with 24 pixel sprites
	ld a,B	;Check X
	cp VScreen_MinX 
	jp NC,VirtualPos_1	; jp is faster if we expect it to be true!
; X<24
	ld a,VScreen_MinX
	sub a,B

;	RRA
;	SRL A	; Extra for spectrum screen
	RLA	; MSX

	ld H,A	;move the sprite A left
	ld L,A	;need to plot A less bytes

	ld B,VScreen_MinX 	 ;B was offscreen, so move it back on
	jp VirtualPos_2
VirtualPos_1:
	;ld a,B	;Check X
	cp VScreen_MaxX -12 :SpriteSizeConfig184less12_Plus1
	jp C,VirtualPos_2
; X>184
	;push B
	ld a,B
	sub VScreen_MaxX -12 :SpriteSizeConfig184less12B_Plus1

;	RRA	; Extra for spectrum screen
;	SRL A	; Extra for spectrum screen
	RLA	; MSX
;	pop B

	add L	;	X pos is ok, but plot A less bytes
	ld L,A
	;ld a,B	;Check X
VirtualPos_2:
	ld a,B	;Check X
	sub VScreen_MinX  ;SpriteSizeConfig24C_Plus1
;	RRA	; halve the result, as we have 80 bytes, but 160 x co-ords
;	SRL A	; Extra for spectrum screen
	RLA	; MSX
	ld B,a	
;-------------------------------------------------------------------------
	ld a,C	;Check Y
	cp VScreen_MinY  ;SpriteSizeConfig24D_Plus1
	jp NC,VirtualPos_3
; Y<24
	ld a,VScreen_MinY  ;SpriteSizeConfig24E_Plus1
	sub a,C
	ld D,A	;move the sprite A up
	ld E,A	;need to plot A less lines
	ld C,VScreen_MinY  ;SpriteSizeConfig24F_Plus1
	jp VirtualPos_4
VirtualPos_3:
	;ld a,C	;Check Y
	cp VScreen_MaxY -24 :SpriteSizeConfig224less24_Plus1
	jp C,VirtualPos_4
; Y>224
	ld a,C
	sub VScreen_MaxY -24 :SpriteSizeConfig224less24B_Plus1
	ld E,A
VirtualPos_4:
	ld a,C	;Check Y
	sub VScreen_MinY  ;SpriteSizeConfig24G_Plus1
	ld C,a
	ret	



;---------------------------------------------------------------------------


ShowSpriteReconfigureEnableDisable:
;	ld hl,null
	or a
	jr z,ShowSpriteReconfigureEnableDisableB
;	ld hl,ShowSpriteReconfigure	
ShowSpriteReconfigureEnableDisableB:
;	ld (ShowSpriteReconfigureCommand_Plus2-2),hl
	jr ShowSpriteReconfigure_24px
ShowSpriteReconfigure:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Fix your sprite editor dagnammit!
;	inc a
;	and %11111110
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ld (SpriteSizeConfig6_Plus1-1),a

	;Akuyou was designed for 24x24 sprites, but this module can 'reconfigure' it for other sizes
;	cp 10;3;6 ;24px
;	jp z,ShowSpriteReconfigure_24px
	cp 12;3;6 ;24px
	jp z,ShowSpriteReconfigure_24px
	cp 16;4;8 ;32px
	jp z,ShowSpriteReconfigure_32px
	cp 24;6;12 ;48px
	jp z,ShowSpriteReconfigure_48px
	cp 32;8;16 ;64px
	jr z,ShowSpriteReconfigure_64px
	cp 36;10;20 ;80px
	jr z,ShowSpriteReconfigure_72px
	cp 40;10;20 ;80px
	jr z,ShowSpriteReconfigure_80px

	cp 48;12;24 ;96px
	jr z,ShowSpriteReconfigure_96px
	cp 64;16;32 ;128px
	jr z,ShowSpriteReconfigure_128px
	cp 4;1;2 ;8px
	jr z,ShowSpriteReconfigure_8px
	cp 8;2;4 ;16px
	jr z,ShowSpriteReconfigure_16px
ret

ShowSpriteReconfigure_128px:			;Not actually used!
	ld a,VScreen_MaxX-64
	ld b,VScreen_MaxY-24;	ld b,224-128
	jr ShowSpriteReconfigure_all
ShowSpriteReconfigure_104px:			;Not actually used!
	ld a,VScreen_MaxX-52
	ld b,VScreen_MaxY-96
	jr ShowSpriteReconfigure_all
ShowSpriteReconfigure_96px:			;Used by Boss 1
	ld a,VScreen_MaxX-48
	ld b,VScreen_MaxY-24;	ld b,224-96
	jr ShowSpriteReconfigure_all
ShowSpriteReconfigure_80px:			;Not actually used!
	ld a,VScreen_MaxX-40
	ld b,VScreen_MaxY-80
	jr ShowSpriteReconfigure_all
ShowSpriteReconfigure_72px:			;Not actually used!
	ld a,VScreen_MaxX-36
	ld b,VScreen_MaxY-72
	jr ShowSpriteReconfigure_all
ShowSpriteReconfigure_48px:
	ld a,VScreen_MaxX-24
	ld b,VScreen_MaxY-48
	jr ShowSpriteReconfigure_all
ShowSpriteReconfigure_32px:
	ld a,VScreen_MaxX-16
	ld b,VScreen_MaxY-32
	jr ShowSpriteReconfigure_all
ShowSpriteReconfigure_64px:			;not actually used
	ld a,VScreen_MaxX-32
	ld b,VScreen_MaxY-64
	jr ShowSpriteReconfigure_all
ShowSpriteReconfigure_16px:
	ld a,VScreen_MaxX-8
	ld b,VScreen_MaxY-16
	jr ShowSpriteReconfigure_all
ShowSpriteReconfigure_8px:
	ld a,VScreen_MaxX-4
	ld b,VScreen_MaxY-8
	jr ShowSpriteReconfigure_all
ShowSpriteReconfigure_24px:
	ld a,VScreen_MaxX-12
	ld b,VScreen_MaxY-24

ShowSpriteReconfigure_all:

;	ld a,c
	;Right X
	ld (SpriteSizeConfig184less12_Plus1-1),a
	ld (SpriteSizeConfig184less12B_Plus1-1),a
	ld a,B
	;Bottom Y
	ld (SpriteSizeConfig224less24_Plus1-1),a
	ld (SpriteSizeConfig224less24B_Plus1-1),a
ret
