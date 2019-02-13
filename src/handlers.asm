.include "title.asm"
.include "test_screen.asm"
.include "game.asm"

; engine state handler routines
state_handler_table:
.word title_handler-1
.word test_screen_handler-1
.word game_handler-1
