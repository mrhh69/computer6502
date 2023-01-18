;vcprmin=10000
	section	text
	global	_new_handler_ca1
_new_handler_ca1:
	rts
; stacksize=0+??
;vcprmin=10000
	section	text
	global	_new_handler_timer1
_new_handler_timer1:
	rts
; stacksize=0+??
;vcprmin=10000
	section	text
	global	_call_handlers
_call_handlers:
	lda	r16
	pha
	lda	r17
	pha
	lda	r18
	pha
	lda	r20
	pha
	lda	r21
	pha
	lda	r1
	sta	r21
	lda	r0
	sta	r20
	stz	r18
l13:
	lda	r18
	ldx	#0
	stx	r31
	asl
	rol	r31
	ldx	r31
	clc
	adc	r20
	sta	r0
	txa
	adc	r21
	sta	r1
	ldy	#1
	lda	(r0),y
	bne	l17
	lda	(r0)
	beq	l12
l17:
	ldy	#1
	lda	(r0),y
	sta	r17
	lda	(r0)
	sta	r16
	jsr	l18
l12:
	inc	r18
	lda	r18
	cmp	#4
	bcc	l13
	pla
	sta	r21
	pla
	sta	r20
	pla
	sta	r18
	pla
	sta	r17
	pla
	sta	r16
	rts
l18:
	jmp	(r16)
; stacksize=0+??
;vcprmin=10000
	section	text
	global	_get_swtch
_get_swtch:
	lda	#255
	sta	r5
	stz	r7
	stz	r6
	stz	r4
l41:
	lda	r4
	asl
	asl
	asl
	sta	r8
	tay
	lda	1+_processes,y ;am(r8)
	beq	l32
	lda	r6
	ora	r7
	bne	l28
	lda	r4
	sta	r6
	stz	r7
	bra	l32
l28:
	lda	r6
	asl
	asl
	asl
	sta	r31
	tax
	pha
	ldy	r31
	lda	0+_processes,y ;am(r31)
	ldy	r8
	cmp	0+_processes,y ;am(r8)
	bcc	l46
	beq	l46
	pla
	lda	r4
	sta	r6
	stz	r7
l30:
	lda	r6
	asl
	asl
	asl
	sta	r31
	tay
	lda	0+_processes,y ;am(r31)
	sta	r2
	cmp	r5
	bcs	l32
	lda	r2
	sta	r5
l32:
	inc	r4
	lda	r4
	cmp	#8
	bcc	l41
	lda	r5
	beq	l44
	stz	r4
l42:
	lda	r4
	asl
	asl
	asl
	sta	r2
	tay
	lda	1+_processes,y ;am(r2)
	beq	l40
	ldy	r2
	lda	0+_processes,y ;am(r2)
	sec
	sbc	r5
	ldy	r2
	sta	0+_processes,y ;am(r2)
l40:
	inc	r4
	lda	r4
	cmp	#8
	bcc	l42
l44:
	ldx	r6
	lda	#0
	stx	r31
	asl
	rol	r31
	ldx	r31
	clc
	adc	#<(_processes_data)
	pha
	txa
	adc	#>(_processes_data)
	tax
	pla
	rts
l46:
	pla
	bra	l30
; stacksize=0+??
;vcprmin=10000
	section	text
	global	_newproc
_newproc:
	sta	r8
	stx	r9
	stz	r6
l55:
	lda	r6
	asl
	asl
	asl
	sta	r7
	lda	#<(1+_processes)
	clc
	adc	r7
	sta	r4
	lda	#>(1+_processes)
	adc	#0
	sta	r5
	lda	(r4)
	bne	l54
	lda	#0
	ldy	r7
	sta	0+_processes,y ;am(r7)
	lda	#1
	sta	(r4)
	lda	r6
	tax
	lda	#0
	stx	r31
	asl
	rol	r31
	ldx	r31
	sta	r31
	clc
	adc	#<(64+_processes_data)
	sta	r0
	txa
	adc	#>(64+_processes_data)
	sta	r1
	lda	#0
	sta	(r0)
	lda	r31
	clc
	adc	#<(65+_processes_data)
	sta	r0
	txa
	adc	#>(65+_processes_data)
	sta	r1
	lda	#64
	sta	(r0)
	lda	r6
	ina
	sta	r0
	lda	r31
	clc
	adc	#<(_processes_data)
	sta	r2
	txa
	adc	#>(_processes_data)
	sta	r3
	lda	r0
	sta	(r2)
	lda	r31
	clc
	adc	#<(1+_processes_data)
	sta	r0
	txa
	adc	#>(1+_processes_data)
	sta	r1
	lda	#249
	sta	(r0)
	lda	r31
	clc
	adc	#<(510+_processes_data)
	sta	r0
	txa
	adc	#>(510+_processes_data)
	sta	r1
	lda	r9
	ldy	#1
	sta	(r0),y
	lda	r8
	sta	(r0)
	lda	#32
	ldy	#3
	sta	(r0),y ;am(3)
	rts
l54:
	inc	r6
	lda	r6
	cmp	#8
	bcc	l55
l56:
	rts
; stacksize=0+??
	global	_processes
	global	_processes_data
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
