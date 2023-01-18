


  include cregs.s
  include edefs.s
  include kdefs.s


  global _systemd    ; Process #0 entrypoint

  global _swtchin

  global interrupt_timer1 ; for crt.s (interrupts)
  global interrupt_ca1
  extern button_press ; from clib.s (for debugging)
  global swtch_call   ; for crt.s (software interrupts)
  global newproc_call
  global handler_timer1_call
  global handler_ca1_call
  global lcdins_call
  global putc_call

  extern _get_swtch  ; from kernelc.c (functions)
  extern _newproc
  ;extern _new_handler
  extern _new_handler_ca1
  extern _new_handler_timer1

  extern _processes  ; bss variables
  extern _processes_data

  ;extern _do_pause
  extern _pause
  extern print_char
  extern lcd_instruction

  extern _dummyf2 ; from user.s (user processes)
  extern _timed


  section text
  global rapper
rapper:
  jsr print_char
  jsr _pause
  rts

_systemd:
  ;lda #'a'
  ;jsr rapper
  ;lda #'b'
  ;jsr rapper

  lda #NEWPROC_BRK
  ldx #<_dummyf2
  ldy #>_dummyf2
  brk
  byte $02 ; IMPORTANT (brk is a two-byte instruction)

  lda #NEWPROC_BRK
  ldx #<_timed
  ldy #>_timed
  ;brk
  ;byte $02 ; IMPORTANT (brk is a two-byte instruction)

  ldx #<_dumca1
  ldy #>_dumca1
  lda #HANDLER_CA1_BRK
  ;brk
  ;byte $02
  ldx #<_dumt1
  ldy #>_dumt1
  lda #HANDLER_T1_BRK
  ;brk
  ;byte $02


  ;lda #'d'
  ;jsr rapper

.loopy:
  ;bra .oloopy
  ldx #(%10000000 | $0a)
  lda #LCDINS_BRK
  brk
  byte $00
  ldx #'l'
  lda #PUTC_BRK
  brk
  byte $00

.bloopy:
  lda #SWTCH_BRK
  brk
  byte $01
  bra .loopy

_dumca1:
  lda #'c'
  jsr print_char
  rts
_dumt1:
  lda #'t'
  jsr print_char
  rts




; TODO: make it so that a handler call executes code with the PPD of the process it was registered from
; So that whatever process is currently running's zero-page doesn't get messed up by the C code
interrupt_ca1:
  phx
  phy
  jsr button_press ; for debugging (from clib.s)

  ;jsr _call_handlers
  ply
  plx
  rts
interrupt_timer1:
  phx
  phy

  ;jsr _call_handlers
  ply
  plx
  rts

swtch_call:
  phy
  phx
  pha

  inc $02 ; INCREMENT PRIORITY

  ; copy out:
  lda $01
  dec
  asl
  clc
  adc #(_processes >> 8)
  sta $0f
  lda #(_processes & $ff)
  sta $0e

  ldy #0
.yloop1:
  lda $0000, y
  sta ($0e), y
  iny
  bne .yloop1

  inc $0f
.yloop2:
  lda $0100, y
  sta ($0e), y
  iny
  bne .yloop2

  ;byte UPDATE
  ;byte PAUSE

  jsr _get_swtch
  sta r0
  stx r1
  ;byte UPDATE
  ;byte PAUSE
  jmp _swtchin



; System calls:
newproc_call: ; wrapper for C function newproc (defined in main.c)
  txa ; X/Y -> A/X
  pha
  tya
  tax
  pla
  jsr _newproc
  rts

handler_ca1_call:
  stx r0 ; X/Y -> r0/r1
  sty r1
  jsr _new_handler_ca1
  rts
handler_timer1_call:
  stx r0 ; X/Y -> r0/r1
  sty r1
  jsr _new_handler_timer1
  rts

lcdins_call:
  txa
  phy
  jsr lcd_instruction
  ply
  rts
putc_call:
  txa
  phy
  jsr print_char
  ply
  rts




; (char * ppda)
_swtchin:
  ; memcpy(0, ppda, 0x200)
  ; NOTE: $200 and $201 are clobbered (in order to protect r0 and r1)
  ;lda sp  ; Make sure to Preserve the software stack pointer across calls
  ;sta $202
  ;lda sp + 1
  ;sta $203

  inc r1 ; Copy Hardware stack
  ldy #0
.loopstack:
  lda (r0), y
  sta $100, y
  iny
  bne .loopstack

  dec r1
  ldy #0
.loopzp:
  cpy #r0
  beq .skipover
  lda (r0), y
  sta $000, y
  iny
  beq .loopzpout
  bra .loopzp
.skipover:
  lda (r0), y
  sta $200
  iny
  lda (r0), y
  sta $201
  iny
  bra .loopzp
.loopzpout:
  lda $200
  sta r0
  lda $201
  sta r1
  ;lda $202
  ;sta sp
  ;lda $203
  ;sta sp
  ;byte UPDATE
  ;byte DISPLAY
  ;asciiz "swtchin"
  ;byte PAUSE

  ldx 0 ; load sp ((struct process *)0->proc.sp)
  txs
  pla
  plx
  ply
  ;byte $02 ; UPDATE
  ;byte DISPLAY
  ;asciiz "Swtch Entering..."
  ;byte $13 ; PAUSE
  rti
