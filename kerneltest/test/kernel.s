


  include cregs.s
  include edefs.s
  include kdefs.s


  global interrupt_timer1 ; for crt.s (interrupts)
  global interrupt_ca1
  global handler_timer1_call
  global handler_ca1_call

  extern _call_handlers
  ;extern _new_handler
  extern _new_handler_ca1
  extern _new_handler_timer1

  extern _handlers_ca1
  extern _handlers_timer1

  global _goin


  section text


_goin:
  ldx #<_dumca1
  ldy #>_dumca1
  lda #HANDLER_CA1_BRK
  brk
  byte $02
  ldx #<_dumt1
  ldy #>_dumt1
  lda #HANDLER_T1_BRK
  brk
  byte $02

  byte DISPLAY
  asciiz "hello"
  byte PAUSE

  jsr interrupt_ca1
  byte UPDATE
  byte PAUSE
  jsr interrupt_timer1

_done:
  jmp _done


_dumt1:
  byte DISPLAY
  asciiz "dumt1"
  byte UPDATE
  byte PAUSE
  rts
_dumca1:
  byte DISPLAY
  asciiz "dumca1"
  rts



interrupt_ca1:
  pha
  phx
  phy
  byte DISPLAY
  asciiz "intca1"
  lda #<_handlers_ca1
  ldx #>_handlers_ca1
  ; I AM SUCH A FUCKING GENIUS HOW DID I FORGET TO STORE A/X TO r0/r1 WTFFF
  sta r0
  stx r1
  byte UPDATE
  byte PAUSE
  jsr _call_handlers
  ply
  plx
  pla
  rts
interrupt_timer1:
  pha
  phx
  phy
  byte DISPLAY
  asciiz "intt1"
  lda #<_handlers_timer1
  ldx #>_handlers_timer1
  byte UPDATE
  byte PAUSE
  sta r0
  stx r1
  jsr _call_handlers
  ply
  plx
  pla
  rts




handler_ca1_call:
  stx r0 ; X/Y -> r0/r1
  sty r1
  jsr _new_handler_ca1
  rts
handler_timer1_call:
  stx r0 ; X/Y -> r0/r1
  sty r1
  jsr _new_handler_timer1
  rts
