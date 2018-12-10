PrintChar 	equ &BB5A

	org &8000
			;DAA will 'wrap' A-F in each nibble, and sets the carry flag for ADD/SUB actions
	ld a,&88
	add &22 	;A will now contain &AA  	
	daa		;A will now contain &10 and the Carry flag will be set

	ld a,&11
	sub &22		;A will now contain &EF with the Carry flag set
	daa		;A will now contain &89
	ret

	
	
	org &8100
	call ShowTest		;Show Val1 to screen

	ld de,BCD_Val1		;Destination
	ld hl,BCD_Val2		;Value to subtract
	ld b,5			;Number of Bytes (2 digits per byte)
	call BCD_Subtract

	call ShowTest

	ld de,BCD_Val1	;Destination
	ld hl,BCD_Val3	;Value to subtract
	ld b,5
	call BCD_Subtract

	call ShowTest

	ld de,BCD_Val1	;Destination
	ld hl,BCD_Val3	;Value to subtract
	ld b,5
	call BCD_Add

	call ShowTest

	ld de,BCD_Val1	;Destination
	ld hl,BCD_Val2	;Value to subtract
	ld b,5
	call BCD_Add

	call ShowTest

	ld de,BCD_Val1	;value A
	ld hl,BCD_Val1	;value to compare to CP
	ld b,5
	call BCD_Cp	;Compare to Same, result should be Z 

	ld de,BCD_Val1	
	ld hl,BCD_ValH
	ld b,5
	call BCD_Cp	;Compare to Higher, result should be C

	ld de,BCD_Val1
	ld hl,BCD_ValL
	ld b,5
	call BCD_Cp	;Compare to Lower, result should be NC

	ret
ShowTest:
	ld de,BCD_Val1	;String to show
	ld b,5		;Bytes
	call BCD_Show	;Show it!
	call NewLine
	ret


BCD_Show:
	call BCD_GetEnd		;Need to process from the end of the array
BCD_Show_Direct:
	ld a,(de)
	and %11110000		;Use the high nibble
	rrca
	rrca
	rrca
	rrca
	add '0'			;Convert to a letter and print it
	call PrintChar
	ld a,(de)	
	dec de
	and %00001111		;Now the Low nibble
	add '0'
	call PrintChar	
	djnz BCD_Show_Direct	;Next byte
	ret

BCD_Subtract:
	or a		;Clear Carry
BCD_Subtract_Again:
	ld a,(de)
	sbc (hl)	;Subtract HL from DE with carry
	daa		;Fix A using DAA
	ld (de),a	;Store it

	inc de
	inc hl
	djnz BCD_Subtract_Again
	ret

BCD_Add:
	or a		;Clear Carry
BCD_Add_Again:
	ld a,(de)
	adc (hl)	;Add HL to DE  with carry
	daa		;Fix A using DAA
	ld (de),a	;store it

	inc de
	inc hl
	djnz BCD_Add_Again
	ret

BCD_Cp:
	call BCD_GetEnd
BCD_Cp_Direct:		;Start from MSB
	ld a,(de)
	cp (hl)
	ret c		;Smaller
	ret nz		;Greater
	dec de		;equal... move onto next Byte
	dec hl
	djnz BCD_Cp_Direct
	or a ;CCF
	ret

BCD_GetEnd:
;Some of our commands need to start from the most significant byte
;This will shift HL and DE along b bytes
	push bc
		ld c,b	;We want to add BC, but we need to add one less than the number of bytes
		dec c
		ld b,0
		add hl,bc
		ex hl,de	;We've done HL, but we also want to do DE

		add hl,bc
		ex hl,de
	pop bc
	ret


;BCD Data
;Least significant Byte first!

BCD_Val1: db &00,&00,&00,&19,&01	;This is the value we will show

BCD_Val2: db &00,&00,&00,&33,&00	;These are used for addition/Subtraction
BCD_Val3: db &01,&00,&00,&00,&00


BCD_ValH: db &00,&00,&00,&20,&01	;used for compare - it is HIGHER
BCD_ValL: db &00,&00,&00,&18,&01	;used for compare - it is LOWER


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NewLine:
	push af
	ld a,13		;Carriage return
	call PrintChar
	ld a,10		;Line Feed 
	call PrintChar
	pop af
	ret