
	macro ScreenStartDrawing
	endm
	macro ScreenStopDrawing
	endm
	ifdef BuildMSX
		read "..\srcMSX\V1_VdpMemory_Header.asm"
	endif
	ifdef BuildCPC
		ifdef V9K
			read "..\srcMSX\V1_VdpMemory_Header.asm"
		endif
	endif