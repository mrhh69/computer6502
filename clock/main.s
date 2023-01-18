



  include Definitions.s


; from rtc lib
  extern rtc_init
  extern rtc_read
  extern rtc_write

; NOTE:
; crt.s Includes the .text.entry and .text.vectors for us
; All we need to define here are
  global pre_init         ; called before anything
  global interrupt_timer1 ; interrupts
  global button_press


  section text

pre_init:
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

; RTC init
  jsr rtc_init
; all pre-initialization complete, it's C time
  rts

interrupt_timer1:
  rts
button_press:
  rts



  lda #$02
  sta $00
  lda #$00
  sta $01
  lda #$00
  ldx #1
  jsr rtc_read

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
  jsr rtc_write

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
  ; (&buf[8] = 0x0002;)
  lda #$02
  sta $00
  lda #$00
  sta $01
  lda #$00
  ldx #8
  cli
  jsr rtc_read


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
