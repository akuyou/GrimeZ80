; Learn Multi platform Z80 Assembly Programming... With Vampires!

;Please see my website at	www.chibiakumas.com/z80/
;for the 'textbook', useful resources and video tutorials

;File		Example 2
;Version	V1.0
;Date		2018/1/19
;Content	Labels, Loop, Conditions, LDIR, Constants

ScreenSize equ &4000		;EQU defines a symbol - this is a constant that the assembler will remember, 
				;it allows us to define something once, and use it in many places
				;if we change our mind later, we only need to change it in this one place
				;not all the places we used it!


				;The number of bytes we're going to copy
				;Note, if you make this higher, the CPC will crash, as you'll overwrite &0000 !
				;If the CPC crashes, just hit CTRL-F9 to reset
org &8000
	ld hl,&0000		;when we use LDIR, HL is the source memory address 
					;as a test, we're going to copy from the start of memory

	ld de,&C000		;when we use LDIR, DE is the destination address 
					;we're setting it to the start of the CPC screen memory

	ld bc,ScreenSize	;when we use LDIR, BC is the bytecount 
					;We're going to copy a full screen of data

	ldir			;LDIR copies a byte from (HL) to (DE), then increments HL and DE, finally it decreases BC, and repeats until BC=0
				;LDIR stands for LoaD Increment Repeat - you'll probably use it quite a bit!
				;Remember, you can put a breakpoint on ldir, and see what LDIR is really doing!
ret

org &8100
	ld hl,&C000
	ld de,&C000+1		;Setting Destination to 1 one more than source 'tricks' LDIR into copying the data it just wrote!
				;this is a quick easy way to fill a range of bytes!
	ld bc,ScreenSize-1	;We're going to set the first byte ourself, so we need to fill one less

				;Mathmatics in Winape code is unusual, There is no "Operator Precedence"
				;Usually if you calculate 5+1*2 you would do the multiplication of 1*2 first then 5+2, so the result is 7
				;however Winape works left to righ, so you would do 5+1 first, then 6*2 = 12!! 
				;there are no brackets either! It can take a bit of getting used to - but it works fine!

	ld (hl),0		;Load the first 

	ldir			;fill the range

ret


org &8200
	ld a,%00001111		;Set the accumulator to binary number %00001111 (15 in decimal)


FillAgain:			;This is a label - it's like a symbol that points to code-memory
				;the compiler will remember where this code is, so we can use it for jumps or calls
				;Our code started at &8200, and since the line above takes 2 bytes 
				;'FillAgain' will equal &8202!

				;The compiler will put the byte memory location in to our jump statement automatically
				;so we don't need to worry about it! - isn't it kind!


	ld hl,&C000		;these are the same as the previous example
	ld de,&C000+1
	ld bc,ScreenSize-1

	ld (hl),a		;this time well fill the bytes with A instead of zero

	ldir			;Fill the range

	dec a			;LDIR doesn't use A, so it still has the same value as before

	cp 255			;when A goes below zero, it wraps around to 255

	jp nz, FillAgain	;A compare with a jump is effectively a loop

				;the Z flag means Zero, but when we're doing a comparison it means "Equals" or "Zero difference"
				;it's weird, but that's because CP # 'pretends' to subtract # ... and sets the flags as if it had.
				;if A=255, then subtracting 255 would equal zero - but of course CP doesn't really change A
				;of course NZ has the effect of  Not Equals (<> or !=) (NonZero difference)
				;The C flag is Carry, and NC is NoCarry... 
				;But when we're doing comparisons C means Smaller (<) than (<... think of it as Chibi)
				;and NC means Bigger or Equal to (>=... think of it as Not Chibi)

ret