GBC_Turbo:
	ld a,0
	ld (&FFFF),a
	
	ld a,%00110000
	ld (&FF00),a
	
	ld a,1
	ld (&FF4D),a
	stop
	ret