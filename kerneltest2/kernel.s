
  include cregs.s
  include emu.s
  include kdefs.s


  global copy_out
  global copy_in
  global swtchin
  global _processes
  global _processes_data
; for crt.s (system calls)
  global brk_swtch
  global brk_fork

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
  ldy #14
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
  jmp (kr1)



copy_in:
; put return address into kr1
  ply
  sty kr1
  ply
  sty kr1+1
; need to increment because (no idea)
  inc kr1
  bne .noz
  inc kr1+1
.noz:
; copy process image in
  ldy #14
.yloop1:
  lda (kr0), y
  sta $000, y
  iny
  bne .yloop1
; y is 0 here (no need to ldy #0)
  inc kr0+1
.yloop2:
  lda (kr0), y
  sta $100, y
  iny
  bne .yloop2

  inc kr0+1
.yloop3:
  lda (kr0), y
  sta $200, y
  iny
  bne .yloop3
; now jump to the return address (saved into kr1)
  jmp (kr1)







swtchin:
  ;DISPLAY "swtchin"
  ;PAUSE

  ldx 15 ; load sp ((struct process *)0->proc.sp)
  txs
  pla
  plx
  ply
  DISPLAY "swtch Entering..."
  PAUSE
  rti





brk_swtch:
	phy
	phx
	pha

	lda 14 ; PID
  PAUSE
; derive ppda from PID
	sta kr0
	asl
	clc
	adc kr0
	clc
	adc #>_processes_data
	sta kr0+1
	lda #<_processes_data
	sta kr0
; save process into mem ($000-$2ff are ok to modify now)
	jsr copy_out

; get PID of next process
	ldy 14
.loop:
	iny
	cpy #NUM_PROCS
	bcc .f
	ldy #0
.f:
	;DISPLAY "try pid"
	;PAUSE
	lda _processes,y
	bne .loopout
	bra .loop
.loopout:
; y holds PID
; derive ppda from PID
	tya
	sta kr0
	asl
	clc
	adc kr0
	clc
	adc #>_processes_data
	sta kr0+1
	lda #<_processes_data
	sta kr0
; copy new process in
	jsr copy_in

	jmp swtchin



; a and x are already preserved
brk_fork:
  phy
	phx
; return a 0 to the forked process
  lda #0
	pha
; find an available PID
  ldx #0
.loop:
  lda _processes, x
  beq .loopout
  inx
  cmp #NUM_PROCS
  bcc .loop
  DISPLAY "OUT OF PROCESS SLOTS!"
  PAUSE
  JAM
.loopout:
; set up process slot:
  lda #1
  sta _processes, x   ; set proc.flag to 1, indicating slot is used
; convert PID to ppda pointer
  txa
  sta kr0
	asl
	clc
	adc kr0
	clc
	adc #>_processes_data
	sta kr0+1
	lda #<_processes_data
	sta kr0
  txa
  ldy #14
  sta (kr0), y    ; set PID in ppda
  DISPLAY "test"
  PAUSE
; do a copy_out to the new process
; (copy the *active* ppda)
; NOTE: copy_out does NOT preserve y register
  jsr copy_out
; return a 1 to the calling process
  pla
  lda #1
  pha
  jmp swtchin







  section bss

_processes:
  reserve 1*NUM_PROCS
_processes_data:
  reserve 256*3*NUM_PROCS
