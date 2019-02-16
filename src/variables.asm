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

; camera movement "queue"
; put number here and it will scroll to that point 1 pixel at a time
cam_move_x:	.res 1
cam_move_y:	.res 1
cam_move_alt:	.res 1

; scroll buffer direction
scroll_dir:	.res 1 ; 0 = left; 1 = right; 2 = up; else = down

; ppu scroll
scroll_y:	.res 2 ; low byte = scroll; high byte = base nametable (vertical)

; current area object address
cur_area:	.res 2

.segment "STACK"
; also, use part of the stack page for vram update buffers
scroll_buf_x:
scroll_buf_x0:	.res 30
scroll_buf_x1:	.res 30
scroll_buf_y:	.res 32

.segment "BSS"
entities:	.res $100	; entity table
map:		.res $400	; loaded map

