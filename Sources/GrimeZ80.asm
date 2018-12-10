
;Uncomment one of the lines below to select your compilation target

;BuildCPC equ 1	; Build for Amstrad CPC
;BuildMSX equ 1 ; Build for MSX
;BuildTI8 equ 1 ; Build for TI-83+
;BuildZXS equ 1 ; Build for ZX Spectrum
;BuildENT equ 1 ; Build for Enterprise
;BuildSAM equ 1 ; Build for SamCoupe
;BuildSMS equ 1 ; Build for Sega Mastersystem
;BuildSGG equ 1 ; Build for Sega GameGear
;BuildGMB equ 1 ; Build for GameBoy Regular
;BuildGBC equ 1 ; Build for GameBoyColor 
ScrWid256 equ 1

;CpcPlus equ 1			;We can build for CPC plus if we want!

;RedefineKeys equ 1

	ifdef BuildSMS
BuildCONSOLE 	equ 1
BuildCONSOLEjoy	equ 1
BuildSxx 		equ 1

	endif
	ifdef BuildSGG
BuildCONSOLE 	equ 1
BuildCONSOLEjoy	equ 1
BuildSxx 		equ 1
ScreenSmall 	equ 1
	endif
	ifdef BuildGMB
PaletteGB 		equ 1
BuildCONSOLE 	equ 1
BuildCONSOLEjoy	equ 1
BuildGBx 		equ 1
ScreenSmall 	equ 1
	endif
	ifdef BuildGBC
PaletteGB 		equ 1
BuildCONSOLE 	equ 1
BuildCONSOLEjoy	equ 1
BuildGBx 		equ 1
ScreenSmall 	equ 1
	endif
	ifdef BuildCPC
Palette4 		equ 1
	endif
	ifdef BuildENT
Palette4 		equ 1
	endif
	ifdef BuildTI8
ScreenSmall 	equ 1
	endif
	ifdef BuildMSX
		ifdef BuildMSX_MSX1
BuildMSX_MSX1VDP equ 1						;Disable these to use Software screen on MSX1
BuildCONSOLE 	equ 1						;Disable these to use Software screen on MSX1
		else
	ifdef BuildMSX
BuildMSX_MSXVDP equ 1						;Disable these to use Software screen on MSX
BuildCONSOLE 	equ 1						;Disable these to use Software screen on MSX
	endif
;BuildMSX2 equ 1							;Turn off tile animation (not needed if using VDP option)
		endif
	endif
	
;	V9K equ 1							

	ifdef BuildCPC
		ifdef V9K
BuildCPC_VDP equ 1							;Experimental V9K support for CPC
BuildCONSOLE 	equ 1						;Experimental V9K support for CPC

		endif
	endif
	
	ifndef Palette4
		ifndef PaletteGB
Palette16 equ 1
		endif
	endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef vasm
		include "..\SrcALL\VasmBuildCompat.asm"
	else
		read "..\SrcALL\WinApeBuildCompat.asm"
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	read "..\SrcALL\V1_Header.asm"
	ifdef BuildCONSOLE
		read "..\SrcALL\V1_VdpMemory_Header.asm"
	else
		read "..\SrcALL\V1_BitmapMemory_Header.asm"
	endif
	read "..\SrcALL\CPU_Compatability.asm"
	read "..\SrcALL\Multiplatform_ReadJoystick_Header.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef BuildTI8
ScreenWidthG equ ScreenWidth*2
ScreenHeightG equ ScreenHeight*2
	else
ScreenWidthG equ ScreenWidth
ScreenHeightG equ ScreenHeight
	endif

	ifdef BuildCONSOLE
	ifdef BuildMSX			;The starting memory address of the game ram depends on the system
GameRam equ &C000
	else
GameRam equ &D800
		endif
	else
		ifdef BuildMSX
GameRam equ &C000
		else
		ifdef BuildTI8
GameRam equ &F000
			else
GameRam equ &7000
			endif
		endif
	endif
	
	
MonitorRam 						equ GameRam
Monitor_TMP1 					equ MonitorRam; &C011
Monitor_NextMonitorPos_2Byte	equ MonitorRam+2;&C012;-13
Monitor_EI_Reenable_2byte 		equ MonitorRam+4;&C014;-5
Monitor_Special					equ MonitorRam+6;&C016

KeyboardScanner_KeyPresses		equ GameRam+16
PlayerX1	equ GameRam+32
RandomSeed 	equ PlayerX1+1
PlayerY1	equ PlayerX1+2
FastGrowth	equ PlayerX1+3
PlayerDir	equ PlayerX1+4
BulletX1	equ PlayerX1+5
NothingShot	equ PlayerX1+6
BulletY1	equ PlayerX1+7
AllowedFastGrowth	equ PlayerX1+9
BulletDir	equ PlayerX1+10
PlayingSFX	equ PlayerX1+11
ControlMode	equ PlayerX1+12		;0=1fire mode / 1=2fire mode
GameTick	equ PlayerX1+13		
Lives		equ PlayerX1+14
Animframe	equ PlayerX1+15		;Animation frame (0/16)
Score		equ PlayerX1+16		;8 BCD digits (4 bytes)
HiScore		equ PlayerX1+20		;8 BCD digits (4 bytes)
AnimTick	equ PlayerX1+24		;Animation Tick (0-5)
KempsonOn	equ PlayerX1+25		;Used for Speccy Joystick
TileMap 						equ GameRam+64 ;768  (32x24)
TileMap2 						equ GameRam+64+768  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	Call DOINIT				; Get ready
	call ScreenINIT			; Set up graphics screen
	
	ld a,&C9
	ld (&0038),a			;Disable internal hardware interrupts, we don't need them!
	
	ifdef BuildCONSOLE		;Systems with hardware need the tiles copying
		ifdef BuildGBx
			ld	de, &8800	;Tile 128 (Tiles start at &8000)
		endif
		ifdef BuildSxx
			ld	hl, &1000	;Tile 128 (Tiles start at &0000)
			call prepareVram
		endif
		ifdef BuildMSX_MSX1
			ld	hl, 128*8	;Tile 128 (Tiles start at &0000)
			call prepareVram
		endif
		ifdef BuildMSX_MSXVDP
			ld de, 128		;Tile 128 (Tiles start 512+32 lines down)
		endif
		ld hl,RawBitmap
		ld bc,RawBitmap_End-RawBitmap
		call DefineTiles	;Copy the tiles to the VDP
		
		ifdef BuildMSX_MSX1
			
			ld	hl, 128*8+&2000	;Tile 128
			call prepareVram
			
			ld hl,RawPalettes
			ld bc,RawPalettes_End-RawPalettes
			call DefineTiles	;on the MSX1, We load in the Tile palettes in the same way as tiles 
		endif
	endif
	
	ld hl,GameRam				;Clear the memory used by the game vars
	ld de,GameRam+1
	ld bc,64
	ld (hl),0
	z_ldir
	
	ifndef BuildCONSOLEjoy
		call KeyboardScanner_Init				;Reset the controller buffer
		ifndef BuildZXS
			call KeyboardScanner_AllowJoysticks		;enable joystick support (disabled by default on speccy)
		endif
	endif

	ifdef BuildZXS			;Speccy and Sam Coupe only have one fire... all others often have 2!
		xor a
	else
		ifdef BuildSAM
			xor a			;Default to 1 fire mode
		else	
			ld a,1			;Default to 2 fire mode
		endif
	endif
	ld (ControlMode),a		;Set the default control mode
	
	
	;call Monitor
	;push af
	;call Monitor_PushedRegister
	
	Call GetRandom				;Pull a random number to seed the generator

	ifdef BuildCPC
		ifdef CpcPlus
			call CPCPLUS_Init	;if we're using CPC+ turn it on now.
		endif
	endif
	
	ifdef BuildZXS
		ld a,%00000001			;Speed up ZX sound, and turn of the Chibisound border effect
		call ChibiSound_SetZX
		xor a					;Color 0	
		out (&fe),a				;Set border to black
	endif
	
	
	ld hl,Palette			;Pointer to the palette
   	ifdef PaletteGB
       		ld b,32			;32 palette entries on GBC
  	else
			ld b,17			;16 palettes (Plus border) on all other systems
   	endif
	ld c,b
