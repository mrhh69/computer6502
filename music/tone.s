


  org $8000
reset:
  sei
  lda #$ff
  sta DDRA
  sta DDRB
  sta PORTA

  lda #%10100000 ; T2 -> interrupts enabled
  sta IER
  lda #%11000000 ; T1 square wave out on PB7; T2 one-shot
  sta ACR

  ;lda #(1702 & $ff) ; pb7 invert every 1702 microseconds (D4 tone)
  ;sta T1CL
  ;lda #(1702 >> 8) ; pb7 invert every 1702 microseconds (D4 tone)
  ;sta T1CH


  cli

do_tone_loop:
  lda #<tones
  sta $00
  lda #>tones
  sta $01
get_tone:
  ldy #0
  lda ($00), y
  beq do_tone_loop ; start from beginning
  cmp #2
  beq no_tone    ; stop tone


  lda #%11000000 ; tell t1 to out pb7
  sta ACR

  ldy #1
  lda ($00), y
  sta T1CL
  iny
  lda ($00), y
  sta T1CH
  bra wait_tone
no_tone:
  lda #0
  sta ACR  ; t1 no pb7; t2 still one-shot
wait_tone:


  ; first, low 16 bits of wait
  ldy #3
  lda ($00), y
  sta T2CL
  iny
  lda ($00), y
  sta T2CH
  wai


  ldy #5       ; do wait using timer2
  lda ($00), y
  sta $02
tone_time2:
  beq tone_time_done
; re-init timer2 through every loop (find more efficient way?)
  lda #$ff
  sta T2CL
  sta T2CH
  wai

  dec $02
  bra tone_time2
tone_time_done:
; increment tone pointer (by 6 == sizeof(tone))
  lda $00
  clc
  adc #6
  sta $00
  bcc .cc
  inc $01
.cc:
  bra get_tone

loop:
  wai
  bra loop



nmi:
  rti
irq:
  pha
  lda #$ff
  sta IFR
  pla
  rti



  include "music.s"


tones:
; Tetris bass clef:
BPM = 125
  repeat 4
  QUARTER TONE_C4
  endrepeat

  repeat 4
  EIGHTH TONE_F2
  EIGHTH TONE_F3
  endrepeat
  repeat 4
  EIGHTH TONE_D2
  EIGHTH TONE_D3
  endrepeat
  repeat 4
  EIGHTH TONE_E2
  EIGHTH TONE_E3
  endrepeat
  repeat 4
  EIGHTH TONE_F2
  EIGHTH TONE_F3
  endrepeat

  ; Section2:
  QUARTER_REST
  repeat 4
  EIGHTH TONE_B2
  EIGHTH TONE_B3
  endrepeat
  repeat 4
  EIGHTH TONE_A2
  EIGHTH TONE_A3
  endrepeat
  repeat 4
  EIGHTH TONE_E2
  EIGHTH TONE_E3
  endrepeat
  repeat 4
  EIGHTH TONE_E2
  EIGHTH TONE_E3
  endrepeat

  ; Section3: (no more bass clef, instead: bottom treble clef)
  HALF TONE_C5
  HALF TONE_A4
  HALF TONE_B4
  HALF TONE_G4
  HALF TONE_A4
  HALF TONE_F4
  HALF TONE_E4 ; Or is it DS4 ????
  HALF TONE_G4
  HALF TONE_C5
  HALF TONE_A4
  HALF TONE_B4
  HALF TONE_G4

  QUARTER TONE_C5
  QUARTER TONE_C5
  QUARTER TONE_E5
  QUARTER TONE_E5
  HALF TONE_E5



  byte 2
  word 0
  word $0000
  byte 30

  byte 0

; Tetris:
;BPM = 120
  QUARTER TONE_E5
  EIGHTH TONE_B4
  EIGHTH TONE_C5
  EIGHTH TONE_D5
  SIXTEENTH TONE_E5
  SIXTEENTH TONE_D5
  EIGHTH TONE_C5
  EIGHTH TONE_B4

  QUARTER TONE_A4
  EIGHTH TONE_A4
  EIGHTH TONE_C5
  QUARTER TONE_E5
  EIGHTH TONE_D5
  EIGHTH TONE_C5

  QUARTER TONE_B4
  EIGHTH TONE_B4
  EIGHTH TONE_C5
  QUARTER TONE_D5
  QUARTER TONE_E5
  QUARTER TONE_C5
  QUARTER TONE_A4
  HALF TONE_A4

  byte 2
  word 0
  word $0000
  byte 30

  byte 0


; Badiniere:
;BPM = 100
  EIGHTH TONE_B5   ; Bum-bada
  SIXTEENTH TONE_D6
  SIXTEENTH TONE_B5

  EIGHTH TONE_FS5  ; Bum-bada
  SIXTEENTH TONE_B5
  SIXTEENTH TONE_FS5

  EIGHTH TONE_D5   ; Bum-bada
  SIXTEENTH TONE_FS5
  SIXTEENTH TONE_D5

  QUARTER TONE_B4   ; Baah


  SIXTEENTH TONE_FS4  ; Badadada
  SIXTEENTH TONE_B4
  SIXTEENTH TONE_D5
  SIXTEENTH TONE_B4

  SIXTEENTH TONE_CS5  ; dadadada
  SIXTEENTH TONE_B4
  SIXTEENTH TONE_CS5
  SIXTEENTH TONE_B4

  SIXTEENTH TONE_AS4  ; dadadada
  SIXTEENTH TONE_CS5
  SIXTEENTH TONE_E5
  SIXTEENTH TONE_CS5

  EIGHTH TONE_D5    ; da-dum
  EIGHTH TONE_B4

  byte 2
  word 0
  word $0000
  byte 30

  byte 0
; Hot cross buns:
  QUARTER TONE_B4
  QUARTER TONE_A4
  HALF TONE_G4
  QUARTER TONE_B4
  QUARTER TONE_A4
  HALF TONE_G4

  EIGHTH TONE_G4
  EIGHTH TONE_G4
  EIGHTH TONE_G4
  EIGHTH TONE_G4
  EIGHTH TONE_A4
  EIGHTH TONE_A4
  EIGHTH TONE_A4
  EIGHTH TONE_A4

  QUARTER TONE_B4
  QUARTER TONE_A4
  HALF TONE_G4


  ; 2 second wait and then repeat:
  byte 2 ; type (1 = tone; 2 = wait; 0 = end)
  word 0 ; 1000000 / frequency
  word $ffff ; Timer countdown
  byte 30    ; multiplier

  byte 0 ; end of song


  include "Definitions.s"


  org $fffa
  VECTORS
