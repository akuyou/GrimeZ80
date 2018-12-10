; Learn Multi platform Z80 Assembly Programming... With Vampires!

;Please see my website at	www.chibiakumas.com/z80/
;for the 'textbook', useful resources and video tutorials

;File		Example 5
;Version	V1.0
;Date		2018/2/12
;Content	Bit operations AND OR XOR,Shifts and Carry, Self modifying code.




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Run with Call &8000

;Mask bits - try this on Mode 2 for best appearance

org &8000

	ld hl,&C000	;We're going to alter the screen
AgainE:
	ld a,(hl)	;Load a byte from the screen



	xor %11111111	;Invert the bits that are 1

       ;and %11111110 	;Clear the bits that are 0 
       ;and %11111110 is the same as res 0,a

        ;or %00000001 	;Set the bits to 1
        ;or %00000001 is the same as set 0,a


	ld (hl),a	;Load the modifyed byte to the screen

	inc l		;Increase L
	jp nz,AgainE	;Repeat if it's not reached zero

	inc h		;We've zero'd L - so we need ti INC H
	jp nz,AgainE	; when HL=0000 we've finished the screen
			; Note  inc L  is faster than INC HL so this saves time.
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Run with Call &8050

; Try:
; Call &8050,&80xx - this is the same as AND XX
; Call &8050,&40xx - this is the same as OR XX

org &8050
	cp 1
	ret nz
	ld b,(ix+1)
	ld c,(ix+0)
	ld hl,&C000
Again:
	ld a,(hl)

	bit 7,b		;if Bit 7 is set to 1 (&80) then we will use AND
	jr z,NoAnd	;Z if bit wasn't set
	and c
NoAnd:
	bit 6,b		;if Bit 6 is set to 1 (&40) then we will use OR
	jr z,NoOR	;Z if bit wasn't set
	or  c
NoOR:

	ld (hl),a	;Load the altered bit into the memory location
	inc l
	jp nz,Again
	inc h	
	jp nz,Again
ret


org &8100
	ld hl,&C000	;This version will shift to the Right
AgainB:
	ld a,(hl)

;	RR a   ;Rotates r right with carry (RRA is actually faster)
;	RRC a  ;Rotates r right with wrap (RRCA is actually faster)

;	SRA a  ;Shifts r right, top bit = previous top bit
	SRL a  ;Shifts r right, top bit 0

	ld (hl),a
	inc l
	jp nz,AgainB
	inc h	
	jp nz,AgainB
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Run with Call &8200

org &8200
	di
	ld hl,&FF00	;This version will shift to the left
AgainC:
	ld a,(hl)
	
;	RL a   ;Rotates r left with carry (RLA is actually faster)
;	RLC a  ;Rotates r left with wrap  (RLCA is actually faster)


;	SLA a  ;Shifts r left, bottom bit 0
	SLL a  ;Shifts r left, bottom bit 1


	ld (hl),a
	dec l 		;Note - first L is &00 (because &FF00) but dec l will make it &FFFF - so nonzero... 
			;this is to avoid missing &FF00 and to save overcomplicated CP 

	jp nz,AgainC
	dec h
	ld a,h
	cp &BF		;Repeat until we go below &C000
	jp nz,AgainC
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Run with Call &8300,&xxyy	where xx is operation and yy is mask

;operations
;	01	AND	yy
;	02 	OR	yy
;	03	XOR	yy

org &8300
	cp 1		
	ret nz		;We need one 16 bit parameter - if we didn't get it return

	ld a,(ix+1)	;Load the first part (xx) this is the operation

	ld hl,SMAND	;set HL to the address of the AND command
	cp 1
	jr z,Start	;Start if operation is 1

	ld hl,SMOR	;Set HL to the address of the OR command
	cp 2
	jr z,Start	;Start if operation is 2

	ld hl,SMXOR	;Set HL to the address of the XOR command
	cp 3
	jr z,Start	;Start if operation is 3
Start:
	ld a,(hl)	;Load the command's byte - remember not all commands are 1 byte!
	ld (SelfModify),a	; Load the first byte into our desination


	ld a,(ix+0)		;Load the mask (&yy) that was passed by the user
	ld (SelfModify+1),a	; Load the second byte into our desination

	ld hl,&C000	;Start the loop as before
AgainD:
	ld a,(hl)
SelfModify:
	nop	;this command will be reprogrammed to the command- try putting a breakpoint here and see how it changes
	nop	;this command will be reprogrammed to the mask

	ld (hl),a
	inc l
	jp nz,AgainD
	inc h	
	jp nz,AgainD
ret

SMAND: AND 1	;1
SMOR:  or  1	;2
SMXOR: Xor 1	;3