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

; buffer the bg for scrolling
buffer_bg:
	; first get the vram address offset of the buffer origin
	lda cam_x
	lsr	
	lsr	
	lsr	
	sta tmp8
	lda cam_y
	rol
	rol
	and #$e0
	clc
	adc tmp8
	sta tmp8
	lda cam_y
	clc
	rol
	rol
	rol
	and #$03
	sta tmp8+1
	; and account for passing the bottom of the first nametable
	; if the camera is passed the first name table, jump to the second
	lda cam_y
	cmp #240
	bcc :+
	lda #$40
	clc
	adc tmp8
	sta tmp8
	lda #$04
	adc tmp8+1
	sta tmp8+1
:

	;;; HORIZONTAL BUFFER

	; enable the ppu
	bit ppustatus
	lda #$88	; enable nmi and use second chr page for sprites
	sta ppuctrl
	
	; latch the ppu address
	lda tmp8+1
	clc
	adc #.hibyte(nt0)
	sta ppuaddr
	lda tmp8
	and #$e0	; align with the horizontal edge of the screen
	clc
	adc #.lobyte(nt0)
	sta ppuaddr

	; put data
	lda #$20
	sta tmp9
:
	lda global_timer
	and #$1
	clc
	adc tmp9
	sta ppudata
	dec tmp9
	bne :-

	;;; VERTICAL BUFFER

	; enable the ppu
	bit ppustatus
	lda #$8c	; enable nmi and use second chr page for sprites
	sta ppuctrl

	; latch the ppu address
	lda #.hibyte(nt0)
	sta ppuaddr
	lda tmp8
	and #$1f	; align with the vertical edge of the screen
	sta ppuaddr

	; put data on first nametable
	lda #$1e
	sta tmp9
:
	lda global_timer
	and #$1
	clc
	adc tmp9
	sta ppudata
	dec tmp9
	bne :-

	rts

; handler for the main game screen
game_handler:
	; bg scroll buffer!
	jsr buffer_bg

	; copy oam
	lda #.lobyte(oam)
	sta oamaddr
	lda #.hibyte(oam)
	sta oamdma

	; set camera?
	lda cam_x
	sta ppuscroll
	lda cam_y
	sta ppuscroll

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