PaletteAgain:
	ld e,(hl)				;Read in 2 byte palette
	inc hl
	ld d,(hl)
	inc hl
	push hl
		z_ex_dehl			;-GRB definition must be in HL
		push bc

			ld a,c			;First entry is palette 0, we need to set A to the palette number
			sub b
			call SetPalette ;Set Palette A to HL
		pop bc
	pop hl
	dec b
	jp nz,PaletteAgain
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TitleScreen:
	
       	di
       	
		;call ForceRepaint		;Reset Tilemap2, so everything redraws
       	call ClearScreen	
       	
       	
       	ld de,TileMap
       	ifndef ScreenSmall	;Move down 4 lines on normal sized (24 line) screens
       		ld hl,2*32+4
       		add hl,de
       		z_ex_dehl
       	endif
		ifdef ScreenSmall
			ld a,15				;Skip one line on the small screens (otherwise the animation overwrites the highscore)
		else
			ld a,16				;Logo has 16 lines.. this is because the ti83 is 24x16
		endif
       	z_ld_ixl_a
      	
       	
       	ifdef ScreenSmall
       		ifdef BuildTI8
       			ld hl,TitlePic
       		else
       			ld hl,TitlePic+2	;GB and GG are 20x18... so we need to skip 2 tiles on each size... 
       		endif
       	else
       		ld hl,TitlePic
       	endif
TitlePicNextLine:
       	ld bc,24
       	z_ldir						;Copy 24 bytes to the tile array
       	push hl
       		ld hl,8					;As the tilemap is 32 tiles wide,
       		add hl,de				;we don't have entries for 4 tiles on each side of the tilemap
       		z_ex_dehl
       	pop hl
       	z_dec_ixl					;repeat for the next line
       	jr nz,TitlePicNextLine
      	
       	;push bc	
       		call RepaintScreen		;Repaint the screen
       	;pop bc
    ifdef BuildZXS
		ld a,(KempsonOn)
		or a
		jr nz,KempsonAlreadyOn
		ld h,screenwidth/2-9		;Show the highscore message
       	ld l,screenheight-5
       	call Locate
       	ld hl,KempsonMessage
       	call PrintString
KempsonAlreadyOn:

	endif
		
		
		
		
       	ld h,screenwidth/2-8		;Show the highscore message
       	ld l,screenheight-3
       	call Locate
       	ld hl,HighScoreMessage
       	call PrintString
       	ld de,HiScore				;Show the highscore
       	ld b,4
       	call BCD_Show
       	
		call RepaintScreen
		
TitleTextReset:					;Scrolling message
       	ld c,0					;First character in the string to show
TitleAgain:
       	ld e,0					;No of Chars to skip
       	ld b,c					;Number of characters to show on screen
       	inc b
       	ld a,ScreenWidth-1		;See if Some characters are being skipped
       	sub c
       	jr nc,TextNotTooLong
       	ld b,ScreenWidth		;We're showing all the characters
       	ld a,c
       	sub ScreenWidth-1
       	ld e,a					;No of Chars to skip
       	ld a,0
       	
TextNotTooLong:
       	ld h,a
       	ld l,ScreenHeight-1		;Position the text cursor to the bottom of the screen
       	call locate
;       	ld a,(hl)
       	ld hl,ScrollingMessage
       	ld d,0
       	add hl,de				;skip characters we're past showing
       	
       	dec hl
       	ld a,(hl)
       	cp 255					;See if we've show all the characters already, 
       	jr z,TitleTextReset		;If we have, reset the tile array
       	inc hl     	
TextNextChar:
       	ld a,(hl)				;Load in the next character
       	cp 255
       	inc hl
       	jr nz,TextNextCharValidChar
       	dec hl
       	ld a,32					;If we've reached the end of the string, pad it with spaces
       TextNextCharValidChar:
       	call PrintChar			;Show the character
       	z_djnz TextNextChar
       	inc c					;Start from the next character next time
       	push bc
		ifdef BuildTI8
			ld bc,&C000			;We don't animate the titlescreen on the TI
			call Pause
		else
			call ForceAnimate	;Update 2 sets of framws
			ifndef BuildMSX2
				call ForceAnimate
			endif
			ifdef ScreenSmall
				ld bc,&4000		;Add some delay on small screen devices
				call Pause
			endif
			call RepaintScreen	;repaint the screen
		endif
	
       		
			ld a,(RandomSeed)		;use R to seed the random number generator
       		inc a
			ld (RandomSeed),a		;use R to seed the random number generator
			
			;keep pulling random values, to increase randomization.
       		call ReadBothControls
       		
       	pop bc
       	or Keymap_AnyFire
       	inc a
       	jr nz,NewGame				;Wait until fire is pressed
       	ifdef BuildZXS
			ld a,(KeyboardScanner_KeyPresses+6)
			bit 2,a
			jr nz,KempsonNotEnabled
			ld a,1
			ld (KempsonOn),a
			call KeyboardScanner_AllowJoysticks
			jp TitleScreen
KempsonNotEnabled:		
		endif
       	jp TitleAgain				;Update the scrolling text
       	
       	
       	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    	
NewGame:
	di
	ld a,3							;Set lives to 3
	ld (Lives),a
	
	ld hl,Score
	ld b,4
ScoreReset:
	ld (hl),0						;Set 4 bytes of score to 0
	inc hl
	z_djnz ScoreReset
		
NewGameRound:	

	call ClearScreen				;Zero tile array
	call RepaintScreen				;repaint screen
		
	ld a,ScreenWidthG/2				;Center player
	ld (PlayerX1),a
	ld (BulletX1),a
	
	ld a,ScreenHeightG/2			
	ld (PlayerY1),a
	ld (BulletY1),a
	
	ld a,4							;Aim player Left
	ld (PlayerDir),a
	ld (BulletDir),a
	
	ld a,2							;Start the game with fast growth
	ld (AllowedFastGrowth),a
	
	call CreateInvader				;Create two invaders at the start of the game
	call CreateInvader
	
	xor a							;Reset Game Ticks
	ld (GameTick),a
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GameLoop:

	call GetRandom				;Pull a random number
	di
	and %11111110				;invader/descender happens 1 in 128
	cp 192
	call z,CreateInvader		;Create an invaider
	cp 128
	call z,CreateDescender		;Create a descender
	
	
	ld a,(FastGrowth)
	or a
	jr z,NoFastGrowth			;If FastGrowth counter is >0 then we grow every frame
	dec a
	ld (FastGrowth),a
	jr DoGameEvolve
NoFastGrowth:	
	ld a,(GameTick)
	inc a
	ld (GameTick),a
	and %00111111				;Frequency of evoloution
	jp nz,DoGameMove
DoGameEvolve:
	call MouldEvolve			;Evolve the mould
	call RepaintScreen
	jr ProcessPlayer	
	
DoGameMove:	
	and %00000001
	jr nz,DoGamePause
	call MouldMove				;Move the mould
	call RepaintScreen
	jr ProcessPlayer	
DoGamePause:
	;call RepaintScreen
	ifndef BuildMSX2
		call ForceAnimate			;Animate the mould
	endif
	ifdef BuildGBx
				ld bc,&2000		;Add some delay on small screen devices
				call Pause
	endif
	ifdef BuildSGG
				ld bc,&2000		;Add some delay on small screen devices
				call Pause
	endif
	call RepaintScreen
;	ld bc,10000
	;call Pause

ProcessPlayer:	

	ifndef BuildTI8
		 ld hl,&0000
		 push hl
			 call Locate			;Print Score on top left, except on TI
			 ld de,Score
			 ld b,4
			 call BCD_Show
		 pop hl
		 ld h,ScreenWidth-2
		 call Locate				;Print Lives on top right, except on TI
		 ld a,"L"
		 call PrintChar
		 ld a,(Lives)
		 add "0"
		 call PrintChar
	endif
	
	ld a,(NothingShot)				;Is the player busy?
	inc a
	and %00011111
	cp 31
	jr c,PlayerActive
	call CreateInvader				;player is slacking, so lets spawn some stuff
	call CreateInvader
	call CreateDescender
	
	ld a,2							
	ld (AllowedFastGrowth),a		;Fast grow the mould for a few frames
	
	xor a
PlayerActive:	
	ld (NothingShot),a		
	
	ld a,(PlayerX1)					;Read in the current location to BC
	ld b,a
	ld a,(PlayerY1)
	ld c,a
	
	call findtile					;Get the tile location of the player, we need this to check uf the player is alive
									;if the player is surrounded on UDLR then the player is dead
	ld a,b
	cp 0
	jr z,PlayerFarLeft				;Player is at far left, we can't check that direction
	dec hl
	ld a,(hl)
	cp 8
	jr c,PlayerStillAlive			;Player is not surrounded on left
	inc hl
PlayerFarLeft:
	inc hl
	
	ld a,b
	cp ScreenWidthG-1			
	jr z,PlayerFarRight				;Player is far right, we can't check that direction
	
	ld a,(hl)
	cp 8
	jr c,PlayerStillAlive			;Player is not surrounded on right
PlayerFarRight:
	ld de,-33
	add hl,de
	ld a,C
	cp 0
	jr z,PlayerFarTop				;player is at top of screen, we can't check that direction
	ld a,(hl)
	cp 8
	jr c,PlayerStillAlive			;Player is not surrounded at top
PlayerFarTop:
	ld de,64
	add hl,de
	
	ld a,C
	cp ScreenHeightG-1
	jr z,PlayerFarBottom			;Player is at bottom of screen, we can't check that direction
	
	ld a,(hl)
	cp 8
	jr c,PlayerStillAlive			;Player is not surrounded from bottom
PlayerFarBottom:
	jp PlayerDead					;Player is dead!
PlayerStillAlive:	
	
	call ReadBothControls			;read key and joy controls
	ld a,(PlayerDir)
	ld l,a							;Load in the player direction into L (UDLR=1234)

	xor a
	ld (PlayingSFX),a				;Reset the sound effects

	ld a,(ControlMode)				;Check the control mode (1fire 2fire)
	bit 0,a
	jr nz,ControlMode2Fire
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;												Single Fire Mode (1 firebutton)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
F1_ControlMode1Fire:				;1fire mode
	bit Keymap_U,h
	jr nz,F1_PlayerNotUp
	bit Keymap_F1,h					;Up button is pressed
	jr z,FireFaceUp
	ld a,c
	cp 0
	jr z,F1_PlayerNotUp
	dec c							;Move player down
	jr F1_PlayerNotUp
FireFaceUp:
	ld a,1							;Set fire direction to down
	ld l,a
F1_PlayerNotUp:
	bit Keymap_D,h
	jr nz,F1_PlayerNotDown
	bit Keymap_F1,h					;Down button pressed
	jr z,FireFaceDown
	ld a,c
	cp ScreenHeightG-1
	jr z,F1_PlayerNotDown
	inc c							;Move player up
	jr F1_PlayerNotDown
	FireFaceDown:
	ld a,3							;Set fire direction to up
	ld l,a							
F1_PlayerNotDown:
	bit Keymap_L,h
	jr nz,F1_PlayerNotLeft
	bit Keymap_F1,h					;Left button pressed
	jr z,FireFaceLeft
	ld a,b
	cp 0
	jr z,F1_PlayerNotLeft
	dec b							;Move player left
	jr F1_PlayerNotLeft
FireFaceLeft:
	ld a,4							;Set fire direction to left
	ld l,a
F1_PlayerNotLeft:
	bit Keymap_R,h
	jr nz,F1_PlayerNotRight
	bit Keymap_F1,h					;Right button pressed
	jr z,FireFaceRight
	ld a,b
	cp ScreenWidthG-1
	jr z,F1_PlayerNotRight
	inc b							;Move player right
	jr F1_PlayerNotRight
FireFaceRight:	
	ld a,2							; Set fire direction to right
	ld l,a
F1_PlayerNotRight:
	;bit Keymap_F1,h
	jp PlayerNotFire2				;Continue control processing
	
	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;												Alt Fire Mode (2 firebutton)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ControlMode2Fire:		
	
	bit Keymap_U,h
	jr nz,PlayerNotUp				
	ld a,c
	cp 0
	jr z,PlayerNotUp
	dec c							;Move player up
PlayerNotUp:
	bit Keymap_D,h
	jr nz,PlayerNotDown
	ld a,c
	cp ScreenHeightG-1
	jr z,PlayerNotDown
	inc c							;Move player down
PlayerNotDown:
	bit Keymap_L,h
	jr nz,PlayerNotLeft
	ld a,b
	cp 0
	jr z,PlayerNotLeft
	dec b							;Move player left
PlayerNotLeft:
	bit Keymap_R,h
	jr nz,PlayerNotRight
	ld a,b
	cp ScreenWidthG-1
	jr z,PlayerNotRight
	inc b							;Move player right
PlayerNotRight:
	bit Keymap_F1,h
	jr nz,PlayerNotFire
	ld a,l
	dec a							;Rotate player left
	jr nz,PlayerDirReset
	ld a,4
PlayerDirReset:	
	ld l,a
PlayerNotFire:
	bit Keymap_F2,h
	jr nz,PlayerNotFire2
	ld a,l
	inc a							;Rotate player right
	cp 5
	jr nz,PlayerDirReset2
	ld a,1
PlayerDirReset2:	
	ld l,a
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;												This section is used by both control modes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PlayerNotFire2:
	bit Keymap_F3,h
	jr nz,PlayerNotFire3
	ld a,(ControlMode)				;Fire 3 (enter) swaps control modes
	cpl
	ld (ControlMode),a
	call Debounce					;Wait for fire key to be released
PlayerNotFire3:
	bit Keymap_Pause,h
	jr nz,PlayerNotPause
	push bc
	push hl
		ld h,ScreenWidth/2-3
		ld l,ScreenHeight/2
		call Locate
		ld hl,PauseMessage
		call PrintString			;Show pause message
	
		call WaitForFire			;Wait for player to press fire
		call ForceRepaint
		call RepaintScreen
	pop hl
	pop bc
PlayerNotPause:

	ld a,(PlayerDir)			;Check if we need to update the player sprite
	cp L
	jr nz,PlayerMoved
	
	ld a,(PlayerX1)
	cp B
	jr nz,PlayerMoved
	
	ld a,(PlayerY1)
	cp C
	jr nz,PlayerMoved
	jr PlayerUnmoved			;Player position/direction unchanged


PlayerMoved:
	ld a,l
	ld (PlayerDir),a
	call FindTile
	ld a,(hl)					;check if direction player wants to move is empty
	or a
	jr nz,PlayerUnmoved			
	
	push bc
		ld a,(PlayerX1)			;Update player location
		ld b,a
		ld a,(PlayerY1)
		ld c,a
		
		call FindTile	
		ld a,0					;Clear player sprite from old location
		ld (hl),a
		call RenderTile
	pop bc
	ld a,b
	ld (PlayerX1),a				;Store in the new player location
	ld a,c
	ld (PlayerY1),a
	
PlayerUnmoved:
	ld a,(BulletX1)				;Get current bullet location
	ld b,a
	ld a,(BulletY1)
	ld c,a	
	push bc
		call FindTile	
		ld a,0
		ld (hl),a
		call RenderTile			;Clear current bullet sprite
	pop bc
	ld a,4						;Bullet moves per tick
	z_ld_ixl_a
BulletRecalc:
	ld a,(BulletDir)		;Bullet Direction
	cp 1
	jr z,BulletUp
	cp 2
	jr z,BulletRight
	cp 3
	jr z,BulletDown
	cp 4
	jr z,BulletLeft
BulletUp:
	dec c					;Up
	jr BulletCheck
BulletDown:
	inc c					;Down
	jr BulletCheck
BulletLeft:
	dec b					;Left
	jr BulletCheck
BulletRight:
	inc b					;Right
BulletCheck:
	ld a,b
	cp ScreenWidthG
	jr nc,BulletRestart		;If bullet has gone ofscreen we need to make a new one
	ld a,c
	cp ScreenHeightG
	jr nc,BulletRestart

	call FindTile	
	ld a,(hl)
	or a
	jp nz,BulletStrike
	
	z_dec_ixl
	jr nz,BulletRecalc			;Move bullet again for next tick
	
	jr BulletDraw
BulletRestart:
	ld a,(PlayerDir)			;Bullet has gone offscreen, so create a new one at player location
	ld (BulletDir),a
	ld a,(PlayerX1)
	ld b,a
	ld a,(PlayerY1)
	ld c,a
	call FindTile
BulletDraw:
	ld a,b						;Store bullet location
	ld (BulletX1),a
	ld a,c
	ld (BulletY1),a
	
	ld a,5						;Draw the bullet sprite
	ld (hl),a
	call RenderTile
	
	ld a,(PlayerX1)				;Reload the player location
	ld b,a
	ld a,(PlayerY1)
	ld c,a

	call FindTile
	ld a,(PlayerDir)			;Draw the player sprite
	ld (hl),a
	call RenderTile

	ld a,(PlayingSFX)			;Play the current soundeffect (0=nosound)
	call ChibiSound

	jp GameLoop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CreateDescender:
	call GetRandom			;Get a random column
	and %00011111
	cp ScreenWidthG
	jr nc,CreateDescender	;Get a number 0-screenwidth
	ld hl,tilemap
	add l
	ld l,a					;Column number (top of screen)
	ld a,12					;Descender sprite
	ld (hl),a
	xor a					;Clear A
	ret
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CreateInvader:
	call GetRandom		;Get a random row
	and %00011111
	cp ScreenHeightG
	jr nc,CreateInvader	;Get a number 0-screenheight
	ld hl,tilemap
	ld b,0
	ld c,a
	or a
	rl c				;Multiply by 32
	rl b
	rl c
	rl b
	rl c
	rl b
	rl c
	rl b
	rl c
	rl b
	ld a,ScreenWidthG-1	;Far right of screen
	or c
	ld c,a
	add hl,bc
	ld a,11				;Invader sprite
	ld (hl),a
	xor a
	xor a	;Clear A
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PlayerDead:							;Player has been killed
	ld bc,1000

PlayerDead_SpotRepeat:
	push bc
		call GetRandom				;Pick a random column between 0-31
		and %00011111
		ld hl,tilemap				;Load in the address of the tilemap
		add l
		ld l,a						;Shift to the random column
		ld b,0
PlayerDead_SpotSeek:
		ld a,(hl)
		cp 13						;Check if the column is showing our gameover grime
		jr nz,PlayerDead_FoundSpot
		ld de,32					;If it is, move down until we find an empty spot
		add hl,de
		inc b
		ld a,b
		cp ScreenHeightG-1			
		jr z,PlayerDead_FoundSpot	;We've got to the end of the screen.
		jr PlayerDead_SpotSeek
PlayerDead_FoundSpot:
		ld a,13
		ld (hl),a					;Set the tile to our gameover gri,e
		
	pop bc
	push bc
		ld a,c
		and %00001111
		jr nz,PlayerDead_NoRedraw	;only update the screen each 16 tiles
		
		ld a,c
		and %11110000				;Change the counter to a sound effect
		rrca
		rrca
		rrca
		rrca
		ld c,a
		ld a,b
		and %00001111
		rrca
		rrca
		rrca
		rrca
		or c
		xor %00111111
		or  %10000000
		call ChibiSound			;Make the sound
		call ForceAnimate
		call RepaintScreen		;Update the screen
		
PlayerDead_NoRedraw:		
	pop bc
	dec bc
	ld a,b
	or c
	jr nz,PlayerDead_SpotRepeat	;Continue the gameover animation
	
	xor a
	call ChibiSound				;stop the sound
	
	ld de,TileMap+1
	ld hl,TileMap
	ld a,13
	ld (hl),a
	ld bc,768-1
	z_ldir
	call RepaintScreen			;We may not have actually filled the screen with grime, so lets force-fill it here
	
	
	ld bc,&1000					;Wait a bit
	call pause
	
	ld a,(Lives)				;Decrease the lives
	dec a
	ld (Lives),a
	
	jp nz,NewGameRound			;If the player has lives left, keep playing
		
	ld h,(ScreenWidth/2)-7+1	
	ifdef BuildTI8
		ld l,(ScreenHeight/2)-2
	else
		ld l,(ScreenHeight/2)-3
	endif
	call Locate
	ld hl,GameOver 				;Print the gameover message
	call PrintString
		
	ifdef BuildTI8
		ld h,0
		ld l,(ScreenHeight/2)-1
	else
		ld h,(ScreenWidth/2)-8
		ld l,(ScreenHeight/2)+1
	endif
	call Locate 
	ld hl,GameOver2				;Print the yousuck messaage
	call PrintString
	
	ld hl,Score
	ld de,HiScore
	ld b,4
	call BCD_Cp					;Check if we have a new highscore
	jr nc,GameOverWaitForFire
	
	ld h,(ScreenWidth/2)-7+1
	ifdef BuildTI8
		ld l,(ScreenHeight/2)+1
	else
		ld l,(ScreenHeight/2)+4
	endif
	call Locate
	ld hl,NewHiscore			
	call PrintString			;Show the 'new highscore' message
	ld bc,4
	ld hl,Score
	ld de,HiScore
	z_ldir						;update the highscore
	
GameOverWaitForFire:
	ifdef BuildTI8
       	ld h,0						;Show the highscore message
       	ld l,screenheight-2
       	call Locate
       	ld hl,HighScoreMessage
       	call PrintString
       	ld de,HiScore				;Show the highscore
       	ld b,4
       	call BCD_Show
	endif

	call WaitForFire				;Pause, then restart the game
	jp TitleScreen
	
	
GameOver:  db "You're dead!",255
	ifdef BuildTI8
					;  123456789012
		GameOver2: db "cos you suck",255
	else
		GameOver2: db "('cos you suck!)",255
	endif
NewHiscore: db "New Hiscore!",255
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BulletStrike:				;Players bullet has hit something
	push bc
		push hl
		
			ld hl,BCD1			;Seeker Score
			ld b,%10000001		;Seeker Sound
			cp 10
			jr z,ApplyScore
			ld hl,BCD3			;Blue Mould Score
			ld b,%10000111		;Blue Mould Sound
			cp 9
			jr z,ApplyScore
			ld hl,BCD5			;Green Mould Score
			ld b,%10000111		;Green Mould Sound
			cp 8				
			jr z,ApplyScore
			ld hl,BCD20			;Invader/Descender Score
			ld b,%10001111		;Invader/Descender Sound
ApplyScore:
			ld a,b
			ld (PlayingSFX),a	;Make a sound
			ld de,Score
			ld b,4
			call BCD_Add		;Add the score
		pop hl

		ld (hl),0
		call RenderTile			;Remove the enemy from the tilemap
		
		xor a
		ld (NothingShot),a
		ld (AllowedFastGrowth),a	;Player is busy, so stop fast growth
		
		
		call GetRandom	;Add some randomization

	pop bc
	
	jp BulletRestart
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetRandom:
	push hl
		ld hl,RandomSeed		;Update the random seed 
		z_ld_a_r				;Get a random number from R
		xor (hl)				;Xor it with the last one
		rlca					;Bitshift everything to the left
		ld (hl),a
	pop hl
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Pause:
      	dec bc
      	ld a,b
       	or c
      	jr nz,Pause				;Pause for BC ticks
       	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ReadBothControls:
	push bc
		call Player_ReadControlsDual
		ld a,h
		and l
		ld h,a					;Read both controllers, and merge them together into H
	pop bc
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Debounce:	
		push hl
			call ReadBothControls
			inc a
		pop hl
		jr nz,Debounce			;Wait for all keys to be released
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
WaitForFire:	
	call debounce				;Wait for keys to be released
