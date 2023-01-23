


  include Definitions.s


  extern pre_init
  extern main
  extern interrupt_timer1
  extern interrupt_timer2
  extern button_press

  section .text.entry
reset:
  jsr pre_init

  jsr main
  stp



irq:
  pha
  ; Determine source of interrupt:
  lda IFR
  bit #INT_T1
  bne .irq_timer1
  bit #INT_T2
  bne .irq_timer2
  bit #INT_CA1
  bne .irq_ca1
  ; Should not happen hopefully:
  lda #$aa
  sta PORTA
  stp

.irq_timer1: ; Timer1 interrupt
  lda #INT_T1 ; Clear Interrupt flag
  sta IFR
  jsr interrupt_timer1
  jmp .irq_out
.irq_timer2:
  lda #INT_T2
  sta IFR
  jsr interrupt_timer2
  jmp .irq_out
.irq_ca1: ; CA1 Interrupt
  lda #INT_CA1 ; Clear Flag
  sta IFR
  jsr button_press ; external subroutine
  jmp .irq_out

.irq_out:
  pla
  rti
nmi:
  rti



  section .text.vectors
  word nmi
  word reset
  word irq
