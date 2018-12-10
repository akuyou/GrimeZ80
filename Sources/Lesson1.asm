; Learn Multi platform Z80 Assembly Programming... With Vampires!

;Please see my website at	www.chibiakumas.com/z80/
;for the 'textbook', useful resources and video tutorials

;File		Example 1
;Version		V1.0
;Date		2018/1/19
;Content		Mathematics and memory storage
;-------------------------------------------------------------------------



		;green text after a semicolon is a comment
		;you do not need to type it in
	
		;Assembly is not case sensitive 'INC A' and 'inc a' are the same thing

	nolist	
	org &8000 	;Set the memory Start point (ORIGIN) of the program code
				;& Marks the number as hexadecimal - some assemblers use $ or #
				;instead but WinApe uses &

	ld a,4		;Set Accumulator to 4
	inc a		;Increment A (now A = 5)
	inc a		;Increment A (now A = 5)
	ld b,10		;Set B to 10

	add b		;Add B to A  (now A=16 (&10)) ... 
		;	this could also be written as ADD A,B

	ld (&7000),a	;LOAD the value in A to memory point &7000

	ret		;return... in this case to basic


	