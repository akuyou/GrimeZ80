; Learn Multi platform Z80 Assembly Programming... With Vampires!

;Please see my website at	www.chibiakumas.com/z80/
;for the 'textbook', useful resources and video tutorials

;File		Example 4
;Version	V1.0
;Date		2018/2/12
;Content	Stack, Strings,Compiler Directives, Indirect registers, CPC call with parameters, Dec-> hex example


ThinkPositive equ 1			;A test declaration - comment this out for a different message!

PrintChar equ &BB5A			;Firmware call to write a character
WaitChar  equ &BB06			;Firmware call to read a character

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;	EG 1 - Lets learn how the stack works!

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org &8000 	
					;Lets consider the stack empty as  ]
	call WaitChar			;Get a character from the user - suppose they press A
	call PrintChar			;Print it onscreen
	push af				;push it onto the stack, stack is now A]
		ld a,'|'
		push af			;Put | onto the stack ... stack is now |A]
		call PrintChar		; Call xxxx also uses the stack, it's the equivalent of
					; Push PC, JP xxxx

			ld a,'x'	;Print an X
			call PrintChar
		pop af			;pop off the stack, we get |... stack is now A]
		call PrintChar
		
	pop af				;pop off the stack, we get |... stack is now ]
	call PrintChar
ret					;Ret uses the stack too - it's the equivlent of ret of pop PC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;	EG 2 Lets Print a string to screen - and change it with a DEF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


org &8100
	ld hl,Introduction	;Print our introduction message
	call PrintString	

	call NewLine		;Newline command - on the CPC we print CHR(13) then CHR (10)

	ld hl,Message		;Print our second message - we're going to flip this with our DEF statement
	call PrintString

ret


PrintString:
	ld a,(hl)		;Load the next character
	cp 255			
	ret z			;Return if it's 255
	inc hl			;Otherwise print it to screen
	call PrintChar		;Do it again
jr PrintString

Introduction:
	db 'Thought of the day...',255	;String - ends with 255
	

;We're using a compiler directive to flip the message - only one of thse two will end up in the code
;so we can have two versions of the program, and change the one we use easily
ifdef ThinkPositive
	Message:	db 'Z80 is Awesome!',255
else
	Message:	db '6510 sucks!',255
endif

NewLine:			;This is a newline command - different systems may need a different command (EG TI-83)

	ld a,13			;CHR(13) Carridge return
	call PrintChar

	ld a,10			;CHR(10) Newline
	call PrintChar
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;	EG 3 - Lets use IX to point to different memory locations

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;You could also use IY for the same purpose - but the TI-83 needs it for its own purpose

org &8200
	ld ix,SquareBrackets	;Point IX to our square brackets
	ld hl,Message		;Pointer to the message
	ld de,PrintString	;Set DE to our message printer
	call DoBrackets		;Call our brackets routine


	call NewLine

	ld ix,CurlyBrackets	;Point IX to our square brackets
	ld hl,Message		;Pointer to the message
	ld de,PrintString	;Set DE to our message printer
	call DoBrackets		;Call our brackets routine
	
ret

;Two bracket options
SquareBrackets: db '[]'		
CurlyBrackets: db '{}'

DoBrackets:
	
	ld a,(ix+0)			;Load the first of our chosen brackets
;	ld a,(SquareBrackets)
	call PrintChar			;Print our chosen bracket
	
	Call DoCallDE			;Call the routine we were given in DE
					;there is no Call (DE) command - but we can MAKE ONE!

	ld a,(ix+1)			;Load the second of our brackets
;	ld a,(SquareBrackets+1)
	call PrintChar			;print the second bracket
ret


DoCallDE:		
	push de		;Push the address we want to call onto the stack
ret			;The RET command will pop an address off the stack into (PC)
			;this will move execution to the value DE we just pushed

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;	EG 4 - Lets use IX to read a 16 bit number from the user's CALL (Amstrad CPC only)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org &8300			;Execute with Call &8300,XXX 

	cp 1			;how many vars were we passed - eg
				;Call &8300 - 0
				;Call &8300,66 - 1
				;Call &8300,66,66 - 2	ETC
	jp nz,ShowUsage
	
	ld a,'&'		;Print an & symbol
	call PrintChar
	
;integers are passed in 16 bit, in reverse order, so the high byte is 2nd, and the low one is 1st
;this is called "little-endian" because the 'little' part comes first.

;Lets pretend we were did CALL &8300,&CCBB

	ld a,(ix+1)		;Get the first part (&CC) - 1st part is 2nd because little endian
	or a
	call nz,ShowHex		;if the HIGH byte not is zero, then print it!


	ld a,(ix+0)		;Get the Second part (&BB) - 2nd part is 1st because little endian
	call ShowHex		;Print the low order byte

ret
ShowUsage:			;Passed no vars, so show usage.
	ld hl,ShowUsageMessage
jp PrintString

ShowUsageMessage:
	defb "Usage: Call &8300,[16 bit number]",255

ShowHex:			
	ld b,16				;Divide A by 16 - this gives our first Hex digit
	call MathDiv
	push af
		ld a,c			;put our result in A
		call PrintHexChar	;Call our HEX printer

	pop af	;get back the remainder
	call PrintHexChar		;Print it
ret

PrintHexChar:
	cp 10				;If we're less then 10, add Ascii '0' to it (48) to print a Digit
	jr c,PrintHexCharNotAtoF
					;Our digit is 10 or above so we need to print an Ascii letter 
	add 7				;A-F, so add another 7
PrintHexCharNotAtoF:
	add 48				;Add 48 (character '0')
	jp PrintChar			;print it

MathDiv: 		;divide A by B , result in C, remainder in A
	ld c,0		;Our result will be in C
	cp 0		
	ret z		;Return if dividing by zero

MathDivAgain:
	sub b			;Subtract one B
	inc c			;increase our result
	jp nc,MathDivAgain	;Repeat if we're not below zero	

	add b			;we went too far, so Add B again, so the valid remainder is in A
	dec c			;we went too far, so subtract 
ret
