; draw the entire bg map, both top and bottom nametables
draw_map:
	; first draw the top 
	lda #$00
	sta tmp8
	jsr draw_map_part
	; then draw the bottom
	lda #$02
	sta tmp8
	jsr draw_map_part

	rts

; tmp8 = basenametable / map region
draw_map_part:
	jsr wait_vblank

	;;; note: assuming ppu is off and horizontal increment mode
	; its 32 by 30 soooo
	; lets just loop over whichever nametable we are supposed to be filling..!
	; latch the ppu address
	bit ppustatus
	lda tmp8
	clc
	rol
	rol
	adc #.hibyte(nt0)
	sta ppuaddr
	lda #.lobyte(nt0)
	sta ppuaddr

	; y !
	lda #$00
	sta tmpa
:
	; x !
	lda #$00
	sta tmpa+1
:
	; inner loop with x and y:
	jsr get_tile
	sta ppudata

	; done inner loop
	inc tmpa+1
	lda tmpa+1
	cmp #$20
	bne :-

	inc tmpa
	lda tmpa
	cmp #$1e
	bne :--
	
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
; tmpa = y
; tmpa+1 = x
; tmp8 = quadrant : ) (just like nametable select)
get_tile:
	; x
	lda tmpa+1
	lsr
	sta tmpb
	; y
	lda tmpa
	rol
	rol
	rol
	and #$f0
	ora tmpb
	sta tmpb
	; now we have the map address
	; get the metatile individual tile offset
	lda tmpa+1
	and #$01
	sta tmpb+1
	lda tmpa
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
	rts
