; constants for nancy!
nancy_walk_step_size	= $000c ; $0030
nancy_run_step_size	= $0018 ; $0030

; make mancy move horizontally dude
; tmp8 = offset
move_nancy_x:
	; low byte
	lda entities+Entity::x_pos, y
	clc
	adc tmp8
	sta entities+Entity::x_pos, y
	; high byte
	lda entities+Entity::x_pos+1, y
	adc tmp8+1
	sta entities+Entity::x_pos+1, y
	; buh bey
	rts

; make mancy move vertically dude
; tmp8 = offset
move_nancy_y:
	; low byte
	lda entities+Entity::y_pos, y
	clc
	adc tmp8
	sta entities+Entity::y_pos, y
	; high byte
	lda entities+Entity::y_pos+1, y
	adc tmp8+1
	sta entities+Entity::y_pos+1, y
	; buh bey
	rts

; nancy's entity handler
; remember y is the entity pointer
; so dont mess w it!
nancy_entity_handler:

;;;; MOVEMENT CONTROLS

	; see if nancy needs any animation changes at all!
	lda pad_change
	and #$0f
	beq :+
	lda #$00
	sta entities+Entity::frame, y
	sta entities+Entity::timer, y
:

	; see if nancy needs needs animation changes for stopping!
	lda pad_unpress
	and #%00000001
	beq :+
	; stop moving right
	lda #$02
	sta entities+Entity::state, y
	jmp @skip_stop_moving
:
	lda pad_unpress
	and #%00000010
	beq :+
	; stop moving left
	lda #$03
	sta entities+Entity::state, y
	jmp @skip_stop_moving
:
	lda pad_unpress
	and #%00000100
	beq :+
	; stop moving down
	lda #$01
	sta entities+Entity::state, y
	jmp @skip_stop_moving
:
	lda pad_unpress
	and #%00001000
	beq :+
	; stop moving up
	lda #$00
	sta entities+Entity::state, y
:
@skip_stop_moving:

	; see if nancy needs animation changes for movement!
	; see if run or walk first
	lda pad
	and #%01000000
	beq :+
	lda #$04
	sta tmp8
	jmp :++
:
	lda #$00
	sta tmp8
:
	; make sure something relevant was newly pressed
	lda pad_change
	and #%01001111
	beq @skip_start_moving
	lda #$00
	sta entities+Entity::timer, y
	; so anyway
	lda pad
	and #%00000001
	beq :+
	; start moving right
	lda #$06
	clc
	adc tmp8
	sta entities+Entity::state, y
	jmp @skip_start_moving
:
	lda pad
	and #%00000010
	beq :+
	; start moving left
	lda #$07
	clc
	adc tmp8
	sta entities+Entity::state, y
	jmp @skip_start_moving
:
	lda pad
	and #%00000100
	beq :+
	; start moving down
	lda #$05
	clc
	adc tmp8
	sta entities+Entity::state, y
	jmp @skip_start_moving
:
	lda pad
	and #%00001000
	beq :+
	; start moving up
	lda #$04
	clc
	adc tmp8
	sta entities+Entity::state, y
:
@skip_start_moving:

	; see if nancy needs to actually move!
	; sync motion with animation frames tho,
	; bc otherwise it looks awkward lol
	lda entities+Entity::timer, y
	cmp #$00
	;bne @skip_move	
	; ok now we've been synced, lets see what buttons are pressed
	; see if run or walk first
	lda pad
	and #%01000000
	beq :+
	st16 tmp8, nancy_run_step_size	
	st16 tmp9, -nancy_run_step_size	
	jmp :++
:
	st16 tmp8, nancy_walk_step_size	
	st16 tmp9, -nancy_walk_step_size	
:
	lda pad
	and #%00000001
	beq :+
	; move right
	jsr move_nancy_x
	jmp @skip_move
:
	lda pad
	and #%00000010
	beq :+
	; move left
	lda tmp9
	sta tmp8
	lda tmp9+1
	sta tmp8+1
	jsr move_nancy_x
	jmp @skip_move
:
	lda pad
	and #%00000100
	beq :+
	; move down
	jsr move_nancy_y
	; wrap at 240
	;lda entities+Entity::y_pos+1, y
	;cmp #$0f
	;bcs @skip_move
	;sec
	;sbc #$0f
	;sta entities+Entity::y_pos+1, y
	jmp @skip_move
:
	lda pad
	and #%00001000
	beq :+
	; move up
	lda tmp9
	sta tmp8
	lda tmp9+1
	sta tmp8+1
	jsr move_nancy_y
	; wrap at 240
	;lda entities+Entity::y_pos+1, y
	;cmp #$0f
	;bcs @skip_move
	;sec
	;sbc #$01
	;sta entities+Entity::y_pos+1, y
:
@skip_move:


;;;;; CAMERA FOLLOW NANCY

	; ok we're gonna do a simpler camera scrolling effect
	; simply move the camera in a direction if nancy is past it lol

	; get cam 16bit x
	lda cam_x
	rol
	rol
	rol
	rol
	and #$f0
	sta tmp3
	lda cam_x
	lsr
	lsr
	lsr
	lsr
	sta tmp3+1
	lda cam_high
	and #$f0
	ora tmp3+1
	sta tmp3+1

	; get cam 16bit y
	lda cam_y
	rol
	rol
	rol
	rol
	and #$f0
	sta tmp4
	lda cam_y
	lsr
	lsr
	lsr
	lsr
	sta tmp4+1
	lda cam_high
	rol
	rol
	rol
	rol
	and #$f0
	ora tmp4+1
	sta tmp4+1

	; get nancy delta x
	lda entities+Entity::x_pos, y
	sec
	sbc tmp3
	sta tmp3
	lda entities+Entity::x_pos+1, y
	sbc tmp3+1
	sta tmp3+1

	; get nancy delta y
	lda entities+Entity::y_pos, y
	sec
	sbc tmp4
	sta tmp4
	lda entities+Entity::y_pos+1, y
	sbc tmp4+1
	sta tmp4+1

	; ok nancy delta on tmp3 and tmp4
	; now we need to check if its past certain boundaries
	; Horizontal scroll?
	lda tmp3+1
	cmp #$04
	bcs :++
:
	lda #$ff
	sta cam_move_x
	jmp :++
:
	lda tmp3+1
	cmp #$0c
	bcc :+
	; check sign bit first...
	; cheap hax m8
	and #$80
	bne :--
	lda #1
	sta cam_move_x
:
	; Vertical scroll?
	lda tmp4+1
	cmp #$04
	bcs :++
:
	lda #$ff
	sta cam_move_y
	jmp :++
:
	lda tmp4+1
	cmp #$0a
	bcc :+
	; check sign bit first...
	; cheap hax m8
	and #$80
	bne :--
	lda #1
	sta cam_move_y
:

	; all done here! bye bye nancy ;)
	jmp entity_handler_return
