; setup the main game screen
; tmp3 = area address
enter_game:
	; wait for vblank
	jsr wait_vblank

	; disable ppu
	lda #$00
	sta ppuctrl
	sta ppumask

	; lol look, i just honestly dont know when to wait for vblank
	; it is something to learn
	; v important
	; wait for vblank
	jsr wait_vblank

	; set the engine state
	lda #$02
	sta state

	; load the sprite palette
	st16 tmp0, pal::fg::day
	jsr load_fg_palette

	; load the bg palette
	st16 tmp0, pal::bg::day
	jsr load_bg_palette

	; load the map data
	ldy #Area::map
	lda (tmp3), y
	sta tmp0
	iny
	lda (tmp3), y
	sta tmp0+1
	st16 tmp1, map
	st16 tmp2, $400
	jsr copy

	; load the entity table
	ldy #Area::entities
	lda (tmp3), y
	sta tmp0
	iny
	lda (tmp3), y
	sta tmp0+1
	st16 tmp1, entities
	st16 tmp2, $100
	jsr copy

	; reset scroll direction var and cam and ppu scroll vars
	jsr reset_cam

	; now that the map is loaded
	; render it to the bg map
	jsr draw_map

	; prepare the initial frame
	jsr prepare_for_vblank

	; wait for vblank
	jsr wait_vblank
	jsr vblank_critical

	; enable the ppu
	lda #$88	; enable nmi and use second chr page for sprites
	sta ppuctrl
	lda #$18	; show sprites and bg
	sta ppumask

	rts

; stuff critical to do during vblank
vblank_critical:
	; update nametables..!
	jsr update_nametables

	; copy oam
	jsr update_oam

	; set camera?
	jsr update_scroll

	rts

; stuff to do after vblank critical stuff before the next vblank
prepare_for_vblank:
	; update oam for next frame
	jsr clear_oam
	jsr iterate_entities

	; render the scroll seam for next frame
	; draw whichever one depending on the direction you're moving
	lda scroll_dir
	cmp #$00
	beq :+
	jsr draw_scroll_buffer_right
	jmp :++
:
	jsr draw_scroll_buffer_left
:
	rts

; handler for the main game screen
game_handler:
	;; VBLANK STUFF FIRST
	jsr vblank_critical

	;; POST VBLANK STUFF
	jsr prepare_for_vblank

	;; and misc temp stuff yeah
	; await the start button
	lda pad_press
	and #%00010000
	beq :+
	
	; return to the title screen
	jsr enter_title
:
	rti

