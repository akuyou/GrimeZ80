NextCharX equ &C000
NextCharY equ &C001
SelKeyChar equ &C002
zIXH equ &C003
zIXL equ &C004
zIYH equ &C003
zIYL equ &C004
SHUTDOWN:
	di
	halt
	
DOINIT:

	ld	a,0			; SET SCREEN TO TO UPPER RIGHT HAND CORNER
	ld	($FF43), a
	ld	($FF42), a		

	call	StopLCD		; YOU CAN NOT LOAD $8000 WITH LCD ON
	
	ld	hl, BitmapFont
	ld	de, $8000 		; $8000
	ld	bc, 8*96		; the ASCII character set: 256 characters, each with 8 bytes of display data
	call	Copy2Bit	; load tile data
	
	call SetGBPaletteDark
	
	ld c,0*8		;palette no
	ld hl,GBPal
	call SetGBCPalettes
	
	
	    ld      a,($FF40)
        set     7,a             ; Reset bit 7 of LCDC
        ld      ($FF40),a
	
	ret
	
	
SetGBPaletteDark:
	ld a,%00011011
	jr SetGBPalette

SetGBPaletteLight:
	ld a,%11100100
SetGBPalette:

	ld (&FF47),a
	ld (&FF48),a
	cpl
	ld (&FF49),a
;FF47 	BGP	BG & Window Palette Data  (R/W)	= $FC ;
;FF48  	OBP0	Object Palette 0 Data (R/W)	= $FF ;
;FF49  	OBP1	Object Palette 1 Data (R/W)	= $FF ;
	ret
	
SetGBCPalettes:
	ifdef BuildGMB_Greypal
	push af
	push de
	push bc
	push hl
		ld d,4
		xor a
		ld b,a
SetGBPalAgain:		

		;Convert the palette to greyscale
		ld a,(hl)  ;RB
		
		and %11000000
		ld c,a
		
		ld a,(hl)  ;RB
		and %00001100
		rlca
		rlca
		rlca
		rlca
		or c
		ld c,a
		inc hl
		ld a,(hl)  ;RB
		inc hl
		and %00001100
		rlca
		rlca
		rlca
		rlca
		or c
		
		rrc b
		rrc b
		or b
		
		ld b,a
		dec d
		jr nz,SetGBPalAgain
		
		ld	a,b
		cpl
		ld	($FF47), a		; Set the background palette
	pop hl	
	pop bc
	pop de
	pop af
	endif
	
	ifdef BuildGMB
		ret
	endif
	ifdef BuildGBC
		

	;		    -GRB
		
		ld a,(hl)  ;RB
		and %00001111 ;B
		rlca
		ld d,a
		
		
		ld a,(hl)  
		and %11110000 ;R
		rrca
		rrca
		rrca
		ld e,a
		
		inc hl
		ld a,(hl) ;-G
		rlca
		rlca
		rlca
		rlca
		
		rla
		rl d
		rla
		rl d
		
		
		or e
		ld e,a
		
		;;      xBBBBBGG GGGRRRRR
		call SetGBCPAL
		
		inc hl
		
		;ld a,'*'
		;call PrintChar
		;ld a,d
		;call ShowHex
		;ld a,e
	;	call ShowHex
		;ld a,'*'
		;call PrintChar
	;	
		ld a,%00000010
		add c
		ld c,a
		and  %00111110;and  %00000110
		ret z
		;call ShowHex
		jr SetGBCPalettes
	endif
	
SetGBCPAL:
	push hl
		LD	HL,$FF68	; set up a pointer to the BCPS
		LD	A,C			; Load A with the write specification data
		LDI	(HL),A		; place the data in the specification register and move the pointer to the  BCPD
		LD	A,E			; get the low data BYTE
		LDI	(HL),A		; send the low data BYTE to the register
		LD	HL,$FF68	; set the pointer back to the BCPS
		LD	A,C			; Load A with the write specification data
		INC	A			; Add 1 to the data, therefore setting BIT 0 which means we are now writing the high data BYTE
		LDI	(HL),A		; place the data in the specification register and move the pointer to the BCPD
		LD	A,D			; get the high data BYTE
		LDI	(HL),A		; send the high data BYTE to the register
	Pop hl
	ret
	
