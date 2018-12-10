; Learn Multi platform Z80 Assembly Programming... With Vampires!

;Please see my website at	www.chibiakumas.com/z80/
;for the 'textbook', useful resources and video tutorials

;File		LocateTest
;Version	V1.0
;Date		2018/4/1
;Content	Test the locate command, and key reading 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


nolist

;Uncomment one of the lines below to select your compilation target

BuildCPC equ 1	; Build for Amstrad CPC
;BuildMSX equ 1 ; Build for MSX
;BuildTI8 equ 1 ; Build for TI-83+
;BuildZXS equ 1  ; Build for ZX Spectrum
;BuildENT equ 1 ; Build for Enterprise
;BuildSAM equ 1 ; Build for SamCoupe

read "..\SrcALL\V1_Header.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	Call DOINIT	; Get ready

	call CLS

	ld hl,&0000		;Screen position - 0,0 is top left, H=X,L=Y
	call locate	;Set cursor position

	;Show text cursor positions onscreen at various places - so we can check our GetCursorPos is working

	call GetCursorPos			;Get cursor pos to HL
	push hl					;Show it
	call Monitor_PushedRegister

	call GetCursorPos			;and again
	push hl
	call Monitor_PushedRegister
	
	call GetCursorPos			;and again
	push hl
	call Monitor_PushedRegister

	call NewLine				;new line

	call GetCursorPos			;and again
	push hl
	call Monitor_PushedRegister
	
	call GetCursorPos			;and again
	push hl
	call Monitor_PushedRegister

	call GetCursorPos			;and again
	push hl
	call Monitor_PushedRegister
CharLoop:
	call WaitChar	;Read a key

	;Enter and Backspace are different keys on different systems, so we use definitions to allow for configurability 

	cp KeyChar_Enter 	;Add a blank line if enter was pressed
	jr z,DoNewLine

	cp KeyChar_Backspace	;Clear the screen on backspace
	jr z,DoCLS

	call PrintChar
jr CharLoop

DoNewLine:
	call NewLine	;New Line
	jp CharLoop
DoCLS:
	call cls	;Clear screen
	jp CharLoop



ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;read "..\SrcAll\Multiplatform_Monitor.asm"
read "..\SrcAll\Multiplatform_MonitorSimple.asm"
read "..\SrcAll\Multiplatform_ShowHex.asm"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

read "..\SrcALL\V1_Functions.asm"
read "..\SrcALL\V1_Footer.asm"
