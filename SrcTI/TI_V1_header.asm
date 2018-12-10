; Learn Multi platform Z80 Assembly Programming... With Vampires!

;Please see my website at	www.chibiakumas.com/z80/
;for the 'textbook', useful resources and video tutorials

;File		TI-83 Header
;Version	V1.0
;Date		2018/3/01
;Content	Generic Header

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PutString		equ &450A

	write "..\BldTI\program.bin"


	Org &9D93
	db &BB,&6d	;Header
ProgramOrg:
	;Program actually starts at 9D95
	print "*** TI-83+ Build ***"
	print "*** Saved to BldTI\program.bin ***"
	print "*** Run Ti_Go.bat ***"

BuildCPCv equ 0
BuildMSXv equ 0
BuildTI8v equ 1
BuildZXSv equ 0
BuildENTv equ 0
BuildSAMv equ 0


ScreenWidth16 equ 1
ScreenHeight8 equ 1

	ifdef ScrTISmall
ScreenWidth equ 16
	else
ScreenWidth equ 12
	endif
ScreenHeight equ 8

KeyChar_Enter equ 5
KeyChar_Backspace equ 10

