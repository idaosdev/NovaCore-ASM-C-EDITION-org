[bits 32]
[extern main]
[extern mouse_handler]
[extern timer_handler]
[extern empty_handler_c]

global _start
_start:
    call main
    jmp $

global mouse_stub
mouse_stub:
    pushad
    call mouse_handler
    popad
    iretd

global timer_stub
timer_stub:
    pushad
    call timer_handler
    popad
    iretd

global empty_stub
empty_stub:
    pushad
    call empty_handler_c
    popad
    iretd
