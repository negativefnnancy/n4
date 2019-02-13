; setup the main game screen
; tmp3 = area address
enter_game:
	; disable ppu
	lda #$00
	sta ppuctrl
	sta ppumask

	; set the engine state
	lda #$02
	sta state

	; load the test background nametable
	st16 tmp0, nt::test
	jsr load_nametable

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

	; reset scrolling
	lda #$00
	sta ppuscroll
	sta ppuscroll

	; enable the ppu
	lda #$88	; enable nmi and use second chr page for sprites
	sta ppuctrl
	lda #$18	; show sprites and bg
	sta ppumask
	rts

; handler for the main game screen
game_handler:
	; copy oam
	lda #.lobyte(oam)
	sta oamaddr
	lda #.hibyte(oam)
	sta oamdma

	; update oam for next frame
	jsr clear_oam
	jsr iterate_entities

	; await the start button
	lda pad_press
	and #%00010000
	beq :+
	
	; return to the title screen
	jsr enter_title
:
	rti

