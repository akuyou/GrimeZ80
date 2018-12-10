
;Uncomment one of the lines below to select your compilation target

;BuildCPC equ 1	; Build for Amstrad CPC
;BuildMSX equ 1 ; Build for MSX
;BuildTI8 equ 1 ; Build for TI-83+
;BuildZXS equ 1 ; Build for ZX Spectrum
;BuildENT equ 1 ; Build for Enterprise
;BuildSAM equ 1 ; Build for SamCoupe
;BuildSMS equ 1 ; Build for Sega Mastersystem
;BuildSGG equ 1 ; Build for Sega GameGear
;BuildGMB equ 1 ; Build for GameBoy Regular
;BuildGBC equ 1 ; Build for GameBoyColor 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef vasm
		include "..\SrcALL\VasmBuildCompat.asm"
	else
		read "..\SrcALL\WinApeBuildCompat.asm"
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	include "..\SrcALL\V1_Header.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	Call DOINIT	; Get ready
	;call SetGBPaletteLight
;	call SetGBPaletteDark
	
	;call GBC_Turbo

	ld hl,&0000		;Screen position - 0,0 is top left, H=X,L=Y
LocateAgain:
	push hl
		call Locate	;Set cursor position
		ld hl,Message	
		call PrintString;Print Message

	pop hl
	inc h	;Move Right 2
	inc h
	inc l	;Move Down 1
	ld a,l
	cp 3	;We're going to do this 3 times
	jp nz,LocateAgain

	call NewLine	;Newline command

	ld hl,Message2	;Press A key
	call PrintString

	;FE00-FE9F   Sprite Attribute Table (OAM)

	
	ld bc,&0203
	ld hl,&0606
	ld de,&0000
	call FillAreaWithTiles
	
	ld	hl, SpriteData
	ld	de, $8000 		; $8000
	ld	bc, SpriteDataEnd-SpriteData
SpriteFillAgain:
	ld a,(hl)
	ld (de),a
	inc hl
	inc de
	dec bc
	ld a,b
	or c
	jp nz,SpriteFillAgain
	
	;ld a,1
	;ld bc,&0201
	;call SetCGBTileAttribs
	
	;ld a,0
	;ld (&FF4F),a;turn of color ram
	
	ld      a,($FF40)
	or %00000010
	ld      ($FF40),a
	
	
	ld a,32		;spr
	again:
	push af
		; Loop until we are in VBlank
        ld      a,($FF44)
        cp      145             ; Is display on scan line 145 yet?
    ;    jr      nz,again        ; no, keep waiting
	
	
	ld hl,&FE00
	
	ld a,128		;y
	ldi (hl),a
	ld a,128		;x
	ldi (hl),a
	pop af
	;di
	;halt
	
	push af
	ldi (hl),a
	
	ld a,0		;tile
	ldi (hl),a
	
	pop af
	inc a
	jp again
	
	
	call NewLine	;Newline command

	call WaitChar	;Wait for a keypress

	push af
		ld hl,Message3	;Print message
		call PrintString
	pop af

	call PrintChar	;Show Pressed key
	call NewLine

	CALL SHUTDOWN ; return to basic or whatever
	ret

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

SpriteData:
	incbin "Z:\ResALL\sprites\RawGB.RAW" ; ASCII character set from devrs.com
SpriteDataEnd:

Message: db 'Hello World xxx!',255
Message2: db 'Press A Key:',255
Message3: db 'You Pressed:',255


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	include "..\SrcALL\V1_Functions.asm"
	include "..\SrcALL\V1_Footer.asm"
