





  .include defs.s


R0 = $10
R1 = $18
R2 = $20
R3 = $28
R4 = $30
R5 = $38
R6 = $40
R7 = $48
SP = $50
STACK_START = $8000


_coremap = $0200
_size = $0300
_pos = $0302


  .org $8000
  .org $8400
reset:
  sei
  ldx #$ff
  txs

  lda #(STACK_START & $ff)
  ldx #(STACK_START >> 8)
  sta SP
  stx SP + 1

  jsr _main





  .byte UPDATE
  .byte JAM




  .include "main3.s"




nmi:
irq:

  rti



  .org $fffa
  .word nmi
  .word reset
  .word irq
