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

	; now that the map is loaded
	; render it to the bg map
	jsr draw_map

	; enable the ppu
	lda #$88	; enable nmi and use second chr page for sprites
	sta ppuctrl
	lda #$18	; show sprites and bg
	sta ppumask

	; reset scrolling
	lda #$00
	sta ppuscroll
	sta ppuscroll

	rts

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
	; lookup the metatile
	clc
	rol
	rol
	clc
	adc tmpb+1
	tax
	lda metatiles, x
 
	; go get em tiger
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
	lsr	
	lsr	
	lsr	
	sta tmp8+1

	;;; VERTICAL BUFFER

	; increment vertically
	lda #$8c
	sta ppuctrl

	; latch the ppu address
	lda cam_high
	and #$01
	beq :+
	; starting on the bottom name table
	; store alt nametable
	lda #.hibyte(nt2)
	sta tmp3
	; start on main nametable
	lda #.hibyte(nt0)
	sta ppuaddr
	lda tmp8
	sta ppuaddr
	jmp :++
:
	; starting on the upper nametable
	; store alt nametable
	lda #.hibyte(nt0)
	sta tmp3
	; start on main nametable
	lda #.hibyte(nt2)
	sta ppuaddr
	lda tmp8
	sta ppuaddr
:

	; load the stuffs
	lda #$00
	sta tmp9
:
	cmp tmp8+1
	bne :+
	; switch to top table
	lda cam_y
	clc
	rol
	rol
	and #$e0
	clc
	adc tmp8
	sta tmp4
	lda cam_y
	clc
	rol
	rol
	rol
	and #$03
	clc
	adc tmp3
	sta ppuaddr
	lda tmp4
	sta ppuaddr
:
	; load the byte
	lda global_timer
	and #$3
	clc
	adc tmp9
	sta ppudata
	; next
	inc tmp9
	lda tmp9
	cmp #$1e
	bne :--

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
	; low bits
	lda cam_x
	sta ppuscroll
	lda cam_y
	sta ppuscroll
	; high bits
	lda cam_high
	lsr
	lsr
	lsr
	lsr
	and #$01
	sta tmp4
	lda cam_high
	rol
	and #$02
	ora tmp4
	clc
	adc #$88
	sta ppuctrl	

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

