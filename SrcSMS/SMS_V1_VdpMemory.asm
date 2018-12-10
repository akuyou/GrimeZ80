
clearVram:
    ; set VRAM write address to 0 by outputting &4000 ORed with &0000
    ld hl, &4000
    call prepareVram
    clearVramLoop:
        ld a,&00    ; Value to write
        out (vdpData),a ; Output to VRAM address, which is auto-incremented after each write
        dec bc
        ld a,b
        or c
        jp nz,clearVramLoop
    ret

prepareVram:
    push af
	    ld a,l
	    out (vdpControl),a
	    ld a,h
	    or &40
	    out (vdpControl),a
   pop af
    ret

setUpVdpRegisters:
    ld hl,VdpInitData
    ld b,VdpInitDataEnd-VdpInitData
    ld c,vdpControl
    otir
    ret

VdpInitData:
	db &06 ; reg. 0, display and interrupt mode.
	db 128+0
	db &a1 ; reg. 1, display and interrupt mode.
	db 128+1
	db &ff ; reg. 2, name table address. &ff = name table at 		&3800
	db 128+2
	db &ff ; reg. 3, Name Table Base Address  (no function)			&0000
	db 128+3
	db &ff ; reg. 4, Color Table Base Address (no function)			&0000
	db 128+4
	db &ff ; reg. 5, sprite attribute table. -DCBA98- = bits of address	$3f00
	db 128+5
	db &ff ; reg. 6, sprite tile address.    -----D-- = bit 13 of address	$2000
	db 128+6
	db &00 ; reg. 7, border color.		 ----CCCC = Color
	db 128+7
	db &00 ; reg. 8, horizontal scroll value = 0.
	db 128+8
	db &00 ; reg. 9, vertical scroll value = 0.
	db 128+9
	db &ff ; reg. 10, raster line interrupt. Turn off line int. requests.
	db 128+10
VdpInitDataEnd:


	
	
	
writeToVramx4:
    ld a,(hl)
    out (vdpData),a
    out (vdpData),a
    out (vdpData),a
    out (vdpData),a
    inc hl
    dec bc
    ld a,c
    or b
    jp nz, writeToVramx4
    ret
