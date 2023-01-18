E = %10000000
RW = %01000000
RS = %00100000


initialize_lcd:
  lda #%00111000   ; Mode set
  jsr lcd_instruction

  lda #%00001110   ; Display on; Cursor on; Cursor blink off
  jsr lcd_instruction


  lda #%00000110
  jsr lcd_instruction

  lda #%00000001
  jsr lcd_instruction

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
