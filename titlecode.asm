;---------------------------------------
;PARA LANDER DX
;
;By Richard Bayliss
;
;(C) 2021 The New Dimension
;
;Turbo assembler/Turbo Macro Pro code
;
;
;TITLE SCREEN
;---------------------------------------

;Variables
;---------

;Screen and bitmap data

;NTSC control pointers
system   = $0ffe
ntsctimer = $0fff

logocol  = $5800
colour   = $d800
screen   = $0400
matrix   = $2800
matcol   = $2c00
gamestart = $3000

;Music

musicinit = $7000  ;BEWARE!
musicplay = $7003
music2init = $8000 ;If testing, use
music2play = $8003 ;$1000, $1003

;Scroll text position

scrolltext = $3d00
hiscore  = $4400

;Raster splits

split1   = $2e
split2   = $6a
split3   = $b0
split4   = $ba
split5   = $c8

;Animation char values

reedchar = $0a00 ;char id!for reeds
seachar  = $0800+($3c*8)

;=======================================

         *= $4800

         ;PAL/NTSC clock check

         lda #252
         sta 808
         lda #8
         jsr $ffd2

titlescreen
         ;Switch off IRQ
         sei
         lda #0
         sta $d020
         sta $d021
         lda #$0f
         sta $d022
         lda #$09
         sta $d023
         lda #252
         sta 808

         ldx #$31
         ldy #$ea
         lda #$81
         stx $0314
         sty $0315
         sta $dc0d
         sta $dd0d

         lda #$00
         sta $d019
         sta $d01a
         cli

         ;Init scroll text

         lda #<scrolltext
         sta messread+1
         lda #>scrolltext
         sta messread+2

         lda #<musicplay
         sta pal+1
         lda #>musicplay
         sta pal+2

;---------------------------------------
;Copy all screen matrix data in place
;display the sea bed and the credits
;---------------------------------------

         ldx #$00
clr      lda #$20 ;Clear screen first
         sta $0400,x
         sta $0500,x
         sta $0600,x
         sta $06e8,x
         inx
         bne clr

         ;Copy seabed

         ldx #$00
drawscr
         lda matrix+$02b8,x
         sta screen+$02b8,x
         lda matcol+$02b8,x
         sta colour+$02b8,x
         lda matrix+$02d0,x
         sta screen+$02d0,x
         lda matcol+$02d0,x
         sta colour+$02d0,x
         lda matrix+$0308,x
         sta colour+$0308,x
         lda matcol+$0308,x
         sta colour+$0308,x
         lda matrix+$0320,x
         sta screen+$0320,x
         lda matcol+$0320,x
         sta colour+$0320,x
         lda matrix+$0348,x
         sta screen+$0348,x
         lda matcol+$0348,x
         sta colour+$0348,x
         lda matrix+$0370,x
         sta screen+$0370,x
         lda matcol+$0370,x
         sta colour+$0370,x
         lda matrix+$0398,x
         sta screen+$0398,x
         sta screen+$03c0,x
         lda matcol+$0398,x
         sta colour+$0398,x
         lda matcol+$03c0,x
         sta colour+$03c0,x
         inx
         cpx #40
         beq drawdone
         jmp drawscr

drawdone

;---------------------------------------
;Draw logo colour
;---------------------------------------

         ldx #$00
paintlogo
         lda logocol,x
         sta colour,x
         inx
         bne paintlogo
         ldx #$00
paintlogo2
         lda logocol+$0100,x
         sta colour+$0100,x
         inx
         cpx #$50
         bne paintlogo2

;---------------------------------------
;Copy the credits to screen
;---------------------------------------

         ldx #$00
copycred lda line1,x
         jsr convert
         sta screen+(8*40),x
         lda #1
         sta colour+(8*40),x
         lda line2,x
         jsr convert
         sta screen+(10*40),x
         lda #13
         sta colour+(10*40),x
         lda line3,x
         jsr convert
         sta screen+(12*40),x
         lda #3
         sta colour+(12*40),x
         lda line4,x
         jsr convert
         sta screen+(14*40),x
         lda #5
         sta colour+(14*40),x
         jsr convert
         inx
         cpx #40
         bne copycred
         jmp irqs

;---------------------------------------
;Convert PETSCII text lines-screen code
;---------------------------------------
convert  cmp #$3b
         bcc ok
         sec
         sbc #$40
ok       rts
;---------------------------------------
;Setup the IRQ raster interrupt player
;---------------------------------------

irqs     ldx #<irq1
         ldy #>irq1
         lda #$7f
         stx $0314
         sty $0315
         sta $dc0d
         lda #$2e
         sta $d012
         lda #$1b
         sta $d011
         lda #$01
         sta $d01a
         lda #$00
         jsr musicinit
         lda #0
         sta spacebar
         sta firebutton
         cli
         jmp titleloop

;---------------------------------------
;Main IRQ raster interrupts
;---------------------------------------

