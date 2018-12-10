TestSprite equ &C010
Monitor_TMP1 equ &C011

Monitor_NextMonitorPos_2Byte equ &C012;-13
Monitor_EI_Reenable_2byte equ &C014;-5
Monitor_Special	equ &C016

;Uncomment one of the lines below to select your compilation target

;BuildCPC equ 1	; Build for Amstrad CPC
;BuildMSX equ 1 ; Build for MSX
;BuildTI8 equ 1 ; Build for TI-83+
;BuildZXS equ 1 ; Build for ZX Spectrum
;BuildENT equ 1 ; Build for Enterprise
;BuildSAM equ 1 ; Build for SamCoupe
BuildSMS equ 1 ; Build for Sega Mastersystem
;BuildSGG equ 1 ; Build for Sega GameGear
;BuildGMB equ 1 ; Build for GameBoy Regular
;BuildGBC equ 1 ; Build for GameBoyColor 


Monitor_Full equ 1
Monitor_Pause equ 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef BuildGBC
vasm equ 1	
	endif
	ifdef BuildGMB
vasm equ 1	
	endif
	ifndef vasm
		macro include incfilename
			read incfilename
		mend
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;read "..\SrcALL\V1_Header.asm"
	include "..\SrcALL\V1_Header.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	Call DOINIT	; Get ready

	call Cls
;call monitor
;    call loadColorPalette
;    call loadFontTiles
;    call turnOnScreen

;	ld bc,&0000
;	call getscreenpos
;	call writeText





;	ld bc,&0101
;	call getscreenpos
;	call writeText

;	ld bc,&0302
;	call getscreenpos
;	call writeText

;	ld bc,&0303
;	call getscreenpos
;	call writeText

di
	ld bc,&0103
	ld hl,&0606
	ld de,256	;Start at &2000
	call FillAreaWithTiles

    ld hl, &2000
    call prepareVram


	ld hl,RawSprite
	ld bc,RawSpriteEnd-RawSprite
RawSpriteFill:
	ld a,(hl)
	out (vdpData),a
	inc hl
	dec bc
	ld a,b
	or c
jp nz,RawSpriteFill

	;BC = X,Y)
	;HL = W,H)
	;DE = Start Tile


;	ld hl, &0000
;	call prepareVram
;	ld bc, &3800		
;	xor a
;fillagain:
;	out (vdpData),a
;	inc a
;	dec bc
;	ld a,b
;	or c
;	jp nz, fillagain




InfiniteLoop:

	ld hl,0
	call Locate
;call Monitor_MemDump
;db 32
;dw &C000


	ld hl,&3F00
	call prepareVram

	ld a,50
	out (vdpData),a

	ld a,70
	out (vdpData),a


	ld hl,&3F80
	call prepareVram
	ld a,100
	out (vdpData),a

;	ld hl,&3F81
;	call prepareVram
	ld a,(TestSprite)
	out (vdpData),a
	inc a
	ld (TestSprite),a

;push af
;call Monitor_PushedRegister

	ld a,110
	out (vdpData),a
	ld a,2
	out (vdpData),a


	jp InfiniteLoop


;--( Subroutines )-------------------------------------------------------------

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
			call getscreenpos
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



RawSprite:
incbin "Z:\ResALL\Sprites\RawSMS.RAW"
RawSpriteEnd:





; writeText

; Text Message ("Hello, World!")
Message:
;   H   e   l   l   o   ,       W   o   r   l   d   !
db "Hello, World!?!"
MessageEnd:

writeText:
    ; Set VRAM write address to name table index &cc
    ; by outputting &4000 ORed with &3800+cc
    ;
    ; Game Gear 102 empty cells, 3 lines with 6+20+6 tiles,  3*(6+20+6) + 6
    ;            102 words = 204 bytes = &cc



;    ld a,&CC
;    out (vdpControl),a
;    ld a,%01111000;&38|&40
;    out (vdpControl),a
	;sms 32x24	
	;gg 20x18 (6 lR and 3 ud lines missing)
;	ld hl,&380		
;	call prepareVram



;	ld a,&28

	ld hl,Message
	ld bc,MessageEnd-Message  ; Counter for number of bytes to write

writeTochar:
    	ld a,(hl)
	sub 32
    	out (vdpData),a
	xor a
	out (vdpData),a
    	inc hl
    	dec bc
    	ld a,c
    	or b
    jp nz, writeTochar
    ret



FillTest:
	ld b,0
	ld hl,&0000
	ld bc,512 ;32*24
OutAgain:
	ld a,&28
	ld a,l
	out (vdpData),a
	ld a,h
	out (vdpData),a
	inc hl
	dec bc
	ld a,b
	or c
	jp nz,OutAgain

	ret


getscreenpos:	;B=Xpos, C=Ypos
	push bc
		ld hl,&3800		;(32x32 - 2 bytes per cell = &800)
		ld a,b
		ld b,c
		ld c,a


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

read "..\SrcAll\Multiplatform_MonitorMemdump.asm"
read "..\SrcAll\Multiplatform_MonitorSimple_RomVer.asm"
read "..\SrcAll\Multiplatform_ShowHex.asm"
read "..\SrcAll\Multiplatform_Monitor_Romver.asm"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	include "..\SrcALL\V1_Functions.asm"
	include "..\SrcALL\V1_Footer.asm"