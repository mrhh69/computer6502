


  include cregs.s
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
  global interrupt_timer2
  global button_press

; from clock.c
  extern _update_lcd_clock

  global _timer2_loop
; PB6 oscillating at 32768, 4096/32768 = 1/8 hz
TIMER2_COUNT = 4096

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


; Enter a timer2 loop (periodically calling update_lcd_clock)
_timer2_loop:
; enable and start timer2
  lda (INT_EN|INT_T2)
  sta IER
  lda #(T2_COUNTPB6)
  ora ACR
  sta ACR

  lda #'s'
  jsr print_char

.loop:
; set flag to 0
  lda #0
  sta _timer2_interrupted
; start timer2
  lda #<TIMER2_COUNT
  sta T2CL
  lda #>TIMER2_COUNT
  sta T2CH
.wai_loop:
  wai
; wait for interrupted flag to be set
  lda _timer2_interrupted
  beq .wai_loop
; do periodic stuff here:
  jsr _update_lcd_clock

  bra .loop


interrupt_timer2:
; set interrupted flag
  lda #1
  sta _timer2_interrupted
  lda #'2'
  jsr print_char
; reset timer 2
  lda #<TIMER2_COUNT
  sta T2CL
  lda #>TIMER2_COUNT
  sta T2CH
  rts
interrupt_timer1:
  rts
button_press:
  rts

  section bss
_timer2_interrupted: reserve 1

  section text

; TODO: move all wrapper functions into their respective folders (spi_lib/)
; Wrapper functions (for rtc)
  global _rtc_write
  global _rtc_read

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



; Wrapper functions (for lcd)
  global _putc
  global _lcdins


; __reg("a") char character
_putc:
  jsr print_char
  rts
; __reg("a") char instruction
_lcdins:
  jsr lcd_instruction
  rts


  include 4BitLCD.s
