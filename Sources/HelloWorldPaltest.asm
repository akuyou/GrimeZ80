
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



;read "..\SrcALL\V1_Header.asm"
	read "..\SrcALL\V1_Header.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	Call DOINIT	; Get ready

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

	
	ld hl,Palette
	ld b,16
PaletteAgain:
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	push hl
		;ex de,hl
		push hl
		push de
		pop hl
		pop de
		
		push bc
			ld a,16
			sub b
			call SetPalette
		pop bc
	pop hl

	dec b
	jp nz,PaletteAgain

	
	
	
	
	
	
	
	
	
	
	call NewLine	;Newline command

	ld hl,Message2	;Press A key
	call PrintString

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


Message: db 'Hello World 666!',255
Message2: db 'Press A Key:',255
Message3: db 'You Pressed:',255


	read "..\SrcAll\Multiplatform_Palette.asm"
Palette:
	;   -grb
	dw &0000
	dw &0099
	dw &0E0F
	dw &0FFF
	dw &000F
	dw &004F
	dw &008F
	dw &00AF
	dw &00FF
	dw &04FF
	dw &08FF
	dw &0AFF
	dw &0CCC
	dw &0AAA
	dw &0888
	dw &000F
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	read "..\SrcALL\V1_Functions.asm"
	read "..\SrcALL\V1_Footer.asm"
