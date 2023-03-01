
	include kdefs.s
	include emu.s


	global _entry


	section text

_entry:
	DISPLAY "entered _entry!"
	PAUSE

	ldx #2
	ldy #3

	brk
	byte BRK_FORK

	cmp #0
	beq _entry_forked
.loop:
	DISPLAY "_entry.loop!"
	PAUSE
	inx
	iny

	brk
	byte BRK_SWTCH

	bra .loop



_entry_forked:
.loop:
	DISPLAY "_entry_forked .loop!"
	PAUSE
	inx
	inx
	iny
	iny

	brk
	byte BRK_SWTCH
	
	bra .loop
