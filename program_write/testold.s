

  include Definitions.s
  org $8000

CURSOR_ON=1
CURSOR_BLINK=0

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

  lda #(~INT_EN & $ff)
  sta VIA1_IER
  lda #(INT_EN|INT_T1)
  sta VIA1_IER
  lda #(T1_ONESHOT)
  sta VIA1_ACR

  ;lda #(CURSOR_ON<<1)|CURSOR_BLINK
  cli
  jsr initialize_lcd




halt:
  stp


E =  %10000000
RW = %00000010
RS = %00000001
DATA_BASE = 2
; cursor flags passed through accumulator
; (CURSOR_ON << 1) | CURSOR_BLINK
initialize_lcd:
; RESET SEQUENCE
  lda #$02
  sta VIA1_PORTB
  WAIT_US (50000); More than 40 ms

  ;lda #$FF
  ;sta VIA1_T1CL
  ;sta VIA1_T1CH
  ;wai

  lda #$03
  sta VIA1_PORTB
  lda #E
  sta LCD_PORT

  lda #(%0011 << DATA_BASE)
  sta LCD_PORT
  ora #E
  sta LCD_PORT
  eor #E
  sta LCD_PORT

  WAIT_US (5000) ; More than 4.1 ms

  lda #(%0011 << DATA_BASE)
  sta LCD_PORT
  ora #E
  sta LCD_PORT
  eor #E
  sta LCD_PORT

  WAIT_US (200) ; More than 100 us

  lda #(%0011 << DATA_BASE)
  sta LCD_PORT
  ora #E
  sta LCD_PORT
  eor #E
  sta LCD_PORT

  WAIT_US (200)

; Initialize
  lda #(%0010 << DATA_BASE)           ; function set 4-bit
  sta LCD_PORT
  ora #E
  sta LCD_PORT
  eor #E
  sta LCD_PORT




function1:
  ;-----checkflag----
  lda #(E|RW|RS) ; configure data bus as input
  sta LCD_DDR

.lcd_busy:
  lda #RW
  sta LCD_PORT
  lda #(RW | E)
  sta LCD_PORT

  lda LCD_PORT

  and #(%1000 << DATA_BASE)
  tax

  lda #RW
  sta LCD_PORT
  lda #(RW | E)
  sta LCD_PORT

  txa
  bne .lcd_busy

  lda #RW
  sta LCD_PORT

  lda #(E|RW|RS|($f << DATA_BASE))
  sta LCD_DDR

; X destroyed
; -----------lcd_instruction********
  lda #%00101000           ; function set (DataLength4Bit=0, NLines2=1, Font=0, 5x8)
  ldx #0


; ----lcd_write-----
  tay

  and #$f0 ; NOTE: fix this bit-fiddling port storing stuff
  lsr
  lsr
  sta LCD_PORT
  lda #E
  ora LCD_PORT
  sta LCD_PORT
  eor #E
  sta LCD_PORT

  tya
  and #$0f
  asl
  asl

  sta LCD_PORT
  lda #E
  ora LCD_PORT
  sta LCD_PORT
  eor #E
  sta LCD_PORT

  tya





function2:
  ;-----checkflag----
  lda #(E|RW|RS) ; configure data bus as input
  sta LCD_DDR

.lcd_busy:
  lda #RW
  sta LCD_PORT
  lda #(RW | E)
  sta LCD_PORT

  lda LCD_PORT

  and #(%1000 << DATA_BASE)
  tax

  lda #RW
  sta LCD_PORT
  lda #(RW | E)
  sta LCD_PORT

  txa
  bne .lcd_busy

  lda #RW
  sta LCD_PORT

  lda #(E|RW|RS|($f << DATA_BASE))
  sta LCD_DDR

; X destroyed
; -----------lcd_instruction********
  lda #(CURSOR_ON<<1)|CURSOR_BLINK
  ora #%00001100; | (CURSOR_ON << 1) | CURSOR_BLINK ; Display on


; ----lcd_write-----
  tay

  and #$f0 ; NOTE: fix this bit-fiddling port storing stuff
  lsr
  lsr
  sta LCD_PORT
  lda #E
  ora LCD_PORT
  sta LCD_PORT
  eor #E
  sta LCD_PORT

  tya
  and #$0f
  asl
  asl

  sta LCD_PORT
  lda #E
  ora LCD_PORT
  sta LCD_PORT
  eor #E
  sta LCD_PORT

  tya




  lda #%00000110           ; Entry mode set
  jsr lcd_instruction

  lda #%00000001           ; reset
  jsr lcd_instruction

  lda #$01
  sta VIA1_PORTB
  rts






check_busy_flag:
  pha
  phx
  lda #(E|RW|RS) ; configure data bus as input
  sta LCD_DDR

lcd_busy:
  lda #RW
  sta LCD_PORT
  lda #(RW | E)
  sta LCD_PORT

  lda LCD_PORT

  and #(%1000 << DATA_BASE)
  tax

  lda #RW
  sta LCD_PORT
  lda #(RW | E)
  sta LCD_PORT

  txa
  bne lcd_busy

  lda #RW
  sta LCD_PORT

  lda #(E|RW|RS|($f << DATA_BASE))
  sta LCD_DDR

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


; X -> (flags sent)
;
lcd_write:
  tay

  and #$f0 ; NOTE: fix this bit-fiddling port storing stuff
  lsr
  lsr
  sta LCD_PORT
  txa
  ora #E
  ora LCD_PORT
  sta LCD_PORT
  eor #E
  sta LCD_PORT

  tya
  and #$0f
  asl
  asl

  sta LCD_PORT
  txa
  ora #E
  ora LCD_PORT
  sta LCD_PORT
  eor #E
  sta LCD_PORT

  tya
  rts












irq:
  pha
  lda VIA1_IFR
  bit #INT_T1
  bne .timer1

  ;sta VIA1_PORTB
  ;lda #$aa
  ;sta VIA1_PORTA
  ;stp
  pla
  rti

.timer1:
  lda #INT_T1
  sta VIA1_IFR
  pla
  rti


  org $fffa
  word reset
  word reset
  word irq
