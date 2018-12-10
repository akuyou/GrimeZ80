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
	ld b,&C0	;Our table is relative to 0 - so we need to add our screen base
	add hl,bc	;This is so it can be used for alt screen buffers
	ld (ScreenLinePos_Plus2-2),hl
	ret

	ifndef ScrWid256


	GetNextLine:
	push af
		ld hl,&0000;<--SM ****
ScreenLinePos_Plus2:	;Remeber last screen line, so the next one will appear directly below
		ld a,&50
		add l
		ld l,a
		jr nc,GetNextLineDone
		inc h				;if L has overflowed we need to update H
	GetNextLineDone:
	pop af
	ld (ScreenLinePos_Plus2-2),hl		;Back up last screen line
	ret


	align 2			;Align the data to a 2 byte boundary - this allow us to use INC L rather than INC HL
			;as we know that the second part will not be at an address like &8100 that would cross a boundary

	; This is the screen addresses of all the lines of the screen - Just copy paste these!
	; Note you will have to add the base address of your screen (usually &C000)
	; This table is used in Chibi Akumas, where the screen can be at &C000, or &8000 depending on which buffer is shown.

scr_addr_table:


	defw &0000,	&0050,	&00A0,	&00F0,	&0140,	&0190,	&01E0,	&0230
	defw &0280,	&02D0,	&0320,	&0370,	&03C0,	&0410,	&0460,	&04B0
	defw &0500,	&0550,	&05A0,	&05F0,	&0640,	&0690,	&06E0,	&0730
	defw &0780,	&07D0,	&0820,	&0870,	&08C0,	&0910,	&0960,	&09B0
	defw &0A00,	&0A50,	&0AA0,	&0AF0,	&0B40,	&0B90,	&0BE0,	&0C30
	defw &0C80,	&0CD0,	&0D20,	&0D70,	&0DC0,	&0E10,	&0E60,	&0EB0
	defw &0F00,	&0F50,	&0FA0,	&0FF0,	&1040,	&1090,	&10E0,	&1130
	defw &1180,	&11D0,	&1220,	&1270,	&12C0,	&1310,	&1360,	&13B0
	defw &1400,	&1450,	&14A0,	&14F0,	&1540,	&1590,	&15E0,	&1630
	defw &1680,	&16D0,	&1720,	&1770,	&17C0,	&1810,	&1860,	&18B0
	defw &1900,	&1950,	&19A0,	&19F0,	&1A40,	&1A90,	&1AE0,	&1B30
	defw &1B80,	&1BD0,	&1C20,	&1C70,	&1CC0,	&1D10,	&1D60,	&1DB0
	defw &1E00,	&1E50,	&1EA0,	&1EF0,	&1F40,	&1F90,	&1FE0,	&2030
	defw &2080,	&20D0,	&2120,	&2170,	&21C0,	&2210,	&2260,	&22B0
	defw &2300,	&2350,	&23A0,	&23F0,	&2440,	&2490,	&24E0,	&2530
	defw &2580,	&25D0,	&2620,	&2670,	&26C0,	&2710,	&2760,	&27B0
	defw &2800,	&2850,	&28A0,	&28F0,	&2940,	&2990,	&29E0,	&2A30
	defw &2A80,	&2AD0,	&2B20,	&2B70,	&2BC0,	&2C10,	&2C60,	&2CB0
	defw &2D00,	&2D50,	&2DA0,	&2DF0,	&2E40,	&2E90,	&2EE0,	&2F30
	defw &2F80,	&2FD0,	&3020,	&3070,	&30C0,	&3110,	&3160,	&31B0
	defw &3200,	&3250,	&32A0,	&32F0,	&3340,	&3390,	&33E0,	&3430
	defw &3480,	&34D0,	&3520,	&3570,	&35C0,	&3610,	&3660,	&36B0
	defw &3700,	&3750,	&37A0,	&37F0,	&3840,	&3890,	&38E0,	&3930
	defw &3980,	&39D0,	&3A20,	&3A70,	&3AC0,	&3B10,	&3B60,	&3BB0
	defw &3C00,	&3C50,	&3CA0,	&3CF0,	&3D40,	&3D90,	&3DE0,	&3E30


	else

