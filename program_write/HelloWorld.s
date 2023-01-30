

  include Definitions.s
  org $8000

reset:
  sei

  lda #$ff
  sta VIA1_DDRB
  sta VIA1_DDRA
  sta VIA2_DDRB
  sta VIA2_DDRA
  lda #0
  sta VIA1_PORTB
  sta VIA1_PORTA
  sta VIA2_PORTB
  sta VIA2_PORTA

  lda #(INT_EN|INT_T1)
  sta VIA1_IER
  lda #(T1_ONESHOT)
  sta VIA1_ACR

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
  lda VIA1_IFR
  bit #INT_T1
  bne .timer1

  stp

.timer1:
  lda #INT_T1
  sta VIA1_IFR
  pla
  rti



message:  asciiz "Hello, word!                            "

  include 4BitLCD.s


  org $fffa
  word reset
  word reset
  word irq
