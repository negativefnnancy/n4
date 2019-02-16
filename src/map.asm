; fill the screen with the map!
; kinda just assuming cam has ben reset first
; one idea is to have a push_cam and pull_cam subroutines, and use them here
draw_map:
	; horizental increments
	lda #$00
	sta ppuctrl

	; sweep the screen from top to bottom drawing each line	
:
	jsr draw_up_seam
	jsr copy_up_seam
	lda scroll_y
	clc
	adc #$08
	sta scroll_y
	sta cam_y
	cmp #$f0
	bne :-
	rts

; update the down seam buffer
draw_down_seam:
	; set the y origin
	lda cam_y
	; add a vertical screen's worth :^ )
	clc
	adc #$f0
	php
	lsr
	lsr
	lsr
	tay

	; set effective cam_high
	lda cam_high
	and #$0f
	plp
	adc #$00
	sta tmp8

	; continue...
	jmp draw_vertical_scroll_seam

; update the up seam buffer
draw_up_seam:
	; set the y origin
	lda cam_y
	lsr
	lsr
	lsr
	tay

	; set effective cam_high
	lda cam_high
	sta tmp8

draw_vertical_scroll_seam:
	; set the x origin
	ldx #$20

	; set vertical quadrant
	lda tmp8
	rol
	and #$02
	sta tmp8

	; set quadrant change
	lda cam_x
	clc
	adc #$08
	php
	lsr
	lsr
	lsr
	sta tmp7

	; set quadrant
	lda cam_high
	lsr
	lsr
	lsr
	lsr
	plp
	adc #$00
	and #$01
	clc
	adc tmp8	; change to ora?
	sta tmp8

	; sweep the x direction
:
	; see if time to change quadrant
	cpx tmp7
	bne :+
	; change x quadrant
	lda tmp8
	eor #$01
	sta tmp8
:
	; next iteration
	dex
	php
	jsr get_tile
	sta scroll_buf_y, x
	plp
	bne :--

	; done
	rts

draw_right_seam:
	lda cam_x
	lsr
	lsr
	lsr
	tax
	lda cam_high
	lsr
	lsr
	lsr
	lsr
	sta tmp8+1
	inc tmp8+1
	jmp draw_horizontal_scroll_seam

draw_left_seam:
	; im rewriting this idc it was awful
	; and idc how ugly this is rn just work!!!
	; get the dang x coordinate >:T
	lda cam_x
	clc
	adc #$08
	php
	lsr
	lsr
	lsr
	tax
	lda cam_high
	lsr
	lsr
	lsr
	lsr
	plp
	adc #$00
	sta tmp8+1

draw_horizontal_scroll_seam:
	; and the dang y coordinate!!
	lda cam_y
	lsr
	lsr
	lsr
	tay

	; and the damn quadrant!!!
	lda cam_high
	rol
	and #$02
	sta tmp8
	lda tmp8+1
	and #$01
	ora tmp8
	sta tmp8

	; where do we start drawing?
	; at scroll_y
	; also account for base nametable !!!
	lda scroll_y
	lsr
	lsr
	lsr
	clc
	adc #.lobyte(scroll_buf_x)
	sta tmp4
	lda scroll_y+1
	and #$01
	beq :+
	lda tmp4
	clc
	adc #30
	sta tmp4
:
	lda #.hibyte(scroll_buf_x)
	sta tmp4+1

	; how many times do we draw?
	; 32!! just do it
	lda #$20
	sta tmp5

	; do the DAMN loop
	; its so ugly
:
	jsr get_tile
	sta tmp3
	tya
	pha
	lda #$00
	tay	
	lda tmp3
	sta (tmp4), y
	pla
	tay
	inc tmp4
	; overflowing x scroll buf?
	lda tmp4
	cmp #.lobyte(scroll_buf_x+60)
	bne :+
	lda tmp4+1
	cmp #.hibyte(scroll_buf_x+60)
	bne :+
	lda #.lobyte(scroll_buf_x)
	sta tmp4
	lda #.hibyte(scroll_buf_x)
	sta tmp4+1
