

;  65c02 OS Kernel
; System calls:
;   newproc: create a new process
;     * Arg1 - starting PC
;   exit: exit running process
;   sleep: sleep current process
;     -> (Sleep is currently permanent)
;   swtch: write out current process image,
;          and swap in image of process w/ lowest priority






  .include defs.s


; Registers
R0 = $10
R1 = $18
R2 = $20
R3 = $28

; Kernel Registers
KR0 = $0200
KR1 = $0208
KR2 = $0210
KR3 = $0218

; Important cur process information
PRN = $30
SP = $31
; Stack on swtchin: X, Y, A, STATUS, PC

; Sleep priority
SLEEP = $7f

NPROCS = 16
PROCS = $1000
IMGS = $1100

; System calls (number in A register)
C_NEWPROC = 1
C_EXIT = 2
C_SLEEP = 3
C_SWTCH = 4



  .org $8000

  .org $8400

reset:
  sei ; Critical initialization
  ldx #$ff
  txs


init:    ; bzero segments ($10 - $30)
  lda #0
  sta R0
  lda #$0f
  sta R0 + 1

initloop1:
  lda R0 + 1
  inc
  cmp #$30
  beq initexit
  sta R0 + 1
  lda #0
  ldy #$ff
initloop2:
  sta (R0), y
  beq initexit1
  dey
  jmp initloop2
initexit1:
  jmp initloop1
initexit:

  lda #-1
  sta PRN

  lda #(main1 & $ff)
  sta R0
  lda #(main1 >> 8)
  sta R0 + 1
  jsr newproc

  .byte DISPLAY
  .asciiz "Process Created"
  .byte PAUSE

  ; interrupts still not enabled

  jmp swtchin





swtchentf:
  php
swtchentc:
  sei ; Critical section (proc status w/ interrupts is on stack)
  pha
  phy
  phx

swtch:
  .byte DISPLAY
  .asciiz "switchstart"
  .byte UPDATE
  tsx
  stx SP

  lda PRN ; PRN * 3
  asl
  adc PRN
  tax
  ;inc PROCS, x
  lda PROCS + 1, x
  sta $00
  lda PROCS + 2, x
  sta $01

  ldy #$ff
copyoutloop1:
  lda $0000, y
  sta ($00), y
  tya
  cmp #$10
  beq copyoutexit1
  dey
  jmp copyoutloop1
copyoutexit1:

  inc $01
  ldy #$ff
copyoutloop2:
  lda $0100, y
  sta ($00), y
  ;tya
  cpy SP
  beq copyoutexit2
  dey
  jmp copyoutloop2
copyoutexit2:

  ;jmp swtchin







swtchin:
  .byte DISPLAY
  .asciiz "switchinstart"
  .byte UPDATE
  lda #127
  sta KR2
  ldx #0
  ldy #0
swtchloop1:
  ;txa
  ;cmp PRN
  ;beq swtchnext
  lda PROCS + 1, y
  bne notnull
  lda PROCS + 2, y
  bne notnull

swtchnext:
  iny
  iny
  iny
  inx
  txa
  cmp #NPROCS
  beq swtchout
  jmp swtchloop1

notnull:
  lda PROCS, y
  cmp KR2
  bpl swtchnext

  sta KR2
  tya
  sta KR1
  lda PROCS + 1, y
  sta KR0
  lda PROCS + 2, y
  sta KR0 + 1

  jmp swtchnext


swtchout:
  lda #127
  cmp KR2
  beq swtcherr

  ;lda KR1
  ;tay
  ;lda #0
  ;sta PROCS, y

  lda KR0
  sta $00
  lda KR0 + 1
  sta $01


  ldy #$ff
segloop1:
  lda ($00), y
  sta $0000, y
  tya
  cmp #$10
  beq segexit1
  dey
  jmp segloop1
segexit1:

  inc $01

  ldy #$ff
segloop2:
  lda ($00), y
  sta $0100, y
  tya
  beq segexit2
  dey
  jmp segloop2
segexit2:

  ; Setup Clock to interrupt in [quantum]
  .byte CLOCK_STOP
  .byte CLOCK_SET

  lda #USER
  tsb PORTA

  ldx SP
  txs

  plx
  ply
  pla


  .byte DISPLAY
  .asciiz "Entering"
  .byte UPDATE
  .byte PAUSE
  rti



swtcherr:
  .byte DISPLAY
  .asciiz "Swtch Err no procs"
  rti




sleep:
  php
  sei
  .byte CLOCK_STOP

  lda PRN
  asl
  adc PRN

  tax
  lda #SLEEP
  sta PROCS, x

  .byte DISPLAY
  .asciiz "Sleeping..."
  ;.byte UPDATE

  jmp swtchin



exit:
  sei ; critical section
  .byte CLOCK_STOP
  lda PRN
  asl
  adc PRN
  tax
  lda #0
  sta PROCS + 1, x
  sta PROCS + 2, x

  .byte DISPLAY
  .asciiz "Exited"

  jmp swtchin





newproc:
  php
  sei
  .byte CLOCK_PAUSE
  ldx #0
  ldy #0
loop1:
  lda PROCS + 1, y
  bne nextproc
  lda PROCS + 2, y
  bne nextproc

  jmp nullproc