GetNextLine:
	push af
		ld hl,&0000;<--SM 
ScreenLinePos_Plus2:
		ld a,&40
		add l
		ld l,a
		jr nc,GetNextLineDone
		inc h				;If L has overflowed we need to also update H
GetNextLineDone:
	pop af
	ld (ScreenLinePos_Plus2-2),hl
	ret
	align 2
scr_addr_table:
	defw &0000,	&0040,	&0080,	&00C0,	&0100,	&0140,	&0180,	&01C0
	defw &0200,	&0240,	&0280,	&02C0,	&0300,	&0340,	&0380,	&03C0
	defw &0400,	&0440,	&0480,	&04C0,	&0500,	&0540,	&0580,	&05C0
	defw &0600,	&0640,	&0680,	&06C0,	&0700,	&0740,	&0780,	&07C0
	defw &0800,	&0840,	&0880,	&08C0,	&0900,	&0940,	&0980,	&09C0
	defw &0A00,	&0A40,	&0A80,	&0AC0,	&0B00,	&0B40,	&0B80,	&0BC0
	defw &0C00,	&0C40,	&0C80,	&0CC0,	&0D00,	&0D40,	&0D80,	&0DC0
	defw &0E00,	&0E40,	&0E80,	&0EC0,	&0F00,	&0F40,	&0F80,	&0FC0
	defw &1000,	&1040,	&1080,	&10C0,	&1100,	&1140,	&1180,	&11C0
	defw &1200,	&1240,	&1280,	&12C0,	&1300,	&1340,	&1380,	&13C0
	defw &1400,	&1440,	&1480,	&14C0,	&1500,	&1540,	&1580,	&15C0
	defw &1600,	&1640,	&1680,	&16C0,	&1700,	&1740,	&1780,	&17C0
	defw &1800,	&1840,	&1880,	&18C0,	&1900,	&1940,	&1980,	&19C0
	defw &1A00,	&1A40,	&1A80,	&1AC0,	&1B00,	&1B40,	&1B80,	&1BC0
	defw &1C00,	&1C40,	&1C80,	&1CC0,	&1D00,	&1D40,	&1D80,	&1DC0
	defw &1E00,	&1E40,	&1E80,	&1EC0,	&1F00,	&1F40,	&1F80,	&1FC0
	defw &2000,	&2040,	&2080,	&20C0,	&2100,	&2140,	&2180,	&21C0
	defw &2200,	&2240,	&2280,	&22C0,	&2300,	&2340,	&2380,	&23C0
	defw &2400,	&2440,	&2480,	&24C0,	&2500,	&2540,	&2580,	&25C0
	defw &2600,	&2640,	&2680,	&26C0,	&2700,	&2740,	&2780,	&27C0
	defw &2800,	&2840,	&2880,	&28C0,	&2900,	&2940,	&2980,	&29C0
	defw &2A00,	&2A40,	&2A80,	&2AC0,	&2B00,	&2B40,	&2B80,	&2BC0
	defw &2C00,	&2C40,	&2C80,	&2CC0,	&2D00,	&2D40,	&2D80,	&2DC0
	defw &2E00,	&2E40,	&2E80,	&2EC0,	&2F00,	&2F40,	&2F80,	&2FC0
	defw &3000,	&3040,	&3080,	&30C0,	&3100,	&3140,	&3180,	&31C0
	endif

ScreenINIT:

	di
                LD A,12		;disable
                OUT (191),A	;memory wait states
		
		;setting the Border color to black

                LD BC,&100+27	;B=1 write
				;C=27 number of system variable (BORDER)	
                LD D,0		;new value
                rst 6*8
		db 16		;handling EXOS variable

                CALL VID	;get a free Video segment
                JP NZ,VideoFail	;if not available then exit
                LD A,C		;store
                LD (VIDS),A	;segment number
		OUT (&B3),A	;paging to the page 3.

		
                LD DE,0		;segment number low
                RRA		;two bits
                RR D		;will be the
                RRA		;top two bits
                RR D		;of the video address
                LD (VIDADR1),DE ;this is the start of
				;pixel data in the video memory


		LD HL,&3F00	;after the pixel bytes
		ADD HL,DE	;starting the
		LD (LPTADR),HL	;Line Parameter Table (LPT)
		

                LD HL,LPT	;Line Parameter Table
                LD DE,&FF00	;copy to
                LD BC,LPTH	;the end of video
                LDIR		;segment
