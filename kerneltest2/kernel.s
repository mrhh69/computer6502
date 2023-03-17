
  include kcregs.s
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
  ;DISPLAY "swtch Entering..."
  ;UPDATE
  rts ;rti





brk_swtch:
	lda PPDA_PID
; derive ppda from PID
	sta r0
	asl
	clc
	adc r0
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
	lda _processes,y
	bne .loopout
	bra .loop
.loopout:
; y holds PID
; derive ppda from PID
	tya
	sta r0
	asl
	clc
	adc r0
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
; return a 0 to the forked process
; set re-entry address to a wrapper entry
  lda #>fork_entry
  pha
  lda #<fork_entry
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
  sta r0
	asl
	clc
	adc r0
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
; pull wrapper return off of the stack
  pla
  pla
; return a 1 to the calling process
  lda #1
  rts

; wrapper entry for forked process
fork_entry:
  lda #0
  rts


; initialize process slot with program file
; takes pointer to program file in kr0
; takes PID in x
exec:
  lda #1
  sta _processes, x
; convert PID to ppda pointer
  txa
  sta r2
	asl
	clc
	adc r2
	clc
	adc #>_processes_data
	sta r2+1
	lda #<_processes_data
	sta r2

; set up base image
  ldy #PROC_SPL
  lda #<PROC_SP
	sta (r2),y
  iny
	lda #>PROC_SP
	sta (r2),y    ; sw sp

	txa
  ldy #PPDA_PID
	sta (r2),y ; pid
; set kernel stack
	lda #KSTACK_START-3
  ldy #PPDA_SP
	sta (r2),y ; hw sp

  inc r2+1
  ;lda #PROC_SR
  ;ldy #$fa+3
	;sta (r2),y ; sr
  lda #<exec_entry-1
  ldy #KSTACK_START-2
  sta (r2),y
  lda #>exec_entry-1
  iny
  sta (r2),y
  lda #USTACK_START-2  ; where user stack starts
  iny
  sta (r2),y


; get entry point
  ldy #0
  lda (r0),y
  sec
  sbc #1     ; important: subtract 1 (jsr does that)
  ldy #USTACK_START-1
	sta (r2),y ; pc lsb
  ldy #1
	lda (r0),y
  sbc #0     ; sub 1
  ldy #USTACK_START-0
	sta (r2),y ; pc msb


; do bss and data initialization
; put bss_start in x
; put bss_size in y
  ldy #6
  lda (r0),y
  tax
  iny
  lda (r0),y
  tay
; move ppda pointer to ppda+$200
; (NOTE: kr2 is already at ppda+$100)
  inc r2+1
; do bss init
.bss_loop:
  lda #0
  sta (r2),y
  iny
  dex
  bne .bss_loop

; put data_loc in kr2
; put data_start in y
; put data_size in x
  ldy #2
  lda (r0),y
  sta r4
  iny
  lda (r0),y
  sta r4+1

  iny
  lda (r0),y
  tax
  iny
  lda (r0),y
  tay

.data_loop:
  lda (r4)
  sta (r2),y
  inc r2
  bne .noz
  inc r2+1
.noz:
  dex
  bne .data_loop

  rts

  byte "................"
exec_entry:
  plx     ; switch to user stack
  txs
  lda #1  ; return 1
  rts


; system call wrapper for exec
; exec takes a pointer to a file
; brk_exec takes a char * (name of process) in a/x
;  (user space)
; NOTE: exec is just re-initializing the calling process' slot
; meaning the current ppda does not have to be preserved
brk_exec:
  sta r0
  stx r0+1

  lda #<exec_table
  ldx #>exec_table
  sta r2
  stx r2+1

  ldx #0
.tab_loop:
  ldy #0
.cmp_loop:
  lda (r2), y   ; load char from exec table
  cmp (r0), y   ; compare against called name
  bne .failed
  cmp #0
  beq .found
  iny
  bra .cmp_loop

.failed:
; this table entry does not match
  lda r2
  clc
  adc #16
  sta r2
  bcc .noc
  lda r2+1
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
  lda (r2),y
  sta r0
  iny
  lda (r2),y
  sta r0+1

  ldx PPDA_PID
  DISPLAY "jumping to exec"
  PAUSE
  jsr exec
  DISPLAY "exec ret"
  PAUSE
; extremely ugly solution here: FIX IT?
  jmp swtch_no_copy





  section bss

_processes_data:
  reserve 256*3*NUM_PROCS
_processes:
  reserve 1*NUM_PROCS
