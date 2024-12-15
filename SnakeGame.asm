; Simple Snake Game for Real Hardware or Emulator Debugging

name "snake"

org 100h ; Start program at offset 100h (standard for COM programs)

; Jump to start of code to skip the data section
jmp start   

;-----------------------------Shalan----------------------------- 
; ---------------- DATA SECTION ----------------

snake_length equ 7 ; Length of the snake

snake_body dw snake_length dup(0) ; Array for snake's coordinates (head to tail)
tail_position dw ? ; Stores the last position of the snake's tail

; Direction constants
DIR_LEFT equ 4bh
DIR_RIGHT equ 4dh
DIR_UP equ 48h
DIR_DOWN equ 50h

current_direction db DIR_RIGHT ; Initial direction

game_delay dw 0 ; Timing variable for game loop delays

; Welcome message for the player
welcome_message db "==== How to Play ====", 0dh,0ah
                db "Use arrow keys to control the snake.", 0dh,0ah
                db "Press ESC to exit.", 0dh,0ah
                db "Press any key to start...$"

; ---------------- CODE SECTION ----------------

start:
    ; Display welcome message
    mov dx, offset welcome_message
    mov ah, 9h
    int 21h

    ; Wait for key press
    mov ah, 00h
    int 16h

    ; Hide the cursor
    mov ah, 1h
    mov ch, 2bh
    mov cl, 0bh
    int 10h

game_loop:
    ; Display the snake
    call display_snake

    ; Store the tail position
    mov ax, snake_body[snake_length * 2 - 2]
    mov tail_position, ax

    ; Move the snake
    call move_snake

    ; Erase the old tail
    call erase_tail

    ; Check for user input
    call handle_input

    ; Wait before the next frame
    call wait_for_delay

    ; Repeat the game loop
    jmp game_loop

; ---------------- FUNCTION SECTION ----------------

; Display the snake on the screen
display_snake proc near
    mov dx, snake_body[0] ; Get snake head position
    mov ah, 2h ; Set cursor position
    int 10h

    mov al, '*' ; Character to display the snake
    mov ah, 9h
    mov bl, 0eh ; Text attribute
    mov cx, 1 ; Print one character
    int 10h
    ret

display_snake endp

; Erase the snake's tail
erase_tail proc near
    mov dx, tail_position
    mov ah, 2h ; Set cursor position to old tail
    int 10h

    mov al, ' ' ; Erase the tail with a space
    mov ah, 9h
    mov cx, 1
    int 10h
    ret

erase_tail endp

;-----------------------------Noura Elsaey-----------------------------
; Handle user input for direction changes
handle_input proc near
    mov ah, 1h
    int 16h
    jz no_key_pressed ; Continue if no key is pressed

    mov ah, 0h
    int 16h
    cmp al, 1bh ; Check if ESC key is pressed
    je end_game ; Exit if ESC is pressed

    ; Update the current direction
    mov current_direction, ah
no_key_pressed:
    ret
handle_input endp

; Move the snake in the current direction
move_snake proc near
    mov ax, 40h
    mov es, ax ; Set ES to BIOS data area segment

    ; Shift snake segments
    mov di, snake_length * 2 - 2 ; Start at the tail
    mov cx, snake_length - 1
shift_segments:
    mov ax, snake_body[di - 2]
    mov snake_body[di], ax
    sub di, 2
    loop shift_segments
    
;-----------------------------Omar Kamal-----------------------------
    ; Update head position based on direction
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
    dec snake_body[0] ; Move left
    ret
move_right:
    inc snake_body[0] ; Move right
    ret
move_up:
    dec snake_body[1] ; Move up
    ret
move_down:
    inc snake_body[1] ; Move down
    ret

move_snake endp

; Wait for a short delay between frames
wait_for_delay proc near
    mov ah, 0h
    int 1ah ; Get system clock ticks
    cmp dx, game_delay
    jb wait_for_delay_end
    add dx, 4
    mov game_delay, dx
wait_for_delay_end:
    ret
wait_for_delay endp

; End the game and restore settings
end_game:
    mov ah, 1h
    mov ch, 0bh
    mov cl, 0bh
    int 10h
    ret