


  include cregs.s
  include edefs.s
  include kdefs.s


STACK_START = $4000

  extern _main
  extern __data_loc
  extern __data_start
  extern __data_end
  extern __bss_start
  extern __bss_end

  extern interrupt_timer1
  extern interrupt_ca1
  extern handler_timer1_call
  extern handler_ca1_call

  section .text.entry
  ; RESERVE $400 IS FOR MY EMU6502 COMPUTER, NOT FOR THE ACTUAL BENEATER COMPUTER
  reserve $400
reset:

; Copy from (__data_loc) -> (__data_start-__data_end)
  lda #(__data_loc & $ff)
  ldx #(__data_loc >> 8)
  sta $00
  stx $01
  lda #(__data_start & $ff)
  ldx #(__data_start >> 8)
  sta $02
  stx $03
data_loop:
  lda $03
  cmp #>__data_end
  bne data_loop1
  lda $02
  cmp #<__data_end
  bne data_loop1
  jmp data_loop_out
data_loop1:
  lda ($00)
  sta ($02)
  inc $00
  bne b1
  inc $01
b1:
  inc $02
  bne b2
  inc $03
b2:
  jmp data_loop
data_loop_out:

  byte $02
  byte $22
  asciiz "data loaded"

; Zero out (__bss_start-__bss_end)
  lda #(__bss_start & $ff)
  ldx #(__bss_start >> 8)
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

  byte $02
  byte $22
  asciiz "bss zeroed"


  lda #(STACK_START & $ff)
  ldx #(STACK_START >> 8)
  sta sp
  stx sp + 1

  byte $02
  byte $22
  asciiz "entering main..."

  jsr _main

  byte $02
  byte $22
  asciiz "main returned, stopping"
  byte $44 ; Exit runner with status accumulator
  byte $03





irq:
.irq_brk:
  ; handle brk:
  cmp #HANDLER_T1_BRK
  beq .handler_t1
  cmp #HANDLER_CA1_BRK
  beq .handler_ca1

  byte UPDATE
  byte DISPLAY
  asciiz "uknown brk type"
  byte JAM

.handler_t1:
  jsr handler_timer1_call
  rti
.handler_ca1:
  jsr handler_ca1_call
  rti

nmi:
  rti


  section .text.vectors
  word nmi
  word reset
  word irq