WaitForFire2:
	push hl
		call ReadBothControls
		or Keymap_AnyFire
		inc a
	pop hl
	jr z,WaitForFire2			;Wait for any key to be pressed
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ClearScreen:					;Clear the tilemap
		ld hl,tilemap
		ld d,h
		ld e,l
		inc de
		ld (hl),0				;Set all bytes in tilemap to 0
		ld bc,768-1
		z_ldir
		call ForceRepaint		; and force a repaint
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ForceAnimate:
	ifndef BuildTI8							;No animation on TI
		ld bc,768/6							;We animate 1/6 tiles each time, this keeps each frame fast, and makes the the frames that animate look 'random'
		ld de,6
		inc b								;Need to inc b for the loop to work
		
		
		ld hl,tilemap2						;We wipe TileMap2, to force an update of the tiles
		
		ld a,(AnimTick)
		inc a
		cp 6								;See if the 6 sets hve all been animated
		jr nz,ForceAnimate_UpdateL			
		
		ld a,(Animframe)					;All the frames have been animated, so we flip to showing the other frame
		xor %00010000
		ld (Animframe),a					;we toggle bit 5, because there are 16 tiles max (0-15)
		xor a
		ld (AnimTick),a						;Reset animation tick
		jr ForceAnimateAgain
		
ForceAnimate_UpdateL:	
		ld (AnimTick),a
		add l
		ld l,a
		xor a					;Need A=0 when loop starts
ForceAnimateAgain:
		cp (hl)					;We don't mess with 0 tiles, as it slows things down and causes problems
		jp z,CellSkip			;this relies on A=0 when this routine starts
		ld (hl),255				;Set the 'oldtile' to 255... this forces a repaint
		CellSkip:
		add hl,de
		dec c
		jp nz,ForceAnimateAgain
		dec b
		jp nz,ForceAnimateAgain
	endif
	ret

ForceRepaint:					;Force a repaint of the whole tilemap (including blanks spaces)
	ld hl,tilemap2
	ld d,h
	ld e,l
	inc de
	ld (hl),255					;Set oldtile to 255, this effectively forces a repaint
	ld bc,768-1
	z_ldir	
	ret	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RepaintScreen:

	ld hl,&0000			;We repaint the screen in 4 sections,
	call DoFill			;this updates in a checkerboard effect, and makes the refresh less visible
	
	ld hl,&0101
	call DoFill
	
	ld hl,&0001
	call DoFill
	
	ld hl,&0100
	call DoFill
	
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DoFill:	
	ld c,l									;Start Y
FillCAgain:
	ld b,h									;Start X
FillBAgain:
	push bc
	push hl
		call FindTile
		ld a,(hl)
		ld de,768							;Adding 768 moves us to tilemap2 (the cache copy)
		add hl,de
		cp (hl)								;Compare new tile to old one
		ld (hl),a
		ifndef BuildTI8
			call nz,RenderTile				;Render the tile if it's not changes
		else
			bit 0,b
			call z,RenderTile				;On TI we render 2 tiles at once, so we skip every other one
		endif
		
	pop hl
	pop bc
	inc b									;We move in twos because we run the routine 4 time 
	inc b									;to make the update look nicer and avoid a wiping effect
	ld a,b
	cp ScreenWidthG
	jr c,FillBAgain
	inc c
	inc c
	ld a,c
	cp ScreenHeightG
	jr c,FillCAgain
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MouldEvolve:								;Evolve the mould (full tick)
	ld hl,TileMap2
	xor a
	ld c,a
MouldEvolve_NextY:
	xor a
	ld b,a
MouldEvolve_NextX:
	or a
	ld a,(hl)
	push hl
		push af
			ld de,768						;subtract 768, because we want to see the previous state.
			z_sbc_hl_de
		pop af
		
		cp 8
		jp z,MouldEvolve_Green				;Evolve a cell of green mould
		cp 9
		jp z,MouldEvolve_Blue				;Evolve a cell of blue mould
		cp 12
		call z,DoDescender					;Move a descender down
		cp 11
		call z,DoInvader					;Move an invader left
		cp 10
		call z,DoMouldSeek					;Move a seeker towards the player
MouldEvolve_Next:
	pop hl
	inc hl
	inc b
	ld a,b
	cp 32
	jr nz,MouldEvolve_NextX
	inc c
	ld a,c
	cp 24
	jr nz,MouldEvolve_NextY
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MouldMove:									;Move the mould (partial tick)

	ld a,(Animframe)					;Force animation
	xor %00010000
	ld (Animframe),a				

	ld hl,TileMap2
	xor a
	ld c,a
MouldMove_NextY:
	xor a
	ld b,a
MouldMove_NextX:
	or a
	ld a,(hl)
	push hl
		push af	
			ld de,768						;subtract 768, because we want to see the previous state.
			z_sbc_hl_de
		pop af
		cp 12
		call z,DoDescender					;Move a descender down
		cp 11
		call z,DoInvader					;Move an invader left
		cp 10
		call z,DoMouldSeek					;Move a seeker towards the player
MouldMove_Next:
	pop hl
	inc hl
	inc b
	ld a,b
	cp 32
	jr nz,MouldMove_NextX
	inc c
	ld a,c
	cp 24
	jr nz,MouldMove_NextY
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DoDescender:
	ld a,c
	cp ScreenHeightG-1
	jr z,ZeroCurrent
	ld d,(hl)
	
	push bc
	push hl	
		ld bc,32							;Move down a line
		add hl,bc
		ld a,(hl)							;Read in the object under the descender
		or a
		jr z,DescenderDone
		cp 5
		jp c,PlayerDead						;See if the descender has hit the player
		jr nz,NoZeroBullet
		xor a								;don't copy player sprites!
NoZeroBullet:
		cp 9
		jr z,DescenderToGreen				;Convert Blue mould to green
		cp 10
		jr z, DescenderToBlue				;Convert seekers to blue mould
		jr DescenderDone
DescenderToBlue:
		ld a,9								;Blue Mould
		jr DescenderDone
DescenderToGreen:
		ld a,8								;Green Mould
DescenderDone:
		ld (hl),d
	pop hl
	pop bc
	
	ld (hl),a
	xor a
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DoInvader:
	ld a,l
	and %00011111
	jr z,ZeroCurrent						;We've reached the left hand side of the screen, so remove the invader
	ld d,(hl)
	
	dec hl
	ld a,(hl)
	or a
	jr z,InvaderDone
	cp 5
	jp c,PlayerDead							;We've hit the player, so they player is dead
	jr nz,NoZeroBullet2
	xor a									;Don't copy player sprites
NoZeroBullet2:
InvaderDone:
	
	ld (hl),d
	inc hl
	ld d,a
	cp 8
	jr nc,DoInvader_NoSpore					;Don't drop a spore on non-empty spaces

	call GetRandom							;We drop spores at random
	ifdef ScreenSmall
		and %00001111						;Spores drop more often on small screens
	else
		and %00011111
	endif
	jr nz,DoInvader_NoSpore
	
	ld a,(AllowedFastGrowth)				;We're making a spore, so speed up the growth for a few ticks
	ld (FastGrowth),a
	
	ld a,8
	jr DoInvader_NewSpore					;Drop a new spore
	
DoInvader_NoSpore:	
	ld a,d
DoInvader_NewSpore:	
	ld (hl),a
	xor a
	ret
