; Learn Multi platform Z80 Assembly Programming... With Vampires!

;Please see my website at	www.chibiakumas.com/z80/
;for the 'textbook', useful resources and video tutorials

;File		ZX Spectrum Firmware Functions
;Version	V1.0c
;Date		2018/3/25
;Content	Provides basic text functions using Firware calls

;Changelog	Updated Waitchar to use firmware var to stop reading of key 'commands'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


CLS:
	call &0D6B		;Clear screen firmware function
	ld a,255
	ld (&5C8C),a		;Stop Scroll prompt
	ret

Locate:
	push bc
	push de
    	push hl
       		ld a,22	;Character for 'AT' command (Yes it's a character in the Charmap!)
       		rst 16
	pop hl
	push hl
		ld a,l	;Print L (Y) to the screen
       		rst 16
	pop hl
	push hl
       		ld a,h	;Print H (X) to the screen
       		rst 16
      	pop hl
	pop de
	pop bc
	ret	
GetCursorPos:	;Return XY location in same format as Locate
	push af
		ld a,(&5C88)	;X1	5C88h (23688)	S POSN	33-column number for PRINT position.
		neg		;For reasons best known to the Speccy - these are from bottom right up and to the left... so we have to subtract them!
		add 33		
		ld h,a
		ld a,(&5C89)	;X1	5C89h (23689)		24-line number for PRINT position.
		neg
		add 24
		ld l,a
	pop af
	ret

NewLine:
	ld a,13			;Carriage return only - Spectrum doesn't like CHR(10)

PrintChar:
	push hl
	push bc
	push de			
	push af
		ld a,2		;Select Stream 2 = topscreen
		call &1601	;CHAN_OPEN
	pop af
	push af
		rst 16		;call &0010	;PRINT_A_1
	pop af
	pop de
	pop bc			
	pop hl
	ret	

PrintString:
	push bc
		push de
		push hl
			ld a,2		;Select Stream 2 = topscreen
			call &1601	;CHAN_OPEN
		pop hl
PrintStringAgain:
		ld a,(hl)
		cp 255
		jr z,PrintStringDone
		inc hl
		rst 16		;call &0010 ;PRINT_A_1
		jr PrintStringAgain
PrintStringDone:
	pop de
	pop bc
	ret


WaitChar:
;Note - this code has changed since my youtube video, I now read in from a firware var...
;this solves the problem of reading in 'basic commands' from the keyboard
;Unfortunately, interrupts must be enabled for this
	push hl
	push bc			
	push de
	ld a,i			;This command sets PO if interrupts disabled
	push af
	ei

	       	ld hl,&5C08	;LASTK	        - Firmware interrupt handler sets this to last keypress
		ld (hl),0	;Clear it - so we're not reading old junk
WaitCharAgain:
	       	ld a,(hl)          
		or a
		jp z,WaitCharAgain
	pop af				;get back Interrupt state
	call po,DisableInterrupts	;Disable interrupts if thats how things were before we were called
	ld a,(hl)			;Get back the character
	pop de
	pop bc			
	pop hl

	ret	

DisableInterrupts:
	di
	ret


SHUTDOWN:
	ret
DOINIT:

	ret