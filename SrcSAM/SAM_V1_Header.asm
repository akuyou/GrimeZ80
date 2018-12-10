; Learn Multi platform Z80 Assembly Programming... With Vampires!

;Please see my website at	www.chibiakumas.com/z80/
;for the 'textbook', useful resources and video tutorials

;File		SAM coupe Header
;Version	V1.0
;Date		2018/4/1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	write "Z:\BldSAM\program"
	org &8000
ProgramOrg:

	print "*** SAM Coupe Build ***"
	print "*** Saved to RelSAM\Disk.DSK ***"
	print "*** Start with SAM_Go.bat ***"

BuildCPCv equ 0
BuildMSXv equ 0
BuildTI8v equ 0
BuildZXSv equ 0
BuildENTv equ 0
BuildSAMv equ 1


ScreenWidth32 equ 1
ScreenHeight24 equ 1

ScreenWidth equ 32
ScreenHeight equ 24

KeyChar_Enter equ 13
KeyChar_Backspace equ 12

