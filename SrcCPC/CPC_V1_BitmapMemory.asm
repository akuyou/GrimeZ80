;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;				Screen Co-ordinate functions

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


GetScreenPos:	;return memory pos in HL of screen co-ord B,C (X,Y)
	
	push bc
		ld b,0			;Load B with 0 because we only want C
		ld hl,scr_addr_table
		add hl,bc	;We add twice, because each address has 2 bytes
		add hl,bc

		ld a,(hl)	
		inc l		;INC L not INC HL because we're byte aligned to 2
		ld h,(hl)
		ld l,a
	pop bc
	ld c,b		;Load the Xpos into C
	ld b,&C0	;Our table is relative to 0 - so we need to add our screen base
	add hl,bc	;This is so it can be used for alt screen buffers
	ld (ScreenLinePos_Plus2-2),hl
	ret

	ifndef ScrWid256
GetNextLine:
	push af
		ld hl,&0000
ScreenLinePos_Plus2:
		ld a,h		;Add &08 to H (each CPC line is &0800 bytes below the last
		add &08
		ld h,a
			;Every 8 lines we need to jump back to the top of the memory range to get the correct line
			;The code below will check if we need to do this - yes it's annoying but that's just the way the CPC screen is!
		bit 7,h		;Change this to bit 6,h if your screen is at &8000!
		jp nz,GetNextLineDone
		push bc
			ld bc,&c050	;if we got here we need to jump back to the top of the screen - the command here will do that
			add hl,bc
		pop bc
	GetNextLineDone:
	pop af
	ld (ScreenLinePos_Plus2-2),hl	;Back up the screen position for next time
	ret


	align2			;Align the data to a 2 byte boundary - this allow us to use INC L rather than INC HL
			;as we know that the second part will not be at an address like &8100 that would cross a boundary

	; This is the screen addresses of all the lines of the screen - Just copy paste these!
	; Note you will have to add the base address of your screen (usually &C000)
	; This table is used in Chibi Akumas, where the screen can be at &C000, or &8000 depending on which buffer is shown.

scr_addr_table:
	defb &00,&00, &00,&08, &00,&10, &00,&18, &00,&20, &00,&28, &00,&30, &00,&38;1
	defb &50,&00, &50,&08, &50,&10, &50,&18, &50,&20, &50,&28, &50,&30, &50,&38;2
	defb &A0,&00, &A0,&08, &A0,&10, &A0,&18, &A0,&20, &A0,&28, &A0,&30, &A0,&38;3
	defb &F0,&00, &F0,&08, &F0,&10, &F0,&18, &F0,&20, &F0,&28, &F0,&30, &F0,&38;4
	defb &40,&01, &40,&09, &40,&11, &40,&19, &40,&21, &40,&29, &40,&31, &40,&39;5
	defb &90,&01, &90,&09, &90,&11, &90,&19, &90,&21, &90,&29, &90,&31, &90,&39;6
	defb &E0,&01, &E0,&09, &E0,&11, &E0,&19, &E0,&21, &E0,&29, &E0,&31, &E0,&39;7
	defb &30,&02, &30,&0A, &30,&12, &30,&1A, &30,&22, &30,&2A, &30,&32, &30,&3A;8
	defb &80,&02, &80,&0A, &80,&12, &80,&1A, &80,&22, &80,&2A, &80,&32, &80,&3A;9
	defb &D0,&02, &D0,&0A, &D0,&12, &D0,&1A, &D0,&22, &D0,&2A, &D0,&32, &D0,&3A;10
	defb &20,&03, &20,&0B, &20,&13, &20,&1B, &20,&23, &20,&2B, &20,&33, &20,&3B;11
	defb &70,&03, &70,&0B, &70,&13, &70,&1B, &70,&23, &70,&2B, &70,&33, &70,&3B;12
	defb &C0,&03, &C0,&0B, &C0,&13, &C0,&1B, &C0,&23, &C0,&2B, &C0,&33, &C0,&3B;13
	defb &10,&04, &10,&0C, &10,&14, &10,&1C, &10,&24, &10,&2C, &10,&34, &10,&3C;14
	defb &60,&04, &60,&0C, &60,&14, &60,&1C, &60,&24, &60,&2C, &60,&34, &60,&3C;15
	defb &B0,&04, &B0,&0C, &B0,&14, &B0,&1C, &B0,&24, &B0,&2C, &B0,&34, &B0,&3C;16
	defb &00,&05, &00,&0D, &00,&15, &00,&1D, &00,&25, &00,&2D, &00,&35, &00,&3D;17
	defb &50,&05, &50,&0D, &50,&15, &50,&1D, &50,&25, &50,&2D, &50,&35, &50,&3D;18
	defb &A0,&05, &A0,&0D, &A0,&15, &A0,&1D, &A0,&25, &A0,&2D, &A0,&35, &A0,&3D;19
	defb &F0,&05, &F0,&0D, &F0,&15, &F0,&1D, &F0,&25, &F0,&2D, &F0,&35, &F0,&3D;20
	defb &40,&06, &40,&0E, &40,&16, &40,&1E, &40,&26, &40,&2E, &40,&36, &40,&3E;21
	defb &90,&06, &90,&0E, &90,&16, &90,&1E, &90,&26, &90,&2E, &90,&36, &90,&3E;22
	defb &E0,&06, &E0,&0E, &E0,&16, &E0,&1E, &E0,&26, &E0,&2E, &E0,&36, &E0,&3E;23
	defb &30,&07, &30,&0F, &30,&17, &30,&1F, &30,&27, &30,&2F, &30,&37, &30,&3F;24
	defb &80,&07, &80,&0F, &80,&17, &80,&1F, &80,&27, &80,&2F, &80,&37, &80,&3F;25

	else

	GetNextLine:
	push af
		ld hl,&0000
ScreenLinePos_Plus2:
		ld a,h
		add a,&08
		ld h,a
		bit 7,h					;this works if the screen is at &C000
							;if it's an &8000 you need to change it to bit 6,h
		jp nz,GetNextLineDone

;		ld a,l
;		add a,32*2		;We can also use this if we don't want to PUSH BC/POP BC
;		ld l,a
;		ld a,h
;		adc a,&c0
;		ld h,a

		push bc
			ld bc,&c040	;if we got here we need to jump back to the top of the screen - the command here will do that
			add hl,bc
		pop bc
	GetNextLineDone:
	ld (ScreenLinePos_Plus2-2),hl
	pop af
	ret
	;This is the screen address table for 256 pixel wide screens
	align2
scr_addr_table:
	defw &0000,&0800,&1000,&1800,&2000,&2800,&3000,&3800
	defw &0040,&0840,&1040,&1840,&2040,&2840,&3040,&3840
	defw &0080,&0880,&1080,&1880,&2080,&2880,&3080,&3880
	defw &00C0,&08C0,&10C0,&18C0,&20C0,&28C0,&30C0,&38C0
	defw &0100,&0900,&1100,&1900,&2100,&2900,&3100,&3900
	defw &0140,&0940,&1140,&1940,&2140,&2940,&3140,&3940
	defw &0180,&0980,&1180,&1980,&2180,&2980,&3180,&3980
	defw &01C0,&09C0,&11C0,&19C0,&21C0,&29C0,&31C0,&39C0
	defw &0200,&0A00,&1200,&1A00,&2200,&2A00,&3200,&3A00
	defw &0240,&0A40,&1240,&1A40,&2240,&2A40,&3240,&3A40
	defw &0280,&0A80,&1280,&1A80,&2280,&2A80,&3280,&3A80
	defw &02C0,&0AC0,&12C0,&1AC0,&22C0,&2AC0,&32C0,&3AC0
	defw &0300,&0B00,&1300,&1B00,&2300,&2B00,&3300,&3B00
	defw &0340,&0B40,&1340,&1B40,&2340,&2B40,&3340,&3B40
	defw &0380,&0B80,&1380,&1B80,&2380,&2B80,&3380,&3B80
	defw &03C0,&0BC0,&13C0,&1BC0,&23C0,&2BC0,&33C0,&3BC0;<<<<
	defw &0400,&0C00,&1400,&1C00,&2400,&2C00,&3400,&3C00
	defw &0440,&0C40,&1440,&1C40,&2440,&2C40,&3440,&3C40
	defw &0480,&0C80,&1480,&1C80,&2480,&2C80,&3480,&3C80
	defw &04C0,&0CC0,&14C0,&1CC0,&24C0,&2CC0,&34C0,&3CC0
	defw &0500,&0D00,&1500,&1D00,&2500,&2D00,&3500,&3D00
	defw &0540,&0D40,&1540,&1D40,&2540,&2D40,&3540,&3D40
	defw &0580,&0D80,&1580,&1D80,&2580,&2D80,&3580,&3D80
	defw &05C0,&0DC0,&15C0,&1DC0,&25C0,&2DC0,&35C0,&3DC0


	endif

ScreenINIT:
	ifndef ScrColor16
		ld a,1
	else
		ld a,0
	endif
	call &BC0E		;SCR SET MODE

;This will change the screenmode without the firmware, but beware! The firware interrupt handler will switch it back!
;	exx
;	ifndef ScrColor16
;		ld bc,&7F00+128+1		;128 means 'set screen mode'
;	else	
	;	ld bc,&7F00+128+0
;	endif
;	out (c),c
;	exx

	ifdef ScrWid256
		ld hl,crtc_vals	;Send the CRTC values to the 
		ld bc,&bc00
		set_crtc_vals:
		out (c),c	;Choose a register
		inc b
		ld a,(hl)
		out (c),a	;Send the new value
		dec b
		inc hl
		inc c
		ld a,c
		cp 14		;When we get to 14, we've done all the registers
		jr nz,set_crtc_vals
	endif

	ret

	ifdef ScrWid256
		crtc_vals:
		defb &3f	; R0 - Horizontal Total
		defb 32	 	; R1 - Horizontal Displayed  (32 chars wide)
		defb 42		; R2 - Horizontal Sync Position (centralises screen)
		defb &86	; R3 - Horizontal and Vertical Sync Widths
		defb 38		; R4 - Vertical Total
		defb 0		; R5 - Vertical Adjust
		defb 24		; R6 - Vertical Displayed (24 chars tall)
		defb 31		; R7 - Vertical Sync Position (centralises screen)
		defb 0		; R8 - Interlace
		defb 7		; R9 - Max Raster 
		defb 0		; R10 - Cursor (not used)
		defb 0		; R11 - Cursor (not used)
		defb &30	; R12 - Screen start (start at &c000)
		defb &00 	; R13 - Screen start
	endif


