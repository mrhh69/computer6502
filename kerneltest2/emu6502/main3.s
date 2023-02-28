_mfree:
  lda #(_coremap & $ff)
  ldx #(_coremap >> 8)
  sta R7
  stx R7 + 1
_mfree_for0:
  lda #(10 & $ff)
  ldx #(10 >> 8)
  sta R0
  stx R0 + 1
  lda #(0 & $ff)
  ldx #(0 >> 8)
  asl R0
  rol R0 + 1
  asl R0
  rol R0 + 1
  clc
  adc R0
  tay
  txa
  adc R0 + 1
  tax
  tya
  sta R0
  stx R0 + 1
  lda #(_coremap & $ff)
  ldx #(_coremap >> 8)
  clc
  adc R0
  tay
  txa
  adc R0 + 1
  tax
  tya
  sta R0
  stx R0 + 1
  lda R7
  ldx R7 + 1
  ldy #0
  cmp R0
  txa
  sbc R0 + 1
  bcs * + 3
  iny
  tya
  tay
  bne * + 5
  jmp _mfree_for0_exit
  lda SP
  sec
  sbc #(0 & $ff)
  sta SP
  bcs * + 4
  dec SP + 1
  lda R7
  ldx R7 + 1
  sta R0
  stx R0 + 1
  ldy #((0 + 1) & $ff)
  lda (R0), y
  tax
  tya
  bne * + 4
  dec R0 + 1
  dey
  lda (R0), y
  tay
  bne * + 5
  txa
  beq * + 4
  lda #$ff
  inc
  tay
  bne * + 5
  jmp _mfree_if0_exit
_mfree_if0:
  jmp _mfree_extend
_mfree_if0_exit:
  lda R7
  ldx R7 + 1
  sta R0
  stx R0 + 1
  ldy #((2 + 1) & $ff)
  lda (R0), y
  tax
  tya
  bne * + 4
  dec R0 + 1
  dey
  lda (R0), y
  sta R0
  stx R0 + 1
  lda R7
  ldx R7 + 1
  sta R1
  stx R1 + 1
  ldy #((0 + 1) & $ff)
  lda (R1), y
  tax
  tya
  bne * + 4
  dec R1 + 1
  dey
  lda (R1), y
  clc
  adc R0
  tay
  txa
  adc R0 + 1
  tax
  tya
  sta R0
  stx R0 + 1
  lda _pos
  ldx _pos + 1
  ldy #0
  cmp R0
  bne * + 7
  cpx R0 + 1
  bne * + 3
  iny
  tya
  tay
  bne * + 5
  jmp _mfree_if1_exit
_mfree_if1:
  jmp _mfree_mergehigh
_mfree_if1_exit:
  lda _size
  ldx _size + 1
  sta R0
  stx R0 + 1
  lda _pos
  ldx _pos + 1
  clc
  adc R0
  tay
  txa
  adc R0 + 1
  tax
  tya
  sta R0
  stx R0 + 1
  lda R7
  ldx R7 + 1
  sta R1
  stx R1 + 1
  ldy #((2 + 1) & $ff)
  lda (R1), y
  tax
  tya
  bne * + 4
  dec R1 + 1
  dey
  lda (R1), y
  ldy #0
  cmp R0
  bne * + 7
  cpx R0 + 1
  bne * + 3
  iny
  tya
  tay
  bne * + 5
  jmp _mfree_if2_exit
_mfree_if2:
  jmp _mfree_mergelow
_mfree_if2_exit:
  lda R7
  ldx R7 + 1
  sta R0
  stx R0 + 1
  ldy #((2 + 1) & $ff)
  lda (R0), y
  tax
  tya
  bne * + 4
  dec R0 + 1
  dey
  lda (R0), y
  sta R0
  stx R0 + 1
  lda _pos
  ldx _pos + 1
  ldy #0
  cmp R0
  txa
  sbc R0 + 1
  bcs * + 3
  iny
  tya
  tay
  bne * + 5
  jmp _mfree_if3_exit
_mfree_if3:
  jmp _mfree_insert
_mfree_if3_exit:
  lda SP
  clc
  adc #(0 & $ff)
  sta SP
  bcc * + 4
  inc SP + 1
_mfree_for0_continue:
  lda R7
  ldx R7 + 1
  clc
  adc #(4 & $ff)
  tay
  txa
  adc #(4 >> 8)
  tax
  tya
  sta R7
  stx R7 + 1
  jmp _mfree_for0
_mfree_for0_exit:
  jmp _mfree_exit
