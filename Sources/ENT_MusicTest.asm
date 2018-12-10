
;Uncomment one of the lines below to select your compilation target

;BuildCPC equ 1	; Build for Amstrad CPC
;BuildMSX equ 1 ; Build for MSX
;BuildTI8 equ 1 ; Build for TI-83+
;BuildZXS equ 1 ; Build for ZX Spectrum
BuildENT equ 1 ; Build for Enterprise
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

	ld a,%00000100
	out (&a0),a		;&A0 - Channel 0 Tone L	LLLLLLLL 	LLLL Tone
	ld a,%000010000
	out (&a1),a		;&A1 - Channel 0 Tone H	RPCCHHHH	R=Ring modulator / high Pass /  polynominal Counter distortion / HHHH Tone

	ld a,0;%00111111		
	out (&A8),a		;&A8 - Tone Channel 0 LH Amplitude --VVVVVV / D/A ladder (tape port, Speaker) 
	out (&AC),a		;&AC - Tone Channel 0 RH Amplitude --VVVVVV / D/A ladder (tape port, Speaker R)  





;	ld a,%00000100
;	out (&a4),a		;&A0 - Channel 2 Tone L	LLLLLLLL 	LLLL Tone
;	ld a,%00000100
;	out (&a5),a		;&A1 - Channel 2 Tone H	RPCCHHHH	R=Ring modulator / high Pass /  polynominal Counter distortion / HHHH Tone
;
;	ld a,%00111111		
;	out (&AA),a		;&AA - Tone Channel 2 LH Amplitude --VVVVVV 
;	out (&AE),a		;&AE - Tone Channel 2 RH Amplitude --VVVVVV 



	ld a,%00111111
	out (&AB),a		;&AB - Noise Channel LH Amplitude  --VVVVVV
	out (&AF),a		;&AF - Noise Channel RH Amplitude  --VVVVVV


	ld a,%01000001
	out (&a6),a 		;&A6 - Noise Channel frequency	RHLBCCNN	Ring pass / High pass / Low Pass / Bits (1=17) / polynomial Counter / Noise clock

;&A0 - Channel 0 Tone L	LLLLLLLL 	LLLL Tone
;&A1 - Channel 0 Tone H	RPCCHHHH	R=Ring modulator / high Pass /  polynominal Counter distortion / HHHH Tone
;&A2 - Channel 1 Tone L
;&A3 - Channel 1 Tone H
;&A4 - Channel 2 Tone L
;&A5 - Channel 2 Tone H
;&A6 - Noise Channel frequency	rhlbccnn	Ring pass / High pass / Low Pass / Bits (1=17 0=7) / polynomial Counter / Noise clock (0=31khz, 1/2/3=channel)
;&A7 - Sync & Interrupt rate	-IIDDSSS	Interrupts (0=1khz,1=50hz,2=tone0,3=tone1) D=da ladder (speccy 48k emu) / Sync for tone 0,1,2
;&A8 - Tone Channel 0 LH Amplitude --VVVVVV / D/A ladder (Speccy emu) 
;&A9 - Tone Channel 1 LH Amplitude --VVVVVV 
;&AA - Tone Channel 2 LH Amplitude --VVVVVV 
;&AB - Noise Channel LH Amplitude  RPCCHHHH
;&AC - Tone Channel 0 RH Amplitude / D/A ladder (Speccy Emu R)
;&AD - Tone Channel 1 RH Amplitude --VVVVVV 
;&AE - Tone Channel 2 RH Amplitude --VVVVVV 
;&AF - Noise Channel RH Amplitude  --VVVVVV 


	di	
	halt
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


Message: db 'Hello World 323!',255
Message2: db 'Press A Key:',255
Message3: db 'You Pressed:',255


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	read "..\SrcALL\V1_Functions.asm"
	read "..\SrcALL\V1_Footer.asm"
