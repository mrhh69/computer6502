PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
PCR = $600C
IFR = $600D
IER = $600E

E = %10000000
RW = %01000000
RS = %00100000

; Division Addresses
value = $0200        ; 2 bytes
mod10 = $0202        ; 2 bytes
divisor = $0204      ; 2 bytes

; Multiplication Addresses
multiplication_value = $2006
multiplicant = $2008
multiplication_answer = $200A
print_bin = $200C
print_bin_value = $200E

counter = $2010
previous_counter = $2012

message = $0220      ; up to 6 bytes


  .org $8000

reset:
  lda #$f0
  sta $0200
  lda $0200


  ldx #$ff
  txs

  cli

  lda #%10000010        ; CA1 interrupt set
  sta IER
  lda #$00000000
  sta PCR




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

  lda #%00000001        ; clear display
  jsr lcd_instruction


  lda #0
  sta counter
  sta counter + 1


print_counter_loop:

  lda counter
  sta value
  lda counter + 1
  sta value + 1

  jsr binary_decimal_convert

  jsr print_message

  lda #%00000010
  jsr lcd_instruction


  jmp print_counter_loop














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





divide:      ; assumes number and mod10 are correctly initialized
  txa
  pha
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

  pla
  tax
  rts             ; Mod10 holds mod and Value holds result; A, Y register - clobbered; X register - saved





multiply:
  lda #0
  sta multiplication_answer
  sta multiplication_answer + 1

  ldx #16
multiplication_loop:

  lda multiplicant              ; If bottom bit of multiplicant 1
  and #1
  beq ignore_bit

  clc
  lda multiplication_answer     ; Add shifted value to answer
  adc multiplication_value
  sta multiplication_answer


  lda multiplication_answer + 1
  adc multiplication_value + 1
  sta multiplication_answer + 1

ignore_bit:
  lsr multiplicant + 1
  ror multiplicant
  clc
  asl multiplication_value
  rol multiplication_value + 1

  clc
  dex
  bne multiplication_loop

  rts                               ; multiplication_value contains answer, a,x,y register values changed





print_binary:
  pha

  ldy #16
  lda #0
  sta print_bin
  lda #%10000000
  sta print_bin + 1
bin_loop:
  lda print_bin_value
  and print_bin
  sta $00
  lda print_bin_value + 1
  and print_bin + 1
  ora $00

  beq if_zero
  lda #"1"
  jmp if_one
if_zero:
  lda #"0"
if_one:
  jsr print_char

  lsr print_bin + 1
  ror print_bin
  dey
  bne bin_loop

  pla
  rts








 ; LCD SUBROUTINES



print_message:
 ldx #0

print:
 lda message, x       ; load string from offset
 beq exit_print              ; if null character, stop printing
 jsr print_char
 inx
 jmp print

exit_print
  rts





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
  rts                 ; A register clobbered; Value in A register printed to display



  .byte $fd           ;NMI check sequence
  .byte $4a
  .byte $55
  .byte $3c
nmi:
  jmp irq



  .byte $a3           ;IRQ check sequence
  .byte $01
  .byte $6e
  .byte $d4
irq:
  pha
  txa
  pha
  tya
  pha
  ldx #$ff
  ldy #$ff

  inc counter
  bne exit_irq
  inc counter + 1
  bne exit_irq

  ;lda #%00000001
  ;jsr lcd_instruction



exit_irq:

  dex
  bne exit_irq
  dey
  bne exit_irq


  bit PORTA

  pla
  tay
  pla
  tax
  pla
  rti




  ;.org $fffc
  ;.word reset
  ;.word $0000
