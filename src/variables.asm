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
tmp8:		.res 2
tmp9:		.res 2
tmpa:		.res 2
tmpb:		.res 2
tmpc:		.res 2
tmpd:		.res 2

; engine state
state:		.res 1

; buttons
pad:		.res 1
pad_change:	.res 1
pad_press:	.res 1
pad_unpress:	.res 1

; timers
global_timer:	.res 2

; 12 bit camera position coordinates
cam_x:		.res 1
cam_y:		.res 1
cam_high:	.res 1	; high=x, low=y

; scroll buffer direction
scroll_dir:	.res 1 ; 0 = left; >0 = right

; ppu scroll
scroll_y:	.res 2 ; low byte = scroll; high byte = base nametable (vertical)

.segment "STACK"
; also, use part of the stack page for vram update buffers
;scroll_buf:	.res 32
nt0_buf0:	.res 30
nt0_buf1:	.res 30
nt2_buf0:	.res 30
nt2_buf1:	.res 30

.segment "BSS"
entities:	.res $100	; entity table
map:		.res $400	; loaded map

