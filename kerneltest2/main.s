

	include defs.s
	include cregs.s
	include emu.s


  extern copy_out

  
; kernel temp registers
kr0=$0e
; crt.s
	global pre_init
	global _main


	section text

pre_init:
	DISPLAY "pre_init"
	rts


_main:
	DISPLAY "_main"

  lda #$69
  sta $020
  lda #$70
  sta $100
  lda #$89
  sta $200

  lda #<$1000
  ldx #>$1000
  sta kr0
  stx kr0+1
  jsr copy_out

  DISPLAY "copy_out done"
  PAUSE


	JAM

	bra _main
