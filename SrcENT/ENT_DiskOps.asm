write "..\BldEnt\program.com"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			Hello World
;
;	Show a hello world message, then read a key
;	From the keyboard and show it.
;
;	Screen and keyboard ops use Enterprise OS calls
;	by opening 'stream' devices to the Keyboard and
;	screen
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




ORG &00F0
	DB 0,5			   ;type 5 - Binary Program
	DW FileEnd-FileStart	   ;File length
	DB 0,0,0,0,0,0,0,0,0,0,0,0 ;Spacer
; org &0100
FileStart:
	LD SP,&100	;set the Stack to a safe place
	di
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		Read a file into memory
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	ld de,ENT_Filename 	;Open stream
	ld a,12
	call ENT_OpenStream	

	ld a,12
	ld bc,100
	ld de,&1000
	call ENT_ReadBlock	;Read 1k to &1000

	ld a,12
	call ENT_CloseStream	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		Delete a file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	ld de,ENT_Filename2 	;Open stream
	ld a,12
	call ENT_OpenStream	

	ld a,12
	call ENT_KillStream	;Delete the file 
;This doesn't seem to work with FILEIO ; - maybe some kind of protection?

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		Create a new file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	ld de,ENT_Filename2 	;Create a new file
	ld a,12
	call ENT_CreateStream	

	ld a,12
	ld bc,3
	ld de,&0
	call ENT_WriteBlock	;Write 3 bytes

	ld a,12
	call ENT_CloseStream	;Close the file


	di
	halt	;stop execution - I've not figured out how to return to basic!




;Device names db [length],'name;'
		;    1234567890123456
ENT_Filename: db 10,'PROGRAM.COM'
ENT_Filename2: db 8,'Test.Bin'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		Functions for controling EXOS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ENT_OpenStream:
			;Open stream A from device string DE 
			;DE should point to a string like...  db 6,'VIDEO;'  or db 9,'KEYBOARD;' (replace ; with a colon)
	rst 6
	db 1 		;open stream
ret

ENT_CloseStream: 	;Close Stream A
	rst 6
	db 3 		;open stream
ret

ENT_CreateStream: 	;Create new File Stream A
			;DE should point to a string like...  db 6,'File;test.com'
	rst 6
	db 2 		;open stream
ret

ENT_KillStream: 	;Delete new File Stream A
	rst 6
	db 4 		;open stream
ret

ENT_ReadBlock:
	rst 6
	db 6
ret
ENT_WriteBlock:
	rst 6
	db 8
ret
WaitChar:
	push de
	push hl
	push bc
		ld a,11
		rst 6
		db 5 	;read from channel - result in b
		ld a,b
	pop bc
	pop hl
	pop de
ret
PrintChar:
	push de
	push hl
	push bc
		ld b,a
		ld a,10
		rst 6
		db 7 	;write to channel a
	pop bc
	pop hl
	pop de
ret

NewLine:
	ld a,13
	call PrintChar
	ld a,10
	call PrintChar
ret
ENT_readvar:		;readvar C from enterprise OS 
	ld b,0
	rst 6
	db 16
ret

ENT_Writevar:		;WriteVar C=D to Enterprise OS
	ld b,1
	rst 6
	db 16
ret

ENT_SpecialFunc:	;Special Function (for displaying screen)
	rst 6
	db 11
ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FileEnd: