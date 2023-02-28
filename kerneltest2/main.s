

	include defs.s
	include cregs.s
	include emu.s



; crt.s
	global pre_init
	global _main


	section text

pre_init:
	DISPLAY "Hello, lol"
	PAUSE

	JAM
	rts


_main:
	DISPLAY "Hello, lol"
	PAUSE

	JAM

	bra _main
