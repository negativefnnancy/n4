; dma the oam to the ppu
update_oam:
	lda #.lobyte(oam)
	sta oamaddr
	lda #.hibyte(oam)
	sta oamdma
	rts

; set the ppu scroll according to world cam
update_scroll:
	; low bits
	lda cam_x
	sta ppuscroll
	lda scroll_y
	sta ppuscroll
	; high bits
	lda scroll_y+1
	rol
	and #$02
	ora #$88
	sta ppuctrl	
	rts

; copy the scroll seam buffer into the nametable
update_vram:
	; we are redoing how it was done before
	; now we are going to have both horizontal AND vertical seams
	; hmm... horizontal seam (vertical scroll) is 32 bytes
	; and vertical seam (horizontal scroll) is 60 bytes (30 for each nametable)
	; both will be updated every frame
	; but only for one direction!
	; so every frame 60+32 bytes will be updated

	;; VERTICAL SCROLL SEAM

	; set things up for horizontal increments
	lda #$88
	sta ppuctrl

	; do y scroll seam update
	lda scroll_dir
	and #$02
	bne :+
	jsr copy_up_seam
	jmp :++
:
	jsr copy_down_seam
:

	;; HORIZONTAL SCROLL SEAM

	; set things up for vertical increments
	lda #$8c
	sta ppuctrl

	; do x scroll seam update
	lda scroll_dir
	and #$01
	bne copy_right_seam

copy_left_seam:
	; left seam is at the scroll position + 1 (first column is disabled) (both name tables)

	; set left seam x coordinate
	lda cam_x
	clc
	adc #$08	; one tile over (8 pixels, before conversion)
	lsr
	lsr
	lsr
	sta tmp8
	
	; continue...
	jmp copy_horizontal_seam

copy_right_seam:
	; right seam is at the scroll position (both name tables)

	; set right seam x coordinate address offset
	lda cam_x
	lsr
	lsr
	lsr
	sta tmp8

copy_horizontal_seam:
	; first top then bottom nametables

	;; TOP NAMETABLE

	; high byte
	lda #$20
	sta ppuaddr

	; low byte
	lda tmp8
	sta ppuaddr

	; and now do the copy
	.repeat 30, I
		lda scroll_buf_x0+I
		sta ppudata
	.endrepeat

	;; BOTTOM NAMETABLE

	; high byte
	lda #$28
	sta ppuaddr

	; low byte
	lda tmp8
	sta ppuaddr

	; and now do the copy
	.repeat 30, I
		lda scroll_buf_x1+I
		sta ppudata
	.endrepeat

	; bye bye
	rts

copy_up_seam:
	; up seam is on current nametable at scroll position

	; so select the address!
	; select the actual nametable first
	lda scroll_y+1	; says which nametable
	rol	
	rol	
	rol	
	and #$08
	clc
	adc #$20
	sta tmp8

	; continue...
	jmp copy_vertical_seam

copy_down_seam:
	; down seam is on the Other nametable at the scroll position

	; so select the address!
	; select the actual nametable first
	lda scroll_y+1	; says which nametable
	eor #$ff	; invert it for the Other nametable
	rol	
	rol	
	rol	
	and #$08
	clc
	adc #$20
	sta tmp8

; assumes horizental increments already set
copy_vertical_seam:
	; high byte
	lda scroll_y
	clc
	rol
	rol
	rol
	and #$03
	clc
	adc tmp8	; add to the nametable base
	sta ppuaddr

	; low byte
	lda scroll_y
	rol
	rol
	and #$e0
	sta ppuaddr

	; and now do the copy
	.repeat 32, I
		lda scroll_buf_y+I
		sta ppudata
	.endrepeat
	rts
