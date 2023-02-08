
; Making RTC I/O buffered, so as to reduce bus usage
; (especially when it is unnecessary)
; And limit updates to/from RTC only when changes happen
;   -> call _rtc_buf_flush to flush to/from RTC


  include defs.s
  include cregs.s


RTC_BUF_SIZE = $10  ; lcd RAM is $00 - $3f

; from rtc.s
  extern rtc_write
  extern rtc_read


; aliases:
  global _rtc_read
  global _rtc_write
; functions:
  global _rtc_buf_read
  global _rtc_buf_write
  global _rtc_buf_flush
  global _rtc_buf

  section text


; Instead of reading from RTC, copy RTC buffer contents into buffer
; *buf -> r0
; addr -> A
; size -> X
_rtc_read:
_rtc_buf_read:
; copy rtc_buf -> buf
  stx r2
  tax
  ldy #0
.loop:
  lda _rtc_buf, x
  sta (r0), y
  iny
  inx
  dec r2
  bne .loop

  rts


; Write into RTC buffer, and update dirty

_rtc_write:
_rtc_buf_write:
; Update buffer dirty bounds
; (bounds that will have to be written to RTC)
; low -> if addr (a) is lower               (gt is comp)
; high -> if addr (a) + len(x) is higher
  cmp dirty_low   ; ((unsigned char)A < (unsigned char)dirty_low) according to vbcc
  bcs .not_low
  sta dirty_low
.not_low:
  sta r2
  txa
  clc
  adc r2
  cmp dirty_high  ; ((u8)A > (u8)dirty_high) according to vbcc
  bcc .not_high
  beq .not_high
  sta dirty_high
.not_high:

; (r2 = a = rtc address)
; (x = length)
; copy buf -> rtc_buf
  lda r2
  stx r2
  tax
  ldy #0
.loop:             ; BUG: write buffer read was not starting at zero
  lda (r0), y
  sta _rtc_buf, x
  iny
  inx
  dec r2
  bne .loop

  rts


_rtc_buf_flush:
; Write into RTC between dirty_low and dirty_high
  ;lda #'f'
  ;jsr print_char
  lda #<_rtc_buf;_rtc_defaults
  ldx #>_rtc_buf;_rtc_defaults
  sta r0
  stx r1
  lda dirty_high  ; NOTE: this is very unsafe, if (high-low) is negative, bad things happen
  sec
  sbc dirty_low
  beq .buf_clean
  tax

  ;lda #'w'
  ;jsr print_char
  ;lda dirty_high
  ;clc
  ;adc #'0'
  ;jsr print_char
  ;lda dirty_low
  ;clc
  ;adc #'0'
  ;jsr print_char

  lda dirty_low
  jsr rtc_write

  lda #0
  sta dirty_high
  lda #127
  sta dirty_low
.buf_clean: ; no need to flush to rtc

  ;lda #'r'
  ;jsr print_char

; Read from RTC into buffer
  lda #<_rtc_buf
  ldx #>_rtc_buf
  sta r0
  stx r1
  lda #0
  ldx #RTC_BUF_SIZE
  jsr rtc_read

  rts


  section bss
_rtc_buf:
  reserve RTC_BUF_SIZE
dirty_low:  reserve 1  ; lowest byte in buffer that has been written to
dirty_high: reserve 1  ; highest byte in buffer + 1
