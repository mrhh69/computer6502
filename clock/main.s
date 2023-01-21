


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
