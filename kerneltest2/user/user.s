
	include kdefs.s
	include emu.s


	global _entry


	section text

  lda #>__user_data_loc
_entry:
	DISPLAY "entered _entry!"
	PAUSE

  lda #1
  ldx #2
	ldy #3

	brk
	byte BRK_FORK

	cmp #0
	beq _entry_forked
.loop:
  lda _bss_var
  ldx _data_var
	DISPLAY "_entry.loop!"
	;PAUSE
  inc
  sta _bss_var
  inx
  stx _data_var
	iny

  PAUSE

	brk
	byte BRK_SWTCH

	bra .loop


_entry_forked:
.loop:
  lda _bss_var
  ldx _data_var
	DISPLAY "_entry_forked .loop!"
	PAUSE
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