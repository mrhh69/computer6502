
  include cregs.s
  include defs.s



  org $8000
  org $8400

reset:
  lda #<rtcinbuf
  ldx #>rtcinbuf
  sta rtcin
  stx rtcin + 1

  lda #0
  sta dirty_low
  sta dirty_high

  byte DISPLAY
  asciiz "flush1"
  jsr _rtc_buf_flush


  lda #<$2000
  ldx #>$2000
  sta r0
  stx r1
  lda #0
  ldx #8
  byte UPDATE
  byte DISPLAY
  asciiz "read"
  byte PAUSE
  jsr _rtc_read

  byte UPDATE
  byte PAUSE


  lda #$69
  sta $2000+7

  lda #<$2000
  ldx #>$2000
  sta r0
  stx r1
  lda #7
  ldx #1
  byte UPDATE
  byte DISPLAY
  asciiz "write"
  byte PAUSE
  jsr _rtc_write

  byte DISPLAY
  asciiz "flush2"
  jsr _rtc_buf_flush





  byte JAM




LCD_BUF_SIZE = $10


; Instead of reading from RTC, copy RTC buffer contents into buffer
; *buf -> r0
; addr -> A
; size -> X
_rtc_read:
_rtc_buf_read:
; copy rtc_buf -> buf
  tay
.loop:
  lda _rtc_buf, y
  sta (r0), y
  iny
  dex
  bne .loop

  rts


; Write into RTC buffer, and update dirty

_rtc_write:
_rtc_buf_write:
; Update buffer dirty bounds
; (bounds that will have to be written to RTC)
; low -> if addr (a) is lower
; high -> if addr (a) + len(x) is higher
  cmp dirty_low
  bcc .not_low
  sta dirty_low
.not_low:
  sta r2
  txa
  clc
  adc r2
  cmp dirty_high  ; TODO: check this math (VERY IMPORTANT)
  bcc .not_high
  sta dirty_high
.not_high:

; copy buf -> rtc_buf
  ldy r2
.loop:
  lda (r0), y
  sta _rtc_buf, y
  iny
  dex
  bne .loop

  rts


_rtc_buf_flush:
; Write into RTC between dirty_low and dirty_high
  lda #<_rtc_buf
  ldx #>_rtc_buf
  sta r0
  stx r1
  lda dirty_high  ; NOTE: this is very unsafe, if (high-low) is negative, bad things happen
  sec
  sbc dirty_low
  beq .buf_clean
  tax
  lda dirty_low
  byte UPDATE
  byte DISPLAY
  asciiz "rtc_write"
  byte PAUSE
  jsr rtc_write
  lda #0
  sta dirty_high
  sta dirty_low
.buf_clean: ; no need to flush to rtc

; Read from RTC into buffer
  lda #<_rtc_buf
  ldx #>_rtc_buf
  sta r0
  stx r1
  lda #0
  ldx #LCD_BUF_SIZE
  byte UPDATE
  byte DISPLAY
  asciiz "rtc_read"
  byte PAUSE
  jsr rtc_read

  rts


rtc_read:
  tay
.loop:
  lda (rtcin), y
  sta (r0), y
  iny
  dex
  bne .loop

  rts

rtc_write:
  tay
.loop:
  lda (r0), y
  byte UPDATE
  ;byte DISPLAY
  ;asciiz "write byte to RTC"
  iny
  dex
  bne .loop

  rts



_rtc_buf  =$1000
dirty_low =$1000+LCD_BUF_SIZE
dirty_high=$1001+LCD_BUF_SIZE
rtcin     =$04

rtcinbuf:
  repeat 32
  byte 1
  byte 2
  byte 3
  byte 4
  byte 5
  byte 6
  byte 7
  byte 8
  endrepeat






  org $fffa
  word reset
  word reset
  word reset
