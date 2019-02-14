; setup the title screen
enter_title:
	; wait for vblank
	jsr wait_vblank

	; disable ppu
	lda #$00
	sta ppuctrl
	sta ppumask

; for entering the title screen when the ppu is already disabled
enter_title_skip:
	; set the engine state
	lda #$00
	sta state

	; load the title screen nametable
	st16 tmp0, nt::title
	jsr load_nametable

	; load the color palette
	st16 tmp0, pal::bg::dusk
	jsr load_bg_palette

	; wait for vblank
	jsr wait_vblank

	; enable the ppu
	lda #$88
	sta ppuctrl
	lda #$08
	sta ppumask	; show bg only

	; reset scrolling
	lda #$00
	sta ppuscroll
	sta ppuscroll

	rts

; blank the "START" string on the title screen
title_blank_start:
	st16 tmp0, nt::title+$270
	st16 tmp1, nt0+$250
	st16 tmp2, $5
	jmp copy_ppu	
	rts

; show the "START" string on the title screen
title_show_start:
	st16 tmp0, nt::title+$250
	st16 tmp1, nt0+$250
	st16 tmp2, $5
	jmp copy_ppu	
	rts

; handler for the title screen
title_handler:
	; blink the "START" string
	lda global_timer
	and #$20
	bne :+
	jsr title_blank_start
	jmp :++
:
	jsr title_show_start
:
	; reset scrolling
	lda #$00
	sta ppuscroll
	sta ppuscroll

	; await the start button
	lda pad_press
	and #%00010000
	beq :+
	
	; enter next screen
	jsr enter_test_screen
:
	rti
