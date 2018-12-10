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

BuildSMS_BuildQuick equ 1

Monitor_Full equ 1
Monitor_Pause equ 1

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

	call Cls



	ld a,%11001111	;1CCTLLLL	(Latch - Channel Type DataL
	out (&7F),a
	ld a,%00001000	;0-HHHHHH	(Latch off - Data H)
	out (&7F),a

	ld a,%11011111	;1CCTVVVV	(Latch - Channel Type Volume)	
	out (&7F),a


	ld a,%11100011	;1CCT-MRRr	(Latch - Channel Type... noise Mode (1=white) Rate (Rate 11= use Tone Channel 2)
	out (&7F),a

	ld a,%11110000	;1CCTVVVV	(Latch - Channel Type Volume)	
	out (&7F),a

	di
	halt

;read "..\SrcAll\Multiplatform_MonitorMemdump.asm"
;read "..\SrcAll\Multiplatform_MonitorSimple_RomVer.asm"
;read "..\SrcAll\Multiplatform_ShowHex.asm"
;read "..\SrcAll\Multiplatform_Monitor_Romver.asm"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	read "..\SrcALL\V1_Functions.asm"
	read "..\SrcALL\V1_Footer.asm"