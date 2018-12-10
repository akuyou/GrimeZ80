ChibiSound:
	or a
	jr z,silent
	ld h,a

	ld a,%11001111	;1CCTLLLL	(Latch - Channel Type DataL
	out (&7F),a
	ld a,h
	and %00111111

;	ld a,%00001000	;0-HHHHHH	(Latch off - Data H)
	out (&7F),a

	ld a,h
	and %01000000
	rrca
	rrca
	rrca
	rrca
	xor %11010100
;	ld a,%11011111	;1CCTVVVV	(Latch - Channel Type Volume)	
	out (&7F),a

	ld a,%11111111	;1CCTVVVV	(Latch - Channel Type Volume)	
	out (&7F),a


	bit 7,h
	ret z

	ld a,%11011111	;1CCTVVVV	(Latch - Channel Type Volume)	
	out (&7F),a

	ld a,%11100111	;1CCT-MRRr	(Latch - Channel Type... noise Mode (1=white) Rate (Rate 11= use Tone Channel 2)
	out (&7F),a

	ld a,%11110000	;1CCTVVVV	(Latch - Channel Type Volume)	
	out (&7F),a


	ret

silent:
	ld a,%11111111	;1CCTVVVV	(Latch - Channel Type Volume)	
	out (&7F),a
	ld a,%11011111	;1CCTVVVV	(Latch - Channel Type Volume)	
	out (&7F),a
	ret

;	ld a,%11001111	;1CCTLLLL	(Latch - Channel Type DataL
;	out (&7F),a
;	ld a,%00001000	;0-HHHHHH	(Latch off - Data H)
;	out (&7F),a

;	ld a,%11011111	;1CCTVVVV	(Latch - Channel Type Volume)	
;	out (&7F),a


;	ld a,%11100011	;1CCT-MRRr	(Latch - Channel Type... noise Mode (1=white) Rate (Rate 11= use Tone Channel 2)
;	out (&7F),a

;	ld a,%11110000	;1CCTVVVV	(Latch - Channel Type Volume)	
;	out (&7F),a