


  include cregs.s
  include Definitions.s


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
  global _button_states
  global _prev_states
; from runner.c
  extern _do_init
  extern _do_periodic
  extern _do_button_press
  extern _mode

; PB6 oscillating at 32768
TIMER2_COUNT = 32768/8
CURSOR_ON=0
CURSOR_BLINK=0

NUM_MODES=2

BUTTON_CLR=%01000000; PORTA

  section text

pre_init:
  lda #%11000011
  sta DDRA
  lda #$ff
  sta DDRB
  lda #0
  sta PORTA
  sta PORTB

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
; clear button states:
  lda PORTA
  ora #BUTTON_CLR
  sta PORTA
  eor #BUTTON_CLR
  sta PORTA
; enable and start timer2
; enable button interrupts
  lda #(T2_COUNTPB6)
  ora ACR
  sta ACR
  lda #(CA1_POS|CB1_POS)
  sta PCR
  lda #(INT_EN|INT_T1|INT_T2|INT_CA1|INT_CB1)
  sta IER


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

  lda _button_edge ; UDLR buttons
  beq .no_button_edge
; clear interrupt
  lda PORTA
  ora #BUTTON_CLR
  sta PORTA
  eor #BUTTON_CLR
  sta PORTA
; read and store new states:
  lda _button_states
  sta _prev_states
  lda PORTA
  and #(%1111 << 2)
  lsr
  lsr
  sta _button_states

  jsr _do_button_press
.no_button_edge:

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
  bra .loop

; overwrites r0 (TODO: make sure that is correct int the vbcc ABI standard)
; Utility that converts from RTC's format for numbers, to regular int
; I wrote this and it worked first try (im just that good)
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
; TODO: maybe idk
;_ntortc:
  ; bottom = a % 10
  ; top = a / 10


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
_button_states: reserve 1
_prev_states: reserve 1
