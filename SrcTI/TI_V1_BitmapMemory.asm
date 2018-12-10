BmpByteWidth equ 1
CharByteWidth equ 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;				Screen Co-ordinate functions

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


GetScreenPos:	;return memory pos in HL of screen co-ord B,C (X,Y)
	
	push bc
		ld a,&80	;Set ROW
		add c
		ld c,a
		push bc
			out (TI_LCD_COMM),a
			call &000B ;_LCD_BUSY_QUICK
		pop bc
		ld a,&20	;Set COL
		add b
		ld b,a
	
		ld (GetNextLineBC_Plus2-2),bc
		out (TI_LCD_COMM),a
		call &000B ;_LCD_BUSY_QUICK
	pop bc
	ret


GetNextLine:
	push af
	push de
	push bc
		ld bc,&0000 ;<--SM ***
GetNextLineBC_Plus2:
		
		
		inc c					;Inc Row
		ld a,c
		cp &C0		;&C0 means 'Set Contrast' 
		jr nc,GetNextLine_Skip
		ld (GetNextLineBC_Plus2-2),bc
		ld a,c
		push bc		
			out (TI_LCD_COMM),a		;Set Row
			call &000B ;_LCD_BUSY_QUICK
		pop bc
		ld a,b
		out (TI_LCD_COMM),a			;Set Col
		call &000B ;_LCD_BUSY_QUICK
GetNextLine_Skip:
	pop bc
	pop de	
	pop af
	ret

ScreenINIT:
	di
	rst 40		;BCALL
	dw &4570	;_RunIndicOff
	
	call &000B ;_LCD_BUSY_QUICK
	ifdef ScrTISmall
		xor a			;6 bytes per char
		out (TI_LCD_COMM),a
		call &000B ;_LCD_BUSY_QUICK
	else
		ld a,&01		;8 bytes per char
		out (TI_LCD_COMM),a
		call &000B ;_LCD_BUSY_QUICK
	endif
	ld a,&07			;Set AutoINC 'Y' - what the TI TFT calls Y everyone else calls X!
	out (TI_LCD_COMM),a
	call &000B ;_LCD_BUSY_QUICK
	ret



;LCD Command Port Cheat Sheet
;	$00 Configure six bits per word 
;	$01 Configure eight bits per word 
;	$02 Turn off 
;	$03 Turn on 
;	$04 X auto-decrement mode 	(note X in TI is what everyone else calls Y!)
;	$05 X auto-increment mode 	(note X in TI is what everyone else calls Y!)
;	$06 Y auto-decrement mode 	(note Y in TI is what everyone else calls X!)
;	$07 Y auto-increment mode 	(note Y in TI is what everyone else calls X!)
;	$08 ? $0B Power supply enhancement. $08 is lowest. 
;	$10 ? $13 Power supply level. $10 is lowest. 
;	$14 ? $17 Unknown 
;	$18 Exit test mode 
;	$19 ? $1B Unknown 
;	$1C ? $1F Enter test mode 
;	$20 ? $2E Set column in 8-bit word mode 
;	$20 ? $33 Set column in 6-bit word mode 
;	$34 ? $3F Unknown 
;	$40 ? $7F Set Z-address 
;	$80 ? $BF Set row 
;	$C0 ? $FF Set contrast 
