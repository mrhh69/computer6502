
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

; NOTE: after some debugging, it turns out read_rtc does indeed hang on first bus failure
; Maybe do some run throughs in an emulator in read_rtc to fully diagnose problem

  include Definitions.s

  global rtc_init
  global rtc_write
  global rtc_read
  ;extern _putc


  section text

rtc_init:
; Setup idle state:
  lda #(SDA | SCL)
  sta PORTA
  WAIT_US 10000
  rts

; Buffer pointer in $00, buffer length in X register
; RTC read start address in A register, Y register destroyed
; NOTE: 2 ack's (plus 8 in the loop) to check
; ack handling is similar here as in rtc_read -> reference the comments there
rtc_write:
  phx
  pha
  jsr put_start
  ldx #RTC_WRITE
  jsr put_byte
  jsr get_ack
  bne .bad_ack1
  plx
  phx
  jsr put_byte
  jsr get_ack
  bne .bad_ack2

  pla
  plx
  phx ; preserve stack
  pha
  ldy #0
.loopx:
  phx
  lda ($00), y
  tax
  phy
  jsr put_byte
  ply
  jsr get_ack
  bne .bad_ack3
  plx
  iny
  dex
  bne .loopx
  jsr put_stop
  rts

.bad_ack3:
  plx
.bad_ack1:
.bad_ack2:
  jsr put_stop
  pla
  plx
  jmp rtc_write


; Buffer pointer in $00, buffer length in X register
; RTC read start address in A register, Y register destroyed
; NOTE: 3 ack's to check, after writing command bytes to the RTC
rtc_read:
  phx
  pha
  jsr put_start
  ldx #RTC_WRITE
  jsr put_byte
  jsr get_ack
  bne .bad_ack1
  plx ; pull A register as X register
  phx ; preserve stack w/ A and X (in case a bad_ack necessitates a function re-entry)
  jsr put_byte
  jsr get_ack
  bne .bad_ack2

  jsr put_stop
; NOTE: this seems to be a problem point
; (from previous tests, this was where the SPI bus seemed to fail)
  jsr rtcdelay;WAIT_US 10000
  jsr put_start
  ldx #((RTC_ADDR<<1) | 1)
  jsr put_byte
  jsr get_ack
  bne .bad_ack3
; Now, read into buffer
  pla ; this pla does nothing, but is necessary to preserve stack (as mentioned on above phx)
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

.bad_ack1:
.bad_ack2:
.bad_ack3:
  ;lda #'0'
  ;jsr _putc
; put RTC back into a stop condition in preparation for a re-try
  jsr put_stop
  pla
  plx
; RTC returned NAK when it shouldn't have, try again
  jmp rtc_read


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
  jsr wait_low
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

; returns ack into A register
get_ack:
  lda #SCL
  sta DDRA
  jsr get_bit
  lda #(SCL | SDA)
  sta DDRA
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
  jsr wait_low ; NOTE: waitus macro protects all registers
  ora #SCL
  sta PORTA
  jsr wait_high
  eor #SCL
  sta PORTA
  rts
; Assumes SCL = 0 SDA = configured for input
; Returns into X register
get_bit:
  jsr wait_low
  lda #SCL
  sta PORTA
  jsr wait_high
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


wait_low:
  WAIT_US LOW_US
  rts
wait_high:
  WAIT_US HIGH_US
  rts

rtcdelay:
  repeat 20
  nop
  endrepeat
  rts
