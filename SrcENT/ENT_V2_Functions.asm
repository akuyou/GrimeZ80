; Learn Multi platform Z80 Assembly Programming... With Vampires!

;Please see my website at	www.chibiakumas.com/z80/
;for the 'textbook', useful resources and video tutorials

;File		Enterprise Firmware Functions
;Version	V1.0c
;Date		2018/3/20
;Content	Provides basic text functions using Firware calls

;Changes	PrintString updated to protect BC
;changes	PrintChar was corrupting de
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; Note RST6 is our EXOS call.	



PrintChar 		equ BMP_PrintChar	
CLS 			equ BMP_CLS
Locate 			equ BMP_Locate
GetCursorPos 	equ BMP_GetCursorPos
NewLine 		equ BMP_NewLine
PrintString 	equ BMP_PrintString
WaitChar 		equ ScanKeys_WaitChar




SHUTDOWN:
	di
	halt
DOINIT:
	di


	jp ScreenINIT