VidAgain:		
                LD HL,(LPTADR)	;LPT video address
                LD B,4		;4 bit rotate
LPTA:           SRL H
                RR L
                DJNZ LPTA
                LD A,L		;low byte
                OUT (&82),A	;send to Nick
                LD A,H		;high 4 bits
                OR &C0		;enable Nick running
				;switch to the new LPT
				;at the end of current frame
                OUT (&83),A	;send to Nick
	
VideoFail:
	ret



VID:            LD HL,FileEnd	;puffer area
                LD (HL),0	;start of the list
GETS:           rst 6*8
		db 24		;get a free segment
                RET NZ		;if error then return
                LD A,C		;segment number
                CP &FC		;<0FCh?, no video segment?
                JR NC,ENDGET	;exit cycle if video
                INC HL		;next puffer address
                LD (HL),C	;store segment number
                JR GETS		;get next segment
ENDGET          PUSH BC		;store segment number
FREES           LD C,(HL)	;deallocate onwanted

                rst 6 *8
		db 25		;non video segments

                DEC HL		;previoud puffer address
                JR Z,FREES	;continue deallocating
				;when call the EXOS 25 function with
				;c=0 which is stored at the start of
				;list, then got a error, flag is NZ
                POP BC		;get back the video segment number
                XOR A		;Z = no error

                RET		;return




	;variables for storing allocated memory

VIDS            DB 0
P1S             DB 0
P2S             DB 0
LPTADR          DW 0





	;NICK Line Parameter Table (LPT)

LPT:        DB 256-200;3833-200 ;200 lines.... Two's complement of the number of scanlines in this mode line. Zero means 256 scanlines. 
;           DB &32  ;0 01 1 001 0
		    ;I CC R MMM L
                    ;I   VINT=0, no IRQ
                    ;CC  Colour Mode=01, 4 colours mode (2/4/16/256)
                    ;R   VRES=1, full vertical resolution (full/half)
                    ;MMM Video Mode=001, pixel graphics mode
                    ;L   Reload=0, LPT will continue
	ifdef ScrColor16
		   ;ICCRMMML
		db %01010010
	else
		   ;ICCRMMML
		db %00110010
	endif

	ifndef ScrWid256
            DB 11   ;left margin=11
            DB 51   ;right margin=51
	else
            DB 11+4   ;left margin=15
            DB 51-4   ;right margin=47

	endif


VIDADR1:    DW 0    ;primary video address, address of pixel data
            DW 0    ;secondary vide0 address, not used in pixel graphics mode
ENT_PALETTE:    DB 0,36,219,73,0,0,0,0 ;black, blue, yellow, red (not used colour are black)  g0 | r0 | b0 | g1 | r1 | b1 | g2 | r2 | - x0 = lsb 

            DB -50,&12,63,0,0,0,0,0,0,0,0,0,0,0,0,0
               ;50 lines of border, this is the bottom margin,
            DB -3,16,63,0,0,0,0,0,0,0,0,0,0,0,0,0
               ;3 black lines, syncronization off
            DB -4,16,6,63,0,0,0,0,0,0,0,0,0,0,0,0
               ;4 lines, syncronization on
            DB -1,&90,63,32,0,0,0,0,0,0,0,0,0,0,0,0
               ;1 line, syncronization will switch off at half of line
               ;the NICK chip generate video IRQ at this line
            DB 252,&12,6,63,0,0,0,0,0,0,0,0,0,0,0,0
               ;4 black lines
            DB -50,&13,63,0,0,0,0,0,0,0,0,0,0,0,0,0
               ;50 lines of border, this is the top margin,


LPTEnd:              
LPTH equ LPTEnd-LPT ;length of LPT

