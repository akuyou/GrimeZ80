; Learn Multi platform Z80 Assembly Programming... With Vampires!

;Please see my website at	www.chibiakumas.com/z80/
;for the 'textbook', useful resources and video tutorials

;File		Example 7
;Version	V1.0
;Date		2018/3/04
;Content	DI EI, RST x, Custom Interrupts, IM1/IM2, HALT, OTI / OTIR, HALT

;Eg2 equ 1		;Enable this line for the more complex example

	org &8000

		di	;Lets install our interrupt handler - we need to disable interrupts when we set up
			;our custom interrupt handler

			exx
			push bc		;The CPC needs BC' to be backed up or the firmware will die
			exx

			ld hl,(&0038)	;Back up the CPC interrupt handler (at RST7)
			push hl	
			ld hl,(&003A)	
			push hl	
		
			ld a,&C3
			ld (&0038),a	;Overwrite RST7 with JP
		
			ld hl,InterruptHandler	
			ld (&0039),hl	;Put our label address after the JP

		ei	;Let our interrupt handler run when it wants

		ld hl,&C000

		ld d,10		;Counnter for the number of times we'll clear the screen
		ld c,%11111111	;Bitmask for the Xor command
	InfLoop:
	ifndef EG2
		halt
	endif
	ifdef EG2
		ld a,(hl)	;Flip the bits in a screen byte
		xor c
		ld (hl),a
		inc hl

		ld a,h		;See if H=0
		or a
		jp z,PageDone	;Reset and decrease our counter
	endif
	jp InfLoop

PageDone:
	ld hl,&C000	;Restart the screen
	dec d
	jp nz,InfLoop		;Fill the screen 10 times

	;We're done, but we need to restore things to keep the firmware working.

	di			
		pop hl		;Restore the firmware interrupt handler
		ld (&003A),hl
		pop hl	
		ld (&0038),hl

		exx	
		pop bc		;restore BC' to keep the CPC happy
		exx
	ei
	ret

InterruptHandler:
	;IM1 calls &0038 (RST7) when interrupts occur

	;On the CPC this interrupt handler run 6 times per screen (300hz)
	;On other systems (MSX/ZX/ENT) it runs 1 time per screen (50hz)

	;BUT - we cannot override the spectrum interrupt handler, because &0000-&3FFF is READ ONLY ROM
	;We can use IM2 instead - but it's more complex, we'll learn about this later!

	exx		;Flip over to the shadow registers - we use these so we don't hurt the normal registers
	ex af,af'

	ld hl,RasterColors :IH_RasterColor_Plus2


	;Read in the screen status - we use this to check if we're at the top of the screen
	ld      b,&f5
	in      a,(c)	;Actually in a,(b)

	rra     ;pop the rightmost bit into the carry
	jp nc,InterruptHandlerOk

	ld hl,RasterColors

InterruptHandlerOk:
	;Define that we're changing COLOR 0
	;B=&7F 	Gate Array port
	;C=0	Set color Number (0)
	ld bc,&7f00      
	out (c),c   	;On the CPC and spectrun this is actually Out (B),C
	ifndef EG2    
		ld a,(hl)	;Read in the new color definition
		out (c),a    
		inc hl
	endif

	ifdef EG2    
		outi		;OUTI does not work right on the CPC
		inc b		;So we need to do INC B
		
		inc c		;inc C - to change the next color
		out (c),c	;Set the Color number

		outi		;OUTI does not work right on the CPC
		inc b		;So we need to do INC B
		
		inc c		;inc C - to change the next color
		out (c),c	;Set the Color number

		outi		;OUTI does not work right on the CPC
		inc b		;So we need to do INC B
		
		inc c		;inc C - to change the next color
		out (c),c	;Set the Color number

		outi		;OUTI does not work right on the CPC

	endif
	ld (IH_RasterColor_Plus2-2),hl

	ex af,af';Restore the normal registers
	exx

	ei	;We've handled the intterupt - so turn interrupts back on
	ret


RasterColors:
	;These are hardware color numbers - they are not the same 
	;as the color numbers used by basic.
	ifndef EG2    
		db &4C,&43,&52,&5C,&5E,&5F
	endif
	ifdef EG2    
		db &4C,&43,&52,&5C	;Change 1
		db &52,&5C,&4C,&43	;Change 2
		db &4C,&43,&52,&5C	;Change 3
		db &52,&5C,&4C,&43	;Chance 4
		db &4C,&43,&52,&5C	;Change 5
		db &52,&5C,&4C,&43	;Change 6
	endif