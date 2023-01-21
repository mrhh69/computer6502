  include Definitions.s
  .org $8000

reset:
  ldx #$ff
  txs

  lda #%11111111
  sta DDRB
  sta DDRA

  jsr initialize_lcd

  ldx #0
print_loop:
  lda message, x
  beq halt
  jsr print_char
  inx
  jmp print_loop


halt:
  jmp halt


message:  .asciiz "Hello, word!                            "

  .include 4BitLCD.s
