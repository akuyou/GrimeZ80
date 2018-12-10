nolist

;Uncomment one of the lines below to select your compilation target

;BuildCPC equ 1	; Build for Amstrad CPC
;BuildMSX equ 1 ; Build for MSX
;BuildTI8 equ 1 ; Build for TI-83+
;BuildZXS equ 1  ; Build for ZX Spectrum
BuildENT equ 1 ; Build for Enterprise
;BuildSAM equ 1 ; Build for SamCoupe

UseHardwareKeyMap equ 1 	; Need the Keyboard map
BitmapFont_LowercaseOnly equ 1	; Minimal font - Uppercase only




read "..\SrcALL\V1_BitmapMemory_Header.asm"
read "..\SrcALL\V1_Header.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	Call DOINIT	; Get ready

	call CLS




        CALL VID	;get a free Video segment
        JP NZ,VideoFail	;if not available then exit
        LD A,C		;store
        LD (VIDS),A	;segment number
	OUT (&B1),A	;paging to the page 3.




	ld de,ENT_Filename 	;Open stream
	ld a,12
	;call ENT_OpenStream	
	rst 6
	db 1

	ld a,12
	ld c,0
	ld de,FileInfoblock
	rst 6
	db 10
	ld hl,(FileInfoblock+4)

	ld a,12
	ld bc,16000
	ld de,&C000
;	call ENT_ReadBlock	;Read 1k to &1000
	rst 6
	db 6


	ld a,12
;	call ENT_CloseStream	
	rst 6
	db 3 		;open stream



	


;11.12 Function 10 - Set and Read Channel Status 
;    Parameters   A channel number
;                  C write flags
;                 DE pointer to parameter block (16 bytes)
;    Results     A status
;                  C read flags                            
;This function is used to provide random access facilities and file protection on file devices such as disk or a RAM driver. The format of the parameter block is: 

;  Byte  0 ... 3  -  File pointer value (32 bits)
;         4 ... 7  -  File size (32 bits)
;               8  -  Protection byte (yet to be defined)
;         9 .. 15  -  Zero (reserved for future expansion)




	ld de,PaletteDest
	ld hl,&FF00;LPT in ram


	ld iyl,0
	ld ixh,10
NextPalBlock:

	ld ixl,4

	ld a,iyl
	ld iyh,a

	ld a,(de)	;linenum
	inc a				;ENTERPRISE FIX
	sub iyl
	neg
	ld (hl),a
	ld a,(de)	;linenum
	inc a				;ENTERPRISE FIX
	ld iyl,a


	inc de

	ld bc,4
	add hl,bc
	ex hl,de		
	push hl

		ld hl,0
		ld a,iyh



		or a
		jr z,EntLineAddAgainSkip

;	push af
;	call Monitor_PushedRegister

	push bc
		ld bc,80
EntLineAddAgain:
		add hl,bc
		dec a
	jr nz,EntLineAddAgain
	pop bc
EntLineAddAgainSkip:
;	push hl
;	call Monitor_PushedRegister

		ld a,l
		ld (de),a
		inc de
		ld a,h
		ld (de),a



	pop hl
	ex hl,de
	


	ld bc,3
	add hl,bc
NextPalentry:
	ld a,(de)	;Paletteentry
	ld c,a
	inc de
	ld a,(de)
	ld b,a
	inc de


	call ParsePaletteBC
	ld (hl),a
	inc hl

;	push hl
;	call Monitor_PushedRegister


;	push bc
;	call Monitor_PushedRegister

	dec ixl
	jr nz,NextPalentry


;	Call Newline

	ld bc,4
	add hl,bc

	dec ixh
	jr nz,NextPalBlock




FlickRepeat:
	ld b,10
	ld hl,VIDADR1+1 -LPT +&FF00
FlipAgain:
	ld a,(hl)
	xor &40
	ld (hl),a

	ld a,16
	add l
	ld l,a
	djnz FlipAgain


	ld bc,4000
