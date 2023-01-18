
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

  section .text.entry
reset:
  sei
  lda #$ff
  sta DDRA
  sta DDRB

  lda #(~INT_EN & $ff)
  sta IER
  lda #(INT_EN|INT_T1)
  sta IER
  lda #(T1_ONESHOT)
  sta ACR

  cli
  jsr initialize_lcd


; RTC:
  ; Setup idle state:
  lda #(SDA | SCL)
  sta PORTA
  WAIT_US 10000

  lda #$02
  sta $00
  lda #$00
  sta $01
  lda #$00
  ldx #1
  jsr read_rtc

  lda $02
  and #$80
  ;beq .no_reset
  ; Reset RTC to defaults, as it is stopped currently
  lda #<rtc_default
  sta $00
  lda #>rtc_default
  sta $01
  lda #$00
  ldx #8
  jsr write_rtc

.no_reset:
; SETUP Timer2 to countdown 4096hz pulses on PB6
  ;lda #(T1_ONESHOT|T2_COUNTPB6)
  ;sta ACR

date_loop:
  ;lda #(1024 & $ff)
  ;sta T2CL
  ;lda #(1024 >> 8)
  ;sta T2CH
  ;cli
  ;wai
  ; (&buf[8] = 0x0020;)
  lda #$02
  sta $00
  lda #$00
  sta $01
  lda #$00
  ldx #8
  cli
  jsr read_rtc


  ldx $02 + 0
  jmp checkthatflag

  ldx $02 + 2
  txa
  lsr
  lsr
  lsr
  lsr
  clc
  adc #'0'
  jsr print_char
  txa
  and #$f
  clc
  adc #'0'
  jsr print_char
  lda #':'
  jsr print_char

  ldx $02 + 1
  txa
  lsr
  lsr
  lsr
  lsr
  clc
  adc #'0'
  jsr print_char
  txa
  and #$f
  clc
  adc #'0'
  jsr print_char
  lda #':'
  jsr print_char

  ldx $02 + 0
  txa
  lsr
  lsr
  lsr
  lsr
  and #$7
  clc
  adc #'0'
  jsr print_char
  txa
  and #$f
  clc
  adc #'0'
  jsr print_char
  lda #'.'
checkthatflag:
  txa
  and #$80
  beq .notstop
  lda #'S'
  jsr print_char
  stp
.notstop:

  lda #%1 ; Reset display
  jsr lcd_instruction
  jmp date_loop

done:
  bra done


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


; char defaults[8]
rtc_default:
  byte $02 ; Seconds (top bit is CH, clock halt)
  byte $15
  byte $18 ; Hours (bit 6 high is 12-hour mode select)
  byte $01 ; Day of the week?
  byte $24 ; Day of the month
  byte $12 ; month
  byte $22 ; year
  byte %00010001 ; control register (OUT 0 0 SQWE 0 0 RS1 RS0)

  include 4BitLCD.s




nmi:
  rti
irq:
  pha
  lda IFR
  cmp #INT_T1
  beq .timer1
  cmp #INT_T2
  beq .timer2
.timer1:
  lda #INT_T1
  sta IFR
  pla
  rti
.timer2:
  stp
  lda #INT_T2
  sta IFR
  pla
  rti





  section .text.vectors
  word nmi
  word reset
  word irq
