
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
	;extern _kalloc
	;extern _kfree

	section text


pre_init:
	DISPLAY "pre_init"

	jsr _init_heap

	rts


_main:
	DISPLAY "_main"

	lda #<entry_init
	ldx #>entry_init
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


  section rodata
  global exec_table
exec_table:
; NOTE: for some reason using .ascii does not work ?
; it still adds a terminating null byte
  byte "init\0........."
  word entry_init
  byte "test\0........."
  word entry_test

	global entry_init
  global entry_test
entry_init:   incbin "user/init.pgm/out.bin"
entry_test:   incbin "user/test.pgm/out.bin"