PauseAgain2:
	dec bc
	ld a,b
	or c
	jp nz,PauseAgain2


	jp FlickRepeat







;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	Call Newline

	ld de,KeyboardScanner_KeyPresses
	rst 6
	db 20
	ld de,KeyboardScanner_KeyPresses
	ld b,8
StatAgain:
	ld a,(de)
;	call ShowHex
	djnz StatAgain
	Call Newline


	ld a,(VIDS)
;	push af	
;	call Monitor_PushedRegister
;	Call Newline
	ld b,8
GetAgain:
	push bc
		rst 6	;Segment please!
		db 24
                JP NZ,GetFail	;if not available then exit
;		push bc
;		call Monitor_PushedRegister
;		push de
;		call Monitor_PushedRegister
;		Call Newline
	pop bc
	djnz,GetAgain





	di
	halt
GetFail:
;		push bc
;		call Monitor_PushedRegister
;		push de
;		call Monitor_PushedRegister
;		Call Newline
	di
	halt
	
BitmapFont:
ifdef BitmapFont_LowercaseOnly
	incbin "..\ResALL\Font64.FNT"
else
	incbin "..\ResALL\Font96.FNT"
endif

;read "..\SrcAll\Multiplatform_Monitor.asm"
read "..\SrcAll\Multiplatform_MonitorSimple.asm"
read "..\SrcAll\Multiplatform_ShowHex.asm"


align 16
	KeyboardScanner_KeyPresses  ds 16,255 ;Player1

read "..\SrcALL\Multiplatform_ScanKeys.asm"
read "..\SrcALL\Multiplatform_KeyboardDriver.asm"

read "..\SrcAll\MultiPlatform_Stringreader.asm"		;*** read a line in from the keyboard
read "..\SrcAll\Multiplatform_StringFunctions.asm"	;*** convert Lower>upper and decode hex ascii

read "Test_EntBmpMemory.asm"
read "..\SrcALL\Multiplatform_BitmapFonts.asm"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PaletteDest:	;The 'Normal' level palette
defb 20	;next split
defw &000F
defw &0010
defw &0000
defw &0000
defb 40		;next split
defw &00FC
defw &0020
defw &0000
defw &0000
defb 60	;next split
defw &0F0A
defw &0030
defw &0000
defw &0000
defb 80	;next split
defw &0008
defw &0040
defw &0000
defw &0000
defb 100		;next split
defw &00F6
defw &0050
defw &0000
defw &0000
defb 120		;next split
defw &0F02
defw &0060
defw &0000
defw &0000
defb 140		;next split
defw &000F
defw &0070
defw &0000
defw &0000
defb 160	;next split
defw &0000
defw &0080
defw &0000
defw &0000
defb 180	;next split
defw &0FAC
defw &0090
defw &0000
defw &0000
defb 200		;next split
defw &0FFF
defw &00a0
defw &0000
defw &0000


ParsePaletteBC:
	push de
	ld a,c
	and &F0
	ld d,a	 ;R
	
	ld a,c
	and &0F  ;B
	rrca
	rrca
	rrca
	rrca
	ld c,a

	ld a,b
	rrca
	rrca
	rrca
	rrca
	ld b,a

	;Green in H

	xor a	; g0 | r0 | b0 | g1 | r1 | b1 | g2 | r2 | - x0 = lsb 

	rl d	;r2
	rra
	rl b	;g2
	rra
	rl c	;b1
	rra

	rl d	;r1
	rra
	rl b	;g1
	rra
	rl c	;b0
	rra

	rl d	;r0
	rra
	rl b	;g0
	rra
	pop de
ret
ENT_Filename: db 11,'TScreen.RAW'
FileInfoblock:

db 4;  Byte  0 ... 3  -  File pointer value (32 bits)
db 4;         4 ... 7  -  File size (32 bits)
db 1;               8  -  Protection byte (yet to be defined)
db 7;         9 .. 15  -  Zero (reserved for future expansion)


read "..\SrcALL\V2_Functions.asm"
read "..\SrcALL\V1_Footer.asm"