Copy2Bit:
	inc	b
	inc	c
	jr	.skip
.loop	ldi	a,(hl)
	ld	(de),a
	inc	de
        ld      (de),a
        inc     de
.skip	dec	c
	jr	nz,.loop
	dec	b
	jr	nz,.loop
	ret
ScreenINIT:
CLS:
	ld	hl, $9800
	
	ld a,l
	ld (NextCharX),a
	ld (NextCharY),a
	
	
	ld a,' '-32
	ld	bc, 32 * 32
	jp	SetVRAM
	
	
PrintChar:
	call PrintCharNoInc
	push af
		ld a,(NextCharX)
		inc a
		ld (NextCharX),a
	pop af
	ret
	
PrintCharNoInc:
	push hl
	push bc
	push af
	
	
	
		
		
		push af
			ld a,(NextCharY)
			ld b,a
			
			ld a,(NextCharX)
			ld c,a
			
		
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
		pop af
		sub 32		;no char <32!
		ld (hl),a
		
		ifdef BuildGBC
			ld a,1			;Turn on GBC extras
			ld (&FF4F),a	
			ld (hl),7
			ld a,0			;Turn off GBC extras
			ld (&FF4F),a	
		endif
		
	pop af
	pop bc
	pop hl
	ret
ReadJoy:
	LD A,$20      ; <- bit 5 = $20
	LD ($FF00),A  ; <- select P14 by setting it low
	LD A,($FF00);
	LD A,($FF00) ;  <- wait a few cycles
	CPL           ; <- complement A
	AND $0F       ; <- get only first 4 bits
	SWAP A        ; <- swap it
	LD B,A        ; <- store A in B
	LD A,$10
	LD ($FF00),A   ;<- select P15 by setting it low
	LD A,($FF00)
	LD A,($FF00)
	LD A,($FF00)
	LD A,($FF00)
	LD A,($FF00)
	LD A,($FF00)  ; <- Wait a few MORE cycles
	CPL           ; <- complement (invert)
	AND $0F       ; <- get first 4 bits
	OR B          ; <- put A and B together
	ret
WaitChar:
	
	ld a,(SelKeyChar)
	call PrintCharNoInc

	push bc
		call ReadJoy
		ld b,a
		ld a,(SelKeyChar)
		
		bit 0,b
		jr nz,WaitCharDone
		
		bit 6,b
		jr z,WaitCharNotDown
		inc a
WaitCharNotDown:
		bit 7,b
		jr z,WaitCharNotUp
		dec a
WaitCharNotUp:
		ld bc,&3000
		push af
WaitCharDelay:
			dec bc
			ld a,b
			or c
			jr nz,WaitCharDelay
		pop af
		cp 32
		jr nc,WaitCharNotTooLow
		ld a,96+32-1
WaitCharNotTooLow:
		cp 32+96
		jr c,WaitCharNotTooHigh
		ld a,32
WaitCharNotTooHigh:
		ld (SelKeyChar),a
		
		
	pop bc
	jr WaitChar
	
WaitCharDone:
	pop bc
	ret
	
        ;LD B,A         <- store A in D
        ;LD A,($FF8B)   <- read old joy data from ram
        ;XOR B          <- toggle w/current button bit
        ;AND B          <- get current button bit back
        ;LD ($FF8C),A   <- save in new Joydata storage
        ;LD A,B         <- put original value in A
        ;LD ($FF8B),A   <- store it as old joy data
		;LD A,$30       <- deselect P14 and P15
        ;LD ($FF00),A   <- RESET Joypad
        
		
	ret
NewLine:
	push af
		ld a,(NextCharY)
		inc a
		ld (NextCharY),a
		xor a
		ld (NextCharX),a
	pop af
	ret
PrintString:
	ld a,(hl)	;Print a '255' terminated string 
	cp 255
	ret z
	inc hl
	call PrintChar
	jr PrintString


Locate:		;Locate X=H Y=L
	push af
		ld a,L
		ld (NextCharY),a
		ld a,H
		ld (NextCharX),a
	pop af
	ret
	

	
;		    -GRB	
GBPal:	dw &0008
		dw &00F0
		dw &0F0F
		dw &0FF0
		
		;
		dw &0222
		dw &0777
		dw &0AAA
		dw &0FFF

