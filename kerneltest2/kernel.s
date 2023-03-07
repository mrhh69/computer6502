
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
  global brk_exec

  global exec
  extern exec_table


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
; Don't store proc.pid
  ldy #15
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
  ldy #PPDA_PID
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
  ldx PPDA_SP ; load sp
  txs
  pla
  plx
  ply
  DISPLAY "swtch Entering..."
  UPDATE
  rti





brk_swtch:
	phy
	phx
	pha

	lda PPDA_PID
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
swtch_no_copy:
; get PID of next process
	ldy PPDA_PID
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
; set the PID of the new process
; (proc.pid is NOT copy_out'd)
  txa
  ldy #PPDA_PID
  sta (kr0), y    ; set PID in ppda
; do a copy_out to the new process
; (copy the *active* ppda)
; NOTE: copy_out does NOT preserve y register
  jsr copy_out
  ;DISPLAY "test"
  ;PAUSE
; return a 1 to the calling process
  pla
  lda #1
  pha
  jmp swtchin



; initialize process slot with program file
; takes pointer to program file in kr0
; takes PID in x
exec:
  lda #1
  sta _processes, x
; convert PID to ppda pointer
  txa
  sta kr1
	asl
	clc
	adc kr1
	clc
	adc #>_processes_data
	sta kr1+1
	lda #<_processes_data
	sta kr1

; set up base image
  ldy #sp
  lda #<PROC_SP
	sta (kr1),y
  iny
	lda #>PROC_SP
	sta (kr1),y    ; sw sp

	txa
  ldy #PPDA_PID
	sta (kr1),y ; pid
	lda #$f9
  ldy #PPDA_SP
	sta (kr1),y ; hw sp

  inc kr1+1
  lda #PROC_SR
  ldy #$fa+3
	sta (kr1),y ; sr

; get entry point
  ldy #0
  lda (kr0),y
  ldy #$fa+4
	sta (kr1),y ; pc lsb
  ldy #1
	lda (kr0),y
  ldy #$fa+5
	sta (kr1),y ; pc msb


; do bss and data initialization
; put bss_start in x
; put bss_size in y
  ldy #6
  lda (kr0),y
  tax
  iny
  lda (kr0),y
  tay
; move ppda pointer to ppda+$200
; (NOTE: kr1 is already at ppda+$100)
  inc kr1+1
; do bss init
.bss_loop:
  lda #0
  sta (kr1),y
  iny
  dex
  bne .bss_loop

; put data_loc in kr2
; put data_start in y
; put data_size in x
  ldy #2
  lda (kr0),y
  sta kr2
  iny
  lda (kr0),y
  sta kr2+1

  iny
  lda (kr0),y
  tax
  iny
  lda (kr0),y
  tay

.data_loop:
  lda (kr2)
  sta (kr1),y
  inc kr2
  bne .noz
  inc kr2+1
.noz:
  dex
  bne .data_loop

  rts


; system call wrapper for exec
; exec takes a pointer to a file
; brk_exec takes a char * (name of process) in a/x
;  (user space)
; NOTE: exec is just re-initializing the calling process' slot
; meaning the current ppda does not have to be preserved
brk_exec:
  sta kr0
  stx kr0+1

  lda #<exec_table
  ldx #>exec_table
  sta kr1
  stx kr1+1

  ldx #0
.tab_loop:
  ldy #0
.cmp_loop:
  lda (kr1), y   ; load char from exec table
  cmp (kr0), y   ; compare against called name
  bne .failed
  cmp #0
  beq .found
  iny
  bra .cmp_loop
  
.failed:
; this table entry does not match
  lda kr1
  clc
  adc #16
  sta kr1
  bcc .noc
  lda kr1+1
.noc:
  inx
  cpx #NUM_USER
  bne .tab_loop
  
; not matching exec entry found
  DISPLAY "NO EXEC ENTRY FOUND"
  PAUSE
  JAM

.found:
; found matching process name
; set up exec call
  DISPLAY "found process"
  PAUSE
  ldy #14
  lda (kr1),y
  sta kr0
  iny
  lda (kr1),y
  sta kr0+1

  ldx PPDA_PID
  DISPLAY "jumping to exec"
  PAUSE
  jsr exec
  DISPLAY "exec ret"
  PAUSE
; extremely ugly solution here: FIX IT
  jmp swtch_no_copy





  section bss

_processes_data:
  reserve 256*3*NUM_PROCS
_processes:
  reserve 1*NUM_PROCS
