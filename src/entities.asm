.include "nancy.asm"

; the null handler for null entities
; does nothing, obv
null_entity_handler:
	jmp entity_handler_return

; entity logic handler routines
entity_handler_table:
.word null_entity_handler-1
.word nancy_entity_handler-1

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