_mfree_extend:
  lda R7
  ldx R7 + 1
  sta R0
  stx R0 + 1
  lda _size
  ldx _size + 1
  ldy #(0 & $ff)
  sta (R0), y
  iny
  bne * + 4
  inc R0 + 1
  txa
  sta (R0), y
  lda R7
  ldx R7 + 1
  sta R0
  stx R0 + 1
  lda _pos
  ldx _pos + 1
  ldy #(2 & $ff)
  sta (R0), y
  iny
  bne * + 4
  inc R0 + 1
  txa
  sta (R0), y
  jmp _mfree_exit
_mfree_mergehigh:
  lda R7
  ldx R7 + 1
  sta R0
  stx R0 + 1
  lda _size
  ldx _size + 1
  sta R1
  stx R1 + 1
  lda R7
  ldx R7 + 1
  sta R2
  stx R2 + 1
  ldy #((0 + 1) & $ff)
  lda (R2), y
  tax
  tya
  bne * + 4
  dec R2 + 1
  dey
  lda (R2), y
  clc
  adc R1
  tay
  txa
  adc R1 + 1
  tax
  tya
  sta R1
  stx R1 + 1
  ldy #(0 & $ff)
  sta (R0), y
  iny
  bne * + 4
  inc R0 + 1
  txa
  sta (R0), y
  lda R1
  ldx R1 + 1
  sta _size
  stx _size + 1
  lda R7
  ldx R7 + 1
  sta R0
  stx R0 + 1
  ldy #((2 + 1) & $ff)
  lda (R0), y
  tax
  tya
  bne * + 4
  dec R0 + 1
  dey
  lda (R0), y
  sta _pos
  stx _pos + 1
  lda R7
  ldx R7 + 1
  sta R0
  stx R0 + 1
  clc
  adc #(4 & $ff)
  tay
  txa
  adc #(4 >> 8)
  tax
  tya
  sta R7
  stx R7 + 1
  lda R0
  ldx R0 + 1
  sta R6
  stx R6 + 1
  lda _pos
  ldx _pos + 1
  sta R0
  stx R0 + 1
  lda _size
  ldx _size + 1
  clc
  adc R0
  tay
  txa
  adc R0 + 1
  tax
  tya
  sta R0
  stx R0 + 1
  lda R7
  ldx R7 + 1
  sta R1
  stx R1 + 1
  ldy #((2 + 1) & $ff)
  lda (R1), y
  tax
  tya
  bne * + 4
  dec R1 + 1
  dey
  lda (R1), y
  ldy #0
  cmp R0
  bne * + 7
  cpx R0 + 1
  bne * + 3
  iny
  tya
  tay
  bne * + 5
  jmp _mfree_if4_exit
_mfree_if4:
  lda SP
  sec
  sbc #(0 & $ff)
  sta SP
  bcs * + 4
  dec SP + 1
  lda R6
  ldx R6 + 1
  sta R0
  stx R0 + 1
  lda _size
  ldx _size + 1
  sta R1
  stx R1 + 1
  lda R7
  ldx R7 + 1
  sta R2
  stx R2 + 1
  ldy #((0 + 1) & $ff)
  lda (R2), y
  tax
  tya
  bne * + 4
  dec R2 + 1
  dey
  lda (R2), y
  clc
  adc R1
  tay
  txa
  adc R1 + 1
  tax
  tya
  ldy #(0 & $ff)
  sta (R0), y
  iny
  bne * + 4
  inc R0 + 1
  txa
  sta (R0), y
_mfree_while0:
  lda SP
  sec
  sbc #(0 & $ff)
  sta SP
  bcs * + 4
  dec SP + 1
  lda R6
  ldx R6 + 1
  clc
  adc #(4 & $ff)
  tay
  txa
  adc #(4 >> 8)
  tax
  tya
  sta R6
  stx R6 + 1
  lda R7
  ldx R7 + 1
  clc
  adc #(4 & $ff)
  tay
  txa
  adc #(4 >> 8)
  tax
  tya
  sta R7
  stx R7 + 1
  lda R6
  ldx R6 + 1
  sta R0
  stx R0 + 1
  lda R7
  ldx R7 + 1
  sta R1
  stx R1 + 1
  ldy #((0 + 1) & $ff)
  lda (R1), y
  tax
  tya
  bne * + 4
  dec R1 + 1
  dey
  lda (R1), y
  ldy #(0 & $ff)
  sta (R0), y
  iny
  bne * + 4
  inc R0 + 1
  txa
  sta (R0), y
  lda R6
  ldx R6 + 1
  sta R0
  stx R0 + 1
  lda R7
  ldx R7 + 1
  sta R1
  stx R1 + 1
  ldy #((2 + 1) & $ff)
  lda (R1), y
  tax
  tya
  bne * + 4
  dec R1 + 1
  dey
  lda (R1), y
  ldy #(2 & $ff)
  sta (R0), y
  iny
  bne * + 4
  inc R0 + 1
  txa
  sta (R0), y
  lda SP
  clc
  adc #(0 & $ff)
  sta SP
  bcc * + 4
  inc SP + 1
  lda R6
  ldx R6 + 1
  sta R0
  stx R0 + 1
  ldy #((0 + 1) & $ff)
  lda (R0), y
  tax
  tya
  bne * + 4
  dec R0 + 1
  dey
  lda (R0), y
  tay
  bne * + 8
  txa
  bne * + 5
  jmp _mfree_while0_exit
  jmp _mfree_while0
