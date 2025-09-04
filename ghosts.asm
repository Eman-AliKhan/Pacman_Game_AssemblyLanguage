; Ghost AI and movement module for Pacman game
; Handles all ghost behavior and movement

.686
.model flat, stdcall
.stack 4096

INCLUDE Irvine32.inc
INCLUDE constants.inc
INCLUDE macros.inc

.data
    ; Ghost modes
    GHOST_CHASE EQU 0
    GHOST_SCATTER EQU 1
    GHOST_FRIGHTENED EQU 2
    GHOST_EATEN EQU 3
    
    ; Ghost directions
    DIR_UP EQU 0
    DIR_DOWN EQU 1
    DIR_LEFT EQU 2
    DIR_RIGHT EQU 3
    
    ; Ghost states
    ghostModes BYTE 4 DUP(GHOST_CHASE)  ; One for each ghost
    ghostTimers DWORD 4 DUP(0)          ; Timers for mode changes
    
.code
; Include external procedures
EXTERN playerX:BYTE, playerY:BYTE, playerDirection:BYTE
EXTERN score:DWORD, highScore:DWORD, lives:BYTE, level:BYTE

; Ghost structure definition
GHOST STRUCT
    x BYTE ?
    y BYTE ?
    targetX BYTE ?
    targetY BYTE ?
    direction BYTE ?
    color BYTE ?
    inHouse BYTE ?
    frightenedTimer DWORD ?
GHOST ENDS

; Ghost instances
ghosts GHOST 4 DUP(<>)

; Initialize all ghosts
InitGhosts PROC
    ; Initialize ghost 1 (Red - Blinky)
    mov ghosts[0].x, 15
    mov ghosts[0].y, 14
    mov ghosts[0].direction, DIR_LEFT
    mov ghosts[0].color, red
    mov ghosts[0].inHouse, 0
    mov ghosts[0].frightenedTimer, 0
    
    ; Initialize ghost 2 (Pink - Pinky)
    mov ghosts[4].x, 15
    mov ghosts[4].y, 17
    mov ghosts[4].direction, DIR_UP
    mov ghosts[4].color, 13  ; Pink
    mov ghosts[4].inHouse, 1
    mov ghosts[4].frightenedTimer, 0
    
    ; Initialize ghost 3 (Cyan - Inky)
    mov ghosts[8].x, 14
    mov ghosts[8].y, 17
    mov ghosts[8].direction, DIR_UP
    mov ghosts[8].color, cyan
    mov ghosts[8].inHouse, 1
    mov ghosts[8].frightenedTimer, 0
    
    ; Initialize ghost 4 (Orange - Clyde)
    mov ghosts[12].x, 16
    mov ghosts[12].y, 17
    mov ghosts[12].direction, DIR_UP
    mov ghosts[12].color, 14  ; Yellow/Orange
    mov ghosts[12].inHouse, 1
    mov ghosts[12].frightenedTimer, 0
    
    ret
InitGhosts ENDP

; Update all ghosts
UpdateGhosts PROC
    pushad
    
    ; Update each ghost
    mov ecx, 4
    mov esi, 0
    
ghost_loop:
    ; Skip if ghost is in frightened mode with timer expired
    cmp ghosts[esi].frightenedTimer, 0
    jle not_frightened
    dec ghosts[esi].frightenedTimer
    jmp next_ghost
    
not_frightened:
    ; Update ghost position based on current direction
    call UpdateGhostPosition
    
    ; Update ghost target based on AI
    call UpdateGhostTarget
    
    ; Decide next direction
    call ChooseGhostDirection
    
next_ghost:
    add esi, TYPE GHOST
    loop ghost_loop
    
    popad
    ret
UpdateGhosts ENDP

; Update ghost position based on current direction
UpdateGhostPosition PROC
    pushad
    
    ; Get current direction
    mov al, ghosts[esi].direction
    
    ; Move ghost based on direction
    cmp al, DIR_UP
    je move_up
    cmp al, DIR_DOWN
    je move_down
    cmp al, DIR_LEFT
    je move_left
    cmp al, DIR_RIGHT
    je move_right
    jmp move_done
    
move_up:
    dec ghosts[esi].y
    jmp move_done
    
move_down:
    inc ghosts[esi].y
    jmp move_done
    
move_left:
    dec ghosts[esi].x
    jmp move_done
    
move_right:
    inc ghosts[esi].x
    
move_done:
    ; Handle screen wrapping
    cmp ghosts[esi].x, 0
    jl wrap_right
    cmp ghosts[esi].x, 79
    jg wrap_left
    jmp position_done
    
wrap_right:
    mov ghosts[esi].x, 79
    jmp position_done
    
wrap_left:
    mov ghosts[esi].x, 0
    
position_done:
    popad
    ret
UpdateGhostPosition ENDP

; Update ghost target based on AI behavior
UpdateGhostTarget PROC
    pushad
    
    ; Different ghosts have different targeting behaviors
    cmp esi, 0
    je blinky_ai
    cmp esi, 4
    je pinky_ai
    cmp esi, 8
    je inky_ai
    jmp clyde_ai
    
blinky_ai:  ; Red ghost - targets player directly
    mov al, playerX
    mov ah, playerY
    jmp set_target
    
pinky_ai:   ; Pink ghost - targets 4 tiles ahead of player
    mov al, playerX
    mov ah, playerY
    ; Adjust based on player direction
    cmp playerDirection, DIR_UP
    je pinky_up
    cmp playerDirection, DIR_DOWN
    je pinky_down
    cmp playerDirection, DIR_LEFT
    je pinky_left
    ; Right
    add al, 4
    jmp set_target