nextproc:
  iny
  iny
  iny
  inx
  txa
  cmp #NPROCS
  beq out
  jmp loop1

nullproc:
  lda #0
  sta PROCS, y
  sta PROCS + 1, y
  sta $00
  txa
  asl
  adc #$11
  sta PROCS + 2, y
  sta $01

  ldy #PRN
  txa
  sta ($00), y
  ldy #SP
  lda #$f9
  sta ($00), y

  inc $01

  lda #0
  ldy #$fa
  sta ($00), y
  iny
  sta ($00), y
  iny
  sta ($00), y

  iny
  lda #$32 ; enable interrupts
  sta ($00), y

  iny
  lda R0
  sta ($00), y
  iny
  lda R0 + 1
  sta ($00), y


  .byte CLOCK_SET
  plp

  rts

out:
  .byte DISPLAY
  .asciiz "No space for new procs"
  .byte JAM





commontime:

  ldx #0
  lda #127
  sta KR0
intloop:
  lda PROCS + 1, x
  bne ok
  lda PROCS + 2, x
  beq nextp
ok:
  lda PROCS, x
  cmp KR0
  bpl nextp

  sta KR0
nextp:
  inx
  inx
  inx
  txa
  cmp #(NPROCS * 3)
  beq nextexit
  jmp intloop
nextexit:

  lda KR0
  beq decreaseexit

  ldx #0
decreaseloop:
  lda PROCS + 1, x
  bne valid
  lda PROCS + 2, x
  beq dnextp
valid:
  lda PROCS, x
  cmp #SLEEP
  beq dnextp
  sec
  sbc KR0
  sta PROCS, x
dnextp:
  inx
  inx
  inx
  txa
  cmp #(NPROCS * 3)
  beq decreaseexit
  jmp decreaseloop
decreaseexit:
  rts










main1:
  .byte DISPLAY
  .asciiz "Function Main1"
  .byte UPDATE
  .byte PAUSE

  ; Initialize other procs

  lda #<main2;(main2 & $ff)
  sta R0
  lda #>main2;(main2 >> 8)
  sta R0 + 1
  lda #C_NEWPROC
  brk

  lda #(main3 & $ff)
  sta R0
  lda #(main3 >> 8)
  sta R0 + 1
  lda #C_NEWPROC
  brk

  .byte DISPLAY
  .asciiz "Main2 and Main3 Initialized"
  .byte PAUSE


  lda #C_SLEEP ; For now; sleep is indefinite
  brk

main1loop:
  .byte DISPLAY
  .asciiz "Main1 Loop"
  .byte UPDATE
  .byte PAUSE
  ldx #5
  lda #C_SWTCH
  brk
  jmp main1loop ; fall through (after swap back)





main2:
  .byte DISPLAY
  .asciiz "Function Main2"
  .byte UPDATE
  .byte PAUSE

main2loop:
  jmp main2loop ; fall through (after swap back)


main3:
  .byte DISPLAY
  .asciiz "Function Main3"
  .byte PAUSE

  lda PRN ;PRN * 3
  asl
  adc PRN
  tax

  lda PROCS, x
  ;cmp #2
  ;bne exitmain3

  lda #(main4 & $ff)
  sta R0
  lda #(main4 >> 8)
  sta R0 + 1
  ;jsr newproc


exitmain3:
  .byte DISPLAY
  .asciiz "Main3"
  .byte UPDATE
  .byte PAUSE

  lda #C_SWTCH
  brk
  jmp exitmain3 ; fall through (after swap back)


main4:
  .byte DISPLAY
  .asciiz "Function Main4"
  .byte PAUSE

  brk
  ;jmp exit
  jmp main4 ; fall through (after swap back)









irq:
nmi:
  ; Stop Clock
  ;.byte CLOCK_STOP
  .byte DISPLAY
  .asciiz "Interrupt!"
  .byte UPDATE


  sei ; Critical section (proc status w/ interrupts is on stack)
  pha
  phy
  phx

  tax

  lda IFR
  beq notclock

  .byte DISPLAY
  .asciiz "Clock Interrupt"
  jmp cswtch

notclock:
  txa
  cmp #C_NEWPROC
  bne notnewproc

  .byte DISPLAY
  .asciiz "System Call NEWPROC"

  jsr newproc

  jmp intexit

notnewproc:
  cmp #C_EXIT
  bne notexit

  .byte DISPLAY
  .asciiz "System Call EXIT"

  jmp exit

notexit:
  cmp #C_SLEEP
  bne notsleep

  .byte DISPLAY
  .asciiz "System Call SLEEP"

  jmp sleep

notsleep:
  cmp #C_SWTCH
  bne notswtch

cswtch:
  .byte DISPLAY
  .asciiz "System Call SWTCH"

  lda PRN ; PRN * 3
  asl
  adc PRN
  tax
  inc PROCS, x

  jsr commontime
  .byte UPDATE
  .byte PAUSE

  jmp swtch

notswtch:
  .byte DISPLAY
  .asciiz "No Matching System Call"
  .byte UPDATE
  .byte JAM


intexit:
  lda #USER
  sta PORTA

  plx
  ply
  pla

  rti



  .org $fffa
  .word nmi
  .word reset
  .word irq
