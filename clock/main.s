


  include cregs.s
  include defs.s


; from lcd lib
  extern initialize_lcd
; from rtc lib
  extern rtc_init

; NOTE:
; crt.s Includes the .text.entry and .text.vectors for us
; All we need to define here are
; ANOTHER NOTE:
; _main does not HAVE to be a C function, as long as it
; adheres to the abi, it is a valid C function
; (in this case _main is in assembly)
  global pre_init         ; called before anything
  global _main            ; Called after C initialization
  global interrupt_timer1 ; interrupts
  global interrupt_timer2
  global interrupt_ca1
  global interrupt_cb1

; for main.c
  global _rtcton
; from runner.c
  extern _do_init
  extern _do_periodic
  extern _mode

; PB6 oscillating at 32768
TIMER2_COUNT = 32768/8
CURSOR_ON=0
CURSOR_BLINK=0

NUM_MODES=2

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


; Enter the main timer2 loop
_main:
; enable and start timer2
  lda #(T2_COUNTPB6)
  ora ACR
  sta ACR
  lda #(CA1_POS|CB1_POS)
  sta PCR
  lda #(INT_EN|INT_T1|INT_T2|INT_CA1|INT_CB1)
  sta IER


  jsr _rtc_buf_flush

  jsr _do_init ; intial mode init

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
  sei
; do periodic stuff here:

; check (and update) button states
; the fact that this is done every 1/8 seconds is good for debouncing
  lda _mode_select_edge ; check MS button
  beq .not_new
; mode select pressed
  lda #0
  sta _mode_select_edge
; next mode (mode = (mode + 1 == NUM_MODES) ? 0 : mode + 1)
  lda _mode
  inc
  cmp #NUM_MODES
  bne .nonz
  lda #0
.nonz:
  sta _mode
; do init on new mode
  jsr _do_init
.not_new:

; mode has been updated, do periodic
; show current mode
  lda #($80|15)
  jsr lcd_instruction
  lda _mode
  clc
  adc #'0'
  jsr print_char


  jsr _do_periodic

  cli
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
  lda #1
  sta _mode_select_edge
  rts
interrupt_cb1:
  lda #1
  sta _button_edge
  rts

  section bss
; flag set after timer2 interrupt
_timer2_interrupted: reserve 1
; flag set after ca1 interrupt (positive edge)
_mode_select_edge: reserve 1
_button_edge: reserve 1
