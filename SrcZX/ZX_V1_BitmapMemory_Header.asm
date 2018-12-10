BmpByteWidth equ 1
CharByteWidth equ 1


	macro NextScrByte
		inc l
	endm
	ifdef vasm
		macro SetScrByte,newbyte
			ld (hl),\newbyte
			NextScrByte
		endm
	else
		macro SetScrByte newbyte
			ld (hl),newbyte
			NextScrByte
		endm
	endif
	macro SetScrByteBW
		ld (hl),a
		NextScrByte
	endm
	macro ScreenStartDrawing
	endm
	macro ScreenStopDrawing
	endm
