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
	room:			.incbin "room.map"
	upstairs:		.incbin "upstairs.map"
	downstairs:		.incbin "downstairs.map"
	test:			.incbin "test.map"
.endscope

; attribute maps (collision, color, and room ids for overalying onto maps)
.scope atr
	test:			.incbin "test.atr"
.endscope

; entity tables
.scope ent
	test:			.incbin "test.ent"
.endscope

; areas
.scope area
	test:
		.word map::room
		.word atr::test
		.word ent::test
.endscope

; metatiles
.scope metatiles
	; collision data bit format:
	; hhhhudlr
	; u = up, d = down, l = left, r = right
	; h = in the respective direction, collide at half point?
	collision:
		; $00
		.byte $00, $00, $00, $00, $08, $04, $01, $02
		.byte $00, $00, $00, $00, $04, $02, $00, $00
		.byte $00, $05, $06, $09, $0a, $00, $01, $00
		.byte $01, $1d, $02, $08, $89, $08, $8a, $08

		; $20
		.byte $04, $01, $02, $00, $00, $00, $00, $00
		.byte $00, $00, $00, $00, $00, $00, $00, $00
		.byte $00, $00, $00, $00, $00, $00, $00, $00
		.byte $00, $00, $00, $00, $00, $00, $00, $00

		; $40
		.byte $00, $00, $00, $00, $00, $00, $00, $00
		.byte $00, $00, $00, $00, $00, $00, $00, $00

	tiles:
		; $00
		.byte $23, $23, $23, $23	; blank 0
		.byte $24, $24, $24, $24	; blank 1
		.byte $25, $25, $25, $25	; blank 2
		.byte $26, $26, $26, $26	; blank 3
		.byte $39, $39, $3a, $3a	; south facing wall
		.byte $38, $38, $25, $25	; north facing wall
		.byte $3b, $43, $3b, $43	; west facing wall
		.byte $40, $3c, $40, $3c	; east facing wall

		; $08
		.byte $30, $31, $40, $41	; northwest inner corner
		.byte $32, $33, $42, $43	; northeast inner corner
		.byte $50, $51, $25, $25	; southwest inner corner
		.byte $52, $53, $25, $25	; southeast inner corner
		.byte $38, $3e, $25, $25	; north facing wall w shadow
		.byte $40, $3d, $40, $3c	; east facing wall w shadow
		.byte $48, $48, $25, $25	; south facing shadow
		.byte $25, $49, $25, $49	; west facing shadow

		; $10
		.byte $48, $4b, $25, $49	; southwest facing inner corner shadow
		.byte $34, $35, $3b, $43	; northwest outer corner
		.byte $36, $37, $40, $3c	; northeast outer corner
		.byte $44, $45, $54, $3a	; southwest outer corner
		.byte $46, $47, $3a, $57	; southeast outer corner
		.byte $25, $4a, $25, $25	; southwest outter corner shadow
		.byte $6b, $63, $7b, $73	; west facing window on wall
		.byte $25, $49, $25, $7a	; west facing window shadow

		; $18
		.byte $6d, $43, $7d, $43	; west facing bookshelve against wall
		.byte $25, $6c, $25, $7c	; west facing bookshelf shadow
		.byte $40, $3c, $40, $6a	; east facing wall with picture
		.byte $39, $39, $66, $67	; south facing wall w left end table
		.byte $76, $77, $25, $25	; south facing wall w left end table shadow
		.byte $39, $39, $68, $69	; south facing wall w right end table
		.byte $78, $79, $25, $25	; south facing wall w right end table shadow
		.byte $60, $61, $70, $71	; south facing door

		; $20
		.byte $55, $56, $25, $25	; north facing door
		.byte $62, $63, $72, $73	; west facing door
		.byte $64, $65, $74, $75	; east facing door
		.byte $2b, $2b, $2d, $2d	; south gradient 1
		.byte $2c, $2c, $23, $23	; south gradient 2
		.byte $2d, $2d, $2b, $2b	; north gradient 1
		.byte $23, $23, $2c, $2c	; north gradient 2
		.byte $2d, $2b, $2d, $2b	; west gradient 1

		; $28
		.byte $23, $2c, $23, $2c	; west gradient 2
		.byte $2b, $2d, $2b, $2d	; east gradient 1
		.byte $2c, $23, $2c, $23	; east gradient 2
		.byte $2c, $2c, $2c, $2d	; northwest gradient
		.byte $2c, $2c, $2d, $2c	; northeast gradient
		.byte $2c, $2d, $2c, $2c	; southwest gradient
		.byte $2d, $2c, $2c, $2c	; southeast gradient
		.byte $25, $4d, $25, $49	; west facing shadow of northwest outer corner

		; 30
		.byte $48, $4c, $25, $25	; south facing shadow of southeast outer corner
		.byte $00, $00, $00, $00	; placeholder
		.byte $00, $00, $00, $00	; placeholder
		.byte $00, $00, $00, $00	; placeholder
		.byte $00, $00, $00, $00	; placeholder
		.byte $00, $00, $00, $00	; placeholder
		.byte $00, $00, $00, $00	; placeholder
		.byte $00, $00, $00, $00	; placeholder

		; 38
		.byte $00, $00, $00, $00	; placeholder
		.byte $00, $00, $00, $00	; placeholder
		.byte $00, $00, $00, $00	; placeholder
		.byte $00, $00, $00, $00	; placeholder
		.byte $00, $00, $00, $00	; placeholder
		.byte $00, $00, $00, $00	; placeholder
		.byte $00, $00, $00, $00	; placeholder
		.byte $00, $00, $00, $00	; placeholder

		; 40 -- debug tiles
		.byte $00, $00, $00, $00
		.byte $01, $00, $00, $00
		.byte $02, $00, $00, $00
		.byte $03, $00, $00, $00
		.byte $04, $00, $00, $00
		.byte $05, $00, $00, $00
		.byte $06, $00, $00, $00
		.byte $07, $00, $00, $00

		; 48
		.byte $08, $00, $00, $00
		.byte $09, $00, $00, $00
		.byte $0a, $00, $00, $00
		.byte $0b, $00, $00, $00
		.byte $0c, $00, $00, $00
		.byte $0d, $00, $00, $00
		.byte $0e, $00, $00, $00
		.byte $0f, $00, $00, $00
.endscope

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
		walk_frames	= $06	; speed
		run_frames	= $03	; speed
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
		run_north:
			.byte $04, run_frames
			.byte $03, $00, $00
			.byte $01, $00, $00
			.byte $02, $00, $00
			.byte $01, $00, $00
		run_south:
			.byte $04, run_frames
			.byte $05, $00, $00
			.byte $04, $00, $00
			.byte $06, $00, $00
			.byte $04, $00, $00
		run_east:
			.byte $02, run_frames
			.byte $08, $00, $00
			.byte $07, $00, $00
		run_west:
			.byte $02, run_frames
			.byte $0a, $00, $00
			.byte $09, $00, $00

		; table of all the animations for this entity
		table:
			.word idle_north, idle_south, idle_east, idle_west
			.word walk_north, walk_south, walk_east, walk_west
			.word run_north, run_south, run_east, run_west
	.endscope

	; lookup table of all the animation sets
	table:
		.word null::table
		.word nancy::table
.endscope
