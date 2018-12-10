; Learn Multi platform Z80 Assembly Programming... With Vampires!

;Please see my website at	www.chibiakumas.com/z80/
;for the 'textbook', useful resources and video tutorials

;File		CPC Firmware Functions
;Version	V1.0b
;Date		2018/3/20
;Content	Provides basic text functions using Firware calls

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



PrintChar 	equ BMP_PrintChar	
CLS 		equ BMP_CLS
Locate 		equ BMP_Locate
GetCursorPos 	equ BMP_GetCursorPos
NewLine 	equ BMP_NewLine
PrintString 	equ BMP_PrintString
WaitChar 	equ ScanKeys_WaitChar

DOINIT:

	jp ScreenINIT

SHUTDOWN:
	ret