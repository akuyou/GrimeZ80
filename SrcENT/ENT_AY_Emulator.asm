
; I did not write or convert the AY Emulator code here, it was taken from SYM AMP and was coded by Geco based on IstvanV's original


;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@                                                                            @
;@                                S y m  A m p                                @
;@                                                                            @
;@             (c) 2005-2007 by Prodatron / SymbiosiS (Jörn Mika)             @
;@                                                                            @
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@




; =============================================================================    ;!!!

; if enabled, channel A is played at the left, channel B at center,
; and channel C at right
ENABLE_STEREO           equ     1
; the border color is set to red while the IRQ routine is running if this
; is enabled (for debugging only)
IRQ_BORDER_FX           equ     1
; envelope sample rate = 1000 / ENV_SRATE_DIV Hz (increase this for lower
; quality and CPU usage)
ENV_SRATE_DIV           equ     1
; minimum envelope frequency value (should be at least 14 * ENV_SRATE_DIV,
; and less than 256)
MIN_ENV_FREQVAL         equ     24 * ENV_SRATE_DIV
    ; if non-zero, the envelope generator is stopped in modes 8, 10, 12, and 14
    ; when the envelope enable bits in registers 8 to 10 are changed to disabled
    ; on all channels (NOTE continuing the envelope by enabling it again in
    ; registers 8 to 10 does not work correctly, the envelope must be restarted
    ; by writing to register 13)
ENVELOPE_CPU_SAVING     equ     1
    ; select how tone and noise being enabled on the same channel should be handled
    ;   bit 0 = 0 play tone frequency
    ;   bit 0 = 1 play noise frequency
    ;         >15 use distortion specified in bits 4-7 (defaults to 30h for noise)
toneAndNoiseModeA       equ     01
toneAndNoiseModeB       equ     01
toneAndNoiseModeC       equ     01
; if non-zero, the envelope emulation routine is disabled
NO_ENVELOPE_IRQ         equ     0
; DAVE channels assigned to each AY channel
ayDaveChnA              equ     0
ayDaveChnB              equ     1
ayDaveChnC              equ     2

  if NO_ENVELOPE_IRQ = 0

AYEmulation_Play:
envelopeInterrupt:
        ret
;    if ENV_SRATE_DIV < 2
;        ld    a,33h
;        out   (0b4h), a
;    endif
        push  hl
        push  bc
envelopeInterruptl1:
        ld    hl, #0000                 ; * envelope counter
;        ld    bc, 10000h - (((60000 * ENV_SRATE_DIV) + 500) / 50)      ;1000
envfreq ld      bc,#fb46    ;60000
;        ld      bc,#f74e    ;110830
        add   hl, bc
envelopeInterruptl2:
        jr    c, envelopeInterruptl19   ; * JR if envelope is stopped
envelopeInterruptl3:    
        ld    bc, #ffff                 ; * envelope frequency
envelopeInterruptl4:
        ld    a, 0                      ; * envelope state (0 to 15)
envelopeInterruptl5:
        dec   a                         ; * envelope direction (INC A or DEC A)
        add   hl, bc
        jr    nc, envelopeInterruptl5
        ld    (envelopeInterruptl1 + 1), hl
        cp    #10
envelopeInterruptl6:
        jr    nc, envelopeInterruptl21  ; * envelope mode
envelopeInterruptl7:
        ld    (envelopeInterruptl4 + 1), a
envelopeInterruptl8:
        or    ayVolumeTable
envelopeInterruptl9:
        ld    hl,ayVolumeTable
        ld    l, a
        ld    a, (hl)
        pop   bc
envelopeInterruptl10:
        jr    envelopeInterruptl12     ; * envelope enable mode
envelopeInterruptl11:
        out   (#a8 + ayDaveChnA), a    ; envelope on channel A only
    if ENABLE_STEREO = 0
        out   (0ach + ayDaveChnA), a
    endif
envelopeInterruptl12:
        pop   hl
;        pop     af
;        ei
        ret
envelopeInterruptl13:
        out   (#a8 + ayDaveChnA), a    ; envelope on channels A and B
    if ENABLE_STEREO = 0
        out   (0ach + ayDaveChnA), a
    endif
envelopeInterruptl14:
    if ENABLE_STEREO = 1
        ld    l, a                      ; envelope on channel B only (Carry=0)
        rra
        scf
        adc   a, l
        rra
    endif
        out   (#a8 + ayDaveChnB), a
        out   (#ac + ayDaveChnB), a
        pop   hl
;        pop     af
;        ei
        ret
envelopeInterruptl15:
        out   (#a8 + ayDaveChnA), a    ; envelope on channels A and C
    if ENABLE_STEREO = 0
        out   (0ach + ayDaveChnA), a
    endif
envelopeInterruptl16:
    if ENABLE_STEREO = 0
        out   (0a8h + ayDaveChnC), a
    endif
        out   (#ac + ayDaveChnC), a    ; envelope on channel C only
        pop   hl
;        pop     af
;        ei
        ret
envelopeInterruptl17:
        out   (#a8 + ayDaveChnA), a    ; envelope on channels A, B, and C
    if ENABLE_STEREO = 0
        out   (0ach + ayDaveChnA), a
    endif
envelopeInterruptl18:
    if ENABLE_STEREO = 0
        out   (0a8h + ayDaveChnC), a
    endif
        out   (#ac + ayDaveChnC), a    ; envelope on channels B and C
    if ENABLE_STEREO = 1
        ld    l, a                      ; NOTE Carry is always 0 here
        rra
        scf
        adc   a, l
        rra
    endif
        out   (#a8 + ayDaveChnB), a
        out   (#ac + ayDaveChnB), a
        pop   hl
;        pop     af
;        ei
        ret
envelopeInterruptl19:
        ld    (envelopeInterruptl1 + 1), hl
        pop   bc
        pop   hl
;        pop     af
;        ei
        ret
envelopeInterruptl20:   
        ld    l,ayVolumeTable + 15      ; envelope modes 11 and 13
        defb  #01                       ; = LD BC, nnnn
envelopeInterruptl21:
        ld    l, ayVolumeTable          ; envelope modes 0 to 7, 9, and 15
        ld    a, #18                    ; = JR +nn
        ld    (envelopeInterruptl2), a  ; stop envelope
        ld    a,l
        jp    envelopeInterruptl9
envelopeInterruptl22:   
        and   #0f                       ; envelope modes 8 and 12
        jp    envelopeInterruptl7
envelopeInterruptl23:   
        jp    m, envelopeInterruptl24   ; envelope modes 10 and 14
        xor   #1f
        ld    l, a
        ld    h, #3d                    ; set direction to DEC A
        ld    (envelopeInterruptl4 + 1), hl ; assume .l5 = .l4 + 2
        jp    envelopeInterruptl8
envelopeInterruptl24:
        cpl
        ld    l, a
        ld    h, #3c                    ; set direction to INC A
        ld    (envelopeInterruptl4 + 1), hl
        jp    envelopeInterruptl8

  endif
; -----------------------------------------------------------------------------

    macro ayVolTableMacro
ayVolumeTable:
        defb   0,  1,  2,  3,  4,  5,  6,  9
        defb  12, 17, 22, 28, 36, 44, 53, 63
    endm

    macro ayRegMaskTableMacro
ayRegisterMaskTable:
        defb  #ff, #0f, #ff, #0f, #ff, #0f, #1f, #ff
        defb  #1f, #1f, #1f, #ff, #ff, #0f, #ff, #ff
    endm

    macro ayRegistersMacro
ayRegisters:
        defb  00, 00, 00, 00, 00, 00, 00, 00
        defb  00, 00, 00, 00, 00, 00, 00, 00
    endm

        align 16
align 256

;    if ($ & 0030h) = 0020h
        ;block 16, 00
;    endif
list
ayTablesBegin:

;    if (ayTablesBegin & 0030h) = 0000h
        ayVolTableMacro
        ayRegMaskTableMacro
;    endif
;    if (ayTablesBegin & 0030h) = 0010h
;        ayRegMaskTableMacro
;    endif
;    if (ayTablesBegin & 0030h) = 0030h
;        ayVolTableMacro
;        ayRegistersMacro
;    endif
;        assert  ($ & 000fh) = 0

ayRegWriteTable:
        db  ayRegisterWritel3 - ayRegisterWritel1 - 2
        db  ayRegisterWritel3 - ayRegisterWritel1 - 2
        db  ayRegisterWritel4 - ayRegisterWritel1 - 2
        db  ayRegisterWritel4 - ayRegisterWritel1 - 2
        db  ayRegisterWritel6 - ayRegisterWritel1 - 2
        db  ayRegisterWritel6 - ayRegisterWritel1 - 2
        db  ayRegisterWritel7 - ayRegisterWritel1 - 2
        db  ayRegisterWritel5 - ayRegisterWritel1 - 2
        db  ayRegisterWritel9 - ayRegisterWritel1 - 2
        db  ayRegisterWritel10 - ayRegisterWritel1 - 2
        db  ayRegisterWritel11 - ayRegisterWritel1 - 2
        db  ayRegisterWritel12 - ayRegisterWritel1 - 2
        db  ayRegisterWritel12 - ayRegisterWritel1 - 2
        db  ayRegisterWritel15 - ayRegisterWritel1 - 2
        db  ayRegisterWritel8 - ayRegisterWritel1 - 2
        db  ayRegisterWritel8 - ayRegisterWritel1 - 2

;        assert  ($ & 000fh) = 0

;    if (ayTablesBegin & 0030h) = 0000h
        ayRegistersMacro
;    endif
;    if (ayTablesBegin & 0030h) = 0010h
;        ayRegistersMacro
;        ayVolTableMacro
;    endif
;    if (ayTablesBegin & 0030h) = 0030h
;        ayRegMaskTableMacro
;    endif

;        assert  $ = (ayTablesBegin + 64)

    if NO_ENVELOPE_IRQ = 0

envelopeModeTable:
        db  envelopeInterruptl21 - envelopeInterruptl6 - 2
        db  envelopeInterruptl21 - envelopeInterruptl6 - 2
        db  envelopeInterruptl21 - envelopeInterruptl6 - 2
        db  envelopeInterruptl21 - envelopeInterruptl6 - 2
        db  envelopeInterruptl21 - envelopeInterruptl6 - 2
        db  envelopeInterruptl21 - envelopeInterruptl6 - 2
        db  envelopeInterruptl21 - envelopeInterruptl6 - 2
        db  envelopeInterruptl21 - envelopeInterruptl6 - 2
        db  envelopeInterruptl22 - envelopeInterruptl6 - 2
        db  envelopeInterruptl21 - envelopeInterruptl6 - 2
        db  envelopeInterruptl23 - envelopeInterruptl6 - 2
        db  envelopeInterruptl20 - envelopeInterruptl6 - 2
        db  envelopeInterruptl22 - envelopeInterruptl6 - 2
        db  envelopeInterruptl20 - envelopeInterruptl6 - 2
        db  envelopeInterruptl23 - envelopeInterruptl6 - 2
        db  envelopeInterruptl21 - envelopeInterruptl6 - 2

;        assert  ($ & 000fh) = 0

envelopeEnableTable:
        db  envelopeInterruptl12 - envelopeInterruptl11
        db  envelopeInterruptl11 - envelopeInterruptl11
        db  envelopeInterruptl14 - envelopeInterruptl11
        db  envelopeInterruptl13 - envelopeInterruptl11
        db  envelopeInterruptl16 - envelopeInterruptl11
        db  envelopeInterruptl15 - envelopeInterruptl11
        db  envelopeInterruptl18 - envelopeInterruptl11
        db  envelopeInterruptl17 - envelopeInterruptl11

;        assert  ($ & 0007h) = 0

    endif
nolist
; -----------------------------------------------------------------------------

setChannelAmplitude:
        cp    #10
        jr    c, setChannelAmplitudel1
    if NO_ENVELOPE_IRQ = 0
        res   3, b
        ld    a, (envelopeInterruptl4 + 1)
    else
        xor   a
    endif
setChannelAmplitudel1:                      ; HL = ayRegWriteTable + (8 + channel)
;    if ((ayVolumeTable ^ ayRegWriteTable) & 0ff00h) != 0
;      if ayVolumeTable > ayRegWriteTable
;        inc   h
;      else
;        dec   h
;      endif
;    endif
        or    ayVolumeTable
    if ENABLE_STEREO = 1
        bit   0, l                      ; Z = 0 channel B, Z = 1 channel A, C
    endif
        ld    l, a
        ld    a, (hl)
    if ENABLE_STEREO = 1
        jr    z, setChannelAmplitudel2
		PUSH HL
        ld    l, a                      ; NOTE Carry is always 0 here
        rra
        scf
        adc   a, l
		POP HL
        rra
    endif
        out   (c), a
        set   2, c
setChannelAmplitudel2:
        out   (c), a
		LD A,(HL)
		BIT 1,C
		JR Z,setChannelAmplitudel10
		LD (VOLC),A
		jr setChannelAmplitudel20
setChannelAmplitudel10:
        bit 0,C
		jr z,setChannelAmplitudel11
		ld (VOLB),a
		jr setChannelAmplitudel20
setChannelAmplitudel11
        ld (VOLA),a
setChannelAmplitudel20		
    if NO_ENVELOPE_IRQ = 0
setChannelAmplitudel3:
        ld    hl, envelopeEnableTable   ; *
        ld    a, l                      ; NOTE envelopeEnableTable
        or    b                         ; should be aligned to 16 bytes
        cp    envelopeEnableTable + 8
        jr    c, setChannelAmplitudel4
        xor   b
setChannelAmplitudel4:
        cp    l
        jr    z, setChannelAmplitudel5  ; envelope enable bit has not changed ?
        ld    (setChannelAmplitudel3 + 1), a
        ld    l, a
        ld    a, (hl)
        ld    (envelopeInterruptl10 + 1), a
      if ENVELOPE_CPU_SAVING = 1
        ld    a, (envelopeInterruptl6 + 1)     ; check envelope mode:
        cp    envelopeInterruptl22 - envelopeInterruptl6 - 2
        jr    c, setChannelAmplitudel5                    ; hold or not continue ?
        ld    a, envelopeEnableTable
        sub   l
        sbc   a, a
        and   #20
        or    #18                       ; JR +nn or JR C, +nn
        ld    (envelopeInterruptl2), a ; disable envelope if it is not used
      endif
    endif
setChannelAmplitudel5:
        pop   bc
;        pop   af
        pop   hl
        ret

setChannelAFreq:
        ld    c,  ayDaveChnA * 2 + #a0
        ld    a, (ayRegisters + 7)
        ld    hl, (ayRegisters)
;    if (toneAndNoiseModeA < 16) && ((toneAndNoiseModeA & 1) = 0)
;        rrca
;        jr    nc, setToneGenFrequency   ; tone generator enabled ?
;        and   04h
;        jr    z, setNoiseGenFreq        ; noise generator enabled ?
;    endif
;    if (toneAndNoiseModeA < 16) && ((toneAndNoiseModeA & 1) != 0)
        bit   3, a
        jr    z, setNoiseGenFreq        ; noise generator enabled ?
        rrca
        jr    nc, setToneGenFrequency   ; tone generator enabled ?
;    endif
;    if toneAndNoiseModeA > 15
;        and   09h
;        jr    z, setToneGenAAsNoise     ; tone + noise generator enabled ?
;        cp    08h
;        jr    z, setToneGenFrequency    ; tone generator only ?
;        jr    c, setNoiseGenFreq        ; noise generator only ?
;    endif
        xor   a                         ; channel disabled
        out   (ayDaveChnA * 2 + #a0), a
        out   (ayDaveChnA * 2 + #a1), a
        ret

setChannelBFreq:
        ld    c, ayDaveChnB * 2 + #a0
        ld    a, (ayRegisters + 7)
        ld    hl, (ayRegisters + 2)
;    if (toneAndNoiseModeB < 16) && ((toneAndNoiseModeB & 1) = 0)
;        bit   1, a
;        jr    z, setToneGenFrequency    ; tone generator enabled ?
;        and   10h
;        jr    z, setNoiseGenFreq        ; noise generator enabled ?
;    endif
;    if (toneAndNoiseModeB < 16) && ((toneAndNoiseModeB & 1) != 0)
        bit   4, a
        jr    z, setNoiseGenFreq        ; noise generator enabled ?
        and   #02
        jr    z, setToneGenFrequency    ; tone generator enabled ?
;    endif
;    if toneAndNoiseModeB > 15
;        and   12h
;        jr    z, setToneGenBAsNoise     ; tone + noise generator enabled ?
;        cp    10h
;        jr    z, setToneGenFrequency    ; tone generator only ?
;        jr    c, setNoiseGenFreq        ; noise generator only ?
;    endif
        xor   a                         ; channel disabled
        out   (ayDaveChnB * 2 + #a0), a
        out   (ayDaveChnB * 2 + #a1), a
        ret

setChannelCFreq:
        ld    c, ayDaveChnC * 2 + #a0
        ld    a, (ayRegisters + 7)
        ld    hl, (ayRegisters + 4)
;    if (toneAndNoiseModeC < 16) && ((toneAndNoiseModeC & 1) = 0)
;        bit   2, a
;        jr    z, setToneGenFrequency    ; tone generator enabled ?
;        and   20h
;        jr    z, setNoiseGenFreq        ; noise generator enabled ?
;    endif
;    if (toneAndNoiseModeC < 16) && ((toneAndNoiseModeC & 1) != 0)
        bit   5, a
        jr    z, setNoiseGenFreq        ; noise generator enabled ?
        and   #04
        jr    z, setToneGenFrequency    ; tone generator enabled ?
;    endif
;    if toneAndNoiseModeC > 15
;        and   24h
;        jr    z, setToneGenCAsNoise     ; tone + noise generator enabled ?
;        cp    20h
;        jr    z, setToneGenFrequency    ; tone generator only ?
;        jr    c, setNoiseGenFreq        ; noise generator only ?
;    endif
        xor   a                         ; channel disabled
        out   (ayDaveChnC * 2 + #a0), a
        out   (ayDaveChnC * 2 + #a1), a
        ret

;ayToneDistModeA equ (toneAndNoiseModeA > 15) && ((toneAndNoiseModeA & 1) = 0)
;ayToneDistModeB equ (toneAndNoiseModeB > 15) && ((toneAndNoiseModeB & 1) = 0)
;ayToneDistModeC equ (toneAndNoiseModeC > 15) && ((toneAndNoiseModeC & 1) = 0)
;
;    if ayToneDistModeA 
;setToneGenAAsNoise:
;        ld    a, toneAndNoiseModeA & 0f0h
;        jp    setToneGenFrequency_
;    endif
;
;    if ayToneDistModeB
;setToneGenBAsNoise:
;        ld    a, toneAndNoiseModeB & 0f0h
;        jp    setToneGenFrequency_
;    endif
;
;    if ayToneDistModeC
;setToneGenCAsNoise:
;        ld    a, toneAndNoiseModeC & 0f0h
;        defb  0feh                      ; = CP nn
;    endif

setToneGenFrequency:
;    if ayToneDistModeA || ayToneDistModeB || ayToneDistModeC
;        xor   a
;    endif

setToneGenFrequency_:
;    if ayToneDistModeA || ayToneDistModeB || ayToneDistModeC
;        ld    (setToneGenFrequency_l1 + 1), a
;    endif
convval  add     hl,hl
    ;        ld    b, h
    ;        ld    a, l
    ;        sra   b
    ;        rra
    ;        sra   b
    ;        rra
    ;        sra   b
    ;        rra
    ;        adc   a, l
    ;        ld    l, a
.calcfrr dec   hl
    ;        ld    a, b
    ;        adc   a, h
        ld      a,h
        cp    #10
        jr    nc, setToneGenFrequency_l2    ; overflow ?
setToneGenFrequency_l1:
;    if ayToneDistModeA || ayToneDistModeB || ayToneDistModeC
;        or    00h                       ; * non-zero for tone + noise
;    endif
        out   (c), l
        inc   c
        out   (c), a
        ret
setToneGenFrequency_l2:
        inc   l
        inc   a
        jr    z, setToneGenFrequency_l1
        ld    l, #ff
        ld    a, #0f
        jp    setToneGenFrequency_l1

;    if (toneAndNoiseModeA > 15) && ((toneAndNoiseModeA & 1) != 0)
;setToneGenAAsNoise:
;        ld    h, toneAndNoiseModeA & 0f0h
;        jp    setNoiseGenFreq_
;    endif

;    if (toneAndNoiseModeB > 15) && ((toneAndNoiseModeB & 1) != 0)
;setToneGenBAsNoise:
;        ld    h, toneAndNoiseModeB & 0f0h
;        jp    setNoiseGenFreq_
;    endif

;    if (toneAndNoiseModeC > 15) && ((toneAndNoiseModeC & 1) != 0)
;setToneGenCAsNoise:
;        ld    h, toneAndNoiseModeC & 0f0h
;        jp    setNoiseGenFreq_
;    endif

setNoiseGenFreq:
        ld    h, #30

setNoiseGenFreq_:
        ld    a, (ayRegisters + 6)
        cp    1
        adc   a, 0
        add   a, a
        add   a, a
        dec   a
        out   (c), a
        inc   c
        out   (c), h
        ret

; -----------------------------------------------------------------------------

; reset AY-3-8912 emulation
ayReset1
        ld      a,#29       ;add hl,hl ;!!!
        ld      hl,#fb46	;60000Hz
        jr      ayReset
ayReset2
        xor     a
        ld      hl,#f74e	;110830Hz
ayReset:
        ret
;        push    af
;        push    hl
        push    bc
;        di
        ld      (convval+1),a
        ld      (envfreq+1),hl
        ld    hl, ayRegisters - 1
        ld    bc, #10af
        xor   a
ayResetl1:
        inc   hl
        out   (c), a
        ld    (hl), a
        dec   c
        djnz  ayResetl1
        res   3, l                      ; register 7
        ld    (hl), #3f
    if NO_ENVELOPE_IRQ = 0
        ld    (envelopeInterruptl4 + 1), a
        ld    a, #18                    ; = JR +nn
        ld    (envelopeInterruptl2), a
        ld    hl, MIN_ENV_FREQVAL
        ld    (envelopeInterruptl3 + 1), hl
        ld    a, envelopeInterruptl12 - envelopeInterruptl11
        ld    (envelopeInterruptl10 + 1), a
        ld    a, envelopeEnableTable
        ld    (setChannelAmplitudel3 + 1), a
    endif
    ;        ld    a, 04h
    ;        out   (0bfh), a
    ;        ld    c, b
    ;        call  .l2
    ;        ld    l, b
    ;        call  .l2                       ; L = 1 kHz interrupts per video frame
    ;        ld    a, 25
    ;        cp    l
    ;        ld    a, 01h
    ;        rla
    ;        rla
    ;        out   (0bfh), a                 ; Z80 <= 5 MHz 04h, > 5 MHz 06h
        ld    a, #10                    ; use 17-bit noise generator
        out   (#a6), a
    ;    if NO_ENVELOPE_IRQ == 0
    ;        ld    a, 33h
    ;    else
    ;        ld    a, 30h
    ;    endif
    ;        out   (0b4h), a                 ; enable 1 kHz and video interrupts
        pop     bc
;        pop     hl
;        pop     af
        ret
    ;.l2     in    a, (0b4h)
    ;        and   11h
    ;        or    c
    ;        rlca
    ;        and   66h
    ;        ld    c, a                      ; -ON--ON-
    ;        rlca                            ; ON--ON--
    ;        xor   c                         ; OXN-OXN-
    ;        bit   2, a
    ;        jr    z, .l3
    ;        inc   l                         ; 1 kHz interrupt
    ;.l3     cp    0c0h
    ;        jr    c, .l2                    ; not 50 Hz interrupt ?
    ;        ret

; read AY-3-8912 register A, returning the value in A

ayRegisterRead:
        push    hl
        and   #0f
        or    ayRegisters
        ld    hl, ayRegisters
        ld    l, a
        ld    a, (hl)
        or    a
        pop     hl
        ret

; write C to AY-3-8912 register A
; NOTE interrupts may be enabled on return
ayRegisterWrite:
    ;        push  af
        push    hl
        and   #0f
        or    ayRegisterMaskTable
        ld    hl, ayRegisterMaskTable
        ld    l, a
        ld    a, c
        and   (hl)
;    if ayRegisters = (ayRegisterMaskTable | 0020h)
        set   5, l
;    else
;        res   5, l
;    endif
        cp    (hl)
        jr    z, ayRegisterWritel2          ; register not changed ?
        ld    (hl), a
        push  bc
;    if ayRegWriteTable = (ayRegisters | 0010h)
;        set   4, l
;    else
        res   4, l
;    endif
        ld    a, (hl)
        ld    (ayRegisterWritel1 + 1), a
ayRegisterWritel1:
        jr    ayRegisterWritel8             ; *
ayRegisterWritel2:
    if NO_ENVELOPE_IRQ = 0
        ld    a, l
        xor   ayRegisters + 13
        jr    z, ayRegisterWritel16     ; envelope restart ?
    endif
    ;        pop   af
        pop     hl
        ret
ayRegisterWritel3:    
        call  setChannelAFreq           ; tone generator A frequency
        pop   bc
    ;        pop   af
        pop     hl
        ret
ayRegisterWritel4:
        call  setChannelBFreq           ; tone generator B frequency
        pop   bc
    ;        pop   af
        pop     hl
        ret
ayRegisterWritel5:
        call  setChannelAFreq           ; mixer
        call  setChannelBFreq
ayRegisterWritel6:
        call  setChannelCFreq           ; tone generator C frequency
        pop   bc
;        pop   af
        pop     hl
        ret
ayRegisterWritel7:
        ld    a, (ayRegisters + 7)      ; noise generator frequency
;    if (toneAndNoiseModeA & 1) = 0
;        xor   07h
;        ld    b, a
;        and   09h
;    else
        ld    b, a
        and   #08
;    endif
        call  z, setChannelAFreq
;    if (toneAndNoiseModeB & 1) = 0
;        ld    a, b
;        and   12h
;    else
        bit   4, b
;    endif
        call  z, setChannelBFreq
;    if (toneAndNoiseModeC & 1) = 0
;        ld    a, b
;        and   24h
;    else
        bit   5, b
;    endif
        call  z, setChannelCFreq
ayRegisterWritel8:
        pop   bc
;        pop   af
        pop     hl
        ret
ayRegisterWritel9:
        ld    a, (ayRegisters + 8)      ; channel A amplitude / envelope enable
    if NO_ENVELOPE_IRQ = 0
        ld    bc, #09a8 + ayDaveChnA
    else
        ld    c, #0a8 + ayDaveChnA
    endif
        jp    setChannelAmplitude
ayRegisterWritel10:   
        ld    a, (ayRegisters + 9)      ; channel B amplitude / envelope enable
    if NO_ENVELOPE_IRQ = 0
        ld    bc, #aa8 + ayDaveChnB
    else
        ld    c, #a8 + ayDaveChnB
    endif
        jp    setChannelAmplitude
ayRegisterWritel11:
        ld    a, (ayRegisters + 10)     ; channel C amplitude / envelope enable
    if ENABLE_STEREO = 0
      if NO_ENVELOPE_IRQ = 0
        ld    bc, #ca8 + ayDaveChnC
      else
        ld    c, #a8 + ayDaveChnC
      endif
    else
      if NO_ENVELOPE_IRQ = 0
        ld    bc, #cac + ayDaveChnC
      else
        ld    c, #ac + ayDaveChnC
      endif
    endif
        jp    setChannelAmplitude
ayRegisterWritel12:
    if NO_ENVELOPE_IRQ = 0
        ld    hl, (ayRegisters + 11)    ; envelope generator frequency
        ld    a, h
        or    a
        jr    nz, ayRegisterWritel13
        ld    a, MIN_ENV_FREQVAL
        cp    l
        jr    c, ayRegisterWritel13
        ld    l, a                      ; limit envelope frequency
ayRegisterWritel13:
        ld    (envelopeInterruptl3 + 1), hl
        pop   bc
    ;        pop   af
        pop     hl
        ret
    else
        jr    ayRegisterWritel8
    endif
ayRegisterWritel15:                     ; envelope generator mode / restart
    if NO_ENVELOPE_IRQ = 0
        pop   bc
ayRegisterWritel16:   
        ld    hl, (envelopeInterruptl3 + 1)
        ld    (envelopeInterruptl1 + 1), hl
        ld    a, #38                    ; = JR C, +nn
        ld    (envelopeInterruptl2), a ; enable envelope
        ld    a, (ayRegisters + 13)
        or    envelopeModeTable
        ld    hl, envelopeModeTable
        ld    l, a
        and   #04
        ld    a, (hl)
        ld    (envelopeInterruptl6 + 1), a
        ld    hl, #3c00                 ; INC A, state = 0
        ld    a, l
        jr    nz, ayRegisterWritel17    ; attack ?
        ld    hl, #3d0f                 ; DEC A, state = 15
        ld    a, #3f
ayRegisterWritel17:
        ld    (envelopeInterruptl4 + 1), hl    ; assume eInt.l5 = eInt.l4 + 2
        call  ayRegisterWritel18
    ;        pop   af
        pop     hl
        ret
ayRegisterWritel18:
        call  envelopeInterruptl10     ; NOTE this will pop return address
    else
        jr    ayRegisterWritel8
    endif



VOLA			DB 255
VOLB			DB 255
VOLC			DB 255
