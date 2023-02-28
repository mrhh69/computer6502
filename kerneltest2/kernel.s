
  include cregs.s
  include emu.s


  global copy_out

; kernel temp registers
kr0=$0e
kr1=$0c

  section text
; proc data address in kr0
copy_out:
; put return address into kr1
; (stored on stack lsb..msb)
  ply
  sty kr1
  ply
  sty kr1+1
; need to increment because (no idea)
  inc kr1
  bne .noz
  inc kr1+1
.noz:
; copy process image out
  ldy #$10
.yloop1:
  lda $0000, y
  sta (kr0), y
  iny
  bne .yloop1
; y is 0 here (no need to ldy #0)
  inc kr0+1
.yloop2:
  lda $0100, y
  sta (kr0), y
  iny
  bne .yloop2
  
  inc kr0+1
.yloop3:
  lda $0200, y
  sta (kr0), y
  iny
  bne .yloop3
; now jump to the return address (saved into kr1)
  DISPLAY "returning"
  PAUSE
  jmp (kr1)


NUM_PROCS=8
  section bss
_processes:
  reserve 1*NUM_PROCS
_processes_data:
  reserve 256*3*NUM_PROCS