

  include defs.s

  section .text.entry

reset:
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


  section rodata
message:  asciiz "Hello, word!                            "


  section .text.vectors
  word reset
  word reset
  word irq
