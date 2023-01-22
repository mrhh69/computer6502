PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
PCR = $600C
IFR = $600D
IER = $600E


counter = $2010

message = $0220      ; up to 6 bytes


  .org $8000

reset:
  lda #$f0
  sta $0200
  lda $0200


  ldx #$ff
  txs

  lda #%10000010        ; CA1 interrupt set
  sta IER
  lda #$00000000
  sta PCR




  lda #%11111111   ; All pins on port B output
  sta DDRB

  lda #%11100000   ; Top 3 pins on port A output
  sta DDRA


  jsr initialize_lcd



  lda #1
  sta counter
  lda #0
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


  .include Math.s


  .include Utilities.s






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



  .include 4BitLCD.s



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

  lda counter
  sta multiplication_value
  lda counter + 1
  sta multiplication_value + 1

  lda #3
  sta multiplicant
  lda #0
  sta multiplicant + 1

  jsr multiply

  lda multiplication_answer
  sbc #1
  bne not_one
  lda multiplication_answer + 1
  bne not_one

  lda #%00000001
  jsr lcd_instruction

not_one:
  lda multiplication_answer
  sta counter
  lda multiplication_answer + 1
  sta counter + 1

exit_irq:
  lda #%00000001
  jsr lcd_instruction

  bit PORTA

  pla
  tay
  pla
  tax
  pla
  rti
