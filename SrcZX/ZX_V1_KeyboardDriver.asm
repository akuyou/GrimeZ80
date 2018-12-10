KeyboardScanner_LineCount equ 10
KeyboardScanner_LineWidth equ 5
;Keymap_U equ 0
;Keymap_D equ 1
;Keymap_L equ 2
;Keymap_R equ 3
;Keymap_F1 equ 4
;Keymap_F2 equ 5
;Keymap_F3 equ 6
;Keymap_Pause equ 7

;Keymap_AnyFire equ %11001111

KeyboardScanner_AllowJoysticks:				;Reading Kempson if one isn't installed will cause problems, so we keep it disabled by default
	xor a
	ld (KeyboardScanner_NoJoy_Plus1-1),a
	ret



KeyboardScanner_Read:
Read_Keyboard:	
	di	
	LD  HL,KeyboardScanner_KeyPresses  		;set HL with buffer start - this is where we will write our data to
	LD  B,%11111110		;set upper address lines - note, low bit is zero
	LD  C,&FE  			;port for lines K1 - K5
Read_KeyboardLOOP: 	
	IN  A,(C)
	or %11100000		;There are only 5 keys on each line, so fill the empty lines so our code doesn't bug out.
	LD  (HL),A 		 	;save it
	INC  HL  			;next location in buffer
	SCF  				
	RL  B 			 	;rotate next address line left
	JR  C,Read_KeyboardLOOP	  ;jump if not done (we're done when we pop the zero)
	ret ;<--SM ***
	
KeyboardScanner_NoJoy_Plus1:
		
	ld bc,31            ; Kempston joystick port. (---FUDLR)
        in a,(c)        ; read input.
	cpl
	or %11100000		;Fill in the unused bytes, I believe in theory it's possible to have extra fire buttons?
	ld (hl),a
	ei
	ret


	ifdef UseHardwareKeyMap
HardwareKeyMap:
		db "#","Z","X","C","V" 
		db "A","S","D","F","G"	
		db "Q","W","E","R","T" 
		db "1","2","3","4","5" 
		db "0","9","8","7","6" 
		db "P","O","I","U","Y" 
		db KeyChar_Enter,"L","K","J","H" 
		db " ",KeyChar_Backspace,"M","N","B"	
		db "C","U","D","L","R"
	endif


;Ports

;32766 B, N, M, Sym, Space
;49150 H, J, K, L  , Enter
;57342 Y, U, I, O  , P
;61438 6, 7, 8, 9  , 0
;63486 5, 4, 3, 2  , 1
;64510 T, R, E, W  , Q
;65022 G, F, D, S  , A
;65278 V, C, X, Z  , Caps Shift


