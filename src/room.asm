; logic for the bedroom map
; remember, y should always be the entity pointer...
; also........ make these dang things into macros!!!

bathroom_enter_x	= $0400
bathroom_enter_y	= $0800
bathroom_exit_x		= $0700
bathroom_exit_y		= $0800
closet_enter_x		= $0a00
closet_enter_y		= $0c00
closet_exit_x		= $0a00
closet_exit_y		= $0900

enter_bathroom:
	lda #.lobyte(bathroom_enter_x)
	sta entities+Entity::x_pos, y
	lda #.hibyte(bathroom_enter_x)
	sta entities+Entity::x_pos+1, y
	lda #.lobyte(bathroom_enter_y)
	sta entities+Entity::y_pos, y
	lda #.hibyte(bathroom_enter_y)
	sta entities+Entity::y_pos+1, y
	rts

exit_bathroom:
	lda #.lobyte(bathroom_exit_x)
	sta entities+Entity::x_pos, y
	lda #.hibyte(bathroom_exit_x)
	sta entities+Entity::x_pos+1, y
	lda #.lobyte(bathroom_exit_y)
	sta entities+Entity::y_pos, y
	lda #.hibyte(bathroom_exit_y)
	sta entities+Entity::y_pos+1, y
	rts

enter_closet:
	lda #.lobyte(closet_enter_x)
	sta entities+Entity::x_pos, y
	lda #.hibyte(closet_enter_x)
	sta entities+Entity::x_pos+1, y
	lda #.lobyte(closet_enter_y)
	sta entities+Entity::y_pos, y
	lda #.hibyte(closet_enter_y)
	sta entities+Entity::y_pos+1, y
	rts

exit_closet:
	lda #.lobyte(closet_exit_x)
	sta entities+Entity::x_pos, y
	lda #.hibyte(closet_exit_x)
	sta entities+Entity::x_pos+1, y
	lda #.lobyte(closet_exit_y)
	sta entities+Entity::y_pos, y
	lda #.hibyte(closet_exit_y)
	sta entities+Entity::y_pos+1, y
	rts