:

	; time to change quad????
	iny
	tya
	and #$1f
	tay
	bne :+
	lda tmp8
	eor #$02
	sta tmp8
:
	dec tmp5
	bne :---

	; done
	rts

; render the scroll buffer seam for loading into the nametable next frame
;draw_scroll_buffer_right:
;	;; RIGHT seam!
;
;	; get x coordinate
;	lda cam_x
;	lsr
;	lsr
;	lsr
;	sta tmpa+1
;	
;	; TOP table
;	; get quadrant
;	lda cam_high
;	lsr
;	lsr
;	lsr
;	lsr
;	clc
;	adc #$01
;	and #$01
;	sta tmp8
;	; set destination
;	st16 tmp3, nt0_buf0
;	; do it
;	jsr draw_scroll_buffer_part
;
;	; BOTTOM table
;	; get quadrant
;	lda cam_high
;	lsr
;	lsr
;	lsr
;	lsr
;	clc
;	adc #$01
;	and #$01
;	clc
;	adc #$02
;	sta tmp8
;	; set destination
;	st16 tmp3, nt2_buf0
;	; do it
;	jsr draw_scroll_buffer_part
;
;	rts
;
;draw_scroll_buffer_left:
;	;; LEFT seam!
;
;	; get x coordinate
;	; move it over 1 tile (and wrap around)
;	lda cam_x
;	clc
;	adc #$08
;	php
;	php
;	lsr
;	lsr
;	lsr
;	sta tmpa+1
;	
;	; TOP table
;	; get quadrant
;	lda cam_high
;	lsr
;	lsr
;	lsr
;	lsr
;	plp
;	adc #$00
;	and #$01
;	sta tmp8
;	; set destination
;	st16 tmp3, nt0_buf1
;	; do it
;	jsr draw_scroll_buffer_part
;
;	; BOTTOM table
;	; get quadrant
;	lda cam_high
;	lsr
;	lsr
;	lsr
;	lsr
;	plp
;	adc #$00
;	and #$01
;	clc
;	adc #$02
;	sta tmp8
;	; set destination
;	st16 tmp3, nt2_buf1
;
;	; do it
;
;draw_scroll_buffer_part:
;	; now loop through the column
;	lda #$00
;	tay
;	sta tmpa
;:
;	; get tile and store it
;	tya
;	pha
;	jsr get_tile
;	sta tmp4
;	pla
;	tay
;	lda tmp4
;	sta (tmp3), y
;	; prep next iteration
;	iny
;	inc tmpa
;	lda tmpa
;	cmp #$1e
;	bne :-
;	rts

; load onta a the appropriate bg tile at screen coordinates
; y reg = y pos
; x reg = x pos
; tmp8 = quadrant : ) (just like nametable select)
get_tile:
	; x
	txa
	lsr
	and #$0f
	sta tmpb
	; y
	tya
	pha
	rol
	rol
	rol
	and #$f0
	ora tmpb
	sta tmpb
	; now we have the map address
	; get the metatile individual tile offset
	txa
	and #$01
	sta tmpb+1
	tya
	rol
	and #$02
	ora tmpb+1
	sta tmpb+1	
	; load the metatile id from the map data
	lda tmp8
	clc
	adc #.hibyte(map)
	sta tmp9+1
	lda #$00
	sta tmp9
	lda tmpb
	tay
	lda (tmp9), y
	; now we have the metatile id
	; turn it into an offset by x4'ing it
	; and add it to the metatiles base address
	sta tmpc ; save the metatile id
	clc
	rol
	rol
	clc
	adc #.lobyte(metatiles)
	php
	sta tmpd
	lda tmpc
	rol
	rol
	rol
	and #$03
	plp
	adc #.hibyte(metatiles)
	sta tmpd+1
	lda tmpb+1
	tay
	lda (tmpd), y
 
	; go get em tiger
	sta tmpc
	pla
	tay
	lda tmpc
	rts
