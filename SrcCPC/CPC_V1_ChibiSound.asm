ChibiSound:			;NVVTTTTT	Noise Volume Tone 
	or a
	jr z,silent
	
	ld h,a
	and %00000111
	rrca
	rrca
	rrca
	or %00011111
	ld c,a
	ld a,0			;TTTTTTTT Tone Lower 8 bits	A
	call RegWrite

	ld a,h
	and %00111000
	rrca
	rrca
	rrca
	ld c,a
	ld a,1			;----TTTT Tone Upper 4 bits
	call RegWrite
	bit 7,h
	jr z,AYNoNoise

	ld a,7			;Mixer  --NNNTTT (1=off) --CBACBA
	ld c,%00110110
	call RegWrite

	ld a,6			;Noise ---NNNNN
	ld c,%00011111
	call RegWrite


	jr AYMakeTone
AYNoNoise:
	ld a,7			;Mixer  --NNNTTT (1=off) --CBACBA
	ld c,%00111110
	call RegWrite
	jr AYMakeTone
AYMakeTone:
	;*** these are incorrectly marked as Amplitude Control (Registers R10,R11,R12) in some documentation! ***
	ld a,h
	and %01000000
	rrca
	rrca
	rrca
	rrca
	or  %00001011
	ld c,a
	ld a,8			;4-bit Volume / 2-bit Envelope Select for channel A ---EVVVV
	call RegWrite
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
silent:
	ld a,7		;Mixer  --NNNTTT (1=off) --CBACBA
	ld c,%00111111
	call RegWrite
	

	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RegWrite:
	ifdef BuildCPC
		push bc
			ld b,&f4
			ld c,a
			out (c),c	;#f4 Regnum

			ld bc,&F6C0	;Select REG
			out (c),c	

			ld bc,&f600	;Inactive
			out (c),c

			ld bc,&F680	;Write VALUE
			out (c),c	
		pop bc
		ld b,&F4	;#f4 value
		out (c),c

		ld bc,&f600	;; "inactive"
		out (c),c
		ret
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	ifdef BuildZXS
		push bc
			ld bc,&FFFD
			out (c),a	;Regnum
		pop bc
		ld a,c
		ld bc,&BFFD
		out (c),a	;Value
		ret
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef BuildMSX
		push bc
			out (#a0),a	;regnum
		pop bc
		ld a,c
		out (#a1),a	;value
		ret
	endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;