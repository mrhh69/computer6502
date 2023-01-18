PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

E = %10000000
RW = %01000000
RS = %00100000

value = $0200        ; 2 bytes
mod10 = $0202        ; 2 bytes
divisor = $0204      ; 2 bytes
message = $0206      ; up to 6 bytes


  .org $8000

reset:
  lda #$f0
  sta $0200
  lda $0200


  ldx #$ff
  txs

  lda #%11111111   ; All pins on port B output
  sta DDRB

  lda #%11100000   ; Top 3 pins on port A output
  sta DDRA


  lda #%00111000   ; Mode set
  jsr lcd_instruction

  lda #%00001110   ; Display on; Cursor on; Cursor blink off
  jsr lcd_instruction


  lda #%00000110
  jsr lcd_instruction

  lda #%00000001
  jsr lcd_instruction






divide_init:
  lda number
  sta value
  lda number + 1
  sta value + 1

  lda divider
  sta divisor
  lda divider + 1
  sta divisor + 1

  lda #0
  sta mod10
  sta mod10 + 1

  jsr divide       ; Value contains (number / divider); mod10 contains mod

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

number: .word 1728
divider: .word 108
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
  beq bcd_exit         ; if divided fully (result 0) then print result
  adc #"0"
  jsr push_char     ; if not then push character and repeat
  jmp repeat

bcd_exit:
  rts                  ; Message contains asciiz decimal equivalent of binary starting value


divide:      ; assumes number and mod10 are correctly initialized
  clc
  ldx #16

divide_loop:
  rol value
  rol value + 1
  rol mod10
  rol mod10 + 1

  sec
  lda mod10
  sbc divisor
  tay
  lda mod10 + 1
  sbc divisor + 1
  bcc ignore_result

  sty mod10
  sta mod10 + 1
ignore_result:
  dex
  bne divide_loop

  rol value
  rol value + 1

  rts             ; Mod10 holds mod and Value holds result




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




lcd_busy_check:
  pha

  lda #%00000000     ; PORTB input
  sta DDRB

lcd_busy:
  lda #RW
  sta PORTA
  lda #(RW | E)     ; Read instruction
  sta PORTA
  lda PORTB          ; Read output

  and #%10000000     ; Check busy flag
  bne lcd_busy

  lda #RW
  sta PORTA

  lda #%11111111    ; PORTB Output
  sta DDRB

  pla
  rts


lcd_instruction:
  jsr lcd_busy_check

  sta PORTB

  lda #0           ; Write
  sta PORTA
  lda #E           ; Enable
  sta PORTA
  lda #0
  sta PORTA
  rts

print_char:
  jsr lcd_busy_check
  sta PORTB        ; Output Letter
  lda #RS          ; Select Character RAM
  sta PORTA
  lda #(E | RS)    ; Write
  sta PORTA
  lda #RS
  sta PORTA

  rts

  ;.org $fffc
  ;.word reset
  ;.word $0000
