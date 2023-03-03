
	include kdefs.s
	include emu.s


	global _main


	section text


	macro CPUTC
	brk
	byte BRK_PUTC
	endmacro

_main:
	DISPLAY "entered _entry!"
	PAUSE

	lda #LCD_NO
.ploop:
  ldx #LCD_C_LCDINS
	CPUTC
	ldx _data_var
	CPUTC
	ldx #LCD_C_PUTC
	CPUTC
	lda _data_var
	sec
	sbc #56
	tax
	lda #LCD_NO
	CPUTC

  DISPLAY "_entry putc"
  PAUSE
  inc _data_var
  bra .ploop

  JAM

  ;lda #1
	;sta _bss_var
  ldx #2
	ldy #3

	brk
	byte BRK_FORK

	cmp #0
	beq _entry_forked
.loop:
	DISPLAY "_entry.loop!"
	PAUSE

  lda _bss_var
  ldx _data_var
	;PAUSE
  inc
  sta _bss_var
  inx
  stx _data_var
	iny

	brk
	byte BRK_SWTCH

	bra .loop


_entry_forked:
.loop:
	DISPLAY "_entry_forked .loop!"
	PAUSE

  lda _bss_var
  ldx _data_var
  inc
	inc
  sta _bss_var
  inx
  inx
  stx _data_var
  iny
	iny

	brk
	byte BRK_SWTCH

	bra .loop


  section bss
_bss_var: reserve 1

  section data
_data_var: byte $69
