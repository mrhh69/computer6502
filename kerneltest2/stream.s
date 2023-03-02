
  include kdefs.s
  include emu.s

  global brk_putc
  
  global _streams


  section text
  
brk_putc:
  phy
; stream no in A
; data in X
put_stream:
; put stream struct ptr in kr0
  repeat 4
  asl
  endrepeat
  adc #<_streams
  sta kr0
  lda #>_streams
  adc #0
  sta kr0+1

  ldy #0
  lda (kr0), y
  bne .buf_full
  iny
  iny
  lda (kr0), y  ; stream end ptr into a
  tay
  repeat 3
  iny
  endrepeat
  txa
  sta (kr0), y
  ; increment y (end ptr) and store back
  dey
  dey
  cpy #13
  bcc .nog
  beq .nog
  ldy #0
.nog:
  tya
  ldy #2
  sta (kr0), y
  dey
  cmp (kr0), y   ; check end ptr
  bne .note
  DISPLAY "streambuf just filled"
  PAUSE
  lda #1
  ldy #0
  sta (kr0), y
.note:

  ply
  rts


.buf_full:
  DISPLAY "WRITING INTO A STREAMBUF THAT IS FULL"
  PAUSE
  JAM
  

  
  





  

  section bss

 ; struct stream
 ;   unsigned char flag; 
 ;     /* 1 = buffer is full */
 ;   unsigned char start;
 ;   unsigned char end;
 ;   char buf[13];
_streams:
  reserve 16*NUM_STREAMS