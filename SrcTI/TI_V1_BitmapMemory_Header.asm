
TI_LCD_COMM equ &10
TI_LCD_DATA equ &11



	macro NextScrByte
	endm
	ifdef vasm
		macro SetScrByte,newbyte
		ifdef	ScrTISmall				;We have a special option to bitshift 8 pixels to 6 for the TI 'Narrow Mode'
		push af
		push bc
			xor a
			rl \newbyte
			rl a

			rl \newbyte
			rl a
			rl \newbyte

			rl \newbyte
			rl a

			rl \newbyte
			rl a

			rl \newbyte
			rl a
			rl \newbyte

			rl \newbyte
			rl a

			out (TI_LCD_DATA),a		;send the byte to the GPU
			call &000B ;_LCD_BUSY_QUICK	;Delay

		pop bc
		pop af
		else
			push af
			ld a,\newbyte
			out (TI_LCD_DATA),a			;send the byte to the GPU
			pop af
			call &000B ;_LCD_BUSY_QUICK		;Delay

		endif

		endm
		
	else
		
		macro SetScrBytenewbyte
		ifdef	ScrTISmall				;We have a special option to bitshift 8 pixels to 6 for the TI 'Narrow Mode'
		push af
		push bc
			xor a
			rl newbyte
			rl a

			rl newbyte
			rl a
			rl newbyte

			rl newbyte
			rl a

			rl newbyte
			rl a

			rl newbyte
			rl a
			rl newbyte

			rl newbyte
			rl a

			out (TI_LCD_DATA),a		;send the byte to the GPU
			call &000B ;_LCD_BUSY_QUICK	;Delay

		pop bc
		pop af
		else
			push af
			ld a,newbyte
			out (TI_LCD_DATA),a			;send the byte to the GPU
			pop af
			call &000B ;_LCD_BUSY_QUICK		;Delay

		endif

		endm
	endif


	macro SetScrByteBW
	ifdef	ScrTISmall
	push af
	push bc
		ld b,0
		rl a
		rl b

		rl a
		rl b
		rl a

		rl a
		rl b

		rl a
		rl b

		rl a
		rl b
		rl a

		rl a
		rl b

		ld a,b
			out (TI_LCD_DATA),a		;Send Byte to GPU
			call &000B ;_LCD_BUSY_QUICK	;Delay

	pop bc
	pop af
	else
			out (TI_LCD_DATA),a		;Send Byte to GPU
			call &000B ;_LCD_BUSY_QUICK	;Delay
	endif
	endm

	macro ScreenStartDrawing
	endm
	macro ScreenStopDrawing
	endm
	