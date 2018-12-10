ScreenWidth equ 20
ScreenHeight equ 18


	org &0000
	
; IRQs
	org &0040
;sVblankPos:
	reti

sLCDC:
	org &0048
	reti
;sTimer_Overflow:
	org &0050

	reti
;sSerial:
	org &0058
;SECTION	"Serial",HOME($0058)
	reti
;sp1thru4:
;SECTION	"p1thru4",HOME($0060)
	org &0060
	reti

; ****************************************************************************************
; boot loader jumps to here.
; ****************************************************************************************
sstart:
	org &0100
	nop			;0100	0103	Entry point (start of program)
	jp	begin


	;0104	0133	Nintendo logo (must match rom logo)	
	 DB $CE,$ED,$66,$66,$CC,$0D,$00,$0B,$03,$73,$00,$83,$00,$0C,$00,$0D
	 DB $00,$08,$11,$1F,$88,$89,$00,$0E,$DC,$CC,$6E,$E6,$DD,$DD,$D9,$99
	 DB $BB,$BB,$67,$63,$6E,$0E,$EC,$CC,$DD,$DC,$99,$9F,$BB,$B9,$33,$3E

	 DB "EXAMPLE",0,0,0,0,0,0,0,0 ;0134	0142	Game Name (Uppercase)
	 ifdef BuildGMB				  ;0143	0143	Color gameboy flag (&80 = GB+CGB,&C0 = CGB only)
		DB $00
	 endif 
	 ifdef BuildGBC
		DB $80     
	 endif
	 DB 0,0       ;0144	0145	Game Manufacturer code
	 DB 0         ;0146	0146	Super GameBoy flag (&00=normal, &03=SGB)
	 DB 0	  	  ;0147	0147	Cartridge type (special upgrade hardware) (0=normal ROM)
	 DB 0         ;0148	0148	Rom size (0=32k, 1=64k,2=128k etc)
	 DB 0         ;0149	0149	Cart Ram size (0=none,1=2k 2=8k, 3=32k)
	 DB 1         ;014A	014A	Destination Code (0=JPN 1=EU/US)
	 DB $33       ;014B	014B	Old Licensee code (must be &33 for SGB)
	 DB 0         ;014C	014C	Rom Version Number (usually 0)
	 DB 0         ;014D	014D	Header Checksum - ‘ones complement’ checksum of bytes 0134-014C… not needed for emulators
	 DW 0         ;014E	014F	Global Checksum – 16 bit sum of all rom bytes (except 014E-014F)… unused by gameboy
 
	 
begin:
	nop
	di
	ld	sp, $ffff		; set the stack pointer to highest mem location + 1