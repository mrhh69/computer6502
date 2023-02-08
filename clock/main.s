


  include cregs.s
  include defs.s


; from lcd lib
  extern initialize_lcd
; from rtc lib
  extern rtc_init

; NOTE:
; crt.s Includes the .text.entry and .text.vectors for us
; All we need to define here are
  global pre_init         ; called before anything
  global interrupt_timer1 ; interrupt handlers
  global interrupt_timer2
  global interrupt_ca1

; from clock.c
  extern _update_lcd_clock

  global _timer2_loop
; PB6 oscillating at 32768, 4096/32768 = 1/8 hz
TIMER2_COUNT = 4096


CURSOR_ON=0
CURSOR_BLINK=0

  section text

pre_init:
  lda #(~$40)
  sta VIA1_DDRB
  lda #$ff
  sta VIA1_DDRA
  sta VIA2_DDRA
  sta VIA2_DDRB

  lda #(~INT_EN & $ff)
  sta IER
  lda #(INT_EN|INT_T1)
  sta IER
  lda #(T1_ONESHOT)
  sta ACR

  cli
  lda #(CURSOR_ON<<1)|(CURSOR_BLINK)
  jsr initialize_lcd

; RTC init
  jsr rtc_init
; all pre-initialization complete, it's C time
  rts


; Enter a timer2 loop (periodically calling update_lcd_clock)
_timer2_loop:
; enable and start timer2
  lda #(INT_EN|INT_T1|INT_T2)
  sta IER
  lda #(T2_COUNTPB6)
  ora ACR
  sta ACR


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

  jsr _rtc_buf_flush

  bra .loop


interrupt_timer2:
; set interrupted flag
  lda #1
  sta _timer2_interrupted
  rts
interrupt_timer1:
  rts
interrupt_ca1:
  rts

  section bss
_timer2_interrupted: reserve 1
