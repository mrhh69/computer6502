PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003


message = $0220      ; up to 6 bytes


  .org $8000

reset:

  ldx #$ff
  txs

  lda #%11111111   ; All pins on port B output
  sta DDRB

  lda #%11100000   ; Top 3 pins on port A output
  sta DDRA


  jsr initialize_lcd



  lda number
  sta multiplication_value
  lda number + 1
  sta multiplication_value + 1

  lda divider
  sta multiplicant
  lda divider + 1
  sta multiplicant + 1

  jsr multiply

  lda multiplication_answer
  sta value
  lda multiplication_answer + 1
  sta value + 1



  jsr binary_decimal_convert





print_message:
  ldx #0

print:
  lda message, x       ; load string from offset
  beq halt              ; if null character, stop printing
  jsr print_char
  inx
  jmp print




halt:
  jmp halt

number: .word 1057
divider: .word 31
string: .asciiz "Hello, word!                            Yes - I forgot the L"



binary_decimal_convert:
  lda #0
  sta message

  lda #10
  sta divisor
  lda #0
  sta divisor + 1

repeat:
  lda #0
  sta mod10
  sta mod10 + 1

  jsr divide


  lda mod10
  adc #"0"
  ;jsr print_char
  jsr push_char     ; if not then push character and repeat

  lda value
  ora value + 1
  beq bcd_exit

  jmp repeat

bcd_exit:
  rts                  ; Message contains asciiz decimal equivalent of binary starting value



  .include Math.s





 ; LCD SUBROUTINES



push_char:
  pha
  ldy #0
push_loop:

  lda message, y
  tax
  pla
  sta message, y   ; Start character in a register, prev character in x
  iny
  txa
  pha
  bne push_loop

  pla
  sta message, y

  rts

  .include 4BitLCD.s
