KeyboardScanner_LineCount equ 10
KeyboardScanner_LineWidth equ 8

						;Sam Coupe imitates the speccy, but it has an extra 3 lines on a separate port.


KeyboardScanner_AllowJoysticks:
						;Joystick maps to the keyboard on the SAM, so nothing to do here!
	ret


KeyboardScanner_Read:
Read_Keyboard:	
	di	
	LD  HL,KeyboardScanner_KeyPresses  		;set HL with buffer start - this is where we will write our data to
	LD  B,%11111110		;set upper address lines - note, low bit is zero
Read_KeyboardLOOP: 	
	LD  C,&F9  		;port for Lines K6 - K8 - This is extra for the SAM
	IN  A,(C)
	AND  %11100000		;Keep only the top three bits
	LD  (HL),A  		;Store them
	LD  C, &FE  		;port for Lines K1 - K5 this is the same as the speccy
	IN  A, (C)
	AND  %00011111     	;Keep only the valid bits
	OR (HL) 			;OR in the value for the top 3 lines
	LD  (HL),A 		 	;Save the result
	INC  HL  			;next location in buffer
	SCF  				
	RL  B 			 	;rotate next address line
	JR  C,Read_KeyboardLOOP	 ;jump if not done (we're done when we pop the zero)
	ld b,255
	IN  A,(C)			;read Cursors + Control line
	or   %11100000		;Fill in the unused bits
	LD  (HL),A  		;save it

;ei
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INTERRUPTS STILL DISABLED;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	RET 			 ;return to analyse scan




	ifdef UseHardwareKeyMap
HardwareKeyMap:
		db "#","Z","X","C","V"  ,'1','2','3'
		db "A","S","D","F","G"	,'4','5','6'
		db "Q","W","E","R","T"  ,'7','8','9'
		db "1","2","3","4","5"  ,'X','T','C'
		db "0","9","8","7","6"  ,'-','+',KeyChar_Backspace
		db "P","O","I","U","Y"  ,'=','"','0'
		db KeyChar_Enter,"L","K","J","H"  ,';',':','E'
		db " ","#","M","N","B"	,',','.','I'
		db "C","U","D","L","R"	,',','.','I'

	endif

;KEYBOARD register (254 dec)
	;Bit 0 K1  keyboard matrix line 1, Mouse Control.
	;Bit 1 K2  keyboard matrix line 2, Mouse Up.
	;Bit 2 K3  keyboard matrix line 3, Mouse Down/Button 2.
	;Bit 3 K4  keyboard matrix line 4, Mouse Left/Button 1.
	;Bit 4 K5  keyboard matrix line 5, Mouse Right/Button 3.
	;Bit 5 SPEN light pen strobe/serial input bit.
	;Bit 6 EAR  serial input from EAR of cassette recorder.
	;Bit 7 SOFF status bit show if external memory is set.

;STATUS register (249 dec)
	;Bit 0 LINE int when low, signals the line interrupt register is requesting.
	;Bit 1 MOUSE int when low, signals the mouse requests the interrupt.
	;Bit 2 MIDIIN int when low, signals the MIDI channel has a data byte.
	;Bit 3 FRAME int when low, signals the frame scan has been completed (50 per/second).
	;Bit 4 MIDOUT int when low, indicates the NrDr out register has just completed data output.
	;Bit 5 K6  keyboard matrix line 6.
	;Bit 6 K7  keyboard matrix line 7.
	;Bit 7 K8  keyboard matrix line 8.






