	
	
	
	
	ifndef BuildCONSOLE
		call KeyboardScanner_Init
		call KeyboardScanner_AllowJoysticks
	endif
	;call Monitor
	
	
	ifdef RedefineKeys
		call ConfigureControls
		Call CLS
		
		ld hl,KeyMap2
		
		ld c,4
ShowAgain2:
		ld b,8
ShowAgain:
		 ld a,(hl)
		 inc hl
		 push hl
		 push bc
			call ShowHex
			ifndef BuildTI8
				ld a,32
				call PrintChar
			endif
			
			ifdef BuildTI8
		pop bc
		push bc
				ld a,b
				cp 5
				jr nz,NoTiNL
				Call NewLine
NoTiNL:
			endif
			 
			 
		 pop bc
		 pop hl
		 djnz ShowAgain
		 call NewLine
		 dec c
		 
		 ifdef BuildTI8
			 push bc
			 push hl
			 push de
			 pop de
			 pop hl
			 pop bc
		 endif
		 jr nz,ShowAgain2
		 di
		halt
	endif

Loop:

	ld hl,&0000
	call Locate
	call Player_ReadControlsDual

		ld a,h ;= Keypress bitmap Player 1
	call ShowHex
		ld a,l ;= Keypress bitmap Player 2
	call ShowHex
	jp Loop
