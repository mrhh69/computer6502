
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
  global _button_states
  global _prev_states
; from runner.c
  extern _do_init
  extern _do_periodic
  extern _do_button_press
  extern _mode

; PB6 (->timer2) oscillating at 32768
; ticks for each loop
; (buttons updated, handlers called, tick incremented)
TIMER2_COUNT = (32768/64)
CURSOR_ON=0
CURSOR_BLINK=0

; ticks of timer2 runouts until periodic functions are run
PERIODIC_TICKS = 8
; ticks until buffer is flushed
; NOTE: I set ticks = ticks & (BUF_FLUSH_TICKS-1);
;   -> which assumes that this is larger than periodic ticks (maybe add checks?)
BUF_FLUSH_TICKS = 32
; = max(all tick checks)
MAX_TICKS=BUF_FLUSH_TICKS

NUM_MODES=2

BUTTON_CLR=%01000000
BUTTON_MS =%10000000

  section text

pre_init:
  lda #((%11)|(%0000 << 2)|(BUTTON_CLR)) ; BUTTON_MS is input
  sta VIA1_DDRA
  lda #(~$40)     ; PB6 (RTC sqwout) is input
  sta VIA1_DDRB
  lda #$ff
  sta VIA2_DDRA
  sta VIA2_DDRB

  lda #0
  sta VIA1_PORTA
  sta VIA1_PORTB
  sta VIA2_PORTA
  sta VIA2_PORTB

  lda #(~INT_EN & $ff)
  sta IER
  lda #(INT_EN|INT_T1)
  sta IER
  lda #(T1_ONESHOT)
  sta ACR

  cli
  lda #(CURSOR_ON<<1)|(CURSOR_BLINK)
  jsr initialize_lcd

  jsr rtc_init

; all pre-initialization complete, let crt.s do C initialization now
  rts



; Enter the main timer2 loop
; There are actually 3 loops happening here
; 1 tick = 1 runout of timer2 = TIMER2_COUNT/32768
; -> one,  (ticks=1)         that updates button every timer2 runout
; -> two,  (PERIODIC_TICKS)  that runs periodic code based on current mode
; -> three,(BUF_FLUSH_TICKS) that runs rtc_buf_flush
_main:
; clear button states:
  lda BUTTON_PORT
  ora #BUTTON_CLR
  sta BUTTON_PORT
  eor #BUTTON_CLR
  sta BUTTON_PORT
; enable and start timer2
; enable button interrupts
  lda #(T2_COUNTPB6)
  ora ACR
  sta ACR
  lda #(CA1_POS|CB1_POS)
  sta PCR
  lda #(INT_EN|INT_T1|INT_T2|INT_CA1|INT_CB1)
  sta IER


  lda #'s'
  jsr print_char

  jsr _rtc_buf_flush

  jsr _do_init ; intial mode init

  lda #'d'
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

; ----timer2 loop----
.wai_loop:
  wai
; wait for interrupted flag to be set
  lda _timer2_interrupted
  beq .wai_loop
  sei
; ----do periodic stuff here----

  jsr update_buttons

; check ticks
  lda _ticks
  inc
  and #(BUF_FLUSH_TICKS-1)
  sta _ticks                ; store because BUF_FLUSH > PERIODIC
  bne .no_buf_flush

  cli
  jsr _rtc_buf_flush
  sei
.no_buf_flush:

; check ticks (for periodic)
  lda _ticks
  and #(PERIODIC_TICKS-1)
  bne .no_periodic

; do ticks periodic stuff (do_periodic)


  cli
  jsr _do_periodic
  sei

; show current mode (on top of everything else)
  lda #($80|15)
  jsr lcd_instruction
  lda _mode
  clc
  adc #'0'
  jsr print_char
.no_periodic:

; ----end periodic stuff----
  cli
  bra .loop



; check (and update) button states
update_buttons:
; the fact that this is done every 1/8 seconds is good for debouncing
  lda _mode_select_edge ; check MS button
  beq .not_new

; ---- mode select pressed ----
  lda #0
  sta _mode_select_edge
; update mode select value/edge
  lda BUTTON_PORT
  and #BUTTON_MS
  beq .low
.pos:
; MS state is 1 (trigger next interrupt on negative edge)
  lda PCR
  and #~CA1_POS
  sta PCR

; Only go to next mode on positive edge
; next mode (mode++; if (mode > NUM_MODES) mode = 0;)
  lda _mode
  inc
  cmp #NUM_MODES
  bcc .nonz
  lda #0
.nonz:
  sta _mode
; C function do_init on new mode
  cli
  jsr _do_init
  sei

  bra .out
.low:
; MS state is 0 (trigger next interrupt on positive edge)
  lda PCR
  ora #CA1_POS
  sta PCR
.out:
.not_new:

  if 0
; ---- check other buttons ----
  lda _button_edge ; UDLR buttons
  beq .no_button_edge
; clear interrupt
  lda BUTTON_PORT
  ora #BUTTON_CLR
  sta BUTTON_PORT
  eor #BUTTON_CLR
  sta BUTTON_PORT
; read and store new states:
  lda _button_states
  sta _prev_states
  lda BUTTON_PORT
  and #(%1111 << 2)
  lsr
  lsr
  sta _button_states

  cli
  jsr _do_button_press
  sei
  endif
.no_button_edge:
  rts




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
; number of timer2 interrupts
_ticks: reserve 1
; flag set after ca1 interrupt (positive edge)
_mode_select_edge: reserve 1
;_mode_select_val: reserve 1
_button_edge: reserve 1
_button_states: reserve 1
_prev_states: reserve 1
