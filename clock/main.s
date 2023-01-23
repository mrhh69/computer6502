


  include cregs.s
  include Definitions.s


; from lcd lib
  extern initialize_lcd
; from rtc lib
  extern rtc_init

; NOTE:
; crt.s Includes the .text.entry and .text.vectors for us
; All we need to define here are
  global pre_init         ; called before anything
  global interrupt_timer1 ; interrupts
  global interrupt_timer2
  global button_press

; from clock.c
  extern _update_lcd_clock
; for main.s
  global _timer2_loop
  global _rtcton
; PB6 oscillating at 32768, 4096/32768 = 1/8 hz
TIMER2_COUNT = 4096
CURSOR_ON=0
CURSOR_BLINK=0

  section text

pre_init:
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
  lda #(CURSOR_ON<<1)|(CURSOR_BLINK)
  jsr initialize_lcd

; RTC init
  jsr rtc_init
; all pre-initialization complete, it's C time
  rts


; Enter a timer2 loop (periodically calling update_lcd_clock)
_timer2_loop:
; enable and start timer2
  lda #(INT_EN|INT_T1|INT_T2) ; FUCK THESE GODDAMN TYPOS (I FORGOT A #)
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
  ;lda #'p'
  ;jsr print_char

  bra .loop

; overwrites r0
; Utility that converts from RTC's format for numbers, to regular int
_rtcton:
  tax
  and #$0f
  tay
  txa
  and #$f0
  ; (a >> 4) * 10
  ; (a >> 4) * 0b1010
  ; (a >> 4) << 3 | (a >> 4) << 1
  ; (a >> 1) | (a >> 3)
  lsr
  sta r0
  lsr
  lsr
  ora r0
  sta r0
  tya
  clc
  adc r0
  rts



interrupt_timer2:
; set interrupted flag
  lda #1
  sta _timer2_interrupted
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
