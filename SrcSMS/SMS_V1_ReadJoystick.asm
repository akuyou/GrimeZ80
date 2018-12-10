Player_ReadControlsDual:	
	;ld a,(&DD)
	ifdef BuildSGG	
		ld a,255
	endif
	ifdef BuildSMS
		push bc
			in a,(&DC)	;Most of player 2's keys
			ld b,a
			in a,(&DD)	;but not all! (UD are in p1's!?!)
			rl b
			rla
			rl b
			rla
			or %11000000
		pop bc
	endif
	ld l,a ;= Keypress bitmap Player 2
	
	ifdef BuildSGG
		push bc
		in a,(&0)
		or %01111111
		ld b,a
	endif
	in a,(&DC)
	or %11000000
	ifdef BuildSGG
		and b
		pop bc
	endif
	ld h,a ;= Keypress bitmap Player 1
	
	
BootsStrap_ConfigureControls:

	ret
	
	
	
;Port $DC: I/O port A and B
;Bit 	Function 
;7 	Port B Down pin input 
;6 	Port B Up pin input 
;5 	Port A TR pin input 
;4 	Port A TL pin input 
;3 	Port A Right pin input 
;2 	Port A Left pin input 
;1 	Port A Down pin input 
;0 	Port A Up pin input 


;Port $DD: I/O port B and miscellaneous
;Bit	Function 
;7 	Port B TH pin input (Unused)
;6 	Port A TH pin input (Unused)
;5 	Cartridge slot CONT pin * 
;4 	Reset button (1= not pressed, 0= pressed) * 
;3 	Port B TR pin input 
;2 	Port B TL pin input 
;1 	Port B Right pin input 
;0	Port B Left pin input

;The Game Gear has three face buttons: buttons 1 and 2 as in the Master System, and additionally a Start button.

;When running in Game Gear mode, the Start button state may be read by inputting from port $00; bit 7 reflects its state, with active-low logic (1 = not pressed, 0 = pressed). 