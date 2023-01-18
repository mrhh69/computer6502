


  .include "Definitions.s"
  .org $8000

reset:
  ldx #$ff
  txs
  sei

  lda #$ff
  sta DDRA
  sta DDRB

  lda #%00000000
  sta ACR
  lda #%00000001 ;
  sta PCR
  lda #%11000010 ; S/CB, T1, T2, CB1, CB2, SR, CA1, CA2
  sta IER
  lda #0
  sta IFR

  cli
  jsr initialize_lcd
  cli
  lda #1
  sta PORTA

  ;lda #%11000010 ; S/CB, T1, T2, CB1, CB2, SR, CA1, CA2
  ;sta IER

  lda #<pausemessage
  sta $00
  lda #>pausemessage
  sta $01
  jsr do_pause

  lda #1
  jsr lcd_instruction

  ldx #0
print_loop:
  lda message, x
  beq print_out
  jsr print_char
  inx
  bra print_loop
print_out:


  lda #$ff
  sta PORTA


halt:
  stp
  ;jmp halt



PAUSED = $10

do_pause:
  pha
  phy
  lda #1
  sta PAUSED
  lda #%00000001           ; reset
  jsr lcd_instruction

  ;cli

  ldy #0
do_pause_print:
  lda ($00), y
  beq do_pause_wait
  jsr print_char
  iny
  jmp do_pause_print

do_pause_wait:
  cli
do_pause_loop:
  wai
  lda PAUSED
  beq do_pause_exit
  jmp do_pause_loop

do_pause_exit:
  ply
  pla
  rts



message: .asciiz  "Hello, world!                           init completed."
pausemessage: .asciiz "Paused!"

CURSOR_ON = 1
CURSOR_BLINK = 0
  .include "4BitLCD.s"


irq:
  pha


  lda IFR
  sta PORTA

  bit #%01000000
  beq not_timer1

  lda #%01000000
  sta IFR
  jmp irq_out

not_timer1:
  bit #%00000010
  beq not_ca1

  lda #%00000010
  sta IFR
  lda #0
  sta PAUSED

  jmp irq_out

not_ca1:
  lda #1
  sta PORTB
  jmp halt

irq_out:
  pla
  rti

nmi:
  rti

  .org $fffa
  .word nmi
  .word reset
  .word irq
