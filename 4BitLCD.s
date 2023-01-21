
E =  %10000000
RW = %00000010
RS = %00000001
DATA_BASE = 2 ; Number of bits to shift left, to write data
; NOTE: DATA_BASE doesn't work completely (see lcd_write)

; External variables: CURSOR_ON; CURSOR_BLINK



; cursor flags passed through accumulator
; (CURSOR_ON << 1) | CURSOR_BLINK
initialize_lcd:
; RESET SEQUENCE
  pha
  WAIT_US (50000) ; More than 40 ms

  lda #(%0011 << DATA_BASE)
  sta PORTB
  ora #E
  sta PORTB
  eor #E
  sta PORTB

  WAIT_US (5000) ; More than 4.1 ms

  lda #(%0011 << DATA_BASE)
  sta PORTB
  ora #E
  sta PORTB
  eor #E
  sta PORTB

  WAIT_US (200) ; More than 100 us

  lda #(%0011 << DATA_BASE)
  sta PORTB
  ora #E
  sta PORTB
  eor #E
  sta PORTB

  ; sei
  WAIT_US (200)

; Initialize
  lda #(%0010 << DATA_BASE)           ; function set 4-bit
  sta PORTB
  ora #E
  sta PORTB
  eor #E
  sta PORTB

  lda #%00101000           ; function set (DataLength4Bit=0, NLines2=1, Font=0, 5x8)
  jsr lcd_instruction

  pla
  and #%00000011
  ora #%00001100; | (CURSOR_ON << 1) | CURSOR_BLINK ; Display on
  jsr lcd_instruction

  lda #%00000110           ; Entry mode set
  jsr lcd_instruction

  lda #%00000001           ; reset
  jsr lcd_instruction

  rts

check_busy_flag:
  pha
  phx
  lda #(E|RW|RS) ; configure data bus as input
  sta DDRB

lcd_busy:
  lda #RW
  sta PORTB
  lda #(RW | E)
  sta PORTB

  lda PORTB

  and #(%1000 << DATA_BASE)
  tax

  lda #RW
  sta PORTB
  lda #(RW | E)
  sta PORTB

  txa
  bne lcd_busy

  lda #RW
  sta PORTB

  lda #(E|RW|RS|($f << DATA_BASE))
  sta DDRB

  plx
  pla
  rts



lcd_instruction:
  phx
  phy
  php
  sei

  jsr check_busy_flag

  ldx #0
  jsr lcd_write

  plp
  ply
  plx
  rts



print_char:
  phx
  phy
  php
  sei

  jsr check_busy_flag

  ldx #RS
  jsr lcd_write

  plp
  ply
  plx
  rts


; X -> (flags sent)
;
lcd_write:
  tay

  and #$f0 ; NOTE: fix this bit-fiddling port storing stuff
  lsr
  lsr
  sta PORTB
  txa
  ora #E
  ora PORTB
  sta PORTB
  eor #E
  sta PORTB

  tya
  and #$0f
  asl
  asl

  sta PORTB
  txa
  ora #E
  ora PORTB
  sta PORTB
  eor #E
  sta PORTB

  tya
  rts
