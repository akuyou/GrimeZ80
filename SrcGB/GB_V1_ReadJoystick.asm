Player_ReadControlsDual:	
	
	ld a,%11101111 	;Select UDLR
	ld (&FF00),a
	
	ld a,(&FF00)	;Read in Keys
	
	rra				;Need to swap position of RL and UD
	rl l			
	rra
	rl l
	
	rra
	rr h
	rra
	rr h
	
	ld a,%11011111		;Select Fire/SelectStart
	ld (&FF00),a
	
	rr l			;Need to swap position of RL and UD
	rr h
	rr l
	rr h
	
	ld a,(&FF00)
	
	rra
	rr h
	
	rra
	rr h
	
	rra
	rr h
	
	rra
	rr h
	
	
	ld l,255	;no 2nd 'joystick
BootsStrap_ConfigureControls:

	ret
	
	
	;"The eight gameboy buttons/direction keys are arranged in form of a 2x4 matrix. Select either button or direction keys by writing to this register, then read-out bit 0-3.
  ;Bit 7 - Not used
  ;Bit 6 - Not used
  ;Bit 5 - P15 Select Button Keys      (0=Select)
  ;Bit 4 - P14 Select Direction Keys   (0=Select)
  ;Bit 3 - P13 Input Down  or Start    (0=Pressed) (Read Only)
  ;Bit 2 - P12 Input Up    or Select   (0=Pressed) (Read Only)
;  Bit 1 - P11 Input Left  or Button B (0=Pressed) (Read Only)
 ; Bit 0 - P10 Input Right or Button A (0=Pressed) (Read Only)

;Note: Most programs are repeatedly reading from this port several times (the first reads used as short delay, allowing the inputs to stabilize, and only the value from the last read actually used)."
