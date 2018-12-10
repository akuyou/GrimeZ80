
; --------------------------------------------------------------------------------------------
;***************************************************************************************************

;			 Keyboard Reader

;***************************************************************************************************
;--------------------------------------------------------------------------------------------
KeyboardScanner_LineCount equ 10
KeyboardScanner_LineWidth equ 8
; Don't ask me how this works - someone smarter than me wrote it!


;KeyboardScanner_Flush equ &BB03


;map with 10*8 = 80 key status bits (bit=0 key is pressed)

Read_Keyboard:
KeyboardScanner_Read:
	;Key input on the CPC goes through the 8255 PPI an AY soundchip, we need to use the PPI to talk to the AY, 
	;and tell it to read input through reg 14

	;Port F6C0 = Select Regsiter
	;Port F600 = Inactive
	;Port F6xx = Recieve Data
	;Port F4xx = Send Data to selected Register

	ld bc,#f782     ;Select PPI port direction... A out /C out 
	ld hl,KeyboardScanner_KeyPresses    ;Destination Mem for the Keypresses
	xor a
	di              
	out (c),c       


	ld bc,#f40e     ; Select Ay reg 14 on ppi port A 
	ld e,b          
	out (c),c       
	ld bc,#f6c0     ;This value is an AY index (R14) 
	ld d,b          
	out (c),c        
	out (c),a   	; F600 - set to inactive (needed)
	ld bc,#f792     ; Set PPI port direction A in/C out 
	out (c),c       
	ld a,#40        ;First line is at &40, last is at &4A
	ld c,#4a        
KeyboardScanner_Loop
	ld b,d    	;d=#f6     
	out (c),a       ;select line &F640-F64A
	ld b,e    	;e=#f4   
	ini             ;read in the bits to HL keymap
	inc a           
	cp c            ;Have we got to the end?
	jp c,KeyboardScanner_Loop      
	ld bc,#f782     
	out (c),c       ; reet PPI port direction - PPI port A out / C out 
	ei 
KeyboardScanner_AllowJoysticks:             
	ret

;If we just need joypad UDLR-F type controls we're done, but if we want to read in text from the keyboard, we need to be able to convert to ke
	ifdef UseHardwareKeyMap
HardwareKeyMap:
		db "u","r","d","9","6","3",KeyChar_Enter ,"."
		db "l","c","7","8","5","1","2","F"
		db "c","[",13 ,"]","4","s","\","c"
		db "^","-","@","P",";",":","/","."
		db "0","9","O","I","L","K","M",","
		db "8","7","U","Y","H","J","N"," "
		db "6","5","R","T","G","F","B","V"
		db "4","3","E","W","S","D","C","X"
		db "1","2","e","Q","t","A","c","Z"
		db "u","d","l","r","f","g","h",KeyChar_Backspace

	endif



;Line 	7 	6 	5 	4 	3 	2 	1 	0
;&40 	F Dot 	ENTER 	F3 	F6 	F9 	CUR D 	CUR R 	CUR U
;&41 	F0 	F2 	F1 	F5 	F8 	F7 	COPY 	CUR L
;&42 	CTRL 	\ 	SHIFT 	F4 	] 	RETN 	[ 	CLR
;&43 	. 	/ 	 : 	 ; 	P 	@ 	- 	^
;&44 	, 	M 	K 	L 	I 	O 	9 	0
;&45 	SPACE 	N 	J 	H 	Y 	U 	7 	8
;&46 	V 	B 	F 	G/J2 F1	T/ J2 R	R/ J2 L	5/ J2 D 6/ J2 U
;&47 	X 	C 	D 	S 	W 	E 	3 	4
;&48 	Z 	CAPSLK 	A 	TAB 	Q 	ESC 	2 	1
;&49 	DEL 	J1 F3 	J1 F2 	J1 F 1 	J1 R 	J1 L 	J1 D 	J1 U
