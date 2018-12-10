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

;BuildSMS_BuildQuick equ 11


Monitor_Full equ 1
Monitor_Pause equ 1 

UseHardwareKeyMap equ 1 ; Need the Keyboard map
UseSampleKeymap	equ 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef vasm
		include "..\SrcALL\VasmBuildCompat.asm"
	else
		read "..\SrcALL\WinApeBuildCompat.asm"
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	read "..\SrcALL\CPU_Compatability.asm"
	read "..\SrcALL\V1_Header.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	Call DOINIT	; Get ready

	Call CLS

;KeyboardScanner_OnePlayerOnly equ 1

;Loop2:
;	call Read_Keyboard
;	call ScanKeys
;jp Loop2
	;VdpOut_Control equ &99
	;ld a,2
	;out (VdpOut_Control),a

	call ConfigureControls
	
	
	Call CLS
	
	ld hl,KeyMap2
	ld b,8*4
	
; ShowAgain:
	; ld a,(hl)
	; inc hl
	; push hl
	; push bc
		; call ShowHex
	; pop bc
	; pop hl
	; djnz ShowAgain
	
	; di
	; halt

Loop:

	ld hl,&0000
	call Locate
	call Player_ReadControlsDual

		ld a,h ;= Keypress bitmap Player 1
	call ShowHex
		ld a,l ;= Keypress bitmap Player 2
	call ShowHex


	jp Loop

	CALL SHUTDOWN ; return to basic or whatever
	ret



	align16
KeyboardScanner_KeyPresses  ds 16,255 ;Player1

	read "..\SrcAll\Multiplatform_ReadJoystick.asm"
	read "..\SrcAll\Multiplatform_ShowHex.asm"
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	read "..\SrcALL\V1_Functions.asm"
	read "..\SrcALL\V1_Footer.asm"
