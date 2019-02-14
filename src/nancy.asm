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


;;;;; CAMERA FOLLOW NANCY

	; ok we're gonna do a simpler camera scrolling effect
	; simply move the camera in a direction if nancy is past it lol

	; get the entity's x position
	; maybe this can be done better??
	lda entities+Entity::x_pos, y
	lsr
	lsr
	lsr
	lsr
	sta tmp4
	lda entities+Entity::x_pos+1, y
	rol
	rol
	rol
	rol
	and #$f0
	ora tmp4
	clc
	sbc cam_x
	sta tmp4

	; get the entity's y position
	; maybe this can be done better??
	lda entities+Entity::y_pos, y
	lsr
	lsr
	lsr
	lsr
	sta tmp4+1
	lda entities+Entity::y_pos+1, y
	rol
	rol
	rol
	rol
	and #$f0
	ora tmp4+1
	clc
	sbc cam_y
	sta tmp4+1

	; ok we nancy's position on tmp4, now whats
	; now we need to check if its past certain boundaries
	lda tmp4
	cmp #$40
	bcs :+
	; move cam left
	dec cam_x
	jmp @cam_done_x
:
	lda tmp4
	cmp #$c0
	bcc :+
	; move cam right
	inc cam_x
:
@cam_done_x:
	lda tmp4+1
	cmp #$40
	bcs :+
	; move cam up
	dec cam_y
	jmp @cam_done_y
:
	lda tmp4+1
	cmp #$a0
	bcc :+
	; move cam down
	inc cam_y
:
@cam_done_y:

	; all done here! bye bye nancy ;)
	jmp entity_handler_return
