org &8000
	ld hl,&6669

	call AdvancedVectorJump
	db 0
	call AdvancedVectorJump
	db 2
ret

;	call BankSwitch_FarCall
;	db &C7
;	dw &9000
;	ret
;
;	di
;	ld a,&C7
;	call BankSwitch_SetAndGet
;	push af
;		ld a,&C4
;		call BankSwitch_SetAndGet
;		push af
;		pop af
;		call BankSwitch_SetAndGet
;	pop af
;	call BankSwitch_SetAndGet
;	ret
	jp BankSwitch_PopSetAndGet

CallDE
	push de
	ret
CallHL:			
	push hl
	ret

VectorJumpRegBak:
	ld (VectorJump_Arestore_Plus1-1),a
	ld (VectorJump_HLrestore_Plus2-2),hl
	ld (VectorJump_BCrestore_Plus2-2),bc
	ld (VectorJump_DErestore_Plus2-2),de
ret

AdvancedVectorJump:
	call VectorJumpRegBak

	ex (sp),hl
	ld a,(hl)
	inc hl
	ex (sp),hl

		ld hl,AkuVectorList
		push bc
			ld b,0
			ld c,a
			add hl,bc	;add twice for a two byte address
			add hl,bc
		pop bc
		inc hl
		ld a,(hl)
		or a
		dec hl
		jr z,DoAdvancedVectorJump
		ld l,(hl)
		ld h,a
DoVectorJump:
	ld (VectorJump_Plus2-2),hl
	ld bc,&0000:VectorJump_BCrestore_Plus2
	ld de,&0000:VectorJump_DErestore_Plus2
	ld hl,&0000:VectorJump_HLrestore_Plus2
	ld a,0:VectorJump_Arestore_Plus1
	jp &0000 :VectorJump_Plus2

DoAdvancedVectorJump:

	ld a,(hl)
	call BankSwitch_SetAndGet
	push af
		inc hl
		inc hl
		ld a,(hl)
		inc hl
		ld h,(hl)
		ld l,a
;		call DoVectorJump
;	jp BankSwitch_PopSetAndGet
	jp DoVectorJump_PopSetAndGet

AkuVectorList:
	dw VectorTest
	dw &2345
	dw &00C7
	dw VectorTest
VectorTest:
ret

BankSwitch_FarCall:
	call VectorJumpRegBak

	ex (sp),hl
	ld a,(hl)
	inc hl

		ld e,(hl)
		inc hl
		ld d,(hl)
		inc hl
	ex (sp),hl
	call BankSwitch_SetAndGet
	push af
	ex de,hl
;	call DoVectorJump
;	jr BankSwitch_PopSetAndGet




DoVectorJump_PopSetAndGet:
	call DoVectorJump
BankSwitch_PopSetAndGet:
	pop af
BankSwitch_SetAndGet:	;Set New Bank to A,Get old bank in A

	ld bc,(BankSwitch_CurrentB_Plus2-2)
	push bc
	call BankSwitch_SetCurrent
	pop bc
	ld a,c
ret

BankSwitch_DefaultMem:
	ld a,&C0
BankSwitch_SetCurrent:				; This allows us to remember 'current' bank

	LD B,&7F ;Gate array port
	ld (BankSwitch_CurrentB_Plus2-2),a
	OUT (C),A ;Send it
	ret

BankSwitch_BankCopy:
	push bc
		call BankSwitch_Set
	pop bc
	ldir

BankSwitch_Reset:
	ld a,(BankSwitch_CurrentB_Plus2-2)
BankSwitch_Set:

	LD B,&7F ;Gate array port

	OUT (C),A ;Send it
	ret



db &C0,00 :BankSwitch_CurrentB_Plus2