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

; metasprites
.scope metasprites
	null:
		.byte $00
	nancy_north_1:
	nancy_south_1:
	nancy_east_1:
	nancy_west_1:
		.byte $04
		.byte $00, $00, $00, $00
		.byte $00, $00, $40, $08
		.byte $08, $10, $00, $00
		.byte $08, $10, $40, $08
	nancy_north_2:
	nancy_south_2:
	nancy_east_2:
	nancy_west_2:
		.byte $04
		.byte $00, $01, $40, $00
		.byte $00, $01, $00, $08
		.byte $08, $11, $40, $00
		.byte $08, $12, $40, $08
	nancy_north_3:
	nancy_south_3:
	nancy_east_3:
	nancy_west_3:
		.byte $04
		.byte $00, $01, $40, $00
		.byte $00, $01, $00, $08
		.byte $08, $12, $00, $00
		.byte $08, $11, $00, $08

	; lookup table of all the metasprites
	table:
		.word null
		.word nancy_north_1, nancy_north_2, nancy_north_3
		.word nancy_south_1, nancy_south_2, nancy_south_3
		.word nancy_east_1, nancy_east_2, nancy_east_3
		.word nancy_west_1, nancy_west_2, nancy_west_3
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
		idle_north:
			.byte $01, $10
			.byte $01, $00, $00
		idle_south:
			.byte $01, $10
			.byte $04, $00, $00
		idle_east:
			.byte $01, $10
			.byte $07, $00, $00
		idle_west:
			.byte $01, $10
			.byte $0a, $00, $00
		walk_north:
			.byte $04, $0c
			.byte $01, $00, $00
			.byte $02, $00, $00
			.byte $01, $00, $00
			.byte $03, $00, $00
		walk_south:
			.byte $04, $0c
			.byte $04, $00, $00
			.byte $05, $00, $00
			.byte $04, $00, $00
			.byte $06, $00, $00
		walk_east:
			.byte $04, $0c
			.byte $07, $00, $00
			.byte $08, $00, $00
			.byte $07, $00, $00
			.byte $09, $00, $00
		walk_west:
			.byte $04, $0c
			.byte $0a, $00, $00
			.byte $0b, $00, $00
			.byte $0a, $00, $00
			.byte $0c, $00, $00

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
