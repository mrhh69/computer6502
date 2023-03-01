

	include defs.s
	include cregs.s
	include kdefs.s
	include emu.s


  extern copy_out
	extern copy_in
	extern swtchin
	extern _processes_data

; crt.s
	global pre_init
	global _main

; user.s
	extern _entry



PROC_SP=$2ff
PROC_SR=$20


	section text

pre_init:
	DISPLAY "pre_init"
	rts


_main:
	DISPLAY "_main"

	lda #1
	sta _processes   ; proc.flags

	lda #<PROC_SP
	sta _processes_data+sp
	lda #>PROC_SP
	sta _processes_data+sp+1
	lda #0
	sta _processes_data+PPDA_PID ; pid
	lda #$f9
	sta _processes_data+PPDA_SP ; sp
	lda #<_entry
	sta _processes_data+$1fa+4 ; pc lsb
	lda #>_entry
	sta _processes_data+$1fa+5 ; pc msb
	lda #PROC_SR
	sta _processes_data+$1fa+3 ; sr


  lda #<_processes_data
  ldx #>_processes_data
  sta kr0
  stx kr0+1
  jsr copy_in

  DISPLAY "copy_in done"
  PAUSE

	jmp swtchin
