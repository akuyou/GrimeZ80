;This AY emulator is taken from
;Cookies Hot Butter demo
;I cannot take credit for it!

Volboost Equ 1

ayReset:
	LD C,255 ;soundchip on
	LD B,1
	LD A,onoff
	OUT (C),A
	DEC B
	LD A,1
	OUT (C),A
ret


;the outputs to the AY-3-8912Åfs registers are intercepted and
;are used as memory mapped i/o


memoryio:

ayfine1: DEFB 0;0
aycoarse1: DEFB 0;1
ayfine2: DEFB 0;2
aycoarse2: DEFB 0;3
ayfine3: DEFB 0;4
aycoarse3: DEFB 0;5
aynoisepitch: DEFB 0;6
aymixer: DEFB 0;7
ayvol1: DEFB 0;8
ayvol2: DEFB 0;9
ayvol3: DEFB 0;10
ayenvlength:
ayenvlen: DEFB 0;11
ayenvlen2: DEFB 0;12
ayenvshape: DEFB 0;13


saaouts:
DEFB tone2
saatone2: DEFB 0
DEFB amp2
saaamp2: DEFB 0
DEFB tone3
saatone3: DEFB 0
DEFB amp3
saaamp3: DEFB 0
DEFB oct32
saaoct32: DEFB 0
DEFB tone5
saatone5: DEFB 0
DEFB amp5
saaamp5: DEFB 0
DEFB oct54
saaoct54: DEFB 0
DEFB noisefreq
saanoisefreq: DEFB 0
DEFB freqen
saafreqen: DEFB 0
DEFB noiseen
saanoiseen: DEFB 0
DEFB onoff
DEFB 1

AYEmulation_Play:
LD HL,ayfine1
LD E,(HL) ;ayfine1
INC L
LD A,(HL) ;aycoarse1

AND 15
LD D,A

EX DE,HL
ADD HL,HL
LD DE,pitchconvert
ADD HL,DE

LD A,(HL)
LD (saatone2),A
INC L
LD A,(HL)
LD (stoctave1+1),A

LD HL,ayfine2
LD E,(HL) ;ayfine2
INC HL
LD A,(HL) ;aycoarse2
AND 15
LD D,A

EX DE,HL
ADD HL,HL
LD DE,pitchconvert
ADD HL,DE

LD A,(HL)
LD (saatone3),A
INC L
LD A,(HL)
RLCA
RLCA
RLCA
RLCA
stoctave1: OR 0
LD (saaoct32),A

LD HL,ayfine3
LD E,(HL) ;ayfine3
INC L
LD A,(HL) ;aycoarse3
AND 15
LD D,A

EX DE,HL
ADD HL,HL
LD DE,pitchconvert
ADD HL,DE

LD A,(HL)
LD (saatone5),A
INC L
LD A,(HL)
RLCA
RLCA
RLCA
RLCA
LD (saaoct54),A

LD A,(aynoisepitch)
LD HL,noiseconvert
ADD L
LD L,A
LD A,(HL)
LD (saanoisefreq),A

LD A,(aymixer)
LD DE,0
BIT 0,A
JR NZ,c2nsound
SET 2,D
c2nsound: BIT 3,A
JR NZ,c2nnoise
SET 2,E
c2nnoise: BIT 1,A
JR NZ,c3nsound
SET 3,D
c3nsound: BIT 4,A
JR NZ,c3nnoise
SET 3,E
c3nnoise: BIT 2,A
JR NZ,c5nsound
SET 5,D
c5nsound: BIT 5,A
JR NZ,c5nnoise
SET 5,E
c5nnoise:
LD A,D
LD (saafreqen),A
LD A,E
LD (saanoiseen),A

LD HL,ayvol1
LD A,(HL)
RLCA
RLCA
RLCA
RLCA
ifdef Volboost
	or %00000110
else
	OR (HL)
endif
LD (saaamp2),A

INC HL
LD A,(HL) ;chan2vol
RLCA
RLCA
RLCA
RLCA
ifdef Volboost
	or %00000110
else
	OR (HL)
endif
LD (saaamp3),A

INC HL ;chan3vol
LD A,(HL)
RLCA
RLCA
RLCA
RLCA
ifdef Volboost
	or %00000110
else
	OR (HL)
endif
LD (saaamp5),A

LD BC,&00FF
LD HL,saaouts
OUTI
OUTI
OUTI
OUTI
OUTI
OUTI
OUTI
OUTI
OUTI
OUTI
OUTI
OUTI
OUTI
OUTI
OUTI
OUTI
OUTI
OUTI
OUTI
OUTI
OUTI
OUTI
OUTI
OUTI
RET

amp0 EQU 0
amp1 EQU 1
amp2 EQU 2
amp3 EQU 3
amp4 EQU 4
amp5 EQU 5

tone0 EQU 8
tone1 EQU 9
tone2 EQU 10
tone3 EQU 11
tone4 EQU 12
tone5 EQU 13

oct10 EQU 16
oct32 EQU 17
oct54 EQU 18

freqen EQU 20
noiseen EQU 21
noisefreq EQU 22

env0 EQU 24
env1 EQU 25

onoff EQU 28

align 64
noiseconvert: DEFB 0,0,0,0,0,0,17,17,17,17,17,17,17,17,17,17,34
		DEFB 34,34,34,34,34,34,34,34,34,34,34,34,34,34,34

envconvert: DEFB 132,132,132,132,140,140,140,140
		DEFB 134,132,138,130,142,130,138,140
pitchconvert: incbin "z:\resSAM\AYtable.bin"
