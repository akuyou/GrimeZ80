org &8000
	jp SaveScreen	;&8000
	jp LoadScreen	;&8003
	jp ClearScreen	;&8006


Mode2 equ 1	;Unrem this for Fast unwrapped version using LDI


SaveScreen:
	;Usage
	;	Call &8000,&C4		- Copy screen to &4000 in bank C4

	cp 1		;Check we got one parameter
	ret nz		;return if we did not
	ld a,(ix+0)	;Get the parameter
	cp &C0		;Check it looks like a CPC Bank
	ret C		;Return if not

	di			;Disable interrupts while we bank switch

		call Bankswitch	;Switch to the bank

		ld hl,&C000
		ld de,&4000
		ld bc,&4000	;Copy one screen from &C000 to &4000

		ifndef Mode2
			ldir	; USE LDIR
		else
			Call UseLDI ; Use Unwrapped LDI
		endif
	
		ld a,&C0	;Turn the default bank back on
		call Bankswitch
	ei			;Turn on interupts
ret

LoadScreen:
	;Usage
	;	Call &8003,&C4		- Copy screen from &4000 in bank C4

	cp 1		;Check we got one parameter
	ret nz		;return if we did not
	ld a,(ix+0)	;Get the parameter
	cp &C0		;Check it looks like a CPC Bank
	ret C		;Return if not
	di			;Disable interrupts while we bank switch

		call Bankswitch	;Switch to the bank

		ld de,&C000
		ld hl,&4000
		ld bc,&4000	;Copy one screen from &4000 to &C000

		ifndef Mode2
			ldir	; USE LDIR
		else
			Call UseLDI ; Use Unwrapped LDI
		endif

		ld a,&C0	;Turn the default bank back on
		call Bankswitch
	ei			;Turn on interupts
ret

Bankswitch: 			;pass A=&C0-&C7 to switch to that bank - see cheatsheet
	LD B,&7F		;Send Bank command to Gate aray at &7Fxx
	OUT (C),A 
	ret




ifdef Mode2
UseLDI:
	ldi	;We've 'unwrapped' LDIR into 16 LDI's - reducing the number of 'R repeates' by 15 out of 16
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ret PO	;LDI/LDIR return Overflow when BC=0
jp UseLDI
endif





ClearScreen:
	di				;For safety - you CAN disable this, but an interrupt execution could cause
					;a crash as it will write to the screen, if this happens at &C000 who knows
					;what it will overwrite

	ld (SP_Restore_Plus2-2),sp	;Back up our stackpointer using self modifying code.
	ld sp,&0000	;One byte more than the area we want to fill - because PUSHING decreases the stack pointer
	ld de,&0000	;Bytes we want to fill with 0000 sets all 8 pixels to color 0
	ld b,0	;256	;Count of number of 

ClearScreenAgain:
	push de		;64 bytes of DE pushses!
	push de
	push de
	push de
	push de
	push de
	push de
	push de

	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de

	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de

	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de

djnz ClearScreenAgain	;Repeat

	ld sp,&0000:SP_Restore_Plus2	;restore the stack pointer
	ei
ret					





