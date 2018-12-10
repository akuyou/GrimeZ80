	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;; WARNING: MAP THE STACK SOMEWHERE BELOW C000 !

DiskDriver_LoadDirect:
		push hl
			ld hl,null
			ld (DiscDestRelocateCall_Plus2-2),hl
		pop hl
	jp DiskDriver_Load

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; TRD Betadisk Driver  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef BuildZXS_TRD



DiskDriver_Save:
		;HL = Filename pointer
		;DE = Data address to save
		;BC = Bytecount

	ld (DiskSafeSP_Plus2-2),sp		;Save Stackpointer to our error routine (so we can undo the mess!)
	push bc
		push de

		;	ld hl,FileDescriptor
			ld c,#13		;copy the file descriptor to TR-DOS system variables (13)
			call #3D13
			ld a,9			;find a file with matching 9 first bytes in the descriptor, i.e. just the filename and type
			ld (#5D06),a
			ld c,#0A		;A=Find file
			call #3D13
			inc c			;C will contain #FF if the file with this name wasn't found
			ld c,#12		;if it was found, mark the file descriptor as deleted (12=delete)
			call nz,#3D13
		pop hl
	pop de
		ld c,#0B			;Save CODE file to disk
		call #3D13
		ret


DiskDriver_Setup:
			push hl

				ld a,&C3		;JP
				ld (&5CC2),a	;This is the address the Disksystem calls when something goes wrong!
				ld hl,DiskError	;DiskErrorDriver address
				ld (&5CC3),hl

				ld iy,&5C3A	;Do this - or suffer the concequences! - should always be set when firmware interrupts may run!
				
				di
				LD C,0		;DOS_RESET
				CALL &3D13 	;Call to DiskSystem

				LD A,0		;Disk drive initialisation
				LD C,1  	;Init
				CALL &3D13 	;

				LD C,&18 	;read system track
				CALL &3D13 	;Call to DiskSystem

			pop hl
	ret



DiskError:
		ex (sp),hl		;will eventually return if entered upon NO DISC or ABORT, with the error code in C
		push af
		ld a,h
		cp #0D			;the RIA situation is indicated by #0D6B on the stack (both 5.03 and 5.01)
		jr z,DiskError_Abort
		pop af			;otherwise, we continue
		ex (sp),hl		;LIST, CAT, FORMAT and the like display additional messages, not handled here
		ret
DiskError_Abort:
		ld sp,&0000 ;<-- SM ***
DiskSafeSP_Plus2:	;Restore the proper stackpointer
		jp DiskDriverLoad_ErrorB


DiskDriver_Load_FromHL:					;Load from filename pointed to by HL
		ld (DiskLoadBank_Plus1-1),a
		push hl
			ld hl,null
			ld (DiscDestRelocateCall_Plus2-2),hl	;Relocation is used for specifying an "End address" - file is written to position-length
		pop hl

DiskDriver_Load:						;Advanced load, uses relocation and other funky trick! (for compressed files and numeric names)
		;HL=Filename
		;DE=Destination address

		ld (DiskSafeSP_Plus2-2),sp		;Backup Stackpointer, so if an error occurs we can undo the mess

	ifdef BuildZXS_SPUNSAFE
		ld (SPRestore_Plus2-2),sp		;SP must be below &C000 - by default it is not!
		ld sp,StackPointerAlt
	endif
		push de
				call DiskDriver_Setup

	;			LD HL,filename ; to create a descriptor  
				LD C,&13  
				CALL &3D13  
		
				LD C,&0A; find file  
				CALL &3D13  

				LD A,C  
				INC C  
				JR Z,  DiskDriverLoad_Error  

				LD C,&08  ;Read file descriptor to DOS  variable  area
				CALL &3D13  
	  
				XOR A  
				LD (&5CF9),A  
				LD (&5D10),A  
		pop hl
		push bc

			ld bc,(23784) ;Length
			call null ;<-- SM ***
DiscDestRelocateCall_Plus2:

			ld a,0	;<-- SM ***
DiskLoadBank_Plus1:	;dummy
			call Bankswapper_Set		;We'll cover this later

		pop bc
				LD A,3	 ; A=#03 - take address in HL length in DE;
				LD C,&0E ; read from disk into memory area for an address  
				CALL &3D13  

				call Bankswapper_Reset

				scf		; carry true if sucess 
DiskDriverLoad_Done:
	ifdef BuildZXS_SPUNSAFE
				ld sp,&0000 :SPRestore_Plus2
	endif
				ret

				
DiskDriverLoad_Error:
			pop hl			; ditch this
DiskDriverLoad_ErrorB:
				LD BC,&0FFE  	;Border color port
				LD A,2  
				OUT (C),A  		;Make border red
				
				or a;ccf 		; carry true if sucess
	jr DiskDriverLoad_Done

	endif

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Tape driver ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef BuildZXS_TAP
	ifdef BuildLangE
Tapefailwanted:	db  "Seeking:"," "+&80	
Tapefailfound:	db  "Found:"," "+&80
	else
Tapefailwanted:	db  "SEEKING:",255
Tapefailfound:	db  "FOUND:",255
	endif
TapeFailMessage:		;Got the wrong file, print the file we got, so user can figure out the mess!
	push bc
	push de
			ld hl,&0A15
			ld bc,Tapefailwanted
			call DrawText_LocateAndPrintStringUnlimited

			ld hl,&1615
			call DrawText_LocateSprite
			ld hl,LoadFileName
			ld b,8
			call TapeShowName

			ld hl,&0A16
			ld bc,Tapefailfound
			call DrawText_LocateAndPrintStringUnlimited

			ld hl,&1616
			call DrawText_LocateSprite

			ld hl,TapeHeader+1 
			ld b,8
			call TapeShowName
	pop de
	pop bc
	ret

TapeShowName:

		push hl
		push bc
			ld a,(hl)
			call DrawText_CharSprite
		pop bc
		pop hl
		inc hl
		djnz TapeShowName
	ret

DiskDriverLoad_LoadhdrFail:
		call TapeFailMessage		;Show the file we actually got

		pop af		;Remove waste from stack
		pop hl
		jr DiskDriverLoad_Loadhdr
	  
TapeEnd:	;NC
		pop de   ;use up de
		or a; carry true if sucess 
		di
	jr DiskDriverLoad_Done



DiskDriver_Load:

	ifdef BuildZXS_SPUNSAFE
		ld (SPRestore_Plus2-2),sp
		ld sp,StackPointerAlt
	endif


	push de
DiskDriverLoad_Loadhdr:
	push hl
		ld ix, TapeHeader	;Destination
		ld de, 17  			;Bytecount
		xor a  
		scf  
		call 1366  ;Jump to tape load firmware
	pop hl
	push hl
	push af
			
			; check header  
			ld b,9  
			ld de,TapeHeader+1  	;HL should be filename at this point

chckname:  
			ld a,(de)  
			  cp (hl)  
			jr nz,DiskDriverLoad_LoadhdrFail	;Filename doesn't match
			inc HL  
			inc DE  
			djnz chckname
	pop af
	pop hl 
		; load block  
	pop ix	;get back de (Tape firmare needs destination in IX)

	push hl
		push bc
			push ix
			pop hl

			ld bc,(TapeHeader+11)
			call null ;<-- SM ***
DiscDestRelocateCall_Plus2:
			push hl
				ld a,0;<-- SM ***
DiskLoadBank_Plus1:	;dummy
				call Bankswapper_Set
			pop ix	;Destination address needs to be in IX
		pop bc
	pop hl
		
		ld de,(TapeHeader+11)  		;File Length 
		ld a,&FF  
		scf  
		call 1366  ;Jump to tape load firmware

		di
		call Bankswapper_Reset
		scf 		; carry true if sucess
DiskDriverLoad_Done:
	ifdef BuildZXS_SPUNSAFE
				ld sp,&0000 ;<-- SM ***
SPRestore_Plus2:
	endif


	;Cant save to tape! - if you need this figure it out yourself!
DiskDriver_Save:	
	ret

TapeHeader:		;Buffer for tape stuff!
	defs 20
	endif 



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; +3 disk driver ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef BuildZXS_DSK
Plus3_RestoreBuffer:
	ret					;For Selfmod
	di				
	push ix				;The Effing +3 uses &1100 bytes of bank 7 for it's cache, but that's the 2nd screenbuffer - and we want it!
	push de
	push hl
	push bc
		;HL=Source Pos
		;DE=Dest Post
		;IXL= Source Bank
		;IXH= Dest Bank
		;BC= ByteCount
			ld ixh,7
			ld ixl,6
			ld de,&DB00		
			ld hl,&C900
			ld bc,&1100
			call Bankswapper_Copy		
	pop bc
	pop hl
	pop de
	pop ix
	ld a,&C9
	ld (Plus3_RestoreBuffer),a	;Copy is done, don't let it run twice by accident!
	ret



DiskDriver_Save:
	;bc=bytecount
	;hl=filename
	;de=address

	ifdef BuildZXS_SPUNSAFE
		ld (SPRestoreB_Plus2-2),sp	;Backup stack pointer in case anything goes wrong!
		ld sp,StackPointerAlt
	endif
	push bc
		push de	
			push hl
				call Plus3_RestoreBuffer
				ld iy,&5C3A	;Do this - or suffer the concequences! - should always be set when firmware interrupts may run!

				ld   a,7
				call Bankswapper_Set		;Switch in bank 7 (Firmware needs this)

				ld DE,&0000	;Stop the Disk driver using our ram!
				ld HL,&0000
				call &013F	; (319) DOS SET 1346

				ld b,1 ;	B = File number 0...15
				ld c,2 ;	C = Access mode required
				ld d,1 ;	D = Create action
				ld e,4 ;	E = Open action

			pop hl
			call &0106    ;DOS_OPEN
			jr   nc,DiskDriverSave_Error

		ld b,1	;B = File number
		pop hl 	;Address to save from
		ld c,&0	;Page for C000h (49152)...FFFFh (65535)
	pop de		;Bytecount
	call &0115 ;DOS_WRITE
	ld b,1
	call &0109 ;DOS CLOSE
	call &019C;h ; (412) DD L OFF MOTOR

	scf	; carry true if sucess
DiskDriverSave_Finish:

		push af
			call Bankswapper_Reset		;Reset bank settings
		pop af
	ifdef BuildZXS_SPUNSAFE
		ld sp,&0000 :SPRestoreB_Plus2	;if we wanted it, we need to restore Stack pointer
	endif
		ret
DiskDriverSave_Error:

		ld b,1
		call &010C ; (268) DOS ABANDON
		pop hl
		pop de
		or a;ccf 		; carry true if sucess
	jr DiskDriverSave_Finish

DiskDriver_Load_FromHL:				;load from HL filename
		ld (DiskLoadBank_Plus1-1),a
		push hl
			ld hl,null
			ld (DiscDestRelocateCall_Plus2-2),hl
		pop hl


DiskDriver_Load:					;Advanced load, uses relocation and other funky trick! (for compressed files and numeric names)
	ifdef BuildZXS_SPUNSAFE
		ld (SPRestore_Plus2-2),sp
		ld sp,StackPointerAlt
	endif
		push de	
			push hl

				call Plus3_RestoreBuffer
				ld iy,&5C3A	;Do this - or suffer the concequences! - should always be set when firmware interrupts may run!
					ld   a,7
					call Bankswapper_Set
				;Stop the Disk driver using our ram!

				ld DE,&0000
				ld HL,&0000
				call &013F; (319) DOS SET 1346

				ld b,1;	B = File number 0...15
				ld c,5;	C = Access mode required
				ld d,0;	D = Create action
				ld e,1;	E = Open action

			pop hl
		



			call &0106    ;DOS_OPEN
			jr   nc,DiskDriverLoad_Error

		ld b,1;B = File number
		call &010F ;DOS REF HEAD
		ld e,(IX+1)
		ld d,(IX+2) ;get file size
		ld b,1;B = File number
	pop hl ;	Destination address
		
		push bc
			push de
			pop bc
			call null ;<-- SM ***
DiscDestRelocateCall_Plus2:
		pop bc

		ld c,&C0;<-- SM ***
DiskLoadBank_Plus1:
		call &0112 ;DOS_READ	(DE=Bytes, HL=Address)
		ld b,1
		call &0109 ;DOS CLOSE
		call &019C;h ; (412) DD L OFF MOTOR

		ld   iy,&5C3A   ;Restore the firmware IY
		scf	; carry true if sucess
	DiskDriverLoad_Finish:
		push af
			call Bankswapper_Reset
		pop af
	ifdef BuildZXS_SPUNSAFE
		ld sp,&0000 :SPRestore_Plus2
	endif


		ret

	DiskDriverLoad_Error:
		ld b,1
		call &010C ; (268) DOS ABANDON
		pop hl 	; get rid of destination
		or a	; carry true if sucess
		jr DiskDriverLoad_Finish

	endif