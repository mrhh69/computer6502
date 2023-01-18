
glyph = $0300
screen = $0400   ; ordered 8 bytes per glyph, and up to down, then to the right (0, top left; 1, bottom left;) 256 bytes
screen_glyphs = $0500 ; 32 bytes
glyphs = $0520 ; up to 64 bytes
glyph_counter2 = $01




set_glyph:
  ldx #8
  ora #%01000000
  sta $00

glyph_loop:
  dex

  txa

  ora $00
  jsr lcd_instruction

  lda glyph, x
  jsr print_char

  txa
  beq glyph_end
  jmp glyph_loop

glyph_end:
  rts





load_screen_glyphs:
  lda #0
  sta glyph_counter2
  ldx #31 ; SGP

load_screen_glyphs1:
  txa
  asl
  asl
  asl
  tay  ; Y Register = SGP << 3
  lda screen, y
  ora screen + 1, y
  ora screen + 2, y
  ora screen + 3, y
  ora screen + 4, y
  ora screen + 5, y
  ora screen + 6, y
  ora screen + 7, y  ; Load, Or values at X, X + 8

  bne load_screen_glyphs2             ; If not Equal, then

  ; If Equal
  lda #32
  ;txa
  ;adc #"0"
  sta screen_glyphs, x
  jmp load_screen_glyphs3

load_screen_glyphs2:
  lda glyph_counter2
  ;txa
  ;adc #"0"
  sta screen_glyphs, x

  txa
  asl
  asl
  asl
  tay  ; Y Register = SGP << 3
  lda screen, y
  sta glyph
  lda screen + 1, y
  sta glyph  + 1
  lda screen + 2, y
  sta glyph  + 2
  lda screen + 3, y
  sta glyph  + 3
  lda screen + 4, y
  sta glyph  + 4
  lda screen + 5, y
  sta glyph  + 5
  lda screen + 6, y
  sta glyph  + 6
  lda screen + 7, y
  sta glyph  + 7

  phx
  lda glyph_counter2
  asl
  asl
  asl
  jsr set_glyph
  plx

  inc glyph_counter2

load_screen_glyphs3:
  txa
  beq load_screen_glyphs4
  dex
  jmp load_screen_glyphs1

load_screen_glyphs4:
  rts





print_screen_glyphs:
  lda #2
  jsr lcd_instruction


  ldx #0
print_screen_glyphs1:
  lda screen_glyphs, x
  jsr print_char
  inx
  txa
  cmp #$10
  bne print_screen_glyphs2

  lda #%11000000
  jsr lcd_instruction
print_screen_glyphs2:
  txa
  cmp #$20
  bne print_screen_glyphs1

  lda #%10001111
  jsr lcd_instruction
  lda glyph_counter2
  adc #"0"
  jsr print_char

  rts

reset_screen:
  ldx #$ff
reset_screen1:


  lda #0
  sta screen, x
  txa
  beq reset_screen2
  dex
  jmp reset_screen1

reset_screen2:
  rts




set_pixel:
  phx
  phy

  pha
  lda HP
  clc
  adc #5
  sta HP

  pla
  phx
  ldx HP

  sta $04
  eor #%11111110
  sta $05


  tya
  and #%00001000
  asl
  asl
  asl
  asl
  sta HS - 5, x
  tya
  and #%111
  ora HS - 5, x
  sta HS - 5, x

  ; y killed

  plx
  txa
  jsr divide8

  ldx HP
  sta HS - 4, x
  tya

  asl
  asl
  asl
  ora HS - 5, x
  tay

  lda #4
  sta $06

set_pixel1:
  lda HS - 4, x
  cmp $06
  bne set_pixel2

  lda screen, y
  and $05
  ora $04
  sta screen, y
  jmp set_pixel_exit
set_pixel2:
  sec
  rol $05
  asl $04
  dec $06
  bmi set_pixel_exit
  jmp set_pixel1

set_pixel_exit:
  lda HP
  sec
  sbc #5
  sta HP

  ply
  plx
  rts


divide8:
  ; a / 5
  ldy #0

divide81:
  sec
  sbc #5
  bmi divide82
  iny
  jmp divide81

divide82:
  adc #5
  rts




; Glyph: SBBBBCCC
; S = Y >> 3
; B = X / 5
; C = Y & %111
