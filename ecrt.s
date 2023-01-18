


  include cregs.s


STACK_START = $4000

DDRA = $6000
DDRB = $6001
PORTA = $6002
  ;include Definitions.s

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

  ;ora #%10000000
  ;sta PORTA

  ;stp


irq:
nmi:
  rti


  section .text.vectors
  word nmi
  word reset
  word irq
