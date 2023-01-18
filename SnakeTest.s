  include Definitions.s

  org $8000

reset:
  ldx #$ff
  txs
  cli ;enable interrupts

  lda $16
  sta HEAP_POINTER

  lda #%11111111
  sta DDRB
  sta DDRA

  lda #%00000000
  sta ACR
  lda #%11000000 ; Timer: 1,2 CB1, CB2, SR, CA1, CA2
  sta IER

  jsr initialize_lcd

; SET CHARACTERS
  jsr reset_screen


  ldy #2
  ldx #6
  lda #1
  jsr set_pixel
  jsr load_screen_glyphs
  jsr print_screen_glyphs

  lda #$ff
  sta PORTA

  ;jmp halt


  ldy #16
pixel_loop2:
  tya
  beq pixel_loop_exit
  dey
  ldx #14

pixel_loop:
  lda #1
  phx
  phy
  jsr set_pixel
  jsr load_screen_glyphs
  jsr print_screen_glyphs
  ply
  plx

  WAIT_MS 100000

  lda #0
  phx
  phy
  jsr set_pixel
  ply
  plx

  txa
  beq pixel_loop2
  dex
  jmp pixel_loop

pixel_loop_exit:

  lda #$ff
  sta PORTA

halt:
  jmp halt


  include LCDScreenDriver.s
  include 4BitLCD.s

  byte 0xfd
  byte 0x4a
  byte 0x55
  byte 0x3c

  rti

  byte 0xa3
  byte 0x01
  byte 0x6e
  byte 0xd4

  rti
