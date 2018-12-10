ChibiSound:
	or a
	jr z,silent
	
	xor %00111111
	ld h,a
	ld a,%01110111 ;-LLL-RRR Channel volume
	ld (&FF24),a
	
	
	;Channel 1
	
	ld a,%10010000
	bit 6,h
	jr z,LowVol
	ld a,%11110000
LowVol:
	ld (&FF12),a	;Vol
	
	
	ld a,h
	and %00000111
	rrca
	rrca
	rrca
	;ld a,64	;%LLLLLLLL pitch L
	ld (&FF13),a
	
	
	ld a,h
	and %00111000
	rrca
	rrca
	rrca
	or  %10000000
	;ld a,%10000111	;%IC---HHH	C1 Initial / Counter 1=stop / pitch H
	ld (&FF14),a
	
	;ld a,%11110001	;%VVVVDNNN C1 Volume / Direction 0=down / envelope Number (fade speed)
	;ld (&FF12),a

	bit 7,h
	jr z,NoiseOff
	
	ld a,h
	and %00111100
	xor %00111100
	rrca
	rrca
	swap a
	or %00000111
	ld (&FF22),a
	
	
	ld a,%10000000	;%IC------	C1 Initial / Counter 1=stop
	ld (&FF23),a
	
	ld a,(&FF12)
	ld (&FF21),a
	
	xor a
	ld (&FF12),a
	ld a,%10001000 ;Mixer LLLLRRRR Channel 1-4 L / Chanel 1-4R
	ld (&FF25),a
	ret
	
NoiseOff:
	ld a,%00010001 ;Mixer LLLLRRRR Channel 1-4 L / Chanel 1-4R
	ld (&FF25),a
	xor a
	ld (&FF21),a
	ret
	
silent:
	ld a,0
	ld (&FF25),a
	ret