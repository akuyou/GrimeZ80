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
	print "*** SMS/GG Build ***"

BuildCPCv equ 0
BuildMSXv equ 0
BuildTI8v equ 0
BuildZXSv equ 0
BuildENTv equ 0
BuildSAMv equ 0

	ifdef BuildSMS
		write "..\RelSMS\cart.sms"
ScreenWidth equ 32
ScreenHeight equ 24
BuildSMSv equ 1
	else
BuildSMSv equ 0
	endif

	ifdef BuildSGG
		write "..\RelSMS\cart.gg"
ScreenWidth equ 20
ScreenHeight equ 18
BuildSGGv equ 1
	else
BuildSGGv equ 0
	endif

vdpControl equ &BF
vdpData    equ &BE


KeyChar_Enter equ 13
KeyChar_Backspace equ &7F


;Variables in Ram
NextCharX equ &C000
NextCharY equ &C001
SelKeyChar equ &C002
FileBegin:
	org &0000
	jr StartOfCart
	ds 62,&C9
StartOfCart:	
  	di      ; disable interrupts
    im 1    ; Interrupt mode 1
    ld sp, &dff0
	
	
	