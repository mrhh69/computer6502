PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
T1CL = $6004 ;T1 counter latches
T1CH = $6005
T1LL = $6006 ; T1 latches
T1LH = $6007
T2CL = $6008
T2CH = $6009
SR =  $600A
ACR = $600B ; Auxillary Control Register (T1, T2, SR, )
PCR = $600C ; CA,CB Control (interrupt lines)
IFR = $600D ; Interrupt Flags Register
IER = $600E ; Interrupt Enable Register
; For ACR:
T1_ONESHOT = (%00 << 6)
T1_CONT    = (%01 << 6)
T1_CONTPB7 = (%11 << 6)
T2_COUNTPB6= (%1 << 5)
; For IFR and IER:
INT_EN =  %10000000 ; this bit SHOULD be set (see datasheet)
INT_T1 =  %01000000
INT_T2 =  %00100000
INT_CB1 = %00010000
INT_CB2 = %00001000
INT_SR =  %00000100
INT_CA1 = %00000010
INT_CA2 = %00000001
; For PCR:
CA1_NEG = (%0 << 0)
CA1_POS = (%1 << 0)
CB1_NEG = (%0 << 4)
CB1_POS = (%1 << 4)



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


  macro VECTORS
  word nmi
  word reset
  word irq
  endmacro
