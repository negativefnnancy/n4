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
	; only draw the ones for the direction you are moving..!!
	lda scroll_dir
	cmp #$00
	beq :+
	jsr update_right_seam
	jmp :++
:
	jsr update_left_seam
:
	; whew
	rts

update_right_seam:
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
	
	rts

update_left_seam:
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

	rts
