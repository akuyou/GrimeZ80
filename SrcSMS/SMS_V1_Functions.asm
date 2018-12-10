; Learn Multi platform Z80 Assembly Programming... With Vampires!

;Please see my website at	www.chibiakumas.com/z80/
;for the 'textbook', useful resources and video tutorials

;File		CPC Firmware Functions
;Version	V1.0b
;Date		2018/3/20
;Content	Provides basic text functions using Firware calls

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PrintChar:

	call PrintCharNoInc
	push af
		ld a,(NextCharX)
		inc a
		ld (NextCharX),a
		cp 32
		call nc,NewLine

	pop af
	ret



PrintCharNoInc:
	push bc
	push hl
	push af
		ld a,(NextCharY)
		ld b,a
		ld a,(NextCharX)
		ld c,a
		ld hl,&3800		

		xor a
		rr b
		rra
		rr b
		rra
;		rr b
;		rra
		rlc c
		or c
		ld c,a
		add hl,bc
		call prepareVram
	
	pop af
	push af
		sub 32
	    	out (vdpData),a
		xor a
		out (vdpData),a

	pop af
		
	pop hl
	pop bc
	ret

ReadJoy:
	in a,(&DC)
	cpl
	ret

WaitChar:
	
	ld a,(SelKeyChar)
	call PrintCharNoInc

	push bc
		call ReadJoy
		ld b,a
		ld a,(SelKeyChar)
		
		bit 4,b
		jr nz,WaitCharDone
		
		bit 1,b
		jr z,WaitCharNotDown
		inc a
WaitCharNotDown:
		bit 0,b
		jr z,WaitCharNotUp
		dec a
WaitCharNotUp:
		ld bc,&3000
		push af
WaitCharDelay:
			dec bc
			ld a,b
			or c
			jr nz,WaitCharDelay
		pop af
		cp 32
		jr nc,WaitCharNotTooLow
		ld a,96+32-1
WaitCharNotTooLow:
		cp 32+96
		jr c,WaitCharNotTooHigh
		ld a,32
WaitCharNotTooHigh:
		ld (SelKeyChar),a
		
		
	pop bc
	jr WaitChar
	
WaitCharDone:
	pop bc
	ret

ScreenINIT:	
CLS:
	push af
	ifdef BuildSMS
		xor a
	else
		ld a,6
	endif
		ld (NextCharX),a
	ifdef BuildSGG
		ld a,3
	endif
		ld (NextCharY),a
	pop af
	ret
Locate:
	push af
		ld a,h
	ifdef BuildSGG
		add 6
	endif
		ld (NextCharX),a
		ld a,l
	ifdef BuildSGG
		add 3
	endif
		ld (NextCharY),a
	pop af
	ret

GetCursorPos:
	push af
		ld a,(NextCharX)
		ld h,a
		ld a,(NextCharY)
		ld l,a
	pop af
	ret

NewLine:
	push af
	ifdef BuildSMS
		xor a
	else
		ld a,6
	endif
		ld (NextCharX),a
		ld a,(NextCharY)
		inc a
		ld (NextCharY),a
	pop af
	ret

PrintString:
	ld a,(hl)	;Print a '255' terminated string 
	cp 255
	ret z
	inc hl
	call PrintChar
	jr PrintString

DOINIT:
    	call setUpVdpRegisters
    	call clearVram
	di
    	call loadColorPalette
    	call loadFontTiles
    	call turnOnScreen
	call loadFontTiles
	call loadColorPalette
	ret


SHUTDOWN:
	di
	halt



loadFontTiles:
    ld hl, &4000		;Any value above &4000 wraps round because there IS only 16k
    call prepareVram
    ld hl,BitmapFont             ; Location of tile data
    ld bc,96*8  ; Counter for number of bytes to write
	jp writeToVramx4


loadColorPalette:

    ld hl, &c000	    ; set VRAM write address to CRAM (palette) address 0 (for palette index 0)
    call prepareVram



    call writeToPalb	;Fill Sprite palette with same data

writeToPalb:
    ld hl,PaletteData ; source of data
    ld bc,16*2 
writeToPal:

;BuildSGG equ 1
	ifdef BuildSGG
			   ;-GRB to  --------BBBBGGGGRRRR
		push bc

			ld a,(hl)	;RB
			ld b,a
			ld c,a
			inc hl

			ld a,(hl)	;-G
			inc hl

			rl b
			rl a
			rl b
			rl a
			rl b
			rl a
			rl b
			rl a

				out (vdpData),a


			ld a,c
			and %00001111
			out (vdpData),a		;-B

		pop bc

		dec bc
		dec bc

		ld a,c
		or b
		jp nz, writeToPal
	endif
	ifdef BuildSMS ;-grb to  --BBGGRR
		ld a,(hl)

		and %11000000		;R
		rlca
		rlca
	;	or d
		ld d,a

		ld a,(hl)
		and %00001100		;B
		rlca
		rlca
		or d
		ld d,a

		inc hl
		dec bc

		ld a,(hl)		;G

		and %00001100
		or d
		out (vdpData),a

			inc hl
			dec bc

			ld a,c
			or b
		jp nz, writeToPal
	endif
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
turnOnScreen:
    ld a,%11000000
    out (vdpControl),a
    ld a,&81
    out (vdpControl),a
    ret


PaletteData:
           ;-GRB
	dw &0008
	dw &0FF0
	dw &0F0F
	dw &00F0
	dw &0F00
	dw &0FF0
	dw &0FF0
	dw &0FF0
	dw &0F00
	dw &0FF0
	dw &0FF0
	dw &0FF0
	dw &0F00
	dw &0FF0
	dw &0FF0
	dw &0FF0
;Sprite palette
;	dw &0008
;	dw &0FF0
;	dw &0F0F
;	dw &00F0
;	dw &0F00
;	dw &0FF0
;	dw &0FF0
;	dw &0FF0
;	dw &0F00
;	dw &0FF0
;	dw &0FF0
;	dw &0FF0
;	dw &0F00
;	dw &0FF0
;	dw &0FF0
;	dw &0FF0
