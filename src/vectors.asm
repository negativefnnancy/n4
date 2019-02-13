; on vblank
nmi:
	; increment the global timer
	inc global_timer
	bne :+
	inc global_timer+1
:

	; update the pad variables
	jsr read_pad

	; grab the current state and jump to the appropriate handler
	lda state
	asl
	tax
	lda state_handler_table+1, x	
	pha
	lda state_handler_table, x	
	pha
	rts

; for audio or somethin idk yet
irq:
	rti

; on reset, init
reset:
	; disable irq and decimal mode
	sei
	cld

	; disable apu frame irq
	ldx #$40
	stx framecounter

	; setup stack
	ldx #$ff
	txs

	; disable ppu and dmc irq
	inx	; x = 0
	stx ppuctrl
	stx ppumask
	stx dmc

	; wait for vblank
	jsr wait_vblank

	; clear ram and oam
	jsr clear_ram
	jsr clear_oam

	; wait for vblank once more
	jsr wait_vblank

	; and enter the title screen
	jsr enter_title_skip
	
	; do nothing forever
:
	jmp :-
