; read the current state of the buttons
read_pad:
	; store the previous pad state first
	lda pad
	sta pad_press

	; read the continuous pad state
	lda #$01
	sta pad1	; enable pad strobe
	sta pad		; shifted left onto carry to indicate done
	lsr		; a = 0
	sta pad1	; disable pad strobe
:
	lda pad1	; read pad
	lsr		; shift button state onto carry
	rol pad		; shift from carry into right side of pad register
	bcc :-		; loop until done bit is shifted off the end

	; now check for instantaneous presses
	lda pad_press
	eor pad		; mask for changes only
	sta pad_change	; store changes
	and pad		; keep only pressed changes
	sta pad_press	; store presses	
	lda pad	
	eor #$ff
	and pad_change	; now get only unpressed changes
	sta pad_unpress
	
	rts

; wait until vblank
wait_vblank:
	bit ppustatus
	bpl wait_vblank
	rts

; initialize ram contents to 0
clear_ram:
	lda #$00
	tax
:
	sta page0, x
	; skip stack, because it contains return address lol
	; skip oam page
	sta page3, x
	sta page4, x
	sta page5, x
	sta page6, x
	sta page7, x
	inx
	bne :-
	rts

; initialize the oam contents to off the screen
clear_oam:
	ldx #$ff
	txa	; a = $ff
	inx	; x = 0
:
	sta oam, x
	inx
	bne :-
	rts

; copy a block of memory
; tmp0 = source
; tmp1 = destination
; tmp2 = length
copy:
	; copy full pages first
	ldx #$00	; page index
	jmp @next_page
:
	ldy #$00	; byte index
:
	lda (tmp0), y
	sta (tmp1), y
	iny
	bne :-	
	inc tmp0+1	; next page
	inc tmp1+1	; next page
	inx
@next_page:
	cpx tmp2+1
	bne :--
	
	; copy the rest
	ldy #$00	; byte index
	jmp @next_byte
:
	lda (tmp0), y
	sta (tmp1), y
	iny
@next_byte:
	cpy tmp2
	bne :-	
	rts

; copy a block of memory to the ppu
; tmp0 = source
; tmp1 = ppu destination
; tmp2 = length
copy_ppu:
	; latch the ppu address
	bit ppustatus
	lda tmp1+1
	sta ppuaddr
	lda tmp1
	sta ppuaddr

	; copy full pages first
	ldx #$00	; page index
	jmp @next_page
:
	ldy #$00	; byte index
:
	lda (tmp0), y
	sta ppudata
	iny
	bne :-	
	inc tmp0+1	; next page
	inx
@next_page:
	cpx tmp2+1
	bne :--
	
	; copy the rest
	ldy #$00	; byte index
	jmp @next_byte
:
	lda (tmp0), y
	sta ppudata
	iny
@next_byte:
	cpy tmp2
	bne :-	
	rts

; copy nametable data to the ppu
; tmp0 = address
load_nametable:
	st16 tmp1, nt0
	st16 tmp2, $400
	jmp copy_ppu	

; copy a background palette into the ppu
; tmp0 = address
load_bg_palette:
	st16 tmp1, palbg
load_bg_palette_skip:
	st16 tmp2, $10
	jmp copy_ppu	

; copy a foreground palette into the ppu
; tmp0 = address
load_fg_palette:
	st16 tmp1, palfg
	jmp load_bg_palette_skip	

