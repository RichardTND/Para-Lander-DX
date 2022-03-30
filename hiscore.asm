;---------------------------------------
;Para Lander DX
;---------------------------------------

;Turbo Assembler/Turbo Macro Pro source
;
;Hi score name + entry routine
;---------------------------------------

;Variables

scorelen = 6
listlen  = 10
namelen  = 9
storbyt  = $02

hitemp1  = $05
hitemp2  = $06
hitemp3  = $07
hitemp4  = $08
nmtemp1  = $09
nmtemp2  = $0a
nmtemp3  = $0b
nmtemp4  = $0c

;List position of names stored in memory
;$4400-$47e8 (FILE: hiscoretable)

nm1      = $4525
nm2      = $4525+(1*40)
nm3      = $4525+(2*40)
nm4      = $4525+(3*40)
nm5      = $4525+(4*40)
nm6      = $4525+(5*40)
nm7      = $4525+(6*40)
nm8      = $4525+(7*40)
nm9      = $4525+(8*40)
nm10     = $4525+(9*40)

;List position of hi scores stored in
;memory $4400-$47e8

hi1      = $4531
hi2      = $4531+(1*40)
hi3      = $4531+(2*40)
hi4      = $4531+(3*40)
hi5      = $4531+(4*40)
hi6      = $4531+(5*40)
hi7      = $4531+(6*40)
hi8      = $4531+(7*40)
hi9      = $4531+(8*40)
hi10     = $4531+(9*40)

;Screen and colour RAM shortcuts

screen   = $0400
colour   = $d800

;Jump address for displaying the hi
;score table

hidisplay = $4c00

;As in the game code, this is where the
;player's score was stored.

score    = $0f00
saver    = $5700

;---------------------------------------
;Assembled to this address ...
;---------------------------------------
         *= $5000
;---------------------------------------
;Switch off all the IRQs and silence
;the SID chip. There is no music made
;for the hi-score routines.
;---------------------------------------
         sei
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

         lda #$00 ;Flush keyboard for
         sta $c6  ;input routines

         ;Silence the SID
         ldx #$00
silence  lda #$00
         sta $d400,x
         inx
         cpx #$18
         bne silence

         ;Set HW screen bits
         lda #$12
         sta $d018
         lda #$08
         sta $d016
         lda #$00
         sta $d015

         ;Clear the screen

         ldx #$00
clearscr lda #$20
         sta screen,x
         sta screen+$0100,x
         sta screen+$0200,x
         sta screen+$02e8,x
         lda #$05
         sta colour,x
         sta colour+$0100,x
         sta colour+$0200,x
         sta colour+$02e8,x
         inx
         bne clearscr

;Grab player's score and put
;into zeropages

         ldx #$00
nextone  lda hslo,x
         sta hitemp1
         lda hshi,x
         sta hitemp2

;Read score digits and compare check
;those to other hi score values from
;the hi score table list

         ldy #$00
scoreget lda score,y
scorecmp cmp (hitemp1),y
         bcc posdown
         beq nextdigit
         bcs posfound
nextdigit
         iny
         cpy #scorelen
         bne scoreget
         beq posfound
posdown  inx
         cpx #listlen
         bne nextone
         beq nohiscor

         ;Store position to storbyt
         ;for sorting hi scores to
         ;rank position.

posfound stx storbyt
         cpx #listlen-1
         beq lastscor

;Move hiscores and ranks down

         ldx #listlen-1
copynext
         lda hslo,x
         sta hitemp1
         lda hshi,x
         sta hitemp2
         lda nmlo,x
         sta nmtemp1
         lda nmhi,x
         sta nmtemp2
         dex
         lda hslo,x
         sta hitemp3
         lda hshi,x
         sta hitemp4
         lda nmlo,x
         sta nmtemp3
         lda nmhi,x
         sta nmtemp4

         ldy #scorelen-1
copyscor
         lda (hitemp3),y
         sta (hitemp1),y
         dey
         bpl copyscor

         ldy #namelen+1
copyname
         lda (nmtemp3),y
         sta (nmtemp1),y
         dey
         bpl copyname
         cpx storbyt
         bne copynext

