
; PORTA:
SCL = %01
SDA = %10

START_DELAY_US = 1000
STOP_DELAY_US = 1000
LOW_US  = 5000
HIGH_US = 5000
RTC_ADDR = %1101000



  include Definitions.s

  section .text.entry
reset:
  sei
  lda #$ff
  sta DDRA
  sta DDRB

  lda #($80 | INT_T1)
  sta IER
  lda #0
  sta IFR

  lda #(T1_ONESHOT)
  sta ACR

  cli
  jsr initialize_lcd

  lda #'h'
  jsr print_char



  ; RTC:
  ; start condition:
  lda #(SCL | SDA)
  sta PORTA
  WAIT_US 100000

  ; Register pointer transfer:
  jsr put_start

  ; SCL: 1 SDA: 0
  ldx #((RTC_ADDR<<1) | 0)
  jsr put_byte

  jsr get_ack
  clc
  adc #'0'
  jsr print_char

  ldx #$00 ; Address of register pointer
  jsr put_byte

  jsr get_ack
  clc
  adc #'0'
  jsr print_char

  jmp .done

  jsr put_stop
  WAIT_US 10000
  ; Read transfer:
  jsr put_start
  ldx #((RTC_ADDR<<1) | 1)
  jsr put_byte

  jsr get_ack
  clc
  adc #'0'
  jsr print_char


  lda #SCL
  sta DDRA
  ldy #8
.loopy:
  jsr get_bit
  txa
  clc
  adc #'0'
  jsr print_char
  dey
  bne .loopy


.done:
  stp
  bra .done

; RTC calls:
put_start:
  lda #(SCL)
  sta PORTA
  WAIT_US START_DELAY_US
  lda #0
  sta PORTA
  rts
put_stop:
  WAIT_US LOW_US
  lda #SCL
  sta PORTA
  WAIT_US STOP_DELAY_US
  lda #(SCL|SDA)
  sta PORTA
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
  WAIT_US LOW_US ; NOTE: WAIT_US protects all registers
  ora #SCL
  sta PORTA
  WAIT_US HIGH_US
  eor #SCL
  sta PORTA
  rts
; Assumes SCL = 0 SDA = configured for input
; Returns into X register
get_bit:
  WAIT_US LOW_US
  lda #SCL
  sta PORTA
  WAIT_US HIGH_US
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




  include 4BitLCD.s




nmi:
  rti
irq:
  pha
  lda #INT_T1
  sta IFR
  pla
  rti





  section .text.vectors
  word nmi
  word reset
  word irq
