; Learn Multi platform Z80 Assembly Programming... With Vampires!

;Please see my website at	www.chibiakumas.com/z80/
;for the 'textbook', useful resources and video tutorials

;File		Example 3
;Version	V1.0
;Date		2018/2/03
;Content	'Case' statement, Addition, Subtraction, 'Multiplication' and 'Division', Passing data to basic

org &8000
	ld a,(&9000) 	;Load A from memory &9000
	ld bc,(&9001)	;Load BC from &9001... note 16 bit pairs are stored in memory backwards, 
			;so C is read from &9001 and B is read from &9002


	;We're going to do a 'case' statement, comparing A to 0-3, jumping depending on value

	cp 0			;OR A does the same and is smaller and faster
	jr z,MathAdd
	cp 1
	jr z,MathSub
	cp 2
	jr z,MathMult
	cp 3
	jr z,MathDiv
		
	;Default action if user entered a different value
	
	ld a,0			;PRO-TIP... XOR A has the same result and is smaller and faster!
SaveResult:
	ld (&9003),a		;Save the result back to memory so basic can get it.
ret


MathSub:
	ld a,c	
	sub b

;alternative... if we don't want to use the SUB command
;	ld a,b
;	neg 		;Convert A into -A
;	add c

jr SaveResult


MathAdd:
	ld a,c
	add b
jr SaveResult



MathMult:
	ld a,b
	cp 0			;See if B=0 we're going to give up if it is
	jr z,SaveResult
	ld a,0			;We can use Xor A instead of this command
MathMultAgain:
	add c			;Add C
	djnz MathMultAgain	;Decrease B and repeat until B=0
jr SaveResult



MathDiv:
	ld a,c		
	cp 0			; we can use or a instead of this command
	jr z,SaveResult		;See if C=0, and give up if it is
	ld d,0			;We need A for our divide command, so we use D for our result
MathDivAgain:
	sub b			;Subtract B from A
	inc d			;Add one to our count
	jp nc,MathDivAgain	;Did we go below Zero? the Carry bit will be set, 
				;so if NC is true, we have not and need to repeat

	dec d			;We get here when we've gone below zero, because we've gone too far
				;we need to reduce D by one to get the proper number
	ld a,d
jr SaveResult

