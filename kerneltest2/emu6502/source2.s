

  .include defs.s


R0 = $10
R1 = $18
R2 = $20
R3 = $28


swapmap = $0200


  .org $8000
  .org $8400
reset:
  sei
  ldx #$ff
  txs

  ldy #0
  lda #0
reset_loop:
  sta swapmap, y
  sta swapmap + 1, y
  iny
  iny
  iny
  iny
  bne reset_loop



  lda #0
  sta R0 + 1
  sta R1 + 1

  lda #11
  sta R0
  lda #2
  sta R1
  jsr mfree

  .byte DISPLAY
  .asciiz "next"
  .byte UPDATE
  ;.byte PAUSE

  lda #0
  sta R0 + 1
  sta R1 + 1

  lda #3
  sta R0
  lda #4
  sta R1
  jsr mfree

  lda #0
  sta R0 + 1
  sta R1 + 1

  lda #1
  sta R0
  lda #1
  sta R1
  jsr mfree

  .byte UPDATE
  .byte JAM









; R0 - Location to free
; R1 - Size to free
mfree:
  ldy #0

mfree_loop:

  lda swapmap, y
  bne ent
  lda swapmap + 1, y
  bne ent
  jmp newent
ent:

  lda swapmap + 2, y
  cmp R0
  lda swapmap + 3, y
  sbc R0 + 1
  bpl overshot

  ; If entpos + entsize == targetpos

  lda swapmap + 2, y
  clc
  adc swapmap, y
  php
  cmp R0
  beq still

  plp
  jmp mfree_next

still:
  plp
  lda swapmap + 3, y
  adc swapmap + 1, y
  cmp R0 + 1
  beq addon

  jmp mfree_next

addon:
  .byte DISPLAY
  .asciiz "addon"

  lda swapmap, y
  clc
  adc R1
  sta swapmap, y
  lda swapmap + 1, y
  adc R1 + 1
  sta swapmap + 1, y

  ; If newsize + entpos == (next)entpos
  ; Merge and move down


  jmp mfree_exit

overshot:
  .byte DISPLAY
  .asciiz "insert"

  ; If targetpos + targetsize == entpos

  lda R0
  clc
  adc R1
  php
  cmp swapmap + 2, y
  beq s1

  plp
  jmp moveup

s1:
  plp
  lda R0 + 1
  adc R1 + 1
  cmp swapmap + 3, y
  beq mergelow

  jmp moveup

mergelow:
  .byte DISPLAY
  .asciiz "mergelow"

  ; Increase entsize by targetsize
  ; Replace entpos with targetpos
  lda swapmap, y
  clc
  adc R1
  sta swapmap, y
  lda swapmap + 1, y
  adc R1 + 1
  sta swapmap + 1, y

  lda R0
  sta swapmap + 2, y
  lda R0 + 1
  sta swapmap + 3, y


  jmp mfree_exit
moveup:
  .byte DISPLAY
  .asciiz "moveup"
  ; Else move entries up

moveuploop:
  lda R0
  tax
  lda swapmap + 2, y
  sta R0
  txa
  sta swapmap + 2, y

  lda R0 + 1
  tax
  lda swapmap + 3, y
  sta R0 + 1
  txa
  sta swapmap + 3, y

  lda R1
  tax
  lda swapmap, y
  php
  sta R1
  txa
  sta swapmap, y

  lda R1 + 1
  tax
  lda swapmap + 1, y
  php
  sta R1 + 1
  txa
  sta swapmap + 1, y

  pla
  sta $00
  pla
  and $00
  and #%10
  bne moveupdone

  iny
  iny
  iny
  iny
  beq moveupdone

  jmp moveuploop
moveupdone:
  jmp mfree_exit


mfree_next:
  iny
  iny
  iny
  iny
  beq entryoverflow
  jmp mfree_loop
entryoverflow:
  .byte DISPLAY
  .asciiz "swapmap entry overflow in mfree"
  .byte JAM




newent:
  .byte DISPLAY
  .asciiz "extend"
  lda R1
  sta swapmap, y
  lda R1 + 1
  sta swapmap + 1, y
  lda R0
  sta swapmap + 2, y
  lda R0 + 1
  sta swapmap + 3, y

mfree_exit:
  rts



nmi:
irq:

  rti



  .org $fffa
  .word nmi
  .word reset
  .word irq
