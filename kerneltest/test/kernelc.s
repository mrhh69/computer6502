;vcprmin=10000
	section	text
	global	_new_handler_ca1
_new_handler_ca1:
	lda	r1
	sta	r5
	lda	r0
	sta	r4
	lda	r5
	sta	r1
	lda	r4
	sta	r0
	lda	#>(_handlers_ca1)
	sta	r3
	lda	#<(_handlers_ca1)
	sta	r2
	jmp	_new_handler
; stacksize=0+??
;vcprmin=10000
	section	text
	global	_new_handler_timer1
_new_handler_timer1:
	lda	r1
	sta	r5
	lda	r0
	sta	r4
	lda	r5
	sta	r1
	lda	r4
	sta	r0
	lda	#>(_handlers_timer1)
	sta	r3
	lda	#<(_handlers_timer1)
	sta	r2
	jmp	_new_handler
; stacksize=0+??
;vcprmin=10000
	section	text
	global	_new_handler
_new_handler:
	sec
	lda	sp
	sbc	#3
	sta	sp
	bcs	l17
	dec	sp+1
l17:
	lda	r1
	sta	r7
	lda	r0
	sta	r6
	stz	r0
	lda	#0
	ldy	#2
	sta	(sp),y
	lda	r3
	dey
	sta	(sp),y
	lda	r2
	dey
	sta	(sp),y
	iny
	lda	(sp),y
	sta	r5
	dey
	lda	(sp),y
	sta	r4
	ldy	#2
	lda	(sp),y
	sta	r2
l7:
	lda	r2
	ldx	#0
	stx	r31
	asl
	rol	r31
	ldx	r31
	clc
	adc	r4
	sta	r0
	txa
	adc	r5
	sta	r1
	ldy	#1
	lda	(r0),y
	bne	l12
	lda	(r0)
	bne	l12
	lda	r7
	ldy	#1
	sta	(r0),y
	lda	r6
	sta	(r0)
	bra	l14
l12:
	inc	r2
	lda	r2
	cmp	#4
	bcc	l7
l14:
	clc
	lda	sp
	adc	#3
	sta	sp
	bcc	l18
	inc	sp+1
l18:
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
;startinline
	byte $02
;endinline
;startinline
	byte $13
;endinline
	stz	r18
l27:
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
	bne	l31
	lda	(r0)
	beq	l26
l31:
	ldy	#1
	lda	(r0),y
	sta	r17
	lda	(r0)
	sta	r16
	jsr	l32
l26:
	inc	r18
	lda	r18
	cmp	#4
	bcc	l27
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
l32:
	jmp	(r16)
; stacksize=0+??
	global	_handlers_ca1
	global	_handlers_timer1
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
