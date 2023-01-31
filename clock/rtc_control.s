
; Making RTC I/O buffered, so as to reduce bus usage
; (especially when it is unnecessary)
; And limit updates to/from RTC only when changes happen
;   -> call _rtc_buf_flush to flush to/from RTC


  include Definitions.s
  include cregs.s


LCD_BUF_SIZE = $10  ; lcd RAM is $00 - $3f

; from rtc.s
  extern rtc_write
  extern rtc_read

  global _rtc_buf_read
  global _rtc_buf_write
  global _rtc_buf_flush
  global _rtc_buf

  section text


; Instead of reading from RTC, copy RTC buffer contents into buffer
; *buf -> r0
; addr -> A
; size -> X
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

_rtc_buf_write:
; Update buffer dirty bounds
; (bounds that will have to be written to RTC)
  cmp dirty_high
  bpl .not_high
  sta dirty_high
.not_high:
  cmp dirty_low
  bmi .not_low
  sta dirty_low
.not_low:
; copy buf -> rtc_buf
  tay
.loop:
  lda _rtc_buf, y
  sta (r0), y
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
  lda dirty_high  ; NOTE: this is very unsafe, if high-low is negative, bad things happen
  clc ; clc in order to add 1 to result
  sbc dirty_low
  beq .buf_clean
  tax
  lda dirty_low
  jsr rtc_write
.buf_clean: ; no need to flush to rtc

; Read from RTC into buffer
  lda #<_rtc_buf
  ldx #>_rtc_buf
  sta r0
  stx r1
  lda #0
  ldx #LCD_BUF_SIZE
  jsr rtc_read

  rts


  section bss
_rtc_buf:
  reserve LCD_BUF_SIZE
dirty_low:  reserve 1
dirty_high: reserve 1