ZeroCurrent:
	ld (hl),0								;Clear the cell
	xor a
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DoMouldSeek:
	ld d,h							;Load current location into DE
	ld e,l
	ld a,(PlayerX1)					;Compare to player X
	cp b
	jr z,DoMouldMove_SkipX
	jr nc,DoMouldMove_XSmaller
		dec de						;Move left
		jr DoMouldMove_SkipX
DoMouldMove_XSmaller:
		inc de						;Move right
DoMouldMove_SkipX:	
	ld a,(PlayerY1)					;Compare to player Y
	cp c
	jr z,DoMouldMove_SkipY
	jr nc,DoMouldMove_YSmaller
		push hl
		ld hl,-32
		add hl,de					;Move up
		z_ex_dehl
		pop hl
		jr DoMouldMove_SkipY
DoMouldMove_YSmaller:
		push hl
		ld hl,32
		add hl,de					;Move down
		z_ex_dehl
		pop hl
DoMouldMove_SkipY:	
	ld a,(de)
	or a
	jr z,SeekOK
	cp 8	;Bullet
	jr c,SeekOK
	ret
SeekOK:
	ld a,(hl)
	ld (de),a					;Move to the new location, clear the old one
	ld (hl),0
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
MouldEvolve_Green:
	ld a,9					;Center objects (seeeker)
	z_ld_ixl_a
	ld a,8					;Edge objects (green)
	z_ld_ixh_a
	jp DoMouldEvolve
	
MouldEvolve_Blue:
	ld a,10					;Center object (Seeker)
	z_ld_ixl_a
	ld a,9					;Edge object (Blue)
	z_ld_ixh_a
	jp DoMouldEvolve

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DoMouldEvolve:
		z_ld_a_ixl 			;New Center spore
		ld (hl),a
		inc hl				;Move Right
		ld a,l
		and %00011111		;See if we're off the screen
		jr z,MouldEvolve_GreenSkip1b
		ld a,(hl)
		or a
		jr nz,MouldEvolve_GreenSkip1
		z_ld_a_ixh 			;New Outer spore
		ld (hl),a
MouldEvolve_GreenSkip1:
		dec hl				;Move to center
		ld a,l
		and %00011111
		jr z,MouldEvolve_GreenSkip2b
MouldEvolve_GreenSkip1b:
		dec hl				;Move left
		ld a,(hl)
		or a				;See if we're offscreen
		jr nz,MouldEvolve_GreenSkip2
		z_ld_a_ixh 			;New Outer spore
		ld (hl),a
MouldEvolve_GreenSkip2:
		inc hl				;Move to Center
MouldEvolve_GreenSkip2b:
		ld de,32
		ld a,c
		cp 24				;See if we're off the bottom of the screen
		jr z,MouldEvolve_GreenSkip3b
		add hl,de			;Move Down
		ld a,(hl)
		or a
		jr nz,MouldEvolve_GreenSkip3
		z_ld_a_ixh 			;New Outer spore
		ld (hl),a
MouldEvolve_GreenSkip3:
		ld a,c
		or a				;See if we're offscreen
		jr z,MouldEvolve_GreenSkip4
		ld de,64
MouldEvolve_GreenSkip3b:
		or a
		z_sbc_hl_de			;Move Up
		ld a,(hl)
		or a
		jr nz,MouldEvolve_GreenSkip4
		z_ld_a_ixh 			;New Outer spore
		ld (hl),a
MouldEvolve_GreenSkip4:
	jp MouldEvolve_Next

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FindTile:						;Convert a BC (XY) co-ordinate to a memory location
	ld hl,TileMap
FindTileAlt:
		ld d,0
		ld e,c
		or a
		rl e					;X32 because we have 32 tiles per line
		rl d
		rl e
		rl d
		rl e
		rl d
		rl e
		rl d
		rl e
		rl d
		ld a,e
		add b
		ld e,a
		add hl,de
	ret		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RenderTile:					;Draw the tile
	ifdef BuildTI8
	di
		ld a,b
		and %11111110
		ld b,a
		
		call FindTile		;We draw tiles in pairs on the TI, because tiles are 4 pixels, so we need to do two together in 1 byte
		ld a,(hl)
		ld ixh,a			;Left tile
		inc hl
		ld a,(hl)
		ld ixl,a			;Right Tile
		call ShowTile
	else
		call FindTile		
		ld a,(Animframe)	;Read in our Animation frame (0/16)
		push bc
			ld b,a
			ld a,(hl)
			or b
		pop bc
		ScreenStartDrawing	;For SAM
		call ShowTile
		ScreenStopDrawing	;For SAM
	endif
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;														Palettes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Palette:
	ifdef Palette16 			;SAM/MSX/GG/SMS palette
		defw &0000;0  -GRB
		defw &0555;1  -GRB
		defw &0AAA;2  -GRB
		defw &0FFF;3  -GRB
		defw &0900;4  -GRB
		defw &0E05;5  -GRB
		defw &0518;6  -GRB
		defw &061F;7  -GRB
		defw &08B0;8  -GRB
		defw &0DF2;9  -GRB
		defw &038E;10  -GRB
		defw &00FF;11  -GRB
		defw &0080;12  -GRB
		defw &00F0;13  -GRB
		defw &0A18;14  -GRB
		defw &0F7B;15  -GRB
		defw &0000; Border (where appropriate)  -GRB

	endif
	ifdef Palette4					;CPC/EP128 palette
		defw &0000;0  -GRB
		defw &061F;7  -GRB
		defw &0F00;5  -GRB
		defw &0FAC;11  -GRB
		defw &0900;4  -GRB
		defw &0F27;5  -GRB
		defw &0518;6  -GRB
		defw &061F;7  -GRB
		defw &08B0;8  -GRB
		defw &0DF2;9  -GRB
		defw &0AAA;10  -GRB
		defw &0BBB;11  -GRB
		defw &0CCC;12  -GRB
		defw &0DDD;13  -GRB
		defw &0EEE;14  -GRB
		defw &0FFF;15  -GRB
		defw &0000;0  -GRB
	endif
		ifdef PaletteGB				;Gameboy color palettes
       		defw &0000;0  -GRB
       		defw &0555;1  -GRB
       		defw &0AAA;2  -GRB
       		defw &0FFF;3  -GRB
       		
       		defw &0000;4  -GRB
       		defw &0800;5  -GRB
       		defw &0C00;6  -GRB
       		defw &0F00;7  -GRB
       		
       		defw &0000;8  -GRB
       		defw &0208;9  -GRB
       		defw &040F;10  -GRB
       		defw &086F;11  -GRB
       		
       		defw &0000;8  -GRB
       		defw &0A80;9  -GRB
       		defw &0FF0;10  -GRB
       		defw &0FF8;11  -GRB
       		
       		defw &0000;8  -GRB
       		defw &00AA;9  -GRB
       		defw &00FF;10  -GRB
       		defw &08FF;11  -GRB
       		
       		defw &0000;8  -GRB
       		defw &0A0A;9  -GRB
       		defw &0F0F;10  -GRB
       		defw &0F8F;11  -GRB
       		
       		defw &0000;8  -GRB
			defw &00F0;13  -GRB
			defw &0A18;14  -GRB
			defw &0F7B;15  -GRB
			
			defw &0000;8  -GRB
       		defw &0A18;9  -GRB
       		defw &0F7B;10  -GRB
      		defw &0F7B;11  -GRB
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef BuildTI8
		read "..\SrcTI\V1_SimpleTileChibi.asm"
	else
		read "..\SrcAll\V1_SimpleTile.asm"
	endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;															Graphics
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BitmapFont:
	ifdef BMP_UppercaseOnlyFont
		incbin "..\ResALL\Font64.FNT"			;Font bitmap, this is common to all systems
	else
		incbin "..\ResALL\Font96.FNT"			;Font bitmap, this is common to all systems
	endif
	
	