lastscor
         ldx storbyt
         lda hslo,x
         sta hitemp1
         lda hshi,x
         sta hitemp2
         lda nmlo,x
         sta nmtemp1
         lda nmhi,x
         sta nmtemp2

         jmp nameentry

         ;Replace last hiscore with
         ;the player's hiscore

placenewscore
         ldy #scorelen-1
putscore
         lda score,y
         sta (hitemp1),y
         dey
         bpl putscore
         ldy #namelen-1
putname  lda name,y
         sta (nmtemp1),y
         dey
         bpl putname
         jsr saver
nohiscor
         jmp $4c00

;---------------------------------------
exitentry jmp saver
;---------------------------------------
;Name entry routine
;---------------------------------------

nameentry
         ldx #$00
display  lda message1,x
         jsr convert
         sta screen+(6*40),x
         lda message2,x
         jsr convert
         sta screen+(9*40),x
         lda message3,x
         jsr convert
         sta screen+(10*40),x
         lda message4,x
         jsr convert
         sta screen+(13*40),x
         inx
         cpx #40
         bne display

         ;Separators
         ldx #$00
makeseps lda #$2d
         sta $06b6,x
         lda #$0d
         sta $dab6,x
         inx
         cpx #9
         bne makeseps

         lda #0
         sta namecount
         sta buffer
         lda #5
         jsr $ffd2

         ldx #16
         ldy #14
         clc
         jsr $fff0

         cli

;---------------------------------------
;Main keyboard input routine. Only alpha
;keys and spacebar, delete and return
;---------------------------------------

keypress

         jsr $ffe4
         cmp #$0d
         beq return
         cmp #$14
         beq delete
         cmp #$20
         beq typein
         cmp #$41
         bcc keypress

         cmp #$5b
         bcs keypress

typein   jsr $ffd2
         inc namecount
         lda namecount
         cmp #9
         beq return
         jmp keypress
return   jmp grabname

delete   sta buffer
         lda namecount
         cmp #0
         beq nodelete
         lda buffer
         jsr $ffd2
         dec namecount
nodelete jmp keypress

;Register screen buffer to name
grabname
         ldx #$00
grabloop lda $06b6-40,x
         sta name,x
         inx
         cpx #$09
         bne grabloop
         jmp placenewscore

;Convert chars to correct alpha format

convert  cmp #$2f
         bcc ok
         sec
         sbc #$40
ok       rts

;Player name

b1       .byte 0
keyread  .byte 0
namecount .byte 0
buffer   .byte 0

;Hi score text

message1
         .text "            CONGRATU"
         .text "LATIONS             "
message2 .text "YOUR FINAL SCORE HAS"
         .text " AWARDED YOURSELF A "
message3
         .text "POSITION IN THE HALL"
         .text " OF FAME.           "
message4
         .text "       - PLEASE ENTER"
         .text " YOUR NAME -        "

         ;Reserved space for player
         ;name input.
name     .text "               "
;---------------------------------------

;Hi score list addresses
;low+hi byte

hslo     .byte <hi1
         .byte <hi2
         .byte <hi3
         .byte <hi4
         .byte <hi5
         .byte <hi6
         .byte <hi7
         .byte <hi8
         .byte <hi9
         .byte <hi10

hshi     .byte >hi1
         .byte >hi2
         .byte >hi3
         .byte >hi4
         .byte >hi5
         .byte >hi6
         .byte >hi7
         .byte >hi8
         .byte >hi9
         .byte >hi10

;Name list addresses
;low+hi byte

nmlo     .byte <nm1
         .byte <nm2
         .byte <nm3
         .byte <nm4
         .byte <nm5
         .byte <nm6
         .byte <nm7
         .byte <nm8
         .byte <nm9
         .byte <nm10

nmhi     .byte >nm1
         .byte >nm2
         .byte >nm3
         .byte >nm4
         .byte >nm5
         .byte >nm6
         .byte >nm7
         .byte >nm8
         .byte >nm9
         .byte >nm10
;------------------------- END ---------

