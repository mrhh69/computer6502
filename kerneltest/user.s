

  include kdefs.s


  section bss
dummyf2_intc:
  reserve 2
_time2_t:
  reserve 2



  section text
  global _dummyf2
  global _timed

_dummyf2:
  ldx #<dummyf2_ca1_interrupt
  ldy #>dummyf2_ca1_interrupt
  lda #HANDLER_CA1_BRK
  ;brk
  ;byte $00
.loopy:
  lda #($40 | (9)) ; move cursor to position 10 on line 2
  jsr _lcdinsw

  lda #'B'
  jsr _putcw
  lda #':'
  jsr _putcw


  lda #($40 | (15)) ; move cursor to position 10 on line 2
  ;jsr _lcdinsw

  lda #'0'   ; Put character 'a' + #ca1_ints
  clc
  adc dummyf2_intc
  ;jsr _putcw

  lda #SWTCH_BRK
  brk
  byte $02
  bra .loopy


dummyf2_ca1_interrupt:
  inc dummyf2_intc
  bne .noinc
  inc dummyf2_intc + 1
.noinc:
  rts





_timed:
  ldx #<time2_t1_int
  ldy #>time2_t1_int
  lda #HANDLER_T1_BRK
  brk
  byte $00
.loopy:
  lda #($40 | (0)) ; move cursor to position 0 on line 2
  jsr _lcdinsw

  lda #'T'
  jsr _putcw
  lda #':'
  jsr _putcw


  lda #($40 | (4))
  jsr _lcdinsw
  lda _time2_t
  clc
  adc #'0'
  jsr _putcw

  lda #SWTCH_BRK
  brk
  byte $02
  bra .loopy


time2_t1_int:
  inc _time2_t
  bne .noinc
  inc _time2_t + 1
.noinc:
  rts



_lcdinsw:
  ora #%10000000
  tax
  lda #LCDINS_BRK
  brk
  byte $00
  rts
_putcw:
  tax
  lda #PUTC_BRK
  brk
  byte $00
  rts
