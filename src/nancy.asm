; constants for nancy!
nancy_walk_step_size	= $0030

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
	lda pad_press
	and #%00000001
	beq :+
	; start moving right
	lda #$06
	sta entities+Entity::state, y
	jmp @skip_start_moving
:
	lda pad_press
	and #%00000010
	beq :+
	; start moving left
	lda #$07
	sta entities+Entity::state, y
	jmp @skip_start_moving
:
	lda pad_press
	and #%00000100
	beq :+
	; start moving down
	lda #$05
	sta entities+Entity::state, y
	jmp @skip_start_moving
:
	lda pad_press
	and #%00001000
	beq :+
	; start moving up
	lda #$04
	sta entities+Entity::state, y
:
@skip_start_moving:

	; see if nancy needs to actually move!
	; sync motion with animation frames tho,
	; bc otherwise it looks awkward lol
	lda entities+Entity::timer, y
	cmp #$00
	bne @skip_move	
	; ok now we've been synced, lets see what buttons are pressed
	lda pad
	and #%00000001
	beq :+
	; move right
	st16 tmp8, nancy_walk_step_size	
	jsr move_nancy_x
	jmp @skip_move
:
	lda pad
	and #%00000010
	beq :+
	; move left
	st16 tmp8, -nancy_walk_step_size
	jsr move_nancy_x
	jmp @skip_move
:
	lda pad
	and #%00000100
	beq :+
	; move down
	st16 tmp8, nancy_walk_step_size
	jsr move_nancy_y
	jmp @skip_move
:
	lda pad
	and #%00001000
	beq :+
	; move up
	st16 tmp8, -nancy_walk_step_size
	jsr move_nancy_y
:
@skip_move:

	; get the camera coordinates onto tmp8 and tmp9
	lda #$00
	sta tmp8+1
	; first the low bits
	lda cam_x
	sta tmp8
	clc
	rol tmp8
	rol tmp8+1
	rol tmp8
	rol tmp8+1
	rol tmp8
	rol tmp8+1
	rol tmp8
	rol tmp8+1
	; now the cam high bits
	lda cam_high
	and #$f0
	ora tmp8+1
	sta tmp8+1

	; now subtract nancy's position from it
	lda entities+Entity::x_pos, y
	clc
	sbc #$78
	sta tmp9
	lda entities+Entity::x_pos+1, y
	clc
	sbc #$78
	sta tmp9+1
	clc
	lda tmp9
	sbc tmp8	; this is delta
	sta tmp8
	lda tmp9+1
	sbc tmp8+1	; this is delta
	sta tmp8+1

	; and now to move the camera to nancy!
	lda tmp8
	lsr
	lsr
	lsr
	lsr
	sta tmp4
	lda tmp8+1
	rol
	rol
	rol
	rol
	and #$f0
	ora tmp4
	; drag effect
	lsr
	lsr
	lsr
	lsr
	; add the delta to the cam
	clc
	adc cam_x
	sta cam_x

	; all done here! bye bye nancy ;)
	jmp entity_handler_return
