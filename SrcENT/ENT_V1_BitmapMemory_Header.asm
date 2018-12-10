; Learn Multi platform Z80 Assembly Programming... With Vampires!

;Please see my website at	www.chibiakumas.com/z80/
;for the 'textbook', useful resources and video tutorials

;File		ENT Bitmapheader
;Version	V1.2
;Date		2018/7/5

;Changes	Bitshifts have been altered on b/w printing, they now print in color 15 on all systems, or color 3 on 4 color systems

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BmpByteWidth equ 2
	ifdef ScrColor16
CharByteWidth equ 4
	else
CharByteWidth equ 2	
	endif

	ifndef ScrWid256

		macro NextScrByte
			inc hl		;We have to use 'inc HL' if our screen is 320 pixels wide
		endm
	else
		macro NextScrByte
			inc l		;If we're using 256 pixel width we can use the faster 'Inc L'
		endm


	endif

	ifdef vasm
		macro SetScrByte,newbyte
			ld (hl),\newbyte		;Set a screen position by byte - the byte must be in the format for the system!
			NextScrByte
		endm
	else
		macro SetScrByte newbyte
			ld (hl),newbyte		;Set a screen position by byte - the byte must be in the format for the system!
			NextScrByte
		endm
	endif

	ifndef ScrColor16		;4 color mode (2bpp)

		macro SetScrByteBW
					;use a 2 bit bitmap in a common way on all platforms
		push bc
		push af
			and %11110000	;in 4 color mode we use half the 'character 
			ld b,a
			rrca
			rrca
			rrca
			rrca
			or b
			ld (hl),a
			NextScrByte
		pop af
		push af
			and %00001111	;Do the 2nd half - we have to put it in the following byte.
			ld b,a
			rrca
			rrca
			rrca
			rrca
			or b
			ld (hl),a
			NextScrByte
		pop af
		pop bc
		endm
	else					;16 color mode (4bpp)
		macro SetScrByteBW		
		push bc
			ld c,a
			and %11000000		;In 16 color mode we have to slice up the bitmap into 4 chunks and put them over 4 bytes
			ld (hl),a
			NextScrByte

			ld a,c
			and %00110000
			rlca
			rlca
			ld (hl),a
			NextScrByte

			ld a,c
			and %00001100
			rlca
			rlca
			rlca
			rlca
			ld (hl),a
			NextScrByte

			ld a,c
			and %00000011
			rrca
			rrca
			ld (hl),a
			NextScrByte
			ld a,c

		pop bc
		endm
	endif
	macro ScreenStartDrawing
	endm
	macro ScreenStopDrawing
	endm
