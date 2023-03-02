
	extern _main
	extern __data_start


; header
; (8 bytes long)


	;assert (__data_start >> 8) == $02
	;assert (__bss_start  >> 8) == $02

	section .header
; entrypoint (offs 0)
	word _main
; data info  (offs 2)
	word __data_loc
	byte __data_size
	byte __data_start & $ff
; bss info   (offs 6)
	byte __bss_size
	byte __bss_start & $ff
