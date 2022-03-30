;--------------------------------------
;Para Lander DX
;Written by Richard Bayliss
;
;(C) 2021 The New Dimension
;--------------------------------------
;Disk Access

hiscorestart = $4520
hiscoreend = $469f

titlescreen = $4800
showtable = $4c00
system   = $0ffe
ntsctimer = $0fff

         *= $5700

;--------------------------------------
;Hi score saver
;======================================
mainsave

         jsr saver

         jmp showtable
saver
         lda #$00
         sta $fb
         sta $fc
         lda #$00
         sta $d020
         sta $d021
         lda #$0b
         sta $d011
         ldx $ba
         cpx #$08
         bcc skipsave
         lda #$0f
         tay
         jsr $ffba
         jsr resetdrive

         lda #dnamelen
         ldx #<dname;Overwrite filename
         ldy #>dname
         jsr $ffbd
         jsr $ffc0
         lda #$0f
         jsr $ffc3
         jsr $ffcc
         lda #$0f
         ldx $ba
         tay
         jsr $ffba
         jsr resetdrive

         lda #fnamelen
         ldx #<fname;Save filename
         ldy #>fname
         jsr $ffbd
         lda #$fb
         ldx #<hiscorestart
         ldy #>hiscorestart
         stx $fb
         sty $fc
         ldx #<hiscoreend
         ldy #>hiscoreend
         jsr $ffd8
skipsave
         lda #0
         sta $fb
         sta $fc
         lda #$1b
         sta $d011
         rts

;---------------------------------------
;Loading hi-score data
;---------------------------------------
         *= $5780 ;
         ;  ^^^^^ This is the jump
         ;        address for the whole
         ;        game project after
         ;        combining and packing

         lda #252
         sta $0328

         lda $02a6
         sta system
         lda #0
         sta ntsctimer
loadhiscore

         lda #$00
         sta $d020
         sta $d021
         lda #$0b
         sta $d011
         ldx $ba
         cpx #$08
         bcc skipload
         lda #$0f
         tay
         jsr $ffba
         lda #fnamelen
         ldx #<fname
         ldy #>fname
         jsr $ffbd
         lda #$00
         jsr $ffd5
         bcc loaded
         jsr saver
loaded
skipload lda #$00
         sta $fb
         sta $fc
         lda #$1b
         sta $d011
         jmp titlescreen

;--------------------------------------
;Initialise disk drive
;--------------------------------------

resetdrive
         lda #$00
         ldx #<initdrive
         ldy #>initdrive
         jsr $ffbd
         jsr $ffc0
         lda #$0f
         jsr $ffc3
         jsr $ffcc
         lda #0
         sta $fb
         sta $fc
         rts

;---------------------------------------
;Filename properties
;---------------------------------------
initdrive .text "i:"
dname    .text "s:"
fname    .text "pldx.hi"
fnamelen = *-fname
dnamelen = *-dname
;---------------------------------------

