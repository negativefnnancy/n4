.segment "CODE"

; palettes
.scope pal
	.scope bg
		day:		.incbin "day_bg.pal"
		dusk:		.incbin "dusk_bg.pal"
		night:		.incbin "night_bg.pal"
	.endscope
	.scope fg
		day:		.incbin "day_sprites.pal"
		dusk:		.incbin "dusk_sprites.pal"
		night:		.incbin "night_sprites.pal"
	.endscope
.endscope

; nametables
.scope nt
	title:			.incbin "title.nam"
	test:			.incbin "test.nam"
.endscope

; maps
.scope map
	test:			.incbin "test.map"
.endscope

; entity tables
.scope ent
	test:			.incbin "test.ent"
.endscope

; areas
.scope area
	test:
		.word map::test
		.word ent::test
.endscope

; metatiles
metatiles:
	.byte $23, $23, $23, $23	; blank 0
	.byte $24, $24, $24, $24	; blank 1
	.byte $25, $25, $25, $25	; blank 2
	.byte $26, $26, $26, $26	; blank 3
	.byte $39, $39, $3a, $3a	; north wall
	.byte $38, $38, $25, $25	; south wall
	.byte $3b, $43, $3b, $43	; east wall
	.byte $40, $3c, $40, $3c	; west wall
	.byte $30, $31, $40, $41	; northwest inner corner
	.byte $33, $34, $43, $44	; northeast inner corner
	.byte $50, $51, $25, $25	; southwest inner corner
	.byte $52, $53, $22, $23	; southeast inner corner

; metasprites
.scope metasprites
	null:
		.byte $00
	nancy_north_1:
		.byte $04
		.byte $00, $02, $00, $00
		.byte $00, $02, $40, $08
		.byte $08, $12, $00, $00
		.byte $08, $12, $40, $08
	nancy_south_1:
		.byte $04
		.byte $00, $00, $00, $00
		.byte $00, $00, $40, $08
		.byte $08, $10, $00, $00
		.byte $08, $10, $40, $08
	nancy_east_1:
		.byte $04
		.byte $00, $04, $40, $08
		.byte $00, $05, $40, $00
		.byte $08, $14, $40, $08
		.byte $08, $15, $40, $00
	nancy_west_1:
		.byte $04
		.byte $00, $04, $00, $00
		.byte $00, $05, $00, $08
		.byte $08, $14, $00, $00
		.byte $08, $15, $00, $08

	nancy_north_2:
		.byte $04
		.byte $00, $03, $40, $00
		.byte $00, $03, $00, $08
		.byte $08, $13, $40, $00
		.byte $08, $08, $40, $08
	nancy_south_2:
		.byte $04
		.byte $00, $03, $40, $00
		.byte $00, $03, $00, $08
		.byte $08, $13, $40, $00
		.byte $08, $08, $40, $08
	nancy_east_2:
		.byte $04
		.byte $00, $06, $40, $08
		.byte $00, $07, $40, $00
		.byte $08, $16, $40, $08
		.byte $08, $17, $40, $00
	nancy_west_2:
		.byte $04
		.byte $00, $06, $00, $00
		.byte $00, $07, $00, $08
		.byte $08, $16, $00, $00
		.byte $08, $17, $00, $08

	nancy_north_3:
		.byte $04
		.byte $00, $03, $40, $00
		.byte $00, $03, $00, $08
		.byte $08, $08, $00, $00
		.byte $08, $13, $00, $08
	nancy_south_3:
		.byte $04
		.byte $00, $03, $40, $00
		.byte $00, $03, $00, $08
		.byte $08, $08, $00, $00
		.byte $08, $13, $00, $08

	; lookup table of all the metasprites
	table:
		.word null
		.word nancy_north_1, nancy_north_2, nancy_north_3
		.word nancy_south_1, nancy_south_2, nancy_south_3
		.word nancy_east_1, nancy_east_2
		.word nancy_west_1, nancy_west_2
.endscope

; animation sets
.scope anim
	.scope null
		null:
			.byte $01, $00
			.byte $00, $00, $00
		table:	.word null
	.endscope
	.scope nancy
		walk_frames	= $06
		idle_north:
			.byte $01, $00
			.byte $01, $00, $00
		idle_south:
			.byte $01, $00
			.byte $04, $00, $00
		idle_east:
			.byte $01, $00
			.byte $07, $00, $00
		idle_west:
			.byte $01, $00
			.byte $09, $00, $00
		walk_north:
			.byte $04, walk_frames
			.byte $03, $00, $00
			.byte $01, $00, $00
			.byte $02, $00, $00
			.byte $01, $00, $00
		walk_south:
			.byte $04, walk_frames
			.byte $05, $00, $00
			.byte $04, $00, $00
			.byte $06, $00, $00
			.byte $04, $00, $00
		walk_east:
			.byte $02, walk_frames
			.byte $08, $00, $00
			.byte $07, $00, $00
		walk_west:
			.byte $02, walk_frames
			.byte $0a, $00, $00
			.byte $09, $00, $00

		; table of all the animations for this entity
		table:
			.word idle_north, idle_south, idle_east, idle_west
			.word walk_north, walk_south, walk_east, walk_west
	.endscope

	; lookup table of all the animation sets
	table:
		.word null::table
		.word nancy::table
.endscope