irq1 ;The main sea bed

         inc $d019
         lda $dc0d
         sta $dd0d
         lda #split1
         sta $d012
         lda #6
         sta $d021

         ldx #$03
         ldy #$12
         lda #$1b
         stx $dd00
         sty $d018
         sta $d011
         lda #$10
         sta $d016

         lda #$01
         sta rt
         jsr pnplayer

         ldx #<irq2
         ldy #>irq2
         stx $0314
         sty $0315
         jmp $ea7e

irq2     ;Split 2, logo display

         inc $d019
         lda #split2
         sta $d012
         ldx #$02
         ldy #$78
         lda #$3b
         stx $dd00
         sty $d018
         sta $d011
         lda #$18
         sta $d016
         lda #0
         sta $d021


         ldx #<irq3
         ldy #>irq3
         stx $0314
         sty $0315
         jmp $ea7e

irq3     ;Split 3 - Credits

         inc $d019
         lda #split3
         sta $d012
         ldx #$03
         ldy #$12
         lda #$1b
         stx $dd00
         sty $d018
         sta $d011
         lda #$08
         sta $d016



         ldx #<irq4
         ldy #>irq4
         stx $0314
         sty $0315
         jmp $ea7e

irq4     ;split 4 - smooth scroller

         inc $d019
         lda #split4
         sta $d012
         ldx #$03
         ldy #$12
         lda #$1b
         stx $dd00
         sty $d018
         sta $d011
         lda xpos
         sta $d016
         ldx #<irq5
         ldy #>irq5
         stx $0314
         sty $0315
         jmp $ea7e

         ;Split 5, still

irq5     inc $d019
         lda #split5
         sta $d012
         lda #$00
         sta $d016
         ldx #<irq1
         ldy #>irq1
         stx $0314
         sty $0315
         jmp $ea7e

;---------------------------------------
;PAL/NTSC timed music player
;---------------------------------------
pnplayer lda system
         cmp #1
         beq pal
         inc ntsctimer
         lda ntsctimer
ntscmode cmp #6
         beq ntscloop
pal      jsr musicplay
         rts
ntscloop lda #$00
         sta ntsctimer
         rts

;---------------------------------------
;Main title screen loop
;---------------------------------------

titleloop
         lda #0
         sta rt
         cmp rt
         beq *-3
         jsr scroller
         jsr animbg
         jsr flasher
         lda $dc00
         lsr a
         lsr a
         lsr a
         lsr a
         lsr a
         bit firebutton
         ror firebutton
         bmi spacecheck
         bvc spacecheck
         jmp gamestart

spacecheck
         lda $dc01
         lsr a
         lsr a
         lsr a
         lsr a
         lsr a
         bit spacebar
         ror spacebar
         bmi titleloop
         bvc titleloop
         jmp halloffame

;---------------------------------------
;Scroll text routine
;---------------------------------------

scroller lda xpos
         sec
         sbc #2
         and #$07
         sta xpos
         bcs exitscr
         ldx #$00
wrap     lda screen+(16*40)+1,x
         sta screen+(16*40),x
         inx
         cpx #39
         bne wrap
messread lda scrolltext
         bne store
         lda #<scrolltext
         sta messread+1
         lda #>scrolltext
         sta messread+2
         jmp messread
store    sta screen+(16*40)+39
         inc messread+1
         bne exitscr
         inc messread+2
exitscr  rts

;---------------------------------------
;Title screen flashing text
;---------------------------------------
flasher
         lda flashdelay
         cmp #3
         beq flashok
         inc flashdelay
         rts
flashok  lda #$00
         sta flashdelay
         jsr doflash
         ldx flashpointer
         lda flashtable,x
         sta flashstore
         lda flashtable2,x
         sta flashstore2
         inx
         cpx #flashtableend-flashtable
         beq resetflash
         inc flashpointer
         rts
resetflash ldx #$00
         stx flashpointer
         rts
doflash  ldx #$00
toscreen lda flashstore
         sta colour+(14*40),x
         lda flashstore2
         sta colour+(16*40),x
         inx
         cpx #40
         bne toscreen
         rts

;---------------------------------------
;Charset animator
;---------------------------------------

;Background animation

animbg   jsr seaflow
         lda bgdelay
         cmp #3
         beq bgdelayok
         inc bgdelay
         rts
bgdelayok lda #$00
         sta bgdelay
         jsr reedanim
         rts

         ;Animate the seaweed

reedanim
         lda reedchar
         sta reedstor
         ldx #$00
screed   lda reedchar+1,x
         sta reedchar,x
         inx
         cpx #$08
         bne screed
         lda reedstor
         sta reedchar+7
         rts

         ;Animate the sea flow
seaflow
         ldx #$00
doflow   lda seachar,x
         lsr a
         ror seachar,x
         inx
         cpx #$08
         bne doflow
         rts

;---------------------------------------
;Display the hall of fame
;---------------------------------------
         *= $4c00 ;Easy target addr

halloffame
         sei
         ldx #$31
         ldy #$ea
         stx $0314
         sty $0315
         lda #$81
         sta $dc0d
         sta $dd0d
         lda #$00
         sta $d019
         sta $d01a
         sta $d015
         ldx #$00
