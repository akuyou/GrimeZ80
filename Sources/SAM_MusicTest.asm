
;Uncomment one of the lines below to select your compilation target

;BuildCPC equ 1	; Build for Amstrad CPC
;BuildMSX equ 1 ; Build for MSX
;BuildTI8 equ 1 ; Build for TI-83+
;BuildZXS equ 1 ; Build for ZX Spectrum
;BuildENT equ 1 ; Build for Enterprise
BuildSAM equ 1 ; Build for SamCoupe
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
	
	di

	ld h,255
SoundAgain:
	ld a,&1C
	ld d,%00000001
	call SetSoundRegister	;Enable Sound


;	ld a,&0
;	ld d,%11111111
;	call SetSoundRegister	;Volume 0

;	ld a,&8
;	ld d,%11111111
;	call SetSoundRegister	;Tone 0

;	ld a,&10
;	ld d,%00000100
;	call SetSoundRegister	;Octive 0

;	ld a,&14
;	ld d,%00000001
;	call SetSoundRegister	;Tone Enable 0


	ld a,&3
	ld d,%11111111
	call SetSoundRegister	;Volume 3


	;ld a,&15
	;ld d,%00001000
	;call SetSoundRegister	;Noise Enable 3

	ld a,&16
	ld d,%00110000
	call SetSoundRegister	;Noise Config 3

	ld a,&11
	ld d,%01000010
	call SetSoundRegister	;Octive 3 / 2


	ld a,&14
	ld d,%00000101
	call SetSoundRegister	;Tone Enable 2




	ld a,&02
	ld d,%11111111
	call SetSoundRegister	;Volume 2

;	ld a,h
; 	and %01110000
;	ld d,a

	ld a,&11
	ld d,%01000000
	call SetSoundRegister	;Octive 2


	ld a,&10
	ld d,%00100000
	call SetSoundRegister	;Tone 1

	ld a,&18
	ld d,%10001010
	call SetSoundRegister	;Envelope Generator 0 (CH2) O-GREEEM envellope controler On / use Generator 1/4 / Resolution / Envelope shape / Mirror other chanel

	ld bc,2999
DelayAgain:
	dec bc
	ld a,b
	or c
	jp nz,DelayAgain

dec h
jp SoundAgain

di
halt
SetSoundRegister
	ld bc,511
	out (c),a

	ld bc,255
	ld a,d
	out (c),a
ret

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
