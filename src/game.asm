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

	; now that the map is loaded
	; render it to the bg map
	jsr draw_map

	; wait for vblank
	jsr wait_vblank

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

; copy the scroll buffer into the nametable
update_nametables:
	; ok we got to update the left and right seams for top and bottom nametables both
	; and we got to be fast
	; so ! unrolled loops

	; first things first
	; set things up for vertical increments
	lda #$8c
	sta ppuctrl
	; and figure out the x offset!
	lda cam_x
	lsr
	lsr
	lsr
	sta tmp8

	;;;;; now Do The STuff

	;;; nt0 right seam (x = 0) nt0_buf0
	; select the address...!
	lda #.hibyte(nt0)
	sta ppuaddr
	lda tmp8
	sta ppuaddr
	; start loop......
.repeat 30, I
	lda nt0_buf0+I
	sta ppudata
.endrepeat

	;;; nt2 right seam (x = 0) nt2_buf0
	; select the address...!
	lda #.hibyte(nt2)
	sta ppuaddr
	lda tmp8
	sta ppuaddr
	; start loop......
.repeat 30, I
	lda nt2_buf0+I
	sta ppudata
.endrepeat

	; move over the column for the left seam now lol
	inc tmp8
	lda tmp8
	and #$1f
	sta tmp8

	;;; nt0 left seam (x = 1) nt0_buf1
	; select the address...!
	lda #.hibyte(nt0)
	sta ppuaddr
	lda tmp8
	sta ppuaddr
	; start loop......
.repeat 30, I
	lda nt0_buf1+I
	sta ppudata
.endrepeat

	;;; nt2 left seam (x = 1) nt2_buf1
	; select the address...!
	lda #.hibyte(nt2)
	sta ppuaddr
	lda tmp8
	sta ppuaddr
	; start loop......
.repeat 30, I
	lda nt2_buf1+I
	sta ppudata
.endrepeat
	; whew
	rts

; handler for the main game screen
game_handler:


	;; VBLANK STUFF

	; update nametables..!
	jsr update_nametables

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


	;; POST VBLANK STUFF

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

