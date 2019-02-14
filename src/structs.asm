; represents an area
.struct Area
	map		.word
	entities	.word
.endstruct

; represents an in-game entity
.struct Entity
	identity	.byte
	state		.byte
	frame		.byte
	timer		.byte
	x_pos		.word
	y_pos		.word
.endstruct

; an oam entry
.struct Sprite
	y_off		.byte
	char		.byte
	attr		.byte
	x_off		.byte
.endstruct

; represents a sprite consisting of multiple hardware sprites
.struct MetaSprite
	size		.byte		; number of sprites
	sprites		.tag Sprite	; array of sprites
.endstruct

; represents a frame of animation
.struct Frame
	sprite		.byte		; metasprite id	
	x_off		.byte		; x offset
	y_off		.byte		; y offset
.endstruct

; represents an animated sprite
.struct Animation
	length		.byte		; number of animation frames
	speed		.byte		; number of hardware frames per animation frame
	frames		.tag Frame	; array of animation frames
.endstruct

; represents a meta tile
.struct MetaTile
	nw		.byte		; north west tile
	ne		.byte		; north east tile
	sw		.byte		; south west tile
	se		.byte		; south east tile
.endstruct