RawBitmap:										;Sprite bitmap data.
	ifdef BuildCPC
		incbin "..\ResALL\Sprites\GrimeCPC.RAW"
		incbin "..\ResALL\Sprites\GrimeCPC2.RAW"
	endif
	ifdef BuildENT
		incbin "..\ResALL\Sprites\GrimeCPC.RAW"
		incbin "..\ResALL\Sprites\GrimeCPC2.RAW"
	endif
	ifdef BuildZXS
		incbin "..\ResALL\Sprites\GrimeZX.Raw"
		incbin "..\ResALL\Sprites\GrimeZX2.Raw"
	endif
	ifdef BuildTI8
		incbin "..\ResALL\Sprites\GrimeTI.Raw"
		;No animation on the TI, so no second sprite bank
	endif
	ifdef BuildGBx
		incbin "..\ResALL\Sprites\GrimeGB.Raw"
		incbin "..\ResALL\Sprites\GrimeGB2.Raw"
	endif
	ifdef BuildSxx
		incbin "..\ResALL\Sprites\GrimeSMS.Raw"
		incbin "..\ResALL\Sprites\GrimeSMS2.Raw"
	endif
	ifdef BuildMSX
		ifdef BuildMSX_MSX1
			incbin "..\ResALL\Sprites\GrimeZX.Raw"
			incbin "..\ResALL\Sprites\GrimeZX2.Raw"
		else
			incbin "..\ResALL\Sprites\GrimeMSX.RAW"
			incbin "..\ResALL\Sprites\GrimeMSX2.RAW"
		endif
	endif
	ifdef BuildSAM
		incbin "..\ResALL\Sprites\GrimeMSX.RAW"
		incbin "..\ResALL\Sprites\GrimeMSX2.RAW"
	endif
RawBitmap_End:	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;															Palettes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RawPalettes:									;Palettes for systems with Color attributes
	ifdef BuildZXS		;Spectrum palettes (one per sprite)
		db	64+ 7;0
		db	64+ 7;1
		db	64+ 7;2
		db	64+ 7;3
		db	64+ 7;4
		db	64+ 7;5
		db	64+ 7;6
		db	64+ 7;7
		db	64+ 4;8
		db	64+ 5;9
		db	64+ 6;10
		db	64+ 3;11
		db	64+ 5;12
		db	64+ 4;13
		db	64+ 6;14
		db	64+ 6;15
		
		db	64+ 7;0		;2nd frame of animation
		db	64+ 7;1
		db	64+ 7;2
		db	64+ 7;3
		db	64+ 7;4
		db	64+ 7;5
		db	64+ 7;6
		db	64+ 7;7
		db	64+ 4;8
		db	64+ 5;9
		db	64+ 6;10
		db	64+ 3;11
		db	64+ 5;12
		db	64+ 4;13
		db	64+ 6;14
		db	64+ 6;15
		
	endif
	ifdef BuildMSX_MSX1	;MSX palettes, 1 DB line per tile, 8 entries per tile (lines of tile)
		db &F0,&F0,&F0,&F0,&F0,&F0,&F0,&F0;0
		db &F0,&F0,&F0,&F0,&F0,&F0,&F0,&F0;1
		db &F0,&F0,&F0,&F0,&F0,&F0,&F0,&F0;2
		db &F0,&F0,&F0,&F0,&F0,&F0,&F0,&F0;3
		db &F0,&F0,&F0,&F0,&F0,&F0,&F0,&F0;4
		db &F0,&F0,&F0,&F0,&F0,&F0,&F0,&F0;5
		db &F0,&F0,&F0,&F0,&F0,&F0,&F0,&F0;6
		db &F0,&F0,&F0,&F0,&F0,&F0,&F0,&F0;7
		db &C0,&20,&3C,&3C,&3C,&3C,&20,&C0;8
		db &40,&40,&50,&50,&50,&50,&40,&40;9
		db &A0,&A0,&B0,&B0,&B0,&B0,&A0,&A0;10
		db &60,&60,&D0,&D0,&D0,&D0,&60,&60;11
		db &e0,&70,&70,&70,&70,&70,&70,&e0;12
		db &23,&23,&23,&23,&23,&23,&23,&23;13
		db &C0,&20,&30,&30,&30,&30,&20,&C0;14
		db &C0,&20,&30,&30,&30,&30,&20,&C0;15
		
		db &F0,&F0,&F0,&F0,&F0,&F0,&F0,&F0;0	;2nd frame of animation
		db &F0,&F0,&F0,&F0,&F0,&F0,&F0,&F0;1
		db &F0,&F0,&F0,&F0,&F0,&F0,&F0,&F0;2
		db &F0,&F0,&F0,&F0,&F0,&F0,&F0,&F0;3
		db &F0,&F0,&F0,&F0,&F0,&F0,&F0,&F0;4
		db &F0,&F0,&F0,&F0,&F0,&F0,&F0,&F0;5
		db &F0,&F0,&F0,&F0,&F0,&F0,&F0,&F0;6
		db &F0,&F0,&F0,&F0,&F0,&F0,&F0,&F0;7
		db &C0,&20,&3C,&3C,&3C,&3C,&20,&C0;8
		db &40,&40,&50,&50,&50,&50,&40,&40;9
		db &A0,&A0,&B0,&B0,&B0,&B0,&A0,&A0;10
		db &60,&60,&D0,&D0,&D0,&D0,&60,&60;11
		db &e0,&70,&70,&70,&70,&70,&70,&e0;12
		db &23,&23,&23,&23,&23,&23,&23,&23;13
		db &C0,&20,&30,&30,&30,&30,&20,&C0;14
		db &C0,&20,&30,&30,&30,&30,&20,&C0;15
	endif
	ifdef BuildGBC		;GBC color palettes for sprites (one per sprite)
		db	0;0
		db	0;1
		db	0;2
		db	0;3
		db	0;4
		db	0;5
		db	0;6
		db	0;7
		db	1;8
		db	2;9
		db	3;10
		db	4;11
		db	5;12
		db	7;13
		db	1;14
		db  0;15
		
		db	0;0			;2nd frame of animation
		db	0;1
		db	0;2
		db	0;3
		db	0;4
		db	0;5
		db	0;6
		db	0;7
		db	1;8
		db	2;9
		db	3;10
		db	4;11
		db	5;12
		db	7;13
		db	1;14
	endif
RawPalettes_End:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;															Keymaps
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	align32	
KeyMap equ KeyMap2+16			;wsad bnm p
KeyMap2:						;Default controls
	ifdef BuildCPC
	db &F7,&03,&7f,&05,&ef,&09,&df,&09,&f7,&09,&fB,&09,&fd,&09,&fe,&09 ;p2-pause,f3,f2,f1,r,l,d,u
	db &f7,&03,&bf,&04,&bf,&05,&bf,&06,&df,&07,&df,&08,&ef,&07,&f7,&07 ;p1-pause,f3,f2,f1,r,l,d,u
	endif
	ifdef BuildENT
	db &ef,&09,&bf,&08,&df,&0a,&bf,&0a,&fe,&0a,&fd,&0a,&fb,&0a,&f7,&0a
	db &ef,&09,&fe,&08,&fe,&00,&fb,&00,&f7,&01,&bf,&01,&df,&01,&bf,&02
	endif
	ifdef BuildZXS
	db &fe,&05,&fe,&07,&fe,&06,&ef,&08,&fe,&08,&fd,&08,&fb,&08,&f7,&08
	db &fe,&0f,&fb,&07,&f7,&07,&ef,&07,&fb,&01,&fe,&01,&fd,&01,&fd,&02
	endif
	ifdef BuildMSX
	db &df,&04,&fe,&08,&ef,&0c,&df,&0c,&f7,&0c,&fb,&0c,&fd,&0c,&fe,&0c
	db &df,&04,&fb,&04,&f7,&04,&7f,&02,&fd,&03,&bf,&02,&fe,&05,&ef,&05
	endif
	ifdef BuildTI8
	db &f7,&05,&fb,&05,&fd,&05,&fe,&05,&fb,&04,&fb,&02,&fd,&03,&f7,&03
	db &bf,&05,&7f,&00,&bf,&00,&df,&00,&fb,&06,&fd,&06,&fe,&06,&f7,&06
	endif
	ifdef BuildSAM
	db &FE,&05,&Fe,&07,&FE,&06,&FE,&04,&F7,&04,&EF,&04,&FB,&04,&FD,&04
	db &FE,&05,&FB,&07,&F7,&07,&EF,&07,&FB,&01,&FE,&01,&FD,&01,&FD,&02
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;															Score BCDs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BCD1: db &01,&00,&00,&00	;1 		Score 'adders' for BCD... 
BCD3: db &03,&00,&00,&00	;3		my BCD requires value to add to match in length destination score
BCD5: db &05,&00,&00,&00	;5
BCD20: db &20,&00,&00,&00	;20
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;															Title Tilemap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TitlePic:		;GRIME Z80 Logo
	; db 0,0,0,9,9,0,9,9,9,0,0,9,0,0,9,9,9,0,9,0,9,9,0,0				;Alt Version
	; db 9,0,9,0,0,9,9,0,0,9,9,0,9,9,0,9,0,9,9,9,0,0,9,0
	; db 0,9,0,8,8,0,0,8,8,0,0,8,0,0,8,0,8,0,9,0,8,8,0,9
	; db 9,0,8,0,0,0,0,8,0,8,0,8,0,8,0,8,0,8,0,8,0,0,9,0
	; db 9,0,8,0,8,8,0,8,8,0,0,8,0,8,0,0,0,8,0,8,8,0,9,0
	; db 9,0,8,0,0,8,0,8,0,8,0,8,0,8,0,9,0,8,0,8,0,0,9,0
	; db 0,9,0,8,8,0,0,8,0,8,0,8,0,8,0,9,0,8,0,0,8,8,0,9
	; db 9,0,9,0,0,9,0,0,0,0,9,0,9,0,9,0,9,0,9,9,0,0,9,0
	; db 0,9,9,9,9,0,8,8,8,0,0,8,0,9,0,8,0,9,9,9,9,9,9,9
	; db 0,9,9,9,9,9,0,0,8,0,8,0,8,0,8,0,8,0,9,9,9,9,9,0
	; db 0,0,9,9,9,9,0,8,0,9,0,8,0,0,8,0,8,0,9,9,9,9,9,0
	; db 9,9,9,9,9,0,8,0,9,0,8,0,8,0,8,0,8,0,9,9,9,0,9,9
	; db 0,9,0,9,9,0,8,8,8,0,0,8,0,9,0,8,0,9,9,9,9,0,0,0
	; db 0,0,9,0,9,9,0,0,0,9,9,0,9,9,9,0,9,9,9,0,9,9,9,0
	; db 0,0,0,9,9,9,9,9,9,0,0,9,0,9,9,9,9,9,9,0,0,0,9,0
	; db 0,0,9,0,9,0,0,9,0,0,0,0,9,0,0,0,9,0,0,9,0,0,0,0
	
	db 0,0,0,9,9,0,9,9,9,0,0,9,0,0,9,9,9,0,9,0,9,9,0,0
	db 9,0,9,0,0,9,9,0,0,9,9,0,9,9,0,9,0,9,9,9,0,0,9,0
	db 0,9,0,13,13,0,0,13,13,0,0,13,0,0,13,0,13,0,9,0,13,13,0,9
	db 9,0,13,0,0,0,0,13,0,13,0,13,0,13,0,13,0,13,0,13,0,0,9,0
	db 9,0,13,0,13,13,0,13,13,0,0,13,0,13,0,0,0,13,0,13,13,0,9,0
	db 9,0,13,0,0,13,0,13,0,13,0,13,0,13,0,9,0,13,0,13,0,0,9,0
	db 0,9,0,13,13,0,0,13,0,13,0,13,0,13,0,9,0,13,0,0,13,13,0,9
	db 9,0,9,0,0,9,0,0,0,0,9,0,9,0,9,0,9,0,9,9,0,0,9,0
	db 0,9,9,9,9,0,13,13,13,0,0,13,0,9,0,13,0,9,9,9,9,9,9,9
	db 0,9,9,9,9,9,0,0,13,0,13,0,13,0,13,0,13,0,9,9,9,9,9,0
	db 0,0,9,9,9,9,0,13,0,9,0,13,0,0,13,0,13,0,9,9,9,9,9,0
	db 9,9,9,9,9,0,13,0,9,0,13,0,13,0,13,0,13,0,9,9,9,0,9,9
	db 0,9,0,9,9,0,13,13,13,0,0,13,0,9,0,13,0,9,9,9,9,0,0,0
	db 0,0,9,0,9,9,0,0,0,9,9,0,9,9,9,0,9,9,9,0,9,9,9,0
	db 0,0,0,9,9,9,9,9,9,0,0,9,0,9,9,9,9,9,9,0,0,0,9,0
	db 0,0,9,0,9,0,0,9,0,0,0,0,9,0,0,0,9,0,0,9,0,0,0,0
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;															Text Messages
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef BuildZXS
KempsonMessage:																			;Title Message
       	db "Press K for Kempson",255
		db 0	;needed so our scroller doesn't gack up (it looks for an EOL 255)
	endif
ScrollingMessage:																			;Title Message
       	db "Written By Keith S, based on the DOS game by Mark Elendt... Check out my Z80 tutorials at www.chibiakumas.com/z80 ... "
		
		db "Thanks to Shane O'Brien,bR0k3nK3y,Rob Uttley,Barry White,Gradius Dias and my other Patreon backers!",255

		
		; Thanks to ALL my patreon backers... Alejandro Perez, Barry White, bR0k3nK3y, Dimitris Topouzis, Ervin Pajor, hamlet440, Ivar Fiske, James Ford, krt17, Laurens Holst, Remax, Michael Steil, Peter Jones, Rajasekaran Senthil Kumaran, Rob Uttley, Shane O'Brien, Themistocles/Gryzor, Volodymyr Bezobiuk

		
HighScoreMessage:																			;Highscore Message
	ifdef BuildTI8
			db "Hsc:",255
	else
			db "HiScore:",255
	endif
PauseMessage:
       	db "Paused",255
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Monitor_Pause equ 1 				;*** Pause after showing debugging info



	read "..\SrcALL\Multiplatform_Monitor_RomVer.asm"
	read "..\SrcALL\Multiplatform_MonitorSimple_RomVer.asm"
	read "..\SrcALL\Multiplatform_ShowHex.asm"
	read "..\SrcALL\Multiplatform_BCD.asm"
	
	read "..\SrcALL\Multiplatform_ChibiSound.asm"


	;read "..\SrcAll\MultiPlatform_Stringreader.asm"		;*** read a line in from the keyboard
	;read "..\SrcAll\Multiplatform_StringFunctions.asm"	;*** convert Lower>upper and decode hex ascii
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifndef BuildCONSOLEjoy
UseHardwareKeyMap equ 1 ; Need the Keyboard map
	endif
	
	ifdef BuildCONSOLE
	
		read "..\SrcALL\V1_VdpMemory.asm"
		read "..\SrcALL\V1_HardwareTileArray.asm"
	else

		;read "..\SrcALL\Multiplatform_ScanKeys.asm"
		;read "..\SrcALL\Multiplatform_KeyboardDriver.asm"
		read "..\SrcALL\Multiplatform_BitmapFonts.asm"
		read "..\SrcALL\V1_BitmapMemory.asm"
	endif
	align16

	read "..\SrcAll\Multiplatform_ReadJoystick.asm"
	
	read "..\SrcAll\V1_Palette.asm"
	read "..\SrcALL\V2_Functions.asm"
	read "..\SrcALL\V1_Footer.asm"
	