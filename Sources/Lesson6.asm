; Learn Multi platform Z80 Assembly Programming... With Vampires!

;Please see my website at	www.chibiakumas.com/z80/
;for the 'textbook', useful resources and video tutorials

;File		Example 6
;Version	V1.0
;Date		2018/2/12
;Content	Lookup table, Screen Co-ordinates, Vector Tables, Basic Parameters Byref




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Do VectorArray

org &8000
	;Jump block... this makes it easy to call commands in our program 
	;without knowing the real address

	jp GetSprite	;this is at &8000
	jp PutSprite	;this is at &8003 - as JP XXXX is 3 bytes
	jp GetMemPos	;this is at &8006
	jp VectorTableTest;this is at &8009

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;				Screen Co-ordinate functions

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


GetScreenPos:	;return memory pos in HL of screen co-ord B,C (X,Y)
	
	push bc
		ld b,0			;Load B with 0 because we only want C
		ld hl,scr_addr_table
		add hl,bc	;We add twice, because each address has 2 bytes
		add hl,bc

		ld a,(hl)	
		inc l		;INC L not INC HL because we're byte aligned to 2
		ld h,(hl)
		ld l,a
	pop bc
	ld c,b		;Load the Xpos into C
	ld b,&C0	;Our table is relative to 0 - so we need to add our screen base
	add hl,bc	;This is so it can be used for alt screen buffers
ret

GetNextLine:
	ld a,h		;Add &08 to H (each CPC line is &0800 bytes below the last
	add &08
	ld h,a
			;Every 8 lines we need to jump back to the top of the memory range to get the correct line
			;The code below will check if we need to do this - yes it's annoying but that's just the way the CPC screen is!
	bit 7,h		;Change this to bit 6,h if your screen is at &8000!
	ret nz		

	ld bc,&c050	;if we got here we need to jump back to the top of the screen - the command here will do that
	add hl,bc
	ret


align 2			;Align the data to a 2 byte boundary - this allow us to use INC L rather than INC HL
			;as we know that the second part will not be at an address like &8100 that would cross a boundary

; This is the screen addresses of all the lines of the screen - Just copy paste these!
; Note you will have to add the base address of your screen (usually &C000)
; This table is used in Chibi Akumas, where the screen can be at &C000, or &8000 depending on which buffer is shown.
scr_addr_table:
	defb &00,&00, &00,&08, &00,&10, &00,&18, &00,&20, &00,&28, &00,&30, &00,&38;1
	defb &50,&00, &50,&08, &50,&10, &50,&18, &50,&20, &50,&28, &50,&30, &50,&38;2
	defb &A0,&00, &A0,&08, &A0,&10, &A0,&18, &A0,&20, &A0,&28, &A0,&30, &A0,&38;3
	defb &F0,&00, &F0,&08, &F0,&10, &F0,&18, &F0,&20, &F0,&28, &F0,&30, &F0,&38;4
	defb &40,&01, &40,&09, &40,&11, &40,&19, &40,&21, &40,&29, &40,&31, &40,&39;5
	defb &90,&01, &90,&09, &90,&11, &90,&19, &90,&21, &90,&29, &90,&31, &90,&39;6
	defb &E0,&01, &E0,&09, &E0,&11, &E0,&19, &E0,&21, &E0,&29, &E0,&31, &E0,&39;7
	defb &30,&02, &30,&0A, &30,&12, &30,&1A, &30,&22, &30,&2A, &30,&32, &30,&3A;8
	defb &80,&02, &80,&0A, &80,&12, &80,&1A, &80,&22, &80,&2A, &80,&32, &80,&3A;9
	defb &D0,&02, &D0,&0A, &D0,&12, &D0,&1A, &D0,&22, &D0,&2A, &D0,&32, &D0,&3A;10
	defb &20,&03, &20,&0B, &20,&13, &20,&1B, &20,&23, &20,&2B, &20,&33, &20,&3B;11
	defb &70,&03, &70,&0B, &70,&13, &70,&1B, &70,&23, &70,&2B, &70,&33, &70,&3B;12
	defb &C0,&03, &C0,&0B, &C0,&13, &C0,&1B, &C0,&23, &C0,&2B, &C0,&33, &C0,&3B;13
	defb &10,&04, &10,&0C, &10,&14, &10,&1C, &10,&24, &10,&2C, &10,&34, &10,&3C;14
	defb &60,&04, &60,&0C, &60,&14, &60,&1C, &60,&24, &60,&2C, &60,&34, &60,&3C;15
	defb &B0,&04, &B0,&0C, &B0,&14, &B0,&1C, &B0,&24, &B0,&2C, &B0,&34, &B0,&3C;16
	defb &00,&05, &00,&0D, &00,&15, &00,&1D, &00,&25, &00,&2D, &00,&35, &00,&3D;17
	defb &50,&05, &50,&0D, &50,&15, &50,&1D, &50,&25, &50,&2D, &50,&35, &50,&3D;18
	defb &A0,&05, &A0,&0D, &A0,&15, &A0,&1D, &A0,&25, &A0,&2D, &A0,&35, &A0,&3D;19
	defb &F0,&05, &F0,&0D, &F0,&15, &F0,&1D, &F0,&25, &F0,&2D, &F0,&35, &F0,&3D;20
	defb &40,&06, &40,&0E, &40,&16, &40,&1E, &40,&26, &40,&2E, &40,&36, &40,&3E;21
	defb &90,&06, &90,&0E, &90,&16, &90,&1E, &90,&26, &90,&2E, &90,&36, &90,&3E;22
	defb &E0,&06, &E0,&0E, &E0,&16, &E0,&1E, &E0,&26, &E0,&2E, &E0,&36, &E0,&3E;23
	defb &30,&07, &30,&0F, &30,&17, &30,&1F, &30,&27, &30,&2F, &30,&37, &30,&3F;24
	defb &80,&07, &80,&0F, &80,&17, &80,&1F, &80,&27, &80,&2F, &80,&37, &80,&3F;25




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;				Get Sprite command

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetSprite:
	;Usage
	;Call &8000,MEMDEST,X,Y,W,H
	; The parameters come in backwards, so... H W Y X MEMDET 
	cp 5		;Check we have 5 parameters
	ret nz

	ld e,(ix+8)	;Load DE - the destination for the sprite
	ld d,(ix+9)

	ld b,(ix+6)	;X - Source Xpos in bytes (0-79)
	ld c,(ix+4)	;Y - Source Ypos in lines (0-199)

	ld a,(ix+2)	;w - read the Width from the users parameters
	ld iyh,a	;store the width in IY-High IYH is the top part of the IY register pair (like HL)

	ld (de),a	;Store the width in the destination location
	inc de		

	ld a,(ix+0)	;h - read the height from the users parameters
	ld iyl,a	;store the height in IY-Low IYL is the bottom part of IY register pair (like HL)

	ld (de),a	;Store the height in the destination location
	inc de


	Call GetScreenPos	;Get get the Screen Memory pos from  from B,C (X,Y)

RepeatY:
	push hl			;We have the memory pos of our screen line in HL
		ld b,0		;set B to zero (LDIR uses BC
		ld c,iyh	;set C to the width
		ldir		;Copy the line from HL to DE

	pop hl			;Get back the memory pos of our screen line

	call GetNextLine	;Move down a line

	dec iyl			;Decrease our line counter
	jp nz,RepeatY		;Loop if we're not finished

	ld (LastSpritePos_Plus2-2),de	;Backup the next free memory pos in our selfmodifying temp-var
ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;				Get Next Mempos command

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetMemPos:
	;Usage
	;Call &8006,@int
	;return mempos of integer

	cp 1		;Check we got 1 parameter
	ret nz	

	ld l,(ix+0)	;Load the parameter in
	ld h,(ix+1)	;We are expecting a Reference - a memory address of an integer

	;The line below uses selfmodifying code to store the next free byte for sprites
	;This allows us to store sprite addresses in integers in basic
	ld de,&0000	:LastSpritePos_Plus2

	;HL is now the memory address of the basic integer, so write in the value of DE

	ld (hl),e	;Load DE into hl - remember Little Endian so low byte first
	inc hl		;INC HL
	ld (hl),d	;High byte of DE 
ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;				Put Sprite command

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PutSprite:
	;Usage
	;Call &8003,MEMDEST,X,Y
	; The parameters come in backwards, so... Y X MEMDET 
	cp 3
	ret nz

	ld e,(ix+4)	;Load the memory address of the sprite we want to show.
	ld d,(ix+5)

	ld b,(ix+2)	;x - Destination Xpos in Bytes (0-79)
	ld c,(ix+0)	;y - Destination Ypos in Lines (0-199)

	ld a,(de) 	;Read the sprite width from the destination
	ld iyh,a	;store the width in IY-High IYH is the top part of the IY register pair (like HL)
	inc de		


	ld a,(de)	;Read the sprite height from the destination
	ld iyl,a	;store the height in IY-Low IYL is the bottom part of IY register pair (like HL)
	inc de

	Call GetScreenPos ;Get get the Screen Memory pos from  from B,C (X,Y)

RepeatYB:
	push hl		 ;We have the memory pos of our screen line in HL
		ld b,0	 ;set B to zero (LDIR uses BC
		ld c,iyh ;set C to the width

		ex de,hl ;We need to write to HL from DE, so swap DE and HL
		ldir
		ex de,hl ;We need to Put DE back, so swap DE and HL
	pop hl

	call GetNextLine ;Get back the memory pos of our screen line
	dec iyl		;Decrease our line counter
	jp nz,RepeatYB	;Loop if we're not finished

ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;				Vector Table for calls 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


PrintChar equ &BB5A
;Usage
	;Call &8009,CMD
	;run CMD from vectortable (CMD=0-2)
VectorTableTest:
	cp 1		;Check we got 1 parameter
	ret nz	
	ld a,(ix+0)	;Get it

	RLCA		;Rotate A left (doubling it - we're relying on A being <128)

	ld hl, VectorTable

	;If you use an align you can use this faster version
;	add l
;	ld l,a

	;This version doesn't need an align
	ld b,0
	ld c,a
	add hl,bc

	ld a,(hl)
	inc hl		;If you use an align you can change this to inc l
	ld h,(hl)
	ld l,a
jp (hl)

;Align 64		;if we put an align here, we can simplify the jump, this makes space for 32 commands
VectorTable:
defw TestA	;0
defw TestB	;1
defw TestC	;2

TestA:
	ld a,'a'
	jp PrintChar
TestB:
	ld a,'b'
	jp PrintChar
TestC:
	ld a,'c'
	jp PrintChar