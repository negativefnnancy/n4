; reset camera to origin
reset_cam:
	lda #$00
	sta scroll_dir
	sta scroll_y	
	sta scroll_y+1
	sta cam_x
	sta cam_y
	sta cam_high
	sta cam_move_x
	sta cam_move_y
	sta cam_move_alt
return:
	rts

; master camera movement logic
; call once per frame
move_cam:
	; if theres no x to move, move y
	lda cam_move_x
	cmp #$00
	beq move_cam_y
	; if theres no y to move, move x
	lda cam_move_y
	cmp #$00
	beq move_cam_x
	; otherwise alternate between the x and y queues
	lda cam_move_alt
	eor #$ff
	sta cam_move_alt
	bne move_cam_y
	jmp move_cam_x

; handle the cam y movemente queue
move_cam_y:
	lda cam_move_y
	cmp #$00
	beq return
	; move cam y
	; negative?
	and #$80
	bne :+
	; positive
	dec cam_move_y
	jmp move_cam_down
:
	; negative
	inc cam_move_y
	jmp move_cam_up

; handle the cam x movemente queue
move_cam_x:
	lda cam_move_x
	cmp #$00
	beq return
	; move cam x
	; negative?
	and #$80
	bne :+
	; positive
	dec cam_move_x
	jmp move_cam_right
:
	; negative
	inc cam_move_x
	jmp move_cam_left

; move camera 1 pixel to the right
move_cam_right:
	; indicate scrolling direction (for vram buffer)
	lda #$01
	sta scroll_dir
	; update the cam coordinate
	inc cam_x
	; and check for overflow/underflow
	bne :+
	; it over/underflowed so update the high bits of cam pos too
	lda cam_high
	clc
	adc #$10
	and #$f0
	sta tmp3
	lda cam_high
	and #$0f
	ora tmp3
	sta cam_high
:
	rts

; move camera 1 pixel to the left
move_cam_left:
	; indicate scrolling direction (for vram buffer)
	lda #$00
	sta scroll_dir
	; update the cam coordinate
	dec cam_x
	; and check for overflow/underflow
	lda cam_x
	cmp #$ff
	bne :+
	; it over/underflowed so update the high bits of cam pos too
	lda cam_high
	sec
	sbc #$10
	and #$f0
	sta tmp3
	lda cam_high
	and #$0f
	ora tmp3
	sta cam_high
:
	rts

; move camera 1 pixel down
move_cam_down:
	; indicate scrolling direction (for vram buffer)
	lda #$03
	ora #$02	; set bit 1 = 1
	sta scroll_dir
	; update the y scrolling!!
	inc scroll_y
	; and check for overflow 240
	lda scroll_y
	cmp #$f0
	bcc :+
	; wrap it
	inc scroll_y+1
	lda #$00
	sta scroll_y
:
	; update the cam coordinate
	inc cam_y
	; and check for overflow/underflow
	bne :+
	; it over/underflowed so update the high bits of cam pos too
	lda cam_high
	clc
	adc #$01
	and #$0f
	sta tmp3
	lda cam_high
	and #$f0
	ora tmp3
	sta cam_high
:
	rts

; move camera 1 pixel up
move_cam_up:
	; indicate scrolling direction (for vram buffer)
	lda #$02
	sta scroll_dir
	; update the y scrolling!!
	dec scroll_y
	; and check for overflow 240
	lda scroll_y
	cmp #$ff
	bcc :+
	; wrap it
	dec scroll_y+1
	lda #$ef
	sta scroll_y
:
	; update the cam coordinate
	dec cam_y
	; and check for overflow/underflow
	lda cam_y
	cmp #$ff
	bne :+
	; it over/underflowed so update the high bits of cam pos too
	lda cam_high
	sec
	sbc #$01
	and #$0f
	sta tmp3
	lda cam_high
	and #$f0
	ora tmp3
	sta cam_high
:
	rts
