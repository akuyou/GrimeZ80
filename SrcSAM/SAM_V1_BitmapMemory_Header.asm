; Learn Multi platform Z80 Assembly Programming... With Vampires!

;Please see my website at	www.chibiakumas.com/z80/
;for the 'textbook', useful resources and video tutorials

;File		SAM coupe Bitmapheader
;Version	V1.2
;Date		2018/7/5

;Changes	Bitshifts have been altered on b/w printing, they now print in color 15 on all systems, or color 3 on 4 color systems

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



BmpByteWidth equ 4
CharByteWidth equ 4

	macro NextScrByte
		inc l
	endm

	
	ifndef vasm
	macro SetScrByte newbyte
		ld (hl),newbyte
		NextScrByte
	endm
	else
	macro SetScrByte,newbyte
		ld (hl),\newbyte
		NextScrByte
	endm
	endif

	macro SetScrByteBW
		push af				;Split up the byte into 4 2 pixel bits and show it.
			push bc
				ld c,a
			
				xor a		
				rl c
				rl a
				rlca
				rlca
				rlca
				rl c
				rl a
				ld b,a
				rlca
				or b
				rlca
				or b
				rlca
				or b
				ld (hl),a
				NextScrByte

				xor a
				rl c
				rl a
				rlca
				rlca
				rlca
				rl c
				rl a
				ld b,a
				rlca
				or b
				rlca
				or b
				rlca
				or b
				ld (hl),a
				NextScrByte

				xor a
				rl c
				rl a
				rlca
				rlca
				rlca
				rl c
				rl a
				ld b,a
				rlca
				or b
				rlca
				or b
				rlca
				or b
				ld (hl),a
				NextScrByte

				xor a
				rl c
				rl a
				rlca
				rlca
				rlca
				rl c
				rl a
				ld b,a
				rlca
				or b
				rlca
				or b
				rlca
				or b
				ld (hl),a
				NextScrByte

			pop bc
		pop af
	endm




	macro ScreenStartDrawing
		push af
		push bc
			di
			ld bc,250 	;LMPR - Low Memory Page Register (250 dec) 
			ld a,%00100010  ;Turn off Rom 0
			out (c),a
		pop bc
		pop af
	endm

	macro ScreenStopDrawing
		push af
		push bc
			di
			ld bc,250 	;LMPR - Low Memory Page Register (250 dec) 
			ld a,%00000010  ;Turn on Rom 0
			out (c),a
		pop bc
		pop af
	endm

;LMPR - Low Memory Page Register (250 dec) 
;	Bit 0 R/W  BCD 1 of low memory page control.
;	Bit 1 R/W  BCD 2 of low memory page control.
;	Bit 2 R/W  BCD 4 of low memory page control.
;	Bit 3 R/W  BCD 8 of low memory page control.
;	Bit 4 R/W  BCD 16  of low memory bank control.
;	Bit 5 R/W  RAM0 when bit set high, RAM replaces the first half of the ROM (ie ROM0) in section A of the CPU address map.
;	Bit 6 R/W  ROM1 when bit set high, the second half of the ROM (ie ROM1) replaces the RAM in section D of the CPU address map
;	Bit 7 R/W  WPRAM Write Protection of the RAM in section A of the CPU address map is enabled when this bit is set high.