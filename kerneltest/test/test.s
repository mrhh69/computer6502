;vcprmin=10000
	section	text
	global	_main
_main:
	ldx	#>(_systemd)
	lda	#<(_systemd)
	jsr	_newproc
	lda	#>(_processes)
	sta	r1
	lda	#<(_processes)
	sta	r0
	jsr	_swtchin
	ldx	#0
	txa
	rts
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
