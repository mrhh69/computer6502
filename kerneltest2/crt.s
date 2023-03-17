

; C Runtime for Emulated 6502 Computer
; To be used with vbcc output
; Sections:
;  - .text.entry: entry point for 6502
;  - .text.vectors: vectors to be loaded at 0xfffa
; Externs:
;  - pre_init: called before any C initialization
;  - _main: main function
;
;  - __[data/bss]_[loc/start/end]: linker-defined data/bss segment info


  include kcregs.s
  include defs.s
  include kdefs.s
  include emu.s


STACK_START = $4000


  extern _main
  extern pre_init
; system (brk) calls
  extern brk_swtch
  extern brk_fork
  extern brk_exec
  extern brk_putc

  section .text.entry
reset:
  sei
  jsr pre_init


; Setup for C code (initialize data/bss, setup stack)
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
  lda #(__bss_start & $ff)
  ldx #(__bss_start >> 8)
  sta $00
  stx $01
.bss_loop:
  lda $01
  cmp #>__bss_end
  bne .bss_loop1
  lda $00
  cmp #<__bss_end
  bne .bss_loop1
  jmp .bss_loop_out
.bss_loop1:
  lda #0
  sta ($00)
  inc $00
  bne .b3
  inc $01
.b3:
  jmp .bss_loop
.bss_loop_out:


  lda #(STACK_START & $ff)
  ldx #(STACK_START >> 8)
  sta sp
  stx sp + 1

; Enter main function, once initialization has completed
  jsr _main
; Upon main function return:
  ;ora #%10000000
  ;sta PORTA
; Stop the processor. Nothing more.
  stp





irq:
  phy
  phx
  pha
; save a/x in an accessible place (they could be important)
  sta r2
  stx r3
; switch to kernel mode (stack)
; put user sp on stack
  tsx
  txa
; restart kernel stack
  ldx #KSTACK_START
  txs
  pha

; check the status register (user stack)
  tax
  lda $104,x
  bit #$10       ; brk flag
  bne .irq_brk

.irq_hw:
  DISPLAY "irq hw"
  jmp .irq_out


.irq_brk:
; get the byte after the brk instruction
  lda $106,x
  sta r0+1
  lda $105,x
  sec
  sbc #1
  bcs .noz   ; TODO: check this math
  dec r0+1
.noz:
  sta r0

  lda (r0)
  cmp #BRK_SWTCH
  beq .brk_swtch
  cmp #BRK_FORK
  beq .brk_fork
  cmp #BRK_EXEC
  beq .brk_exec
  cmp #BRK_PUTC
  beq .brk_putc

  DISPLAY "BAD BRK CALL"
  PAUSE
  JAM

.brk_swtch:
  DISPLAY "brk call swtch"
  lda r2
  ldx r3
  jsr brk_swtch
  bra .call_out
.brk_fork:
  DISPLAY "brk call fork"
  lda r2
  ldx r3
  jsr brk_fork
  bra .call_out
.brk_exec:
  DISPLAY "brk call exec"
  lda r2
  ldx r3
  jsr brk_exec
  bra .call_out
.brk_putc:
  DISPLAY "brk call putc"
  lda r2
  ldx r3
  jsr brk_putc
  bra .call_out


.call_out:
  plx
  txs
  plx   ; dummy pull A, return a register to process
  plx
  ply
  DISPLAY "call out..."
  UPDATE
  rti
.irq_out:
; switch to user mode
; (stack)
  plx
  txs
; return back into process
  pla
  plx
  ply
  rti
nmi:
  rti



  section .text.vectors
  word nmi
  word reset
  word irq
