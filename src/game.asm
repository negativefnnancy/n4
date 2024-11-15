; setup the main game screen
; cur_area = area address
enter_game:
	; clear any warp
	lda #$00
	sta warp_area
	sta warp_area+1

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
	;ldy #Area::map
	;lda (cur_area), y
	;sta tmp0
	;iny
	;lda (cur_area), y
	;sta tmp0+1
	;st16 tmp1, map
	;st16 tmp2, $400
	;jsr copy

	; load the entity table
	ldy #Area::entities
	lda (cur_area), y
	sta tmp0
	iny
	lda (cur_area), y
	sta tmp0+1
	st16 tmp1, entities
	st16 tmp2, $100
	jsr copy

	; reset scroll direction var and cam and ppu scroll vars
	jsr reset_cam

	; now that the map is loaded
	; render it to the bg map
	jsr wait_vblank
	jsr draw_map

	; reset cam again now that map has been drawn
	jsr reset_cam

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
	; copy scrol seam buffer into the name tables !
	jsr update_vram

	; copy oam from ram into ppu
	jsr update_oam

	; set camera?
	jsr update_scroll

	rts

; stuff to do after vblank critical stuff before the next vblank
prepare_for_vblank:
	; update oam for next frame
	jsr clear_oam
	jsr iterate_entities

	; camera movement engine
	jsr move_cam

	;; buffer vram updates!!!

	lda scroll_dir
	cmp #$00
	bne :+
	jmp draw_left_seam
:
	cmp #$01
	bne :+
	jmp draw_right_seam
:
	cmp #$02
	bne :+
	jmp draw_up_seam
:
	jmp draw_down_seam

; handler for the main game screen
game_handler:
	;; VBLANK STUFF FIRST
	jsr vblank_critical

	;; POST VBLANK STUFF
	jsr prepare_for_vblank

	;; and then see if a warp to a new area has been requested...
	lda warp_area
	beq :+
	lda warp_area+1
	beq :+
	; yes good, warp time
	lda warp_area
	sta cur_area
	lda warp_area+1
	sta cur_area+1
	
	; enter 8 )
	jsr enter_game
:
	rti

