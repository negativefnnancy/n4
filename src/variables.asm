.segment "ZEROPAGE"
; scratch vars
tmp0:		.res 2
tmp1:		.res 2
tmp2:		.res 2
tmp3:		.res 2
tmp4:		.res 2
tmp5:		.res 2
tmp6:		.res 2
tmp7:		.res 2

; engine state
state:		.res 1

; buttons
pad:		.res 1
pad_press:	.res 1

; timers
global_timer:	.res 2

; 12 bit camera position coordinates
cam_x:		.res 1
cam_y:		.res 1
cam_high:	.res 1	; high=x, low=y

.segment "BSS"
entities:	.res $100	; entity table
map:		.res $400	; loaded map
