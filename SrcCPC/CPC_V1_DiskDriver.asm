cas_noisy equ &bc6b
cas_in_open equ &bc77
cas_in_direct equ &bc83
cas_in_close equ &bc7a
txt_set_cursor equ &bb75
bios_set_message equ &c033
cas_out_open equ &bc8c
cas_out_direct equ &bc98
cas_out_close equ &bc8f


DiskDriver_Save:
	push bc
	push de

		call &BB57 ; VDU Disable


		ld a,255
		ld (&BE78),a ;bios_set_message

		ld b,12 ;; B = length of the filename in characters
		ld de,&C000 ; Address of Buffer in DE ... Filename in HL 
		call cas_out_open ;; firmware function to open a file for writing

	pop hl  ;Load address in HL
	pop de	;File length isn BC
	ld bc,&0000;; BC = execution address

	ld a,2 ;; A = file type (2 = binary)

	call cas_out_direct	;; write file
	call cas_out_close 	;; firmware function to close a file opened for writing

	ld bc,&FA7E         ; FLOPPY MOTOR OFF
    out (c),c      
	

	call &BB54 ; VDU enable
	ret




DiskDriver_LoadDirect:
	push hl
		ld hl,null
		ld (DiscDestRelocateCall_Plus2-2),hl
	pop hl

DiskDriver_Load:
;LoadDiskFileFromHL	; Load a file from HL memory loc
	push hl	
		push de
			;push hl
		
			push hl
				ld hl,&0A0F		; Move cursor so errors dont wrap I don't hide them
				call txt_set_cursor	; so we can see if a problem happened
	;			ld a,1
	;			call cas_noisy
				ld a,255
				ld (&BE78),a ;bios_set_message
			pop hl
	ifdef buildCPC_Tap
			ld de,&A600	;; address of 2k buffer, Casette loads first 2k to here when reading the file header
	else
			ld de,&C000	;; address of 2k buffer, this can be any value if the files have a header
	endif
			ld b,12		;12 chars

			call cas_in_open	; carry true if sucess
		pop de

		ld h,d
		ld l,e
		jr nc,DiskError

		call null ;<-- SM ***
DiscDestRelocateCall_Plus2:
		ld a,&C0:DiskLoadBank_Plus1
		push bc
			call BankSwitch_C0	; switch to bank A
		pop bc
		ifdef buildCPC_Tap
			push bc
			ld a,b
			cp &8
			jr c,TapNotTooBig
			ld bc,&0800			;Load first &800 bytes into correct location
TapNotTooBig:
			ex hl,de
			ld hl,&A600
			ldir
			ex hl,de		
			pop bc
		endif

		call cas_in_direct	; carry true if sucess

		jr nc,DiskError
	pop hl
	call BankSwitch_C0_Reset ; Restore the previous bank

	call cas_in_close
	scf		;Set Carry flag (no error)
	ret


DiskError:
	or a	;Clear the carry flag (Error)
	pop hl
	ret