pinky_up:
    sub ah, 4
    jmp set_target
pinky_down:
    add ah, 4
    jmp set_target
pinky_left:
    sub al, 4
    jmp set_target
    
inky_ai:    ; Cyan ghost - complex targeting
    ; This is a simplified version
    mov al, playerX
    mov ah, playerY
    ; More complex targeting would go here
    jmp set_target
    
clyde_ai:   ; Orange ghost - random behavior when close to player
    ; This is a simplified version
    mov al, playerX
    mov ah, playerY
    ; More complex behavior would go here
    
set_target:
    mov ghosts[esi].targetX, al
    mov ghosts[esi].targetY, ah
    
    popad
    ret
UpdateGhostTarget ENDP

; Choose the best direction for the ghost to move
ChooseGhostDirection PROC
    pushad
    
    ; Simple AI: choose direction that gets closer to target
    ; In a real implementation, this would be more sophisticated
    
    ; Calculate distances for each possible direction
    ; This is a placeholder - actual implementation would check for walls, etc.
    
    ; For now, just choose a random valid direction
    mov eax, 4
    call RandomRange
    mov ghosts[esi].direction, al
    
    popad
    ret
ChooseGhostDirection ENDP

; Draw all ghosts
DrawGhosts PROC
    pushad
    
    mov ecx, 4
    mov esi, 0
    
draw_ghost_loop:
    ; Set cursor position
    mov dl, ghosts[esi].x
    mov dh, ghosts[esi].y
    call Gotoxy
    
    ; Set color based on ghost state
    cmp ghosts[esi].frightenedTimer, 0
    jg frightened_color
    
    ; Normal color
    mov eax, 0
    mov al, ghosts[esi].color
    call SetTextColor
    jmp draw_ghost
    
frightened_color:
    ; Frightened color (blue)
    mov eax, blue
    call SetTextColor
    
draw_ghost:
    ; Draw ghost symbol
    mov al, 'M'  ; Using 'M' as ghost symbol
    call WriteChar
    
    ; Move to next ghost
    add esi, TYPE GHOST
    loop draw_ghost_loop
    
    ; Reset text color
    mov eax, white + (black * 16)
    call SetTextColor
    
    popad
    ret
DrawGhosts ENDP

; Check for collisions between Pacman and ghosts
CheckGhostCollisions PROC
    pushad
    
    mov ecx, 4
    mov esi, 0
    
collision_loop:
    ; Check if ghost is at same position as player
    mov al, ghosts[esi].x
    mov ah, ghosts[esi].y
    cmp al, playerX
    jne next_ghost_collision
    cmp ah, playerY
    jne next_ghost_collision
    
    ; Collision detected
    cmp ghosts[esi].frightenedTimer, 0
    jg ghost_eaten
    
    ; Player dies
    call PlayerDie
    jmp collision_done
    
ghost_eaten:
    ; Ghost is eaten
    ; Add points based on level
    mov eax, 200  ; Base points
    movzx ebx, level
    imul eax, ebx  ; Multiply by level
    call UpdateScore
    
    ; Reset ghost
    call ResetGhost
    
next_ghost_collision:
    add esi, TYPE GHOST
    loop collision_loop
    
collision_done:
    popad
    ret
CheckGhostCollisions ENDP

; Reset a ghost to its starting position
ResetGhost PROC
    ; Reset ghost position based on ghost number
    cmp esi, 0
    je reset_blinky
    cmp esi, 4
    je reset_pinky
    cmp esi, 8
    je reset_inky
    
    ; Clyde
    mov ghosts[12].x, 16
    mov ghosts[12].y, 17
    mov ghosts[12].direction, DIR_UP
    mov ghosts[12].frightenedTimer, 0
    jmp reset_done
    
reset_blinky:
    mov ghosts[0].x, 15
    mov ghosts[0].y, 14
    mov ghosts[0].direction, DIR_LEFT
    mov ghosts[0].frightenedTimer, 0
    jmp reset_done
    
reset_pinky:
    mov ghosts[4].x, 15
    mov ghosts[4].y, 17
    mov ghosts[4].direction, DIR_UP
    mov ghosts[4].frightenedTimer, 0
    jmp reset_done
    
reset_inky:
    mov ghosts[8].x, 14
    mov ghosts[8].y, 17
    mov ghosts[8].direction, DIR_UP
    mov ghosts[8].frightenedTimer, 0
    
reset_done:
    ret
ResetGhost ENDP

; Make all ghosts frightened
FrightenGhosts PROC
    pushad
    
    mov ecx, 4
    mov esi, 0
    
frighten_loop:
    mov ghosts[esi].frightenedTimer, 300  ; 5 seconds at 60 FPS
    add esi, TYPE GHOST
    loop frighten_loop
    
    popad
    ret
FrightenGhosts ENDP

; Release ghosts from the ghost house
ReleaseGhosts PROC
    pushad
    
    ; Release one ghost at a time based on score/dots eaten
    ; This is a simplified version
    
    ; Check if any ghosts are still in the house
    mov ecx, 4
    mov esi, 0
    
release_loop:
    cmp ghosts[esi].inHouse, 1
    jne next_release
    
    ; Release this ghost
    mov ghosts[esi].inHouse, 0
    jmp release_done
    
next_release:
    add esi, TYPE GHOST
    loop release_loop
    
release_done:
    popad
    ret
ReleaseGhosts ENDP
