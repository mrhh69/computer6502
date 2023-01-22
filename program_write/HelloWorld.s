  include Definitions.s
  org $8000

reset:
  ldx #$ff
  txs
  sei

  lda #$ff
  sta DDRB
  sta DDRA

  lda #(INT_EN|INT_T1)
  sta IER
  lda #(T1_ONESHOT)
  sta ACR

  cli
  jsr initialize_lcd

  ldx #0
print_loop:
  lda message, x
  beq halt
  jsr print_char
  inx
  jmp print_loop


halt:
  stp


irq:
  pha
  lda IFR
  bit #INT_T1
  bne .timer1

  stp

.timer1:
  lda #INT_T1
  sta IFR
  pla
  rti



message:  asciiz "Hello, word!                            "

  include 4BitLCD.s


  org $fffa
  word reset
  word reset
  word irq
