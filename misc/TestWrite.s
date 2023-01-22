


  include "Definitions.s"
  ;org $8000
  section .text.entry
reset:
  sei
  ldx #$ff
  txs

  stx DDRA
  stx DDRB
  lda PORTA
  ldx PORTB
  sta $02
  stx $03
  ;lda #0
  ;sta PORTA
  ;sta PORTB

  lda #%00000000
  sta ACR
  lda #%00000001 ;
  sta PCR
  lda #%11000010 ; S/CB, T1, T2, CB1, CB2, SR, CA1, CA2
  sta IER
  lda #0
  sta IFR

  cli
  jsr initialize_lcd

  ;ldx #<string
  ;ldy #>string
  ;jsr printf

  ; TODO: find a way to get a (real) random seed
  lda #$00
  sta DDRA
  lda PORTA
  ;lda ($02)
  ;lda #((150) & $ff) ; Seed
  ldx #0
  sta multiplication_value
  stx multiplication_value + 1




lcg_loop:
  ldx #((249) & $ff) ; Multiplier (a)
  ldy #((249) >> 8)
  stx multiplicant
  sty multiplicant + 1

  jsr multiply

  lda #((15) & $ff) ; Increment (c)
  clc
  adc multiplication_answer
  sta value
  lda #((15) >> 8)
  adc multiplication_answer + 1
  sta value + 1

  lda #((254) & $ff) ; Modulus (m)
  ldx #((254) >> 8)
  sta divisor
  stx divisor + 1


  jsr divide

  lda mod
  ldx mod + 1
  sta multiplication_value
  stx multiplication_value + 1

  ;jmp lcg_loop


  lda multiplication_value ; mod(15)
  ldx multiplication_value + 1
  sta value
  stx value + 1
  lda #(PRINTS_LEN)
  ldx #0
  sta divisor
  stx divisor + 1
  jsr divide


  lda #%10
  jsr lcd_instruction

; Get the pointer
  lda mod
  asl
  tay
  ldx _prints, y
  lda _prints + 1, y
  tay
  jsr printf

  stp



  ; dump multiplication_value to lcd
  lda #$80
  sta $00
print_loop1:
  lda mod + 1
  and $00
  beq print_loop1_zero
  lda #'1'
  jmp print_loop1_continue
print_loop1_zero:
  lda #'0'
print_loop1_continue:
  jsr print_char
  lsr $00
  bne print_loop1

  lda #$80
  sta $00
print_loop2:
  lda mod
  and $00
  beq print_loop2_zero
  lda #'1'
  jmp print_loop2_continue
print_loop2_zero:
  lda #'0'
print_loop2_continue:
  jsr print_char
  lsr $00
  bne print_loop2

  WAIT_US 1000000

  jmp lcg_loop


done:
  lda #1
  sta PORTA

halt:
  stp

  section rodata
string: asciiz "Hello, world!\nTime to hack :)"
; Macbook:
string_mac_asm:  asciiz "Macbook\nx86_64 assembly"
string_mac_c:    asciiz "Macbook\nC (yay)"
string_mac_cpp:  asciiz "Macbook\nC++"
string_mac_java: asciiz "Macbook\nJava (good luck)"
string_mac_py:   asciiz "Macbook\nPython"
; Raspi:
string_raspi_asm:  asciiz "Raspberry Pi 3b\nArm 64 assembly"
string_raspi_c:    asciiz "Raspberry Pi 3b\nC (yay)"
string_raspi_cpp:  asciiz "Raspberry Pi 3b\nC++"
string_raspi_java: asciiz "Raspberry Pi 3b\nJava (good luck)"
string_raspi_py:   asciiz "Raspberry Pi 3b\nPython"
; Arduino:
string_ard_asm:    asciiz "Arduino\nAVR assembly"
string_ard_c:      asciiz "Arduino\nC (yay)"
string_ard_cpp:    asciiz "Arduino\nC++ (boring, ik)"
; 6502:
string_6502_asm:   asciiz "6502 Computer\n6502 assembly"
string_6502_c:     asciiz "6502 Computer\nC (yay)"

PRINTS_LEN = 15
_prints:
; Macbook:
  word string_mac_asm
  word string_mac_c
  word string_mac_cpp
  word string_mac_java
  word string_mac_py
; Raspi:
  word string_raspi_asm
  word string_raspi_c
  word string_raspi_cpp
  word string_raspi_java
  word string_raspi_py
; Arduino:
  word string_ard_asm
  word string_ard_c
  word string_ard_cpp
; 6502:
  word string_6502_asm
  word string_6502_c

; Not actually printf, it's puts()
; X-> (low address) Y-> (high address)
  section text
printf:
  stx $00
  sty $01
  ldy #0
.printf_loop:
  lda ($00), y
  beq .printf_exit
  cmp #'\n'
  beq .printf_newline
  jsr print_char
  jmp .printf_next
.printf_newline:
  ; Move to next line:
  lda #(%10000000 | ($40))
  jsr lcd_instruction
.printf_next:
  iny
  jmp .printf_loop
.printf_exit:
  rts


irq:
  pha
; Determine source of interrupt:
  lda IFR
  sta PORTA

  bit #%01000000
  beq .not_timer1
.irq_timer1: ; Timer1 interrupt
  lda #%01000000 ; Clear Interrupt flag
  sta IFR
  jmp .irq_out

.not_timer1:
  bit #%00000010
  beq .not_ca1
.irq_ca1: ; CA1 Interrupt
  lda #%00000010 ; Clear Flag
  sta IFR
  lda #%10
  ora PORTA
  sta PORTA

  jmp .irq_out

.not_ca1: ; Should not happen hopefully:
  lda #$aa
  sta PORTB
  jmp halt

.irq_out:
  pla
  rti

nmi:
  rti


CURSOR_ON = 1
CURSOR_BLINK = 0
  include 4BitLCD.s

  include Math.s

  section .text.vectors
  word nmi
  word reset
  word irq
