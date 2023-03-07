
  include kdefs.s
	include emu.s


	global _main


	section text

_main:
	DISPLAY "entered _main of test!"
	PAUSE

 
 .loop:
  brk
  byte BRK_SWTCH
  
  DISPLAY "test swtch loop"
  PAUSE
  bra .loop