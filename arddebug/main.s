




PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
T1CL = $6004 ;T1 counter latches
T1CH = $6005
T1LL = $6006 ; T1 latches
T1LH = $6007
T2LC = $6008
T2LH = $6009
SR =  $600A
ACR = $600B ; Auxillary Control Register (T1, T2, SR, )
PCR = $600C ; CA,CB Control (interrupt lines)
IFR = $600D ; Interrupt Flags Register
IER = $600E ; Interrupt Enable Register



  section bss
debug_a: reserve 1 ; A,X,Y regs
debug_x: reserve 1
debug_y: reserve 1
debug_p: reserve 1 ; Processor status
debug_s: reserve 1 ; Stack Pointer
debug_reg = $0c

  section .text.entry
reset:
  sei
  ldx #$ff
  txs
  lda #$ff
  sta DDRB
  lda #%11111101
  sta DDRA
  lda #0
  sta PORTA
  sta PORTB
  sta ACR

  lda #48
  ldx #69
  ldy #$55
  jsr debug

  stp



CMD_A = 1
CMD_X = 2
CMD_Y = 3
CMD_PS = 4
CMD_SP = 5
;CMD_PC = 6
CMD_READ = 8
CMD_CONTINUE = 7

debug:
  php
  sei
  sta debug_a
  stx debug_x
  sty debug_y
  pla
  sta debug_p
  tsx
  stx debug_s

.docmdwait:
  jsr debug_getbyte

  sta PORTB
  cmp #CMD_A
  beq .a
  cmp #CMD_X
  beq .x
  CMP #CMD_Y
  beq .y
  cmp #CMD_PS
  beq .ps
  cmp #CMD_SP
  beq .sp

  cmp #CMD_READ
  beq .read

  cmp #CMD_CONTINUE
  beq .continue

  ora #$80
  sta PORTA
  stp

.a:
  lda debug_a
  bra .write_back
.x:
  lda debug_x
  bra .write_back
.y:
  lda debug_y
  bra .write_back
.ps:
  lda debug_p
  bra .write_back
.sp:
  lda debug_s
  bra .write_back

.read: ; Read 2 more bytes from Arduino (low byte, high byte)
  jsr debug_getbyte
  sta debug_reg
  jsr debug_getbyte
  sta debug_reg + 1
  lda (debug_reg)
  bra .write_back

.write_back: ; Write val in A register to arduino
  ldx #%00011100 ; SR (shift out) extern CB1 control
  stx ACR  ; reset shift register (by writing the value we want to send to it)
  sta SR
  ;sta PORTB

  lda #1
  sta PORTA ; signal ready for write

  lda #%10
.waitsrw:  ; Wait for ARD to write 1
  bit PORTA
  beq .waitsrw

  lda #0
  sta PORTA
  lda #%10
.waitdoneh: ; Wait for Arduino 0
  bit PORTA
  bne .waitdoneh

  bra .docmdwait

.continue: ; TODO: restore ACR, PORTA, PORTB
  ;ldx debug_s
  ;txs
  lda debug_p
  php
  ldy debug_y
  ldx debug_x
  lda debug_a
  plp
  rts



;---Getbyte process:
; Both start at 0
; 6502     Arduino
; 1   ---> 0
; 1   <--- 1
; 6502 prepares SR for input
; 0   ---> 1
; Arduino writes to SR
; 0   <--  0
; 6502 reads from SR
debug_getbyte:
  lda #1
  sta PORTA
  lda #%10
.waitcmd:
  bit PORTA
  beq .waitcmd
  ; Arduino has signalled sending command
  lda #%00001100 ; SR external CB1 control
  sta ACR
  ;lda #%10000100   ; SR interrupt enable
  ;sta IER
  lda SR ; Reset SR

  lda #0
  sta PORTA ; Signal ready

  lda #%10  ; Wait for Arduino 0
.waitsr:
  bit PORTA
  bne .waitsr

  lda SR
  stz ACR
  rts


irq:
nmi:
  rti

  section .text.vectors
  word nmi
  word reset
  word irq
