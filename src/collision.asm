; handle entity collisions
; y = entity id
; tmpa = 4bit movement direction mask (analog to pad)
; tmpb = collision x coordinate
; tmpc = collision y coordinate
; cur_area = the area whose map to collide with
; tmpd = positive speed
; tmpe = negative speed
collide:
	; check half tile positions first
	lda tmpb
	rol
	rol
	and #$01
	sta tmpf
	lda tmpc
	rol
	rol
	rol
	rol
	and #$04
	ora tmpf
	sta tmpf
	eor #$05
	clc
	rol
	ora tmpf
	sta tmpf
	; now tmpf is half block mask

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
	ldy #Area::map
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

	; now we have the metatile, and we need to look up the collision data
	tay
	lda #.lobyte(metatiles::collision)
	sta tmp9
	lda #.hibyte(metatiles::collision)
	sta tmp9+1
	
	; get the collision data!
	lda (tmp9), y

	; save it
	sta tmpb

	; get the half collide flag for the metatile
	lda tmpb
	and #$f0
	lsr
	lsr
	lsr
	lsr
	eor #$ff
	; mask the mask lol
	ora tmpf
	sta tmpf

	; now also mask x with y and y with x
	; and u and d; and l and r
	clc
	rol
	and tmpf
	and #$0a
	sta tmp9
	lsr
	ora tmp9
	; swap lr and ud
	clc
	rol
	rol
	sta tmp9
	lsr
	lsr
	lsr
	lsr
	ora tmp9
	and #$0f
	; and u&d with l and r; and and l&r with u and d	
	and tmpf
	sta tmpf	

	; mask for half collide
	; so mask it with the half tile position mask
	lda tmpb
	and tmpf
	sta tmpb

	; now mask it for direction moving
	lda tmpb
	and tmpa
	sta tmpa

	pla
	tay

	; tmpa = collision flags
	lda tmpa
	cmp #%0001
	bne :+
	; moving right; so push left
	lda tmpe
	sta tmp8
	lda tmpe+1
	sta tmp8+1
	jmp move_entity_x
:
	cmp #%0010
	bne :+
	; moving left; so push right
	lda tmpd
	sta tmp8
	lda tmpd+1
	sta tmp8+1
	jmp move_entity_x
:
	cmp #%0100
	bne :+
	; moving down; so push up
	lda tmpe
	sta tmp8
	lda tmpe+1
	sta tmp8+1
	jmp move_entity_y
:
	cmp #%1000
	bne :+
	; moving up; so push down
	lda tmpd
	sta tmp8
	lda tmpd+1
	sta tmp8+1
	jmp move_entity_y
:
	
	; bye byeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee!
	rts
