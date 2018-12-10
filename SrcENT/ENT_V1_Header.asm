; Learn Multi platform Z80 Assembly Programming... With Vampires!

;Please see my website at	www.chibiakumas.com/z80/
;for the 'textbook', useful resources and video tutorials

;File		Enterprise Header
;Version	V1.0b
;Date		2018/3/20
;Content	Copies from the load address of &0100 to &8000 to allow all systems a common
;		launch address

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	write "..\BldEnt\program.com"
	print "*** Enterprise Build ***"
	print "*** Compiled to RelEnt\program.com ***"
	print "*** Run ENT_File.bat ***"

BuildCPCv equ 0
BuildMSXv equ 0
BuildTI8v equ 0
BuildZXSv equ 0
BuildENTv equ 1
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
KeyChar_Backspace equ &A4



	ORG &7FF0
	DB 0,5			;type 5 = machine code application program
	DW FileEnd-FileStart	;16 bit lenght
	DB 0,0,0,0,0,0,0,0,0,0,0,0 ;not used bytes
FileStart:
;	org &8000
ProgramOrg:
	LD SP,&100	;set the User Stack, 164 bytes free

	;The Enterprise Will load this code in at &1000, but we copy it to &8000
	;and exexute it there, so that we have a common memory range for all our 
	;main systems - this makes using things like 'aroks songs' that need a 
	;fixed address easier


	;We need to allocate a good segment
	rst 48	;Segment please!
	db 24	;segment in C
	
	ld a,C
	out (&B2),a	;&B2 - Ram page 2 (8000-C000)	

	;Copy the program to &8000 
	ld hl,&0100
	ld de,&8000
	ld bc,FileEnd-FileStart
	ldir
	jp FileStart2
FileStart2:
