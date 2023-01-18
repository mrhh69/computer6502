

; C Runtime for Ben Eater 6502 computer
; To be used with vbcc output
; Sections:
;  - .text.entry: entry point for 6502
;  - .text.vectors: vectors to be loaded at 0xfffa
; Externs:
;  - _main: main function
;  - __[data/bss]_[loc/start/end]: linker-defined data/bss segment info


  include cregs.s
  include kdefs.s


STACK_START = $4000

PORTA = $6001
IFR =   $600D
  ;include Definitions.s

  extern _main
  extern __data_loc
  extern __data_start
  extern __data_end
  extern __bss_start
  extern __bss_end

  extern swtch_call
  extern newproc_call
  extern handler_timer1_call
  extern handler_ca1_call
  extern lcdins_call
  extern putc_call

  extern interrupt_ca1
  extern interrupt_timer1

  section .text.entry
reset:
  sei

; Copy from (__data_loc) -> (__data_start-__data_end)
  lda #(__data_loc & $ff)
  ldx #(__data_loc >> 8)
  sta $00
  stx $01
  lda #(__data_start & $ff)
  ldx #(__data_start >> 8)
  sta $02
  stx $03
.data_loop:
  lda $03
  cmp #>__data_end
  bne .data_loop1
  lda $02
  cmp #<__data_end
  bne .data_loop1
  jmp .data_loop_out
.data_loop1:
  lda ($00)
  sta ($02)
  inc $00
  bne .b1
  inc $01
.b1:
  inc $02
  bne .b2
  inc $03
.b2:
  jmp .data_loop
.data_loop_out:

; Zero out (__bss_start-__bss_end)
  lda #<__bss_start
  ldx #>__bss_start
  sta $00
  stx $01
bss_loop:
  lda $01
  cmp #>__bss_end
  bne bss_loop1
  lda $00
  cmp #<__bss_end
  bne bss_loop1
  jmp bss_loop_out
bss_loop1:
  lda #0
  sta ($00)
  inc $00
  bne b3
  inc $01
b3:
  jmp bss_loop
bss_loop_out:


  lda #(STACK_START & $ff)
  ldx #(STACK_START >> 8)
  sta sp
  stx sp + 1


  jsr _main

  ;ora #%10000000
  ;sta PORTA

  stp

  extern rapper


irq:
  pha
  ; Determine source of interrupt:
  lda IFR
  beq .irq_brk ; If IFR is not set, then source was from a BRK, not from VIA chip

  bit #%01000000
  beq .not_timer1
.irq_timer1: ; Timer1 interrupt
  lda #%01000000 ; Clear Interrupt flag
  sta IFR
  jsr interrupt_timer1
  pla
  rti


  extern print_char
.not_timer1:
  bit #%00000010
  beq .not_ca1
.irq_ca1: ; CA1 Interrupt
  lda #%00000010 ; Clear Flag
  sta IFR
  jsr interrupt_ca1 ; external subroutine
  pla
  rti

.not_ca1: ; Should not happen hopefully:
  ;lda #$aa
  sta PORTA
  stp

.irq_brk:
  ; handle brk:
  pla
  ;pha
  ;phx
  ;phy
  ;clc
  ;adc #'0'
  ;jsr rapper
  ;ply
  ;plx
  ;pla

  cmp #SWTCH_BRK
  beq .swtch
  cmp #NEWPROC_BRK
  beq .newproc
  cmp #HANDLER_T1_BRK
  beq .handler_t1
  cmp #HANDLER_CA1_BRK
  beq .handler_ca1
  cmp #LCDINS_BRK
  beq .lcdins
  cmp #PUTC_BRK
  beq .putc

  ora #$80
  sta PORTA ; Bad system call!
  stp

.swtch:
  jmp swtch_call
.newproc:
  jsr newproc_call
  rti
.handler_t1:
  jsr handler_timer1_call
  rti
.handler_ca1:
  jsr handler_ca1_call
  rti
.lcdins:
  jsr lcdins_call
  rti
.putc:
  jsr putc_call
  rti



nmi:
  rti

  section .text.vectors
  word nmi
  word reset
  word irq
