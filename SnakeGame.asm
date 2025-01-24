name "snake"

org 100h
jmp start   

snake_length equ 7
snake_body dw snake_length dup(0)
tail_position dw ?
DIR_LEFT equ 4bh
DIR_RIGHT equ 4dh
DIR_UP equ 48h
DIR_DOWN equ 50h
current_direction db DIR_RIGHT
game_delay dw 0
welcome_message db "==== How to Play ====", 0dh,0ah
                db "Use arrow keys to control the snake.", 0dh,0ah
                db "Press ESC to exit.", 0dh,0ah
                db "Press any key to start...$"

start:
    mov dx, offset welcome_message
    mov ah, 9h
    int 21h
    mov ah, 00h
    int 16h
    mov ah, 1h
    mov ch, 2bh
    mov cl, 0bh
    int 10h

game_loop:
    call display_snake
    mov ax, snake_body[snake_length * 2 - 2]
    mov tail_position, ax
    call move_snake
    call erase_tail
    call handle_input
    call wait_for_delay
    jmp game_loop

display_snake proc near
    mov dx, snake_body[0]
    mov ah, 2h
    int 10h
    mov al, '*'
    mov ah, 9h
    mov bl, 0eh
    mov cx, 1
    int 10h
    ret
display_snake endp

erase_tail proc near
    mov dx, tail_position
    mov ah, 2h
    int 10h
    mov al, ' '
    mov ah, 9h
    mov cx, 1
    int 10h
    ret
erase_tail endp

handle_input proc near
    mov ah, 1h
    int 16h
    jz no_key_pressed
    mov ah, 0h
    int 16h
    cmp al, 1bh
    je end_game
    mov current_direction, ah
no_key_pressed:
    ret
handle_input endp

move_snake proc near
    mov ax, 40h
    mov es, ax
    mov di, snake_length * 2 - 2
    mov cx, snake_length - 1
shift_segments:
    mov ax, snake_body[di - 2]
    mov snake_body[di], ax
    sub di, 2
    loop shift_segments
    cmp current_direction, DIR_LEFT
    je move_left
    cmp current_direction, DIR_RIGHT
    je move_right
    cmp current_direction, DIR_UP
    je move_up
    cmp current_direction, DIR_DOWN
    je move_down
    ret
move_left:
    dec snake_body[0]
    ret
move_right:
    inc snake_body[0]
    ret
move_up:
    dec snake_body[1]
    ret
move_down:
    inc snake_body[1]
    ret
move_snake endp

wait_for_delay proc near
    mov ah, 0h
    int 1ah
    cmp dx, game_delay
    jb wait_for_delay_end
    add dx, 4
    mov game_delay, dx
wait_for_delay_end:
    ret
wait_for_delay endp

end_game:
    mov ah, 1h
    mov ch, 0bh
    mov cl, 0bh
    int 10h
    ret
