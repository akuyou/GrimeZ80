; Learn Multi platform Z80 Assembly Programming... With Vampires!

;Please see my website at	www.chibiakumas.com/z80/
;for the 'textbook', useful resources and video tutorials

;File		Example A2
;Version	V1.0
;Date		2018/5/12
;Content	Interrupt Mode 2

; NOTE... For clear reading This file does not have full comments, as most of the code is a direct copy of the code in Lesson 7... 
; 	  if you don't know how that code works please ses the source file for lesson 7

	org &8000
	jp SkipBlock
	ds 512
SkipBlock:
	di			;Turn off interrupts
		
	ld a,&C3		;IM2 will call &8181, so we define a jump at that point to our real interrupt handler
	ld (&8181),a
	ld hl,InterruptHandler
	ld (&8182),hl

	ld hl,&8000		;the IM2 block starts at &8000
	ld de,&8001
	ld bc,&0101-1		;We need to fill &101 bytes, but we define the first ourselves, so we need to subtract 1

	ld a,&81		;Set the first byte
	ld (hl),a

	ldir			;Fill the range

	ld a,&80		;Define I, and set interrupt mode 2
	ld i,a
	im 2

	ld sp,&8181		;Lets use the spare space for our stack ppointer

	ei			;Turn interrupts back on

	ld hl,&C000	

	ld d,10		
	ld c,%11111111
InfLoop:
	halt

	jp InfLoop

InterruptHandler:

	exx		
	ex af,af'

	ld hl,RasterColors 
IH_RasterColor_Plus2:

	ld      b,&f5
	in      a,(c)

	rra   
	jp nc,InterruptHandlerOk

	ld hl,RasterColors

InterruptHandlerOk:
	ld bc,&7f00      
	out (c),c   

	ld a,(hl)
	out (c),a    
	inc hl

	ld (IH_RasterColor_Plus2-2),hl

	ex af,af'
	exx

	ei
	ret


RasterColors:
	db &4C,&43,&52,&5C,&5E,&5F
