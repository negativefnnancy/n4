; make mancy move horizontally dude
; tmp8 = offset
move_entity_x:
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
move_entity_y:
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