_mfree_while0_exit:
  lda SP
  clc
  adc #(0 & $ff)
  sta SP
  bcc * + 4
  inc SP + 1
_mfree_if4_exit:
  jmp _mfree_exit
_mfree_insert:
_mfree_while1:
  lda SP
  sec
  sbc #(0 & $ff)
  sta SP
  bcs * + 4
  dec SP + 1
  lda R7
  ldx R7 + 1
  sta R0
  stx R0 + 1
  ldy #((2 + 1) & $ff)
  lda (R0), y
  tax
  tya
  bne * + 4
  dec R0 + 1
  dey
  lda (R0), y
  sta R5
  stx R5 + 1
  lda R7
  ldx R7 + 1
  sta R0
  stx R0 + 1
  lda _pos
  ldx _pos + 1
  ldy #(2 & $ff)
  sta (R0), y
  iny
  bne * + 4
  inc R0 + 1
  txa
  sta (R0), y
  lda R5
  ldx R5 + 1
  sta _pos
  stx _pos + 1
  lda R7
  ldx R7 + 1
  sta R0
  stx R0 + 1
  ldy #((0 + 1) & $ff)
  lda (R0), y
  tax
  tya
  bne * + 4
  dec R0 + 1
  dey
  lda (R0), y
  sta R5
  stx R5 + 1
  lda R7
  ldx R7 + 1
  sta R0
  stx R0 + 1
  lda _size
  ldx _size + 1
  ldy #(0 & $ff)
  sta (R0), y
  iny
  bne * + 4
  inc R0 + 1
  txa
  sta (R0), y
  lda R5
  ldx R5 + 1
  sta _size
  stx _size + 1
  lda R7
  ldx R7 + 1
  clc
  adc #(4 & $ff)
  tay
  txa
  adc #(4 >> 8)
  tax
  tya
  sta R7
  stx R7 + 1
  lda SP
  clc
  adc #(0 & $ff)
  sta SP
  bcc * + 4
  inc SP + 1
  lda R5
  ldx R5 + 1
  tay
  bne * + 8
  txa
  bne * + 5
  jmp _mfree_while1_exit
  jmp _mfree_while1
_mfree_while1_exit:
  jmp _mfree_exit
_mfree_mergelow:
  lda R7
  ldx R7 + 1
  sta R0
  stx R0 + 1
  lda _pos
  ldx _pos + 1
  ldy #(2 & $ff)
  sta (R0), y
  iny
  bne * + 4
  inc R0 + 1
  txa
  sta (R0), y
  lda R7
  ldx R7 + 1
  sta R0
  stx R0 + 1
  lda _size
  ldx _size + 1
  sta R1
  stx R1 + 1
  lda R7
  ldx R7 + 1
  sta R2
  stx R2 + 1
  ldy #((0 + 1) & $ff)
  lda (R2), y
  tax
  tya
  bne * + 4
  dec R2 + 1
  dey
  lda (R2), y
  clc
  adc R1
  tay
  txa
  adc R1 + 1
  tax
  tya
  ldy #(0 & $ff)
  sta (R0), y
  iny
  bne * + 4
  inc R0 + 1
  txa
  sta (R0), y
_mfree_exit:
  rts
_main:
  lda #(0 & $ff)
  ldx #(0 >> 8)
  sta _pos
  stx _pos + 1
  lda #(257 & $ff)
  ldx #(257 >> 8)
  sta _size
  stx _size + 1
  jsr _mfree
  lda #(512 & $ff)
  ldx #(512 >> 8)
  sta _pos
  stx _pos + 1
  lda #(1 & $ff)
  ldx #(1 >> 8)
  sta _size
  stx _size + 1
  jsr _mfree
  lda #(257 & $ff)
  ldx #(257 >> 8)
  sta _pos
  stx _pos + 1
  lda #(255 & $ff)
  ldx #(255 >> 8)
  sta _size
  stx _size + 1
  jsr _mfree
  lda #(0 & $ff)
  ldx #(0 >> 8)
  jmp _main_exit
_main_exit:
  rts
