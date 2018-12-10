; Learn Multi platform Z80 Assembly Programming... With Vampires!

;Please see my website at	www.chibiakumas.com/z80/
;for the 'textbook', useful resources and video tutorials

;File		CPC Header
;Version	V1.0b
;Date		2018/3/10
;Content	Works from ROM or DSK - copies program to common address &8000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	org &8000 
ProgramOrg:
	print "*** Amstrad CPC Build ***"
	print "*** Compiled to memory and disk ***"
	print '*** Type Call {and}8000 to run / or run "go" ***'

BuildCPCv equ 1
BuildMSXv equ 0
BuildTI8v equ 0
BuildZXSv equ 0
BuildENTv equ 0
BuildSAMv equ 0

	ifdef ScrWid256
ScreenWidth32 equ 1
ScreenHeight24 equ 1
ScreenWidth equ 32
ScreenHeight equ 24
	else
ScreenWidth40 equ 1
ScreenHeight25 equ 1
ScreenWidth equ 40
ScreenHeight equ 25	
	endif

KeyChar_Enter equ 13
KeyChar_Backspace equ &7F



FileBegin: