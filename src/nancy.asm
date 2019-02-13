; constants for nancy!
nancy_walk_speed	= $0008

; make mancy move horizontally dude
; tmp1 = offset
move_nancy_x:
	; low byte
	lda entities+Entity::x_pos, y
	clc
	adc tmp1
	sta entities+Entity::x_pos, y
	; high byte
	lda entities+Entity::x_pos+1, y
	adc tmp1+1
	sta entities+Entity::x_pos+1, y
	; buh bey
	rts

; make mancy move vertically dude
; tmp1 = offset
move_nancy_y:
	; low byte
	lda entities+Entity::y_pos, y
	clc
	adc tmp1
	sta entities+Entity::y_pos, y
	; high byte
	lda entities+Entity::y_pos+1, y
	adc tmp1+1
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
	lda pad
	and #%00000001
	beq :+
	; move right
	st16 tmp1, nancy_walk_speed	
	jsr move_nancy_x
	jmp @skip_move
:
	lda pad
	and #%00000010
	beq :+
	; move left
	st16 tmp1, -nancy_walk_speed	
	jsr move_nancy_x
	jmp @skip_move
:
	lda pad
	and #%00000100
	beq :+
	; move down
	st16 tmp1, nancy_walk_speed	
	jsr move_nancy_y
	jmp @skip_move
:
	lda pad
	and #%00001000
	beq :+
	; move up
	st16 tmp1, -nancy_walk_speed	
	jsr move_nancy_y
:
@skip_move:

	; all done here! bye bye nancy ;)
	jmp entity_handler_return
