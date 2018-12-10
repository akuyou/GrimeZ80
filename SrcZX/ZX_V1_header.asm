; Learn Multi platform Z80 Assembly Programming... With Vampires!

;Please see my website at	www.chibiakumas.com/z80/
;for the 'textbook', useful resources and video tutorials

;File		ZX Header
;Version	V1.0
;Date		2018/3/01
;Content	Generic Header

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	Org &8000
ProgramOrg:
	write "..\BldZX\program.bin"
	print "*** ZX Spectrum Build ***"
	print "*** saved to BldZX\program.bin ***"
	print "*** Start ZX_goDSK.bat ***"

BuildCPCv equ 0
BuildMSXv equ 0
BuildTI8v equ 0
BuildZXSv equ 1
BuildENTv equ 0
BuildSAMv equ 0


ScreenWidth32 equ 1
ScreenHeight24 equ 1

ScreenWidth equ 32
ScreenHeight equ 24


KeyChar_Enter equ 13
KeyChar_Backspace equ 12


