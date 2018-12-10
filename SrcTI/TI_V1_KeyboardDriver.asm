KeyboardScanner_LineCount equ 7
KeyboardScanner_LineWidth equ 8


Read_Keyboard:
KeyboardScanner_Read:
	di
	ld de,KeyboardScanner_KeyPresses
	ld h,%10111111  ;First line of keyboard, last is %11111110
	ld b,7			;7 lines!
	ld c,1			;Keyboard is port 1, YES 1!!!
keynextline:
	out (c),h		;Select port
	in	a,(c)		;read line
	ld (de),a		;save keypresses
	inc de			
	rrc h			;Move zero to the right
	djnz keynextline;repeat
	ei
KeyboardScanner_AllowJoysticks:
	ret

	ifdef UseHardwareKeyMap
HardwareKeyMap:
	db "d","m","2","y","w","z","t","g"
	db "a","m","x","x","l","l","s"," "
	db "0","1","4","7",",","s","a","t"
	db ".","2","5","8",")","c","p","s"
	db "-","3","6","9","(","t","v"," "
	db 13,"+","-","*","/","^","c"," "
	db "d","l","r","u"," "," "," "," " 

	endif

; Key Code 
;   	0	1	2 	3	4	5	6	7
;0  	GRAPH 	TRACE 	ZOOM 	WINDOW 	Y= 	2nd 	MODE 	DEL 
;1  		STO 	LN 	LOG 	x2 	x-1 	MATH 	ALPHA 
;2  	0 	1 	4 	7 	,  	SIN 	APPS 	xTOn
;3  	. 	2 	5 	8 	) 	COS 	PRGM 	STAT 
;4  	(-) 	3 	6 	9 	( 	TAN 	VARS  
;5  	ENTER 	+ 	- 	* 	/ 	^ 	CLEAR  
;6  	down 	left 	right 	up 
