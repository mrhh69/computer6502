
print_bin = $200C
print_bin_value = $200E


print_binary:
  pha

  ldy #16
  lda #0
  sta print_bin
  lda #%10000000
  sta print_bin + 1
bin_loop:
  lda print_bin_value
  and print_bin
  sta $00
  lda print_bin_value + 1
  and print_bin + 1
  ora $00

  beq if_zero
  lda #"1"
  jmp if_one
if_zero:
  lda #"0"
if_one:
  jsr print_char

  lsr print_bin + 1
  ror print_bin
  dey
  bne bin_loop

  pla
  rts
