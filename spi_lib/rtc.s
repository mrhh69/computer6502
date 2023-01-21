
; PORTA:
SCL = %01
SDA = %10

START_DELAY_US = 100
STOP_DELAY_US = 100
LOW_US  = 20
HIGH_US = 20
RTC_ADDR = %1101000
RTC_WRITE = ((RTC_ADDR<<1)|0)
RTC_READ  = ((RTC_ADDR<<1)|1)



  include Definitions.s

  section text


; Buffer pointer in $00, buffer length in X register
; RTC read start address in A register, Y register destroyed
write_rtc:
  phx
  pha
  jsr put_start
  ldx #RTC_WRITE
  jsr put_byte
  jsr get_ack
  plx
  jsr put_byte
  jsr get_ack

  plx
  ldy #0
.loopx:
  phx
  lda ($00), y
  tax
  phy
  jsr put_byte
  ply
  jsr get_ack
  plx
  iny
  dex
  bne .loopx
  jsr put_stop
  rts

; Buffer pointer in $00, buffer length in X register
; RTC read start address in A register, Y register destroyed
read_rtc:
  phx
  pha
  jsr put_start
  ldx #RTC_WRITE
  jsr put_byte
  jsr get_ack
  plx ; pull A register as X register
  jsr put_byte
  jsr get_ack

  jsr put_stop
  jsr rtcdelay;WAIT_US 10000
  jsr put_start
  ldx #((RTC_ADDR<<1) | 1)
  jsr put_byte
  jsr get_ack
; Now, read into buffer
  plx
  ldy #0
.loopx:
  phx
  phy
  jsr get_byte
  ply
  plx
  sta ($00), y
  iny
  dex
  beq .noack
  ; Do ACK here
  lda #0
  jsr put_bit
  bra .loopx
.noack:
  ; Do NAK here
  lda #1
  jsr put_bit
  jsr put_stop
  rts


; RTC calls:
put_start:
  lda #SCL
  sta PORTA
  jsr rtcdelay;WAIT_US START_DELAY_US ;(start hold)
  lda #0
  sta PORTA
  jsr rtcdelay ; (start hold)
  rts
put_stop:
  jsr rtcdelay;WAIT_US LOW_US
  lda #SCL
  sta PORTA
  jsr rtcdelay;WAIT_US STOP_DELAY_US
  lda #(SCL|SDA)
  sta PORTA
  rts

; A returns byte
; Y register destroyed, X register destroyed
get_byte:
  lda #SCL
  sta DDRA
  lda #0
  ldy #8
.loopy:
  pha
  jsr get_bit
  ;ldx #1
  pla
  asl
  cpx #0
  beq .notone
  ora #1
.notone:
  dey
  bne .loopy
  ldy #(SCL | SDA)
  sty DDRA
  rts


; A, Y destroyed; X holds byte to write
put_byte:
  ldy #8  ; 8 bits
.loopy:
  txa
  and #$80
  jsr put_bit
  ; do loop stuff:
  txa
  asl
  tax
  dey
  bne .loopy
  rts

get_ack:
  lda #SCL
  sta DDRA
  jsr get_bit
  lda #(SCL | SDA)
  sta DDRA
  txa
  clc
  adc #'0'
  jsr print_char
  txa
  rts
; if BE, then writes  0, else 1
; Destroys A register
; Assumes SCL = 0 SDA = configured for output
put_bit:
  beq .notone
  lda #SDA
  bra .clockup
.notone:
  lda #0
.clockup:
  sta PORTA
  jsr rtcdelay;WAIT_US LOW_US ; NOTE: WAIT_US protects all registers
  ora #SCL
  sta PORTA
  jsr rtcdelay;WAIT_US HIGH_US
  eor #SCL
  sta PORTA
  rts
; Assumes SCL = 0 SDA = configured for input
; Returns into X register
get_bit:
  jsr rtcdelay;WAIT_US LOW_US
  lda #SCL
  sta PORTA
  jsr rtcdelay;WAIT_US HIGH_US
  lda PORTA
  and #SDA
  beq .notone
  ldx #1
  bra .isone
.notone:
  ldx #0
.isone:
  lda #0
  sta PORTA
  rts



rtcdelay:
  repeat 100
  nop
  endrepeat
  rts
