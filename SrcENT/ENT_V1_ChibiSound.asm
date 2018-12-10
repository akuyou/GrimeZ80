ChibiSound:
	or a
	jr z,silent
	ld h,a
	
;	ld a,h
	and %00000111
	rrca
	rrca
	rrca
	or %00011111

;	ld a,%00000100
	out (&a0),a		;&A0 - Channel 0 Tone L	LLLLLLLL 	LLLL Tone
;	ld a,%000010000

	ld a,h
	and %00111000
	rrca
	rrca
	rrca
	out (&a1),a		;&A1 - Channel 0 Tone H	RPCCHHHH	R=Ring modulator / high Pass /  polynominal Counter distortion / HHHH Tone

	ld a,h
	and %01000000
	rrca
;	rrca
	xor %00011111
;	ld a,0;%00111111		
	out (&A8),a		;&A8 - Tone Channel 0 LH Amplitude --VVVVVV / D/A ladder (tape port, Speaker) 
	out (&AC),a		;&AC - Tone Channel 0 RH Amplitude --VVVVVV / D/A ladder (tape port, Speaker R)  

	xor a
	out (&AB),a		;&A8 - noise Channel 0 LH Amplitude --VVVVVV / D/A ladder (tape port, Speaker) 
	out (&AF),a		;&AC - noise Channel 0 RH Amplitude --VVVVVV / D/A ladder (tape port, Speaker R)  


	bit 7,h			;Return if we're not making a noise!
	ret z

;Noise 4 U
	xor a
	out (&A8),a		;&A8 - Tone Channel 0 LH Amplitude --VVVVVV / D/A ladder (tape port, Speaker) 
	out (&AC),a		;&AC - Tone Channel 0 RH Amplitude --VVVVVV / D/A ladder (tape port, Speaker R)  

	ld a,1
	out (&A6),a		;&A8 - Tone Channel 0 LH Amplitude --VVVVVV / D/A ladder (tape port, Speaker) 

	ld a,h
	and %01000000
	rrca
	xor %00011111
	out (&AB),a		;&A8 - noise Channel 0 LH Amplitude --VVVVVV / D/A ladder (tape port, Speaker) 
	out (&AF),a		;&AC - noise Channel 0 RH Amplitude --VVVVVV / D/A ladder (tape port, Speaker R)  

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
;&AB - Noise Channel LH Amplitude  --VVVVVV 
;&AC - Tone Channel 0 RH Amplitude / D/A ladder (Speccy Emu R)
;&AD - Tone Channel 1 RH Amplitude --VVVVVV 
;&AE - Tone Channel 2 RH Amplitude --VVVVVV 
;&AF - Noise Channel RH Amplitude  --VVVVVV 

	ret
silent:
	xor a
	out (&A8),a		;&A8 - Tone Channel 0 LH Amplitude --VVVVVV / D/A ladder (tape port, Speaker) 
	out (&AC),a		;&AC - Tone Channel 0 RH Amplitude --VVVVVV / D/A ladder (tape port, Speaker R)  

	out (&AB),a		;&A8 - noise Channel 0 LH Amplitude --VVVVVV / D/A ladder (tape port, Speaker) 
	out (&AF),a		;&AC - noise Channel 0 RH Amplitude --VVVVVV / D/A ladder (tape port, Speaker R)  

	ret