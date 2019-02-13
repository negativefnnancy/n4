; some convenience macros for ca65

; store an immediate 16-bit value as little endian
.macro st16	addr, data
	lda #.lobyte(data)
	sta addr
	lda #.hibyte(data)
	sta addr+1
.endmacro
