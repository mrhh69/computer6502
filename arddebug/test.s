




PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
T1CL = $6004 ;T1 counter latches
T1CH = $6005
T1LL = $6006 ; T1 latches
T1LH = $6007
T2LC = $6008
T2LH = $6009
SR =  $600A
ACR = $600B ; Auxillary Control Register (T1, T2, SR, )
PCR = $600C ; CA,CB Control (interrupt lines)
IFR = $600D ; Interrupt Flags Register
IER = $600E ; Interrupt Enable Register



  section bss

  section .text.entry
reset:
  sei
  lda #$ff
  sta DDRB
  lda #%11111101
  sta DDRA
  lda #0
  sta PORTA
  sta PORTB



.write_back: ; Write val in A register to arduino
  ldx #%00011100 ; SR (shift out) extern CB1 control
  stx ACR
  lda #69
  sta SR
  sta PORTB

  lda #1
  sta PORTA ; signal ready for write

  lda #%10
.waitsrw:  ; Wait for ARD to write 1
  bit PORTA
  beq .waitsrw

  stp


irq:
nmi:
  rti

  section .text.vectors
  word nmi
  word reset
  word irq
