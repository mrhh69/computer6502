
; chip defines:
LCD_PORT = VIA2_PORTB
LCD_DDR  = VIA2_DDRB

RTC_PORT = VIA1_PORTA
RTC_DDR  = VIA1_DDRA

BUTTON_PORT = VIA1_PORTA


; address defines:
VIA1_BASE = $6000
VIA2_BASE = $7000

PORTB_OFFS = $0
PORTA_OFFS = $1
DDRB_OFFS =  $2
DDRA_OFFS =  $3
T1CL_OFFS =  $4 ;T1 counter latches
T1CH_OFFS =  $5
T1LL_OFFS =  $6 ; T1 latches
T1LH_OFFS =  $7
T2CL_OFFS =  $8
T2CH_OFFS =  $9
SR_OFFS =    $A
ACR_OFFS =   $B ; Auxillary Control Register (T1, T2, SR, )
PCR_OFFS =   $C ; CA,CB Control (interrupt lines)
IFR_OFFS =   $D ; Interrupt Flags Register
IER_OFFS =   $E ; Interrupt Enable Register



; via1 defines (via1 is the only one that gets interrupts)
VIA1_PORTB = (VIA1_BASE+PORTB_OFFS)
VIA1_PORTA = (VIA1_BASE+PORTA_OFFS)
VIA1_DDRB  = (VIA1_BASE+DDRB_OFFS)
VIA1_DDRA  = (VIA1_BASE+DDRA_OFFS)
VIA1_T1CL  = (VIA1_BASE+T1CL_OFFS)
VIA1_T1CH  = (VIA1_BASE+T1CH_OFFS)
VIA1_T1LL  = (VIA1_BASE+T1LL_OFFS)
VIA1_T1LH  = (VIA1_BASE+T1LH_OFFS)
VIA1_T2CL  = (VIA1_BASE+T2CL_OFFS)
VIA1_T2CH  = (VIA1_BASE+T2CH_OFFS)
VIA1_SR    = (VIA1_BASE+SR_OFFS)
VIA1_ACR   = (VIA1_BASE+ACR_OFFS)
VIA1_PCR   = (VIA1_BASE+PCR_OFFS)
VIA1_IFR   = (VIA1_BASE+IFR_OFFS)
VIA1_IER   = (VIA1_BASE+IER_OFFS)

; via2 defines
VIA2_PORTB = (VIA2_BASE+PORTB_OFFS)
VIA2_PORTA = (VIA2_BASE+PORTA_OFFS)
VIA2_DDRB  = (VIA2_BASE+DDRB_OFFS)
VIA2_DDRA  = (VIA2_BASE+DDRA_OFFS)
VIA2_T1CL  = (VIA2_BASE+T1CL_OFFS)
VIA2_T1CH  = (VIA2_BASE+T1CH_OFFS)
VIA2_T1LL  = (VIA2_BASE+T1LL_OFFS)
VIA2_T1LH  = (VIA2_BASE+T1LH_OFFS)
VIA2_T2CL  = (VIA2_BASE+T2CL_OFFS)
VIA2_T2CH  = (VIA2_BASE+T2CH_OFFS)
VIA2_SR    = (VIA2_BASE+SR_OFFS)
VIA2_ACR   = (VIA2_BASE+ACR_OFFS)
VIA2_PCR   = (VIA2_BASE+PCR_OFFS)
VIA2_IFR   = (VIA2_BASE+IFR_OFFS)
VIA2_IER   = (VIA2_BASE+IER_OFFS)

; for backwards compatibility:
PORTB = VIA1_PORTB
PORTA = VIA1_PORTA
DDRB  = VIA1_DDRB
DDRA  = VIA1_DDRA
T1CL  = VIA1_T1CL
T1CH  = VIA1_T1CH
T1LL  = VIA1_T1LL
T1LH  = VIA1_T1LH
T2CL  = VIA1_T2CL
T2CH  = VIA1_T2CH
SR    = VIA1_SR
ACR   = VIA1_ACR
PCR   = VIA1_PCR
IFR   = VIA1_IFR
IER   = VIA1_IER


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
  sta VIA1_T1CL
  lda #((\1 & $ff00) >> 8)
  sta VIA1_T1CH
  wai

  if ((\1 >> 16) != 0)
  phy
  ldy #(\1 >> 16)
WAIT_US_\@:
  lda #$FF
  sta VIA1_T1CL
  sta VIA1_T1CH
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
