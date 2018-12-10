;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		Speccy beeper test
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ChibiSound:
	or a
	jr z,Silent
	xor %00111111
	ld h,a

	and %01000000
	jr nz,HighVol
	ld a,%10111011
	jr setVol
HighVol:
	ld a,%11111111

setVol:
	ld d,a
	ld a,&0
;	ld d,%11111111
	call SetSoundRegister	;Volume 0

	ld a,&1C
	ld d,%00000001
	call SetSoundRegister	;Enable Sound

	ld a,h
	and %00001111
	rrca
	rrca
	rrca
	rrca
	or %00001111
	ld d,a

	ld a,&8
;	ld d,%11111111
	call SetSoundRegister	;Tone 0

	ld a,h
	and %00110000
	rrca
	rrca
	rrca
	rrca
	ld d,a
	ld a,&10
;	ld d,%00000100
	call SetSoundRegister	;Octive 0

	ld a,&14
	ld d,%0000001
	call SetSoundRegister	;Tone Enable 

	ld a,h
	and %10000000
	ret z
	;Here comes the noise!

	ld a,&15
	ld d,%00000001
	call SetSoundRegister	;Noise Enable 

	ld a,&16
	ld d,%00110011
	call SetSoundRegister	

	ld a,&14
	ld d,%00000000
	call SetSoundRegister	;Tone Enable 

	ret
Silent:
	ld a,&14
	ld d,0
	call SetSoundRegister	;Tone Enable 

	ld a,&15
	ld d,0
	call SetSoundRegister	;Noise Enable 

	ret
SetSoundRegister
	ld bc,511
	out (c),a

	ld bc,255
	ld a,d
	out (c),a
	ret