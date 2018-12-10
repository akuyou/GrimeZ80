


out7ffdBak equ &5b5c
out1FFDBak equ &5B67
;*** Ram/Rom bank switching ***

;port	Backup
;&7FFD	&5B5C	--IRSMMM	MMM= ram bits				S=Screen page bit
;							R Rom Low bit 				I=I/O Disabling

;&1FFD	&5B67	---SDR-P	P = paging mode 0=normal	R=Ram high bit
;							D = Disk Motor				S=Printer strobe
;&1FFD		&7FFD								
;-----0--	---0----	ROM 0 128k editor, menu system and self-test program
;-----0--	---1----	ROM 1 128k syntax checker
;-----1--	---0----	ROM 2 +3DOS
;-----1--	---1----	ROM 3 48 BASIC

BankSwitch_C0_SetCurrentToC0:
BankSwitch_C0_SetCurrent:
Firmware_Kill:				; Game mode - Font in memory
ifdef buildZXS_DSK
	xor a
	ld (Plus3_RestoreBuffer),a
endif

	ld b,&fe
;0xfe	      xxxEMBBB	Ear Mic Border
	ld c,%00010000
	out (c),c

	ld d,%00000100
	ld e,%00010000
jr Firmware_Apply
Firmware_Restore:			; Disk mode

	ld iy,&5C3A	;Do this - or suffer the concequences! - should always be set when firmware interrupts may run!

	ifdef buildZXS_DSK
		ld d,%00000100
		ld e,0
	endif


	ifdef buildZXS_TRD
		ld d,%00000000			; Rom 1
		ld e,%00010000
	endif
	ifdef buildZXS_TAP
		ld d,%00000100			;NEED ROM 3 on PLUS, 1 on 128k, 0 on 48k
		ld e,%00010000
	endif
	im 1
Firmware_Apply:
	ld a,(out1FFDBak)
	and  %11111011
	or d
        ld   bc,&1ffd   ;32765
        out  (c),a
	ld (out1FFDBak),a
        ld   a,(out7ffdBak)  ;BANKM (23388)
        and  %11101111
	or e
        ld   bc,&7ffd   ;32765
        out  (c),a
        ld   (out7ffdBak),a
ret


Rst6Fake:
jp (IY)
DoCustomRsts:
ret



CallDE
	push de
	ret
BankSwitch_C0_CallHL:
CallHL:			
	push hl
	ret



Bankswapper_Copy:
	;HL=Source Pos
	;DE=Dest Post
	;IXL= Source Bank
	;IXH= Dest Bank
	;BC= ByteCount
;Bankswapper_CopyAgain
;	di 
;	halt
	ld (Bankswapper_ReadPos_Plus2-2),hl
	ld hl,8
	push hl
		add hl,de
		ld (Bankswapper_WritePos_Plus2-2),hl
		ld h,b
		ld l,c
		add hl,de
	pop de
	add hl,de
	ld a,h
	ld (Bankswapper_LastH_Plus1-1),a
	ld a,l
	ld (Bankswapper_LastL_Plus1-1),a
	ld (Bankswapper_SPRestore_Plus2-2),sp

        ld   bc,&7ffd   ;32765
	ld d,ixl
	ld e,ixh
	exx
Bankswapper_Again:
	exx
	out (c),d
	exx

	ld sp,&0000:Bankswapper_ReadPos_Plus2
	pop af
	pop bc
	pop de
	pop hl
	ld (Bankswapper_ReadPos_Plus2-2),sp
	ld sp,&0000:Bankswapper_WritePos_Plus2
	exx
	out (c),e
	exx
	push hl
	push de
	push bc
	push af
	ld hl,16
	add hl,sp
	ld (Bankswapper_WritePos_Plus2-2),hl
	ld a,h
	cp 0 :Bankswapper_LastH_Plus1
	jp nz,Bankswapper_Again
	ld a,l
	cp 0 :Bankswapper_LastL_Plus1
	jp nz,Bankswapper_Again

Bankswapper_Done:
	ld sp,&0000 :Bankswapper_SPRestore_Plus2
	jp Bankswapper_Reset



Bankswapper_FastCopy:
	ld a,C
	and %11110000
	ld c,a
	UseLDI:
	ldi	;We've 'unwrapped' LDIR into 16 LDI's - reducing the number of 'R repeates' by 15 out of 16
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ret PO	;LDI/LDIR return Overflow when BC=0
jp UseLDI
endif


	ret



Bankswapper_MemSwap:
	;HL=Source Pos
	;DE=Dest Post
	;IXL= Source Bank
	;IXH= Dest Bank
	;BC= ByteCount
	ld (Bankswapper_swReadPos_Plus2-2),hl
	ex hl,de
	ld (Bankswapper_swWritePos_Plus2-2),hl
	ld h,b
	ld l,c
	add hl,de
	
	dec hl
	dec hl
	dec hl
	dec hl

	ld a,h
	ld (Bankswapper_swLastH_Plus1-1),a
	ld a,l
	ld (Bankswapper_swLastL_Plus1-1),a
	ld (Bankswapper_swSPRestore_Plus2-2),sp

        ld   bc,&7ffd   ;32765
	ld d,ixl
	ld e,ixh
	

Bankswapper_swAgain:

	out (c),d
	exx

	ld sp,&0000:Bankswapper_swReadPos_Plus2
	pop iy
	pop hl
	ld (Bankswapper_swReadPos_Plus2-2),sp
	push de
	push bc

	ld sp,&0000:Bankswapper_swWritePos_Plus2
	exx
	out (c),e
	exx

	pop bc
	pop de
	ld (Bankswapper_swWritePos_Plus2-2),sp
	push hl
	push iy

	exx
	ld hl,&0000
	add hl,sp

	ld a,h
	cp 0 :Bankswapper_swLastH_Plus1
	jp nz,Bankswapper_swAgain
	ld a,l
	cp 0 :Bankswapper_swLastL_Plus1
	jp nz,Bankswapper_swAgain
Bankswappersw_Done:
	ld sp,&0000 :Bankswapper_swSPRestore_Plus2
	ret












;Bankswapper_RestoreFirmware
;        ld   a,(&5b5c)  ;BANKM (23388)
;        set  4,a
;        and  %11111000
;        ld   (&5b5c),a
;        ld   bc,&7ffd   ;32765
;        out  (c),a
;        ret

;Bankswapper_ZXBank_Plus3Disk:
;
;        ld   c,a
;        ld   a,(&5b5c)  ;BANKM (23388)
;
;        and  %11101000
;        or   c
;        ld   (&5b5c),a
;        ld   bc,&7ffd   ;32765
;        out  (c),a
;        ret
;Bankswapper_ZXBankFirmware
;
;        ld   c,a
;        ld   a,(&5b5c)  ;BANKM (23388)
;
;        and  %11101000
;        or   c
;        ld   (&5b5c),a
;        ld   bc,&7ffd   ;32765
;        out  (c),a
;
;
;        ei
;        ret
 
Bankswapper_CallDefined_Set:
	ld (Bankswapper_CallDefinedA_Plus1-1),a
	ld (Bankswapper_CallDefinedHL_Plus2-2),hl
ret
Bankswapper_CallDefined:
	push af
	push bc
		ld a,(Bankswapper_ZXBank_Current_Plus1-1)
		ld (Bankswapper_CallDefined_ArestorePlus1-1),a
		ld a,0:	Bankswapper_CallDefinedA_Plus1
		call Bankswapper_SetCurrent		
	pop bc
	pop af


	call null :Bankswapper_CallDefinedHL_Plus2

	push af
	push bc
		ld a,0 :Bankswapper_CallDefined_ArestorePlus1
		call Bankswapper_SetCurrent
	pop bc
	pop af
ret

Bankswapper_CallHL:
	ldia
	ld a,(Bankswapper_ZXBank_Current_Plus1-1)
	push af
	ldai
		call Bankswapper_SetCurrent		
		call CallHL
	pop af
	jr Bankswapper_SetCurrent

Bankswapper_Init:
        ld   a,(out7ffdBak)  ;BANKM (23388)
        and  %00000111
Bankswapper_SetCurrent:
	ld (Bankswapper_ZXBank_Current_Plus1-1),a
	jp Bankswapper_set
Bankswapper_Reset:
        ld   a,0 :Bankswapper_ZXBank_Current_Plus1  ;BANKM (23388)
Bankswapper_Set:
        ld   c,a
        ld   a,(out7ffdBak)  ;BANKM (23388)
        and  %11111000
        or   c
        ld   bc,&7ffd   ;32765
        out  (c),a
        ld  (out7ffdBak),a  ;BANKM (23388)
        ret