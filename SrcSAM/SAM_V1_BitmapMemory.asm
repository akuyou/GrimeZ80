;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;				Screen Co-ordinate functions

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


GetScreenPos:	;return memory pos in HL of screen co-ord B,C (X,Y)
	
	push bc
		ld b,0			;Load B with 0 because we only want C
		ld hl,scr_addr_table
		add hl,bc	;We add twice, because each address has 2 bytes
		add hl,bc

		ld a,(hl)	
		inc l		;INC L not INC HL because we're byte aligned to 2
		ld h,(hl)
		ld l,a
	pop bc
	ld c,b		;Load the Xpos into C
	ld b,&00	;Our table is relative to 0 - so we need to add our screen base
	add hl,bc	;This is so it can be used for alt screen buffers
	ld (ScreenLinePos_Plus2-2),hl
	ret

	GetNextLine:
	push af
		ld hl,&0000
ScreenLinePos_Plus2:
		ld a,&80
		add l
		ld l,a
		jr nc,GetNextLineDone
		inc h
	GetNextLineDone:
	pop af
	ld (ScreenLinePos_Plus2-2),hl
	ret

	align 2			;Align the data to a 2 byte boundary - this allow us to use INC L rather than INC HL
			;as we know that the second part will not be at an address like &8100 that would cross a boundary

	; This is the screen addresses of all the lines of the screen - Just copy paste these!
	; Note you will have to add the base address of your screen (usually &C000)
	; This table is used in Chibi Akumas, where the screen can be at &C000, or &8000 depending on which buffer is shown.

scr_addr_table:
	defw &0000,	&0080,	&0100,	&0180,	&0200,	&0280,	&0300,	&0380
	defw &0400,	&0480,	&0500,	&0580,	&0600,	&0680,	&0700,	&0780
	defw &0800,	&0880,	&0900,	&0980,	&0A00,	&0A80,	&0B00,	&0B80
	defw &0C00,	&0C80,	&0D00,	&0D80,	&0E00,	&0E80,	&0F00,	&0F80
	defw &1000,	&1080,	&1100,	&1180,	&1200,	&1280,	&1300,	&1380
	defw &1400,	&1480,	&1500,	&1580,	&1600,	&1680,	&1700,	&1780
	defw &1800,	&1880,	&1900,	&1980,	&1A00,	&1A80,	&1B00,	&1B80
	defw &1C00,	&1C80,	&1D00,	&1D80,	&1E00,	&1E80,	&1F00,	&1F80
	defw &2000,	&2080,	&2100,	&2180,	&2200,	&2280,	&2300,	&2380
	defw &2400,	&2480,	&2500,	&2580,	&2600,	&2680,	&2700,	&2780
	defw &2800,	&2880,	&2900,	&2980,	&2A00,	&2A80,	&2B00,	&2B80
	defw &2C00,	&2C80,	&2D00,	&2D80,	&2E00,	&2E80,	&2F00,	&2F80
	defw &3000,	&3080,	&3100,	&3180,	&3200,	&3280,	&3300,	&3380
	defw &3400,	&3480,	&3500,	&3580,	&3600,	&3680,	&3700,	&3780
	defw &3800,	&3880,	&3900,	&3980,	&3A00,	&3A80,	&3B00,	&3B80
	defw &3C00,	&3C80,	&3D00,	&3D80,	&3E00,	&3E80,	&3F00,	&3F80
	defw &4000,	&4080,	&4100,	&4180,	&4200,	&4280,	&4300,	&4380
	defw &4400,	&4480,	&4500,	&4580,	&4600,	&4680,	&4700,	&4780
	defw &4800,	&4880,	&4900,	&4980,	&4A00,	&4A80,	&4B00,	&4B80
	defw &4C00,	&4C80,	&4D00,	&4D80,	&4E00,	&4E80,	&4F00,	&4F80
	defw &5000,	&5080,	&5100,	&5180,	&5200,	&5280,	&5300,	&5380
	defw &5400,	&5480,	&5500,	&5580,	&5600,	&5680,	&5700,	&5780
	defw &5800,	&5880,	&5900,	&5980,	&5A00,	&5A80,	&5B00,	&5B80
	defw &5C00,	&5C80,	&5D00,	&5D80,	&5E00,	&5E80,	&5F00,	&5F80


ScreenINIT:
	pop hl		;We're going to change the stack pointer, so get the return address now

	di		;The Sam Screen is 24k, and we need to move it in at &0000-&7FFF, but this means 
			;we must keep interrupts disabled the whole time

	ld a,%01100010	;	Bit 0 R/W  BCD 1 of video page control.
			;	Bit 1 R/W  RCD 2 of video page control.
			;	Bit 2 R/W  BCD 4 of video page control.
			;	Bit 3 R/W  BCD 8 of video page control.
			;	Bit 4 R/W  BCD 16  of video bank control, used to switch between the banks of 256 kilobytes.
			;	Bit 5 R/W  MDEO first bit of screen mode control.
			;	Bit 6 R/W  MDE1 second bit of screen mode control.
			;	Bit 7 -/W  TXMIDI  output bit to directly drive the MIDI OUT channel.
			;	Bit 7 R/-  RXMIDI  input bit from MIDI IN channel.

	ld bc,252 	;VMPR - Video Memory Page Register (252 dec)
	out (c),a
	
	ld bc,254 ;	BORDER port (254 dec)
	xor a	  ;Set border to color 0
	out (c),a ;This output port mainly controls the border colour of the screen by supplying a 4-bit address to the Colour Look Up Table (CLUT), to enable a colour to be displayed during border time.
			;Bit 0 BCD 1 of CLUT address for border colour.
			;Bit 1 BCD 2 of CLUT address for border colour.
			;Bit 2 BCD 4 of CLUT address for border colour.
			;Bit 3 MIC  output control bit, normally set high.
			;Bit 4 BEEP output control bit, normally set low.
			;Bit 5 BCD 8 of CLUT address for border colour.
			;Bit 6 THROM bit set high to allow through MIDI operation
			;Bit 7 SOFF bit set high to disable screen display, only
			;active in screen modes 3 and 4, also re
			;moves memory contention during off period
	
	ld bc,250 ;LMPR - Low Memory Page Register (250 dec) 
	ld a,%00100010	;	Bit 0 R/W  BCD 1 of low memory page control.
			;	Bit 1 R/W  BCD 2 of low memory page control.
			;	Bit 2 R/W  BCD 4 of low memory page control.
			;	Bit 3 R/W  BCD 8 of low memory page control.
			;	Bit 4 R/W  BCD 16  of low memory bank control.
			;	Bit 5 R/W  RAM0 when bit set high, RAM replaces the first half of the ROM (ie ROM0) in section A of the CPU address map.
			;	Bit 6 R/W  ROM1 when bit set high, the second half of the ROM (ie ROM1) replaces the RAM in section D of the CPU address map
			;	Bit 7 R/W  WPRAM Write Protection of the RAM in section A of the CPU address map is enabled when this bit is set high.
	out (c),a
	ld sp,&8000
	push hl
	ret

