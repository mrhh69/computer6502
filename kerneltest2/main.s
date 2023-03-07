

	include defs.s
	include cregs.s
	include kdefs.s
	include emu.s


	extern copy_in
	extern swtchin
	extern _processes_data
	extern exec

; crt.s
	global pre_init
	global _main

; kalloc.c
	extern _init_heap
	extern _kalloc
	extern _kfree
	extern _tests

	section text




	global ___rsave8
	global ___rload8
; fuck you
___rsave8:
___rload8:
	rts




pre_init:
	DISPLAY "pre_init"

	jsr _init_heap

	jsr _tests


	JAM


	rts


_main:
	DISPLAY "_main"

	lda #<entry_user
	ldx #>entry_user
	sta kr0
	stx kr0+1

	ldx #0
	jsr exec

	DISPLAY "exec done!"
	PAUSE


  lda #<_processes_data
  ldx #>_processes_data
  sta kr0
  stx kr0+1
  jsr copy_in

  DISPLAY "copy_in done"
  PAUSE

	jmp swtchin



	global entry_user
entry_user:
	incbin "user/out.bin"
