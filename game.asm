; Main game logic for Pacman
; Handles the core game loop and mechanics

.686
.model flat, stdcall
.stack 4096

INCLUDE Irvine32.inc
INCLUDE constants.inc
INCLUDE macros.inc

.data
    ; Game state variables
    gamePaused BYTE 0
    gameOver BYTE 0
    levelComplete BYTE 0
    
    ; Timing variables
    frameCount DWORD 0
    lastTime DWORD 0
    
    ; Player state
    playerDirection BYTE DIR_RIGHT
    nextDirection BYTE DIR_RIGHT
    playerLives BYTE 3
    playerScore DWORD 0
    
    ; Level data
    dotsRemaining DWORD 0
    powerPelletsRemaining BYTE 0
    
    ; Ghost mode timers
    chaseTimer DWORD 0
    scatterTimer DWORD 0
    frightenedTimer DWORD 0
    
.code
; Include external procedures
EXTERN DrawMaze, DrawPlayer, DrawGhosts, UpdatePlayer, UpdateGhosts, CheckCollisions
EXTERN UpdateScoreDisplay, UpdateLivesDisplay, UpdateLevelDisplay

; Main game loop
GameLoop PROC
    call InitializeGame
    
    ; Main game loop
    game_loop:
        call HandleInput
        call UpdateGame
        call RenderGame
        
        ; Check for game over or level complete
        cmp gameOver, 1
        je game_loop_exit
        cmp levelComplete, 1
        je level_complete
        
        ; Cap the frame rate
        call FrameDelay
        jmp game_loop
        
    level_complete:
        call NextLevel
        jmp game_loop
        
    game_loop_exit:
        call GameOver
        ret
GameLoop ENDP

; Initialize game state
InitializeGame PROC
    ; Reset game state
    mov gamePaused, 0
    mov gameOver, 0
    mov levelComplete, 0
    
    ; Initialize player
    mov playerDirection, DIR_RIGHT
    mov nextDirection, DIR_RIGHT
    mov playerLives, 3
    mov playerScore, 0
    
    ; Load current level
    call LoadLevel
    
    ; Initialize ghosts
    call InitGhosts
    
    ; Initialize UI
    call UpdateScoreDisplay
    call UpdateLivesDisplay
    call UpdateLevelDisplay
    
    ; Play start sound
    call PlayOpeningSound
    
    ret
InitializeGame ENDP

; Load the current level
LoadLevel PROC
    ; TODO: Load level data based on current level
    
    ; Reset level-specific variables
    mov dotsRemaining, 0
    mov powerPelletsRemaining, 0
    
    ; Set up timers based on level
    mov eax, 60 * 7  ; 7 seconds of chase mode
    sub eax, level
    imul eax, 10     ; Decrease time slightly per level
    mov chaseTimer, eax
    
    mov scatterTimer, 60 * 3  ; 3 seconds of scatter mode
    mov frightenedTimer, 0
    
    ret
LoadLevel ENDP

; Handle user input
HandleInput PROC
    ; Check for key press
    call ReadKey
    jz input_done  ; No key pressed
    
    ; Handle key press
    cmp al, 'p'    ; Pause game
    je toggle_pause
    cmp al, 'P'
    je toggle_pause
    
    ; Only process movement if game is not paused
    cmp gamePaused, 1
    je input_done
    
    ; Check arrow keys for movement
    cmp ah, 48h    ; Up arrow
    je set_up
    cmp ah, 50h    ; Down arrow
    je set_down
    cmp ah, 4Bh    ; Left arrow
    je set_left
    cmp ah, 4Dh    ; Right arrow
    je set_right
    jmp input_done
    
set_up:
    mov nextDirection, DIR_UP
    jmp input_done
    
set_down:
    mov nextDirection, DIR_DOWN
    jmp input_done
    
set_left:
    mov nextDirection, DIR_LEFT
    jmp input_done
    
set_right:
    mov nextDirection, DIR_RIGHT
    jmp input_done
    
toggle_pause:
    xor gamePaused, 1
    cmp gamePaused, 1
    je pause_game
    call PlayResumeSound
    jmp input_done
    
pause_game:
    call PlayPauseSound
    
input_done:
    ret
HandleInput ENDP

; Update game state
UpdateGame PROC
    ; Skip update if game is paused
    cmp gamePaused, 1
    je update_done
    
    ; Update player
    call UpdatePlayer
    
    ; Update ghosts
    call UpdateGhosts
    
    ; Check for collisions
    call CheckCollisions
    
    ; Update timers
    call UpdateTimers
    
update_done:
    ret
UpdateGame ENDP

; Update game timers
UpdateTimers PROC
    ; Update frame counter
    inc frameCount
    
    ; Update ghost mode timers
    cmp frightenedTimer, 0
    jg update_frightened
    
    ; Update chase/scatter timers
    cmp chaseTimer, 0
    jle check_scatter
    dec chaseTimer
    jmp timers_done
    
check_scatter:
    cmp scatterTimer, 0
    jle switch_to_chase
    dec scatterTimer
    jmp timers_done
    
switch_to_chase:
    ; Switch back to chase mode
    mov eax, 60 * 5  ; 5 seconds of chase mode
    sub eax, level
    imul eax, 8      ; Decrease time slightly per level
    mov chaseTimer, eax
    
    ; Set all ghosts to chase mode
    mov ecx, 4
    mov esi, 0
    
set_chase_mode:
    mov ghosts[esi].mode, GHOST_CHASE
    add esi, TYPE GHOST
    loop set_chase_mode
    
    jmp timers_done
    
update_frightened:
    dec frightenedTimer
    
    ; Flash ghosts when frightened mode is about to end
    cmp frightenedTimer, 60  ; 1 second left
    jg timers_done
    
    test frameCount, 8  ; Flash every 8 frames
    jz timers_done
    
    ; Toggle ghost colors
    mov ecx, 4
    mov esi, 0
    
flash_ghosts:
    xor ghosts[esi].color, 8  ; Toggle between blue and white
    add esi, TYPE GHOST
    loop flash_ghosts
    
timers_done:
    ret
UpdateTimers ENDP

; Render the game
RenderGame PROC
    ; Clear the screen
    call Clrscr
    
    ; Draw the maze
    call DrawMaze
    
    ; Draw game elements
    call DrawPlayer
    call DrawGhosts
    
    ; Draw UI
    call DrawUI
    
    ; If game is paused, draw pause message
    cmp gamePaused, 1
    jne render_done
    
    mov dl, 35
    mov dh, 12
    call Gotoxy
    mov edx, OFFSET pauseMsg
    call WriteString
    
render_done:
    ret
RenderGame ENDP

; Draw the game UI
DrawUI PROC
    ; Draw score
    mov dl, 0
    mov dh, 0
    call Gotoxy
    mov edx, OFFSET scoreString
    call WriteString
    
    mov eax, playerScore
    call WriteDec
    
    ; Draw high score
    mov dl, 30
    mov dh, 0
    call Gotoxy
    mov edx, OFFSET highScoreString
    call WriteString
    
    ; TODO: Get and display high score
    
    ; Draw lives
    mov dl, 60
    mov dh, 0
    call Gotoxy
    mov edx, OFFSET livesString
    call WriteString
    
    mov al, playerLives
    add al, '0'
    call WriteChar
    
    ; Draw level
    mov dl, 75
    mov dh, 0
    call Gotoxy
    mov edx, OFFSET levelString
    call WriteString
    
    mov al, level
    add al, '0'
    call WriteChar
    
    ret
DrawUI ENDP

; Handle player death
PlayerDie PROC
    ; Decrement lives
    dec playerLives
    call UpdateLivesDisplay
    
    ; Check for game over
    cmp playerLives, 0
    jg respawn_player
    
    ; Game over
    mov gameOver, 1
    ret
    
respawn_player:
    ; Reset player position
    mov playerX, 27
    mov playerY, 23
    mov playerDirection, DIR_RIGHT
    mov nextDirection, DIR_RIGHT
    
    ; Reset ghosts
    call ResetGhosts
    
    ; Play death sound
    call PlayDeathSound
    
    ; Brief pause
    mov eax, 1000
    call Delay
    
    ret
PlayerDie ENDP

; Reset all ghosts to their starting positions
ResetGhosts PROC
    mov ecx, 4
    mov esi, 0
    
reset_loop:
    call ResetGhost
    add esi, TYPE GHOST
    loop reset_loop
    
    ret
ResetGhosts ENDP

; Advance to the next level
NextLevel PROC
    ; Increment level
    inc level
    
    ; Reset level-specific state
    call LoadLevel
    
    ; Reset player position
    mov playerX, 27
    mov playerY, 23
    mov playerDirection, DIR_RIGHT
    mov nextDirection, DIR_RIGHT
    
    ; Reset ghosts
    call ResetGhosts
    
    ; Reset level complete flag
    mov levelComplete, 0
    
    ; Update level display
    call UpdateLevelDisplay
    
    ; Play level complete sound
    call PlayLevelCompleteSound
    
    ; Brief pause
    mov eax, 2000
    call Delay
    
    ret
NextLevel ENDP

; Game over screen
GameOver PROC
    call Clrscr
    
    ; Draw game over message
    mov eax, red + (black * 16)
    call SetTextColor
    
    mov dl, 35
    mov dh, 10
    call Gotoxy
    mov edx, OFFSET gameOverMsg
    call WriteString
    
    ; Draw final score
    mov eax, white + (black * 16)
    call SetTextColor
    
    mov dl, 30
    mov dh, 12
    call Gotoxy
    mov edx, OFFSET finalScoreMsg
    call WriteString
    
    mov eax, playerScore
    call WriteDec
    
    ; Check for new high score
    ; TODO: Implement high score check and save
    
    ; Wait for key press
    mov dl, 25
    mov dh, 20
    call Gotoxy
    mov edx, OFFSET pressAnyKeyMsg
    call WriteString
    
    call ReadChar
    
    ; Return to main menu
    call ShowMainMenu
    
    ret
GameOver ENDP

; Delay to maintain consistent frame rate
FrameDelay PROC
    ; Simple delay for now
    ; In a real implementation, this would use a timer for more precise timing
    mov eax, 50  ; 20 FPS
    call Delay
    ret
FrameDelay ENDP
