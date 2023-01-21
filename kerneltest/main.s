;vcprmin=10000
	section	text
	global	_main
_main:
	lda	#255
	sta	24578
	sta	24579
	stz	24576
	lda	#0
	sta	24577
	stz	24587
	stz	24588
	lda	#192
	sta	24590
	stz	24589
;startinline
cli
;endinline
	lda	#1
	stz	r0
	jsr	_lcd_init
	lda	#105
	jsr	_putc
	lda	#1
	sta	24588
	lda	#194
	sta	24590
	stz	24589
	lda	#64
	sta	24587
	lda	#255
	sta	24580
	sta	24581
	ldx	#>(_systemd)
	lda	#<(_systemd)
	jsr	_newproc
	lda	#>(_processes)
	sta	r1
	lda	#<(_processes)
	sta	r0
	jmp	_swtchin
; stacksize=0+??
	global	_processes
	section	bss
_processes:
	reserve	4096
	global	_handlers_ca1
	section	bss
_handlers_ca1:
	reserve	8
	global	_handlers_timer1
	section	bss
_handlers_timer1:
	reserve	8
	global	_newproc
	global	_lcd_init
	global	_putc
	global	_systemd
	global	_swtchin
	zpage	sp
	zpage	r0
	zpage	r1
	zpage	r2
	zpage	r3
	zpage	r4
	zpage	r5
	zpage	r6
	zpage	r7
	zpage	r8
	zpage	r9
	zpage	r10
	zpage	r11
	zpage	r12
	zpage	r13
	zpage	r14
	zpage	r15
	zpage	r16
	zpage	r17
	zpage	r18
	zpage	r19
	zpage	r20
	zpage	r21
	zpage	r22
	zpage	r23
	zpage	r24
	zpage	r25
	zpage	r26
	zpage	r27
	zpage	r28
	zpage	r29
	zpage	r30
	zpage	r31
	zpage	btmp0
	zpage	btmp1
	zpage	btmp2
	zpage	btmp3

	include cregs.s
