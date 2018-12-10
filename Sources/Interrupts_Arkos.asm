nolist

;UNREM ONLY ONE OF THESE

BuildCPC equ 1	; Build for Amstrad CPC
;BuildMSX equ 1 ; Build for MSX
;BuildTI8 equ 1 ; Build for TI-83+
;BuildZXS equ 1  ; Build for ZX Spectrum
;BuildENT equ 1 ; Build for Enterprise
;BuildSAM equ 1 ; Build for SamCoupe

;If we need ALL registers in our interrupt handler - not just the shadow ones, enable this





Interrupts_NeedAllRegisters equ 1		;If your interrupt handler needs more than shadow registers enable this
Interrupts_ProtectShadowRegisters equ 1		;If your program needs shadow registers enable this

Interrupts_UseIM2 equ 1				;Use interrupt mode 2 instead of IM1 (need free &200 byte block at &8000)

Interrupts_AllowStackMisuse equ 1		;Use shadow stack to allow interrupts during misusing the stack
Interrupt_ShadowStack equ &8200

read "..\SrcALL\V1_Header.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



	Call DOINIT	; Get ready
	call Music_Restart


ifdef Interrupts_UseIM2

	jp SkipInterruptBlock
	InterruptBlock:
	ifdef Interrupt_ShadowStack
		defs &8200-InterruptBlock
	else
		defs &8190-InterruptBlock
	endif

endif
SkipInterruptBlock:

	call Interrupts_Install
	ei


infinite:
jp infinite






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start of Stack Abuse Test
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	ld c,250
	ld b,255

Repeatr:
	push bc
		;Fill 40 byte pairs

		ld de,&F0F0
		ld (sprestoreFill_Plus2-2),sp
		ld sp,&C000+60
		ei
SPFillAgain:
		push de		;Fill a row using SP for writing
		push de
		push de
		push de
		push de
		push de
		push de
		push de
		push de
		push de
		push de
		push de
		push de
		push de
		push de
		push de
		push de
		push de
		push de
		di			;*** Must stop interrupts with one write left, incase an interrupt occurs after the last write
		push de


		ld a,r
		ld d,a
		ld e,a
		nop
		nop
		nop
		nop
		ld sp,0000:sprestoreFill_Plus2
		ei

;Note... DI I occru

;Note... EI actually occurs after the command AFTER the EI command
;so
;	EI		- Interrupts won't occur
;	pop de		- Interrupts won't occur
;	ld (hl),e	- Interrupts may now occur




		ld b,4
		ld (sprestoreFillB_Plus2-2),sp
		ld hl,&D000+22

		di			;***
		ld sp,&C800+22
		pop de			;*** Preload the first byte into DE
		push de			;***
		ei			;***
		nop
		nop
		nop
PopCopyAgain:
		pop de			;Copy a row of data using SP for reading
		ld (hl),e
		inc hl
		ld (hl),d
		inc hl
		pop de
		ld (hl),e
		inc hl
		ld (hl),d
		inc hl
		pop de
		ld (hl),e
		inc hl
		ld (hl),d
		inc hl
		pop de
		ld (hl),e
		inc hl
		ld (hl),d
		inc hl
		pop de
		ld (hl),e
		inc hl
		ld (hl),d
		inc hl
		djnz PopCopyAgain
		ld sp,0000:sprestoreFillB_Plus2
		ei



	pop bc
	djnz Repeatr
	dec c
	jp nz,Repeatr


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Stack Abuse Test
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		program Finish
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	call Interrupts_Uninstall
	call Music_Stop
	CALL SHUTDOWN ; return to basic or whatever
ret

AlignedBlock:						;Align the file to the position copied into bank 7 (Second screen)
	defs &9000-AlignedBlock
Akuyou_MusicPos:
Akuyou_SfxPos:
incbin "..\resALL\MusicTest9000.bin"
read "..\SrcALL\Multiplatform_ArkosTrackerLite.asm"

read "..\SrcALL\Multiplatform_Interrupts.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		Interrupt driver
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
read "..\SrcALL\Multiplatform_Interrupt_Start.asm"
	call PLY_Play
Interrupts_FastTick:
read "..\SrcALL\Multiplatform_Interrupt_End.asm"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

read "..\SrcALL\V1_Functions.asm"
read "..\SrcALL\V1_Footer.asm"
