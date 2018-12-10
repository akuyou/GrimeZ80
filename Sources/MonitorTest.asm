nolist

;Uncomment one of the lines below to select your compilation target

;BuildCPC equ 1	; Build for Amstrad CPC
;BuildMSX equ 1 ; Build for MSX
;BuildTI8 equ 1 ; Build for TI-83+
;BuildZXS equ 1  ; Build for ZX Spectrum
BuildENT equ 1 ; Build for Enterprise
;BuildSAM equ 1 ; Build for SamCoupe
 
read "..\SrcALL\V1_Header.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	Call DOINIT	; Get ready

	call CLS

	call CLS
	ld hl,&0000		;Screen position - 0,0 is top left, H=X,L=Y




LocateAgain:
	push hl
		call locate	;Set cursor position
		ld hl,Message	
		call PrintString;Print Message


;		call Monitor_BreakPoint		;Show PC at this point
		call Monitor_BreakPointOnce	;Show PC at this point... Only shows once - removed by Selfmodifying code


	pop hl
	inc h	;Move Right 2
	inc h
	inc l	;Move Down 1
	ld a,l
	cp 3	;We're going to do this 3 times
	jp nz,LocateAgain

di
	call Monitor		;*** Output status of registers

ei
	call Monitor		;*** Output status of registers


	call NewLine	;Newline command

	ld hl,Message2	;Press A key

	push hl					; *** push the register we want to inspect
	call Monitor_PushedRegister		; *** inspect the pushed register

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


Message: db 'Hello World 333!',255
Message2: db 'Press A Key:',255
Message3: db 'You Pressed:',255



;;;;;;;;;;;;;;;;;;;;;;;;;;
;debugger
;;;;;;;;;;;;;;;;;;;;;;;;;
Monitor_Full equ 1				;*** FULL monitor takes more ram, but shows all registers
Monitor_Pause equ 1 				;*** Pause after showing debugging info

read "..\SrcAll\Multiplatform_Monitor.asm"		;*** Full monitor
read "..\SrcAll\Multiplatform_MonitorSimple.asm"	;*** PushRegister and Breakpoint support

read "..\SrcAll\Multiplatform_ShowHex.asm"		;*** Monitor functions require ShowHex support


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

read "..\SrcALL\V1_Functions.asm"
read "..\SrcALL\V1_Footer.asm"
