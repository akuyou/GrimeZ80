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

ReadAgain:
	call GetCurrentRoomDescription


	call printstring	;Show the room description
	call NewLine


	ld hl,txtYouCanSee	;Show "You Can See" message
	call printstring


	call GetCurrentRoomItems
	call ShowItemList
	call NewLine


	ld hl,InputPrompt		;show Chibi> message
	call printstring

	ld hl,TestString	;Read up to 20 chars into Teststring
	ld b,20
	call WaitString

	inc hl			;Create a dummy 2nd command, in case the user didn't actually enter one
	ld (hl),0
	inc hl			;Put a second Char255 at the end of the string for saftey
	ld (hl),255

	ld hl,TestString	;Convert to Uppercase
	call ToUpper

	ld d," "		;Swap Spaces to Char 255, so we can look at words separately
	ld e,255
	ld hl,TestString
	call ReplaceChar

	call NewLine	;Newline command

	ld hl,WordList		;Array of strings
	ld de,TestString	;String to test
	call ScanList
	ld b,a
	push bc
		ld bc,255		;Bytecount 255
		ld a,c			;Search for 255 too!
		ld hl,TestString
		cpir			;Find the next string (after the space, which has been converted to a 255)
	
		dec hl
SkipSpaces:			;the user may have entered multiple spaces 
		inc hl
		ld a,(hl)		;skip spare 'middle spaces'
	
		inc a			;spaces have been converted to 255
		jp z,SkipSpaces	
	
		ex hl,de		;HL is the wordlist, DE is the word to check
		ld hl,WordList
		call ScanList
	pop bc
	ld c,a

	ld a,b

	cp 255				;Command wasn't recognized
	jp z,badcommand

	cp cmdInventory			;Show users held items
	jp z,ShowInventory

	cp cmdTake			;Take an item from 
	jp z,TakeItem

	cp cmdSell			;Sell an item from inventory
	jp z,Sell

	call DoCurrentRoomCommands	;Process room specific events

RestartRead:
	call NewLine	;Newline command
	call NewLine	
jp ReadAgain

	CALL SHUTDOWN ; return to basic or whatever
ret


badcommand:
	ld hl,txtICantDoThat	;Didn't recognize the command
	call printstring
	jp RestartRead


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;	Generic Item Actions

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Sell:
	ld hl,InventoryItems
	call FindItem
	jp c,badcommand

	call RemoveItem
jp RestartRead


TakeItem:
	ld a,c
	inc a			;Check the item was recognised (command 2 <>255)
	jp z,badcommand

	call GetCurrentRoomItems	;Get the room itemlist, we need it in HL, not DE
	ex hl,de

	call FindItem			;Get the position of the item in the room list
	jr nc,TakeItemTaken
TakeItemNone:
	ld hl,txtThereIsNo		;Couldn' find it.... print "There is no"
	call printstring

	ld a,c				;Print the item name
	call GetItemNumber
	call printstring

	jp RestartRead

TakeItemTaken:	;C=item to add
	call RemoveItem			;Remove the item from the room

	ld hl,InventoryItems		;Add the item to the inventory
	call AddItem
jp RestartRead

ShowInventory:
	ld hl,txtYouAreCarrying		;Show "You are carrying"
	call PrintString

	ld de,InventoryItems		;Show List of items"
	call ShowItemList
jp RestartRead

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RemoveItem:					;Remove item pointed to by HL (shifts rest of list along to fill space)
	ld d,h
	ld e,l
	inc hl
RemoveItem_UpdateNext
	ld a,(hl)
	ld (de),a

	inc hl
	inc de
	inc a;cp 255
	jr nz,RemoveItem_UpdateNext
ret

AddItem:				;Add item C to the end of the list HL
	ld a,(hl)
	inc a
	jr z,AddItem_FoundEmpty
	inc hl
	jr AddItem

AddItem_FoundEmpty:
	ld (hl),c
ret

FindItem:		;See if list HL contains item C
	ld a,(hl)
	cp 255
	scf		
	ret z		;return Carry if not found
	cp c
	ret z		;Return NC if found
	inc hl
	jp FindItem

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ScanList:				;Scan a wordlist for matches
					;HL=ListAddress... returns B=match
	ld (ScanListString_Plus2-2),de
	ld b,0
ListAgain:
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl

	ld a,e 				;AND A and B, and see if the result is 255
	and d
	inc a				;if both were 255 return
	jr z,ListDoneNotFound
	push hl
		ld hl,TestString	:ScanListString_Plus2
		call CompareString
	pop hl
	jr nc,ListDoneFound
	inc b
	jp ListAgain

ListDoneNotFound:
	ld b,255			;Return 255 if not found
ListDoneFound:
	ld a,b
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ShowItemList:				;Show a list of items, comma separated
	ld a,(de)		
	cp 255
	jr z,ShowItemListNothing	;No items in the lost