silence  lda #$00
         sta $d400,x
         inx
         cpx #$18
         bne silence
         lda #$00
         sta $d020
         sta $d021
         lda #$03
         sta $dd00
         lda #$12
         sta $d018
         lda #$08
         sta $d016
         ldx #$00
showit   lda hiscore,x
         sta $0400,x
         lda hiscore+$0100,x
         sta $0500,x
         lda hiscore+$0200,x
         sta $0600,x
         lda hiscore+$02e8,x
         sta $06e8,x
         lda #$00
         sta $d800,x
         sta $d900,x
         sta $da00,x
         sta $dae8,x
         inx
         bne showit

 ;Init pointers for hi
 ;shower

         lda #$00
         sta firebutton
         sta flashpointer2
         sta flashdelay2
         sta flashstore3

;Set hi score IRQ interupt

         ldx #<hirq1
         ldy #>hirq1
         lda #$7f
         stx $0314
         sty $0315
         sta $dc0d
         lda #$36
         sta $d012
         lda #$1b
         sta $d011
         lda #1
         sta $d01a

         lda #<music2play
         sta pal+1
         lda #>music2play
         sta pal+2
         lda #0
         jsr music2init
         cli
         jmp halloffamepress

;IRQ for hiscor

hirq1    inc $d019
         lda $dc0d
         sta $dd0d
         lda #$f8
         sta $d012
         lda #1
         sta rt
         jsr pnplayer
         jmp $ea7e

;------------------------------------
;Set mainloop for hi score
;displayer

halloffamepress

         lda #0
         sta rt
         cmp rt
         beq *-3
         jsr flashhi
         lda $dc00
         lsr a
         lsr a
         lsr a
         lsr a
         lsr a
         bit firebutton
         ror firebutton
         bmi halloffamepress
         bvc halloffamepress
         jmp titlescreen

;Flash routine for hiscore

flashhi  lda flashdelay2
         cmp #1
         beq hiflashok
         inc flashdelay2
         rts
hiflashok
         lda #0
         sta flashdelay
         jsr painttable
         ldx flashpointer2
         lda flashtable3,x
         sta flashstore3
         inx
         cpx #flashtable3end-flashtable3
         beq resethif
         inc flashpointer2
         rts
resethif
         ldx #$00
         stx flashpointer2
         rts

;Write flash to screen, and roll over
;on to other rows

painttable
         ldx #$00
ploop    lda colour+(17*40),x
         sta colour+(18*40),x
         lda colour+(16*40),x
         sta colour+(17*40),x
         lda colour+(15*40),x
         sta colour+(16*40),x
         lda colour+(14*40),x
         sta colour+(15*40),x
         lda colour+(13*40),x
         sta colour+(14*40),x
         lda colour+(12*40),x
         sta colour+(13*40),x
         lda colour+(11*40),x
         sta colour+(12*40),x
         lda colour+(10*40),x
         sta colour+(11*40),x
         lda colour+(9*40),x
         sta colour+(10*40),x
         lda colour+(8*40),x
         sta colour+(9*40),x
         lda colour+(7*40),x
         sta colour+(8*40),x
         lda colour+(6*40),x
         sta colour+(7*40),x
         lda colour+(5*40),x
         sta colour+(6*40),x

         lda flashstore3
         sta colour+(5*40),x
         inx
         cpx #40
         beq flashend
         jmp ploop

flashend rts

;---------------------------------------
;Title screen pointers and text
;---------------------------------------

rt       .byte 0   ;Raster sync timer
xpos     .byte 0   ;$D016 register for
                   ;soft scroll
firebutton .byte 0
spacebar .byte 0
flashdelay .byte 0
flashpointer .byte 0
flashstore .byte 0
flashstore2 .byte 0
flashdelay2 .byte 0
flashpointer2 .byte 0
flashstore3 .byte 0
bgdelay  .byte 0
reedstor .byte 0

;-------------------------------------
;Title screen presentation lines and
;scroll flash table. The third table
;is for the hi score displayer.
;-------------------------------------
flashtable
         .byte $09,$02,$08,$0a,$0f,$07
         .byte $01,$07,$0f,$08,$02,$09
flashtableend .byte 0

flashtable2
         .byte $01,$0d,$03,$05,$0e,$04
         .byte $06,$04,$0e,$05,$03,$0d

         .byte $00

flashtable3
         .byte $06,$02,$0a,$07,$0d,$01
         .byte $0d,$07,$0a,$02,$06,$09
flashtable3end
         .byte $09

;------------------------------------
;Title screen text presentation lines
;------------------------------------
line1    .text "       (C) 2021 THE "
         .text "NEW DIMENSION       "
line2    .text "   PROGRAMMING, GRAP"
         .text "HICS AND MUSIC BY   "
line3    .text "             RICHARD"
         .text " BAYLISS            "
line4    .text "         - PRESS FIR"
         .text "E TO START -        "

