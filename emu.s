


DEBUG=1

;UPDATE = $02
;JAM = $03
;PAUSE = $13
;DISPLAY = $22

	macro DISPLAY
	if DEBUG
	byte $22
	asciiz \1
	endif
	endmacro

	macro JAM
	if DEBUG
	byte $03
	endif
	endmacro

	macro PAUSE
	if DEBUG
	byte $13
	endif
	endmacro

  macro UPDATE
  if DEBUG
  byte $02
  endif
  endmacro