; Learn Multi platform Z80 Assembly Programming... With Vampires!

;Please see my website at	www.chibiakumas.com/z80/
;for the 'textbook', useful resources and video tutorials

;File		SAM coupe Firmware Functions
;Version	V1.0
;Date		2018/4/1
;Content	Provides basic text functions using Firware calls

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintChar 	equ BMP_PrintChar	
CLS 		equ BMP_CLS
Locate 		equ BMP_Locate
GetCursorPos 	equ BMP_GetCursorPos
NewLine 	equ BMP_NewLine
PrintString 	equ BMP_PrintString
WaitChar 	equ ScanKeys_WaitChar


SHUTDOWN:
	di		;Can't return to basic on a cartridge
	halt


DOINIT:
	di
	jp ScreenINIT
