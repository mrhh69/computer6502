
; Division Addresses
value = $0200        ; 2 bytes
mod = $0202        ; 2 bytes (not actually mod10 btw, it's just the mod answer)
divisor = $0204      ; 2 bytes

; Multiplication Addresses
multiplication_value = $0206
multiplicant = $0208
multiplication_answer = $020A




multiply:
  lda #0
  sta multiplication_answer
  sta multiplication_answer + 1

  ldx #16
multiplication_loop:

  lda multiplicant              ; If bottom bit of multiplicant 1
  and #1
  beq ignore_bit

  lda multiplication_answer     ; Add shifted value to answer
  clc
  adc multiplication_value
  sta multiplication_answer

  lda multiplication_answer + 1
  adc multiplication_value + 1
  sta multiplication_answer + 1

ignore_bit:
  lsr multiplicant + 1
  ror multiplicant
  asl multiplication_value
  rol multiplication_value + 1

  dex
  bne multiplication_loop

  rts                               ; multiplication_value contains answer, a,x,y register values changed
  ; multiplicant changed


; value, mod10, divisor all need to be set up correctly before calling
; =a     =0     =b          a / b
; Does this work for signed numbers????
divide:      ; assumes number and mod10 are correctly initialized
  txa
  pha

  stz mod
  stz mod + 1

  ldx #16

divide_loop:
  clc
  rol value
  rol value + 1
  rol mod
  rol mod + 1

  sec
  lda mod
  sbc divisor
  tay
  lda mod + 1
  sbc divisor + 1
  bcc ignore_result

  sty mod
  sta mod + 1
ignore_result:
  dex
  bne divide_loop

  rol value
  rol value + 1

  pla
  tax
  rts             ; mod holds mod and value holds result; A, Y register - clobbered; X register - saved
