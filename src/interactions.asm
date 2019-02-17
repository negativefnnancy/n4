; this file contains subroutines for 'interact' triggered events

; the main interaction routine, call from an entity to make it interact with the map
; y = entity id
; tmpb = interaction x coordinate
; tmpc = interaction y coordinate
; cur_area = the area whose map to collide with
interact:
	; x
	lda tmpb+1
	and #$0f
	sta tmpb
	; y
	lda tmpc+1
	rol
	rol
	rol
	rol
	and #$f0
	ora tmpb
	sta tmpb

	tya
	pha

	; tmpb = map quadrant address offset

	; get quadrant on tmp8
	lda tmpb+1
	lsr
	lsr
	lsr
	lsr
	and #$01
	sta tmp8
	lda tmpc+1
	lsr
	lsr
	lsr
	and #$02
	ora tmp8
	sta tmp8

	; get map quadrant base address on tmp9
	ldy #Area::attributes
	lda (cur_area), y ; attribute map address low byte
	sta tmp9
	iny
	lda (cur_area), y ; attribute map address high byte
	clc
	adc tmp8
	sta tmp9+1

	; now get that foo'
	ldy tmpb
	lda (tmp9), y

	; skip null interaction id (0)
	cmp #$00
	bne :+
	pla
	tay
	rts
:

	; now we have the interaction id!!!
	; and we need to look it up in the interaction table
	clc
	rol
	tay
	dey	; account for interaction ids starting at 1 instead of 0
	dey

	lda cur_area
	clc
	adc #.lobyte(Area::interactions)
	sta tmp9
	lda cur_area+1
	adc #.hibyte(Area::interactions)
	sta tmp9+1

	; get the handler pointer
	; and save it
	lda (tmp9), y
	sta tmpb
	iny
	lda (tmp9), y
	sta tmpb+1

	; now tmbp = interaction handler pointer
	; so restore y and jump there Dude
	pla
	tay
	lda tmpb+1
	pha
	lda tmpb
	pha
	rts	; jmup.!

; a test handler lol
test_handler:
	lda #$97
	sta $60
	rts
