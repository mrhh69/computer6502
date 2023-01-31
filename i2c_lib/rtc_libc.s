

  include cregs.s


; From rtc.s:
  extern rtc_write
  extern rtc_read
; C Wrapper functions (for rtc.s)
  global _rtc_write
  global _rtc_read
; C utilities
  global _rtcton
  global _ntortc

  section text

; __reg("r0/r1") char * buf, __reg("x") unsigned char buf_len, __reg("a") unsigned char rtc_addr
_rtc_write:
  jsr rtc_write
  rts
; __reg("r0/r1") char * buf, __reg("x") unsigned char buf_len, __reg("a") unsigned char rtc_addr
_rtc_read:
  jsr rtc_read
  rts


; overwrites r0 (TODO: make sure that is correct int the vbcc ABI standard)
; Utility that converts from RTC's format for numbers, to regular int
; I wrote this and it worked first try (im just that good)
; Actually, it appeared like it worked first try, but actually had a small bug
_rtcton:
  tax
  and #$0f
  tay
  txa
  and #$f0
  ; (a >> 4) * 10
  ; (a >> 4) * 0b1010
  ; (a >> 4) << 3 + (a >> 4) << 1
  ; (a >> 1) + (a >> 3)
  lsr
  sta r0
  lsr
  lsr
  clc
  adc r0
  sta r0
  tya
  clc
  adc r0
  rts


; Utility that converts from unsigned char (between 0 and 99) to RTC format unsigned char
; n into r0
; kills r1 and r2
  ; bottom = a % 10
  ; top = a / 10
_ntortc:
; divide
; r0 -> value (in/out)  -> high nibble
; r1 -> mod   (out)     -> low nibble
; r2 -> divisor (const)
  stz r1
  lda #10
  sta r2

  ldx #8
.divide_loop:
  rol r0
  rol r1

  lda r1
  sec
  sbc r2
  bcc .ignore_result

  sta r1
.ignore_result:
  dex
  bne .divide_loop

  rol r0

  lda r0
  asl
  asl
  asl
  asl
  ora r1
  rts