ShowItemListAgain:

	inc de
	call GetItemNumber		;Get the item name, and print it
	call printstring

	ld a,(de)			;We're done, so don't show any more
	inc a;cp 255
	ret z

	ld a,','			;More items, so show a comma
	call PrintChar

	ld a,(de)
	jp ShowItemListAgain
ShowItemListNothing:
	ld hl,txtNothing		;NOTHING... aboslutely NOTHING!
	jp printstring

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetItemNumber:
	ld hl,WordList		;Load the address of the string description of item A into HL
	push de
		ld d,0
		ld e,a
		add hl,de	;2 bytes per address, so we add twice
		add hl,de
		ld a,(hl)	;load in the address of the string to HL
		inc hl	
		ld h,(hl)
		ld l,a
	pop de
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Room numbers

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetCurrentRoomDescription:	;Load the address of room A's description into HL
	call GetCurrentRoom
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
ret

DoCurrentRoomCommands:
		call GetCurrentRoom
		inc hl
		inc hl		;Skip over Description (2 bytes)
		inc hl
		inc hl		;Skip over items (2 bytes)

		ld a,(hl)	;Read address of  room command-check code
		inc hl
		ld h,(hl)
		ld l,a

		ld a,b		;Load the first command into A for quick comparing
		jp (hl)

GetCurrentRoomItems:
	push hl
		call GetCurrentRoom
		inc hl
		inc hl		;Skip over room description
		ld e,(hl)
		inc hl
		ld d,(hl)
	pop hl
ret

SetCurrentRoom:			;Set the current room to E
	ld a,e			;We use E, so A can be used for compares
	ld (CurrentRoom_Plus1-1),a
ret

GetCurrentRoom:
	ld a,0	:CurrentRoom_Plus1
GetRoomMumber:
	push de
		ld h,0
		ld l,a

		add hl,hl			;Double HL, because we use 2 bytes per entry in the room def
		ex hl,de

		ld hl,RoomDefinitions

		add hl,de			;2	Each room has 6 bytes of definitions 
		add hl,de			;4
		add hl,de			;6


	pop de
ret

TestString: defs 255

CmpString0: db "NORTH",255		;Strings to match
CmpString1: db "SOUTH",255
CmpString2: db "LOOK",255
CmpString3: db "TAKE",255
CmpString4: db "LICK",255
CmpString5: db "SELLONEBAY",255
CmpString6: db "PIE",255
CmpString7: db "SPOON",255
CmpString8: db "C64",255
CmpString9: db "INVENTORY",255

WordList:				;Pointers to strings in the wordlist
defw CmpString0
defw CmpString1
defw CmpString2
defw CmpString3
defw CmpString4
defw CmpString5
defw CmpString6defw CmpString7
defw CmpString8
defw CmpString9
defw &FFFF				;DW &FFFF = end of list



cmdNorth equ 0				;Number of each string in the list
cmdSouth equ 1
cmdLook equ 2
cmdTake equ 3
cmdLick equ 4
cmdSell equ 5
cmdPie equ 6
cmdSpoon equ 7 
cmdC64 equ 8
cmdInventory equ 9

ifdef BuildTI8
	InputPrompt: 	db 'C>',255
else
	InputPrompt: 	db 'Chibi:>',255
endif
txtYouCanSee: 		db 'You Can See:',255
txtYouAreCarrying: 	db 'You Are Carrying:',255
txtThereIsNo:		db 'There is no ',255
txtNothing:		db 'Nothing',255

txtICantDoThat: db "I can't do that",255

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RoomDefinitions:
defw Description0		;Description of the room
defw ItemList0			;Pointer to items in the room
defw LocalCommands0		;Address of code to handle room specific actions

defw Description1
defw ItemList1
defw LocalCommands1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		Room Actions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



Description0:
db 'You are in a room, junk is piled on the floor',255

ItemList0:
db 6,8,255	;PIE, C64

LocalCommands0:
	ld e,1		;If next condition is true, move to room 1
	cp cmdNorth	;Check if user entered NORTH
	jp z,SetCurrentRoom	;Set the current room to 1
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Description1:
db 'You are in a hallway',255
ItemList1:
db 7,255		;SPOON

LocalCommands1:
	ld e,0
	cp cmdSouth
	jp z,SetCurrentRoom
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

InventoryItems:
defs 16,255		;Inventory has space for 16 items, WARNING... there is no 'intentory full check'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;read "..\SrcAll\Multiplatform_Monitor.asm"
read "..\SrcAll\Multiplatform_MonitorSimple.asm"
read "..\SrcAll\Multiplatform_ShowHex.asm"


read "..\SrcAll\MultiPlatform_Stringreader.asm"		;*** Uppercase function
read "..\SrcAll\Multiplatform_StringFunctionsB.asm"	;*** Replace Char, and String compare

read "..\SrcAll\Multiplatform_StringFunctions.asm"	;*** convert Lower>upper and decode hex ascii

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

read "..\SrcALL\V1_Functions.asm"
read "..\SrcALL\V1_Footer.asm"
