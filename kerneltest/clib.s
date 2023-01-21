


  ;section _
PORTB = $6000
PORTA = $6001
DDRB =  $6002
DDRA =  $6003
T1CL =  $6004 ;T1 counter latches
T1CH =  $6005
T1LL =  $6006 ; T1 latches
T1LH =  $6007
T2LC =  $6008
T2LH =  $6009
SR =    $600A
ACR =   $600B ; Auxillary Control Register (T1, T2, SR, )
PCR =   $600C ; CA,CB Control (interrupt lines)
IFR =   $600D ; Interrupt Flags Register
IER =   $600E ; Interrupt Enable Register





; WAIT MICROSECONDS
  macro WAIT_US
  pha
  lda #(\1 & $ff)
  sta T1CL
  lda #((\1 & $ff00) >> 8)
  sta T1CH
  wai

  if ((\1 >> 16) != 0)
  phy
  ldy #(\1 >> 16)
WAIT_US_\@:
  lda #$FF
  sta T1CL
  sta T1CH
  wai

  dey
  bne WAIT_US_\@

WAIT_US_END_\@:
  ply
  endif
  pla
  endmacro



  extern r0
  global _putc
  global _lcd_init
  global _lcd_instruction
  global _pause
  global button_press ; from crt.s

  global lcd_instruction
  global print_char

  section bss
_did_press: reserve 1

  section text

; wait for ca1 interrupt (button press)
_pause:
  stz _did_press
.loop:
  cli
  wai
  lda _did_press
  beq .loop
  rts
; ca1:
button_press:
  lda #1
  sta _did_press
  rts

; (__reg("a") char c)
_putc:
  jsr print_char
  rts
; (__reg("a") char cursor_on, __reg("r0") char cursor_blink)
; NOTE: for some reason, vbcc passes chars as 16 bit ints
_lcd_init:
  asl ; cursor_on
  ora r0 ; cursor_blink
  jsr initialize_lcd
  rts
; (__reg("a") char ins)
_lcd_instruction:
  jsr lcd_instruction
  rts

  include 4BitLCD.s
