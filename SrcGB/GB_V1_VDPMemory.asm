
SetCGBTileAttribs:
	push bc
	push af
		ld a,b
		ld b,c
		ld c,a
		
		ld a,1
		ld (&FF4F),a

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
	ld (hl),a
	push af
		ld a,0
		ld (&FF4F),a
	pop af
	pop bc
	ret
GBC_Turbo:
	ld a,0
	ld (&FFFF),a
	
	ld a,%00110000
	ld (&FF00),a
	
	ld a,1
	ld (&FF4D),a
	stop
	ret
	
LCDWait:
	push    af
        di
.waitagain
        ld      a,($FF41)  
        and     %00000010  
        jr      nz,.waitagain 
    pop     af	
	ret

	
StopLCD:
        ld      a,($FF40)
        rlca                    ; Put the high bit of LCDC into the Carry flag
        ret     nc              ; Screen is off already. Exit.
.wait:							; Loop until we are in VBlank
        ld      a,($FF44)
        cp      145             ; Is display on scan line 145 yet?
        jr      nz,.wait        ; no, keep waiting
        ld      a,($FF40)	; Turn off the LCD
        res     7,a             ; Reset bit 7 of LCDC
        ld      ($FF40),a
        ret
		
		
		
SetVRAM::
	inc	b
	inc	c
	jr	.skip
.loop   call LCDWait
        ldi      (hl),a
        ei
.skip	dec	c
	jr	nz,.loop
	dec	b
	jr	nz,.loop
	ret