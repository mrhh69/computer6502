

  include cregs.s


; From rtc.s:
  extern rtc_write
  extern rtc_read
; C Wrapper functions (for rtc.s)
  global _rtc_write
  global _rtc_read

  section text
  
; __reg("a/x") char * buf, __reg("r0") unsigned char buf_len, __reg("r1") unsigned char rtc_addr
_rtc_write:
  sta $00
  stx $01
  ldx r0
  lda r1
  jsr rtc_write
  rts
; __reg("a/x") char * buf, __reg("r0") unsigned char buf_len, __reg("r1") unsigned char rtc_addr
_rtc_read:
  sta $00
  stx $01
  ldx r0
  lda r1
  jsr rtc_read
  rts
