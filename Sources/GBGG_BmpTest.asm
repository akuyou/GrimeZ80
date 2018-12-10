
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
	ifdef BuildMSX1
BuildMSX_MSX1VDP equ 1
	endif
	ifdef BuildMSX
BuildMSX_MSXVDP equ 1
	endif

V9K equ 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef vasm
		include "..\SrcALL\VasmBuildCompat.asm"
	else
		read "..\SrcALL\WinApeBuildCompat.asm"
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	


;read "..\SrcALL\V1_Header.asm"
	read "..\SrcALL\V1_Header.asm"
	read "..\SrcALL\V1_VdpMemory_Header.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	Call DOINIT	; Get ready
	;call SetGBPaletteLight
;	call SetGBPaletteDark

	;call GBC_Turbo
	call CLS	

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

	
	;di
	;halt
	ifdef BuildSMS
	    ld hl, 256*8*4
		call prepareVram
	endif 
		
	ifdef BuildSGG
	    ld hl, 256*8*4
		call prepareVram
		
	endif 
	
	ifdef BuildMSX_MSX1VDP
		ld hl, 128*8
		call prepareVram
	endif
	ifdef BuildMSX_MSXVDP
		ld de, 128
	endif
	ifdef BuildCPC
		ld de, 128
	endif
	ifdef BuildGMB
		ld	de, 128*2*8+&8000 		; $8000
	endif
	ifdef BuildGBC
		ld	de, 128*2*8+&8000 		; $8000
	endif
	
	ld	hl, SpriteData
	ld	bc, SpriteDataEnd-SpriteData
	call DefineTiles

	
	
	
	
	
	
	
	
	
	ld bc,&0303
	ld hl,&0606
	ifdef BuildGBC
		ld de,128
	endif
	ifdef BuildGMB
		ld de,128
	endif
	ifdef BuildSMS
		ld de,256	;Start at &2000
	endif
	ifdef BuildSGG
		ld de,256	;Start at &2000
	endif
	ifdef BuildMSX_MSX1VDP
		ld de,128	;Start at &2000
	endif
	ifdef BuildMSX_MSXVDP
		ld de,128	;Start at &2000
	endif
	ifdef BuildCPC
		ld de,128	;Start at &2000
	endif
	call FillAreaWithTiles
	
	
	
	di
	halt
	
	ifdef BuildGBC
	
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
	endif
	
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



SpriteData:
	ifdef BuildGBC
		incbin "Z:\ResALL\sprites\RawGB.RAW" ; ASCII character set from devrs.com
	endif
	ifdef BuildGMB
		incbin "Z:\ResALL\sprites\RawGB.RAW" ; ASCII character set from devrs.com
	endif
	ifdef BuildMSX_MSX1VDP
		incbin "Z:\ResALL\sprites\RawMSX1.RAW" ; ASCII character set from devrs.com
	endif
	ifdef BuildMSX_MSXVDP
		incbin "Z:\ResALL\sprites\RawMSXVdp.RAW" ; ASCII character set from devrs.com
	endif
	ifdef BuildCPC;V9K only
		incbin "Z:\ResALL\sprites\RawMSXVdp.RAW" ; ASCII character set from devrs.com
	endif
	ifdef BuildSMS
		incbin "Z:\ResALL\Sprites\RawSMS.RAW"
	endif
	ifdef BuildSGG
		incbin "Z:\ResALL\Sprites\RawSMS.RAW"
	endif
SpriteDataEnd:
BitmapFont:
	ifdef BMP_UppercaseOnlyFont
		incbin "..\ResALL\Font64.FNT"			;Font bitmap, this is common to all systems
	else
		incbin "..\ResALL\Font96.FNT"			;Font bitmap, this is common to all systems
	endif
Message: db 'Hello World xxx!',255
Message2: db 'Press A Key:',255
Message3: db 'You Pressed:',255

	read "..\SrcALL\V1_VdpMemory.asm"
	read "..\SrcALL\V1_HardwareTileArray.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	read "..\SrcALL\V2_Functions.asm"
	read "..\SrcALL\V1_Footer.asm"
