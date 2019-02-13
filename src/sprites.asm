; draw a metasprite
; a = metasprite index
; x = oam pointer
; tmp4 = xy pos
draw_metasprite:
	; get address of metasprite
	asl
	tay
	lda metasprites::table, y
	sta tmp0
	lda metasprites::table+1, y
	sta tmp0+1

	; get the sprite count and multiply by four
	ldy #$00
	lda (tmp0), y
	asl
	asl	
	sta tmp2

	; point to the base of the array
	inc tmp0
	bne :+
	inc tmp0+1
:

	; copy data
	jmp :++
:
	; copy y pos
	lda (tmp0), y
	clc
	adc tmp4+1	; add y offset
	sta oam, x
	inx
	iny
	; copy char
	lda (tmp0), y
	sta oam, x
	inx
	iny
	; copy attributes
	lda (tmp0), y
	sta oam, x
	inx
	iny
	; copy x pos
	lda (tmp0), y
	clc
	adc tmp4	; add x offset
	sta oam, x
	inx
	iny
	; loop
:
	cpy tmp2
	bne :--
	
	rts

; assemble oam from entity data
iterate_entities:
	ldy #$00	; entity pointer
	ldx #$00	; oam pointer
@entity_loop:
	tya
	pha
	txa
	pha

	; get the entity's x position
	lda entities+Entity::x_pos, y
	and #$f0
	sta tmp4
	lda entities+Entity::x_pos+1, y
	and #$0f
	clc
	adc tmp4
	ror
	ror
	ror
	ror
	ror
	sta tmp4

	; get the entity's y position
	lda entities+Entity::y_pos, y
	and #$f0
	sta tmp4+1
	lda entities+Entity::y_pos+1, y
	and #$0f
	clc
	adc tmp4+1
	ror
	ror
	ror
	ror
	ror
	sta tmp4+1

	; get and update the local timer
	ldx entities+Entity::timer, y
	inx
	txa
	sta tmp5
	sta entities+Entity::timer, y

	; lookup animation set for this entity
	lda entities+Entity::identity, y
	asl
	tax
	lda anim::table, x
	sta tmp0
	lda anim::table+1, x
	sta tmp0+1

	; lookup the animation in the set for the entity's current state
	sty tmp7
	lda entities+Entity::state, y
	asl
	tay
	lda (tmp0), y
	sta tmp1
	iny
	lda (tmp0), y
	sta tmp1+1

	; figure out which frame to draw
	ldy #$00	; frame pointer

	; get how many frames there are
	lda (tmp1), y	; get frame count
	sta tmp2
	iny
	; and get the speed
	lda (tmp1), y	; get animation frame duration
	cmp tmp5	; check for timer overflow
	bne :+
	ldy tmp7
	lda #$00
	sta entities+Entity::timer, y	
	sta tmp5
:
	; get the animation frame
	; and point y to that frame
	ldy tmp7
	ldx entities+Entity::frame, y
	lda tmp5
	cmp #$00
	bne :++
	inx
	cpx tmp2
	bne :+
	ldx #$00
:
	txa
	sta entities+Entity::frame, y
:
	ldy #$02	; the frame pointer
	cpx #$00
:
	beq :+
	; skip over a frame
	iny
	iny
	iny
	dex
	jmp :-
:		

	; draw that frame
	pla
	tax
	lda (tmp1), y
	pha
	iny
	lda (tmp1), y
	clc
	adc tmp4
	sta tmp4
	iny
	lda (tmp1), y
	clc
	adc tmp4+1
	sta tmp4+1
	pla
	jsr draw_metasprite

	; loop
	pla
	tay
	iny
	iny
	iny
	iny
	iny
	iny
	iny
	iny
	beq :+
	jmp @entity_loop
:

	rts
