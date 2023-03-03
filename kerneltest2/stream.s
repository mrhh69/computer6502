
  include kdefs.s
  include emu.s

  global brk_putc

  global _streams


  section text

; stream no in A
; data in X
brk_putc:
  phy
; put stream struct ptr in kr0
  repeat 4
  asl
  endrepeat
  adc #<_streams
  sta kr0
  lda #>_streams
  adc #0
  sta kr0+1

  ldy #2
  lda (kr0), y     ; check size
  cmp #8
  bcs .buf_full

  ldy #1
  lda (kr0), y  ; stream start ptr into a
  iny
  clc
  adc (kr0), y  ; add size to get end
  and #8-1      ; wrap around cicrular buffer (size 8)
  clc
  adc #3        ; offset into stream.buf
  tay
  txa
  sta (kr0), y
  ; increment size and store back
  ldy #2
  lda (kr0), y
  inc
  sta (kr0), y
  cmp #8
  bcc .nog
  DISPLAY "streambuf just filled"
  ;PAUSE
; force empty here:
  ldy #0
  lda (kr0), y
  bit #STREAM_LCD
  beq .lcd_empty

  DISPLAY "not implemented: streambuf force empty"
  PAUSE
  JAM

.lcd_empty:
  jsr lcd_empty
  ;DISPLAY "lcd_empty returned"
  ;UPDATE
.nog:

  ply
  rts


.buf_full:
  DISPLAY "WRITING INTO A STREAMBUF THAT IS FULL"
  PAUSE
  JAM



; stream struct ptr in kr0
; returns 1 on success (into a)
; returns 0 on failure (no bytes to write)
lcd_empty:
; check size byte
  ldy #2
  lda (kr0), y
  cmp #2
  bcc .no_empty
; subtract 2 and store back
  dec
  dec
  sta (kr0), y
; put start in x
  ldy #1
  lda (kr0), y
  tax
; get 2 bytes out of buffer into kr1
  ;txa
  and #8-1
  clc
  adc #3
  tay
  lda (kr0), y
  sta kr1

  txa
  inc
  and #8-1
  clc
  adc #3
  tay
  lda (kr0), y
  sta kr1+1
; update start byte to original + 2 (wrap around)
  txa
  inc
  inc
  and #8-1
  ldy #1
  sta (kr0), y

; take action on these bytes
; check command byte first
  lda kr1+1
  ldx kr1
  cpx #LCD_C_LCDINS
  beq .lcdins
  cpx #LCD_C_PUTC
  beq .putc

  DISPLAY "BAD LCD COMMAND BYTE (x)"
  PAUSE
  JAM

.lcdins:
  DISPLAY "lcdins stream"
  UPDATE
  bra .emptied

.putc:
  DISPLAY "putc stream"
  UPDATE
  bra .emptied

.emptied:
  lda #1
  rts
.no_empty:
  lda #0
  rts






  section bss

 ; struct stream
 ;   unsigned char flag;
 ;   unsigned char start;
 ;   unsigned char size;
 ;   char buf[8];
 ;   char pad[5];
_streams:
  reserve 16*NUM_STREAMS
