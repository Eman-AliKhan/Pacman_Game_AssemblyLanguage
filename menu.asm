; Menu system for Pacman game
; Handles all menu screens and user interactions

.686
.model flat, stdcall
.stack 4096

INCLUDE Irvine32.inc
INCLUDE constants.inc
INCLUDE macros.inc

.data
    ; Menu options
    menuOptions DWORD OFFSET StartGame, OFFSET ShowInstructions, OFFSET GameSetup, 
                       OFFSET ShowLevels, OFFSET ShowHighScores, OFFSET ExitGame
    
    ; Level options
    levelOptions DWORD OFFSET SetLevel1, OFFSET SetLevel2, OFFSET SetLevel3
    
    ; Menu navigation
    currentSelection DWORD 0
    maxSelections DWORD 6  ; Number of main menu options
    
    ; Menu colors
    normalColor DWORD white + (black * 16)
    selectedColor DWORD black + (white * 16)
    
.code
; Include external procedures
EXTERN level:BYTE, lives:BYTE, soundEnabled:BYTE
EXTERN score:DWORD, highScore:DWORD

; Main menu procedure
ShowMainMenu PROC
    call Clrscr
    
    ; Draw menu title
    mov eax, yellow + (black * 16)
    call SetTextColor
    
    mov dl, 35
    mov dh, 5
    call Gotoxy
    mov edx, OFFSET menuTitle
    call WriteString
    
    ; Draw menu options
    mov ecx, 6
    mov ebx, 0
    
draw_menu_loop:
    ; Set cursor position
    push ecx
    mov dl, 35
    mov dh, 10
    add dh, bl
    call Gotoxy
    
    ; Highlight selected option
    cmp ebx, currentSelection
    jne not_selected
    
    mov eax, selectedColor
    jmp draw_option
    
not_selected:
    mov eax, normalColor
    
draw_option:
    call SetTextColor
    
    ; Draw menu option text
    mov edx, [menuOptions + ebx * 4]
    call WriteString
    
    inc ebx
    pop ecx
    loop draw_menu_loop
    
    ; Draw footer
    mov eax, white + (black * 16)
    call SetTextColor
    mov dl, 0
    mov dh, 28
    call Gotoxy
    mov edx, OFFSET gameCreatorMsg
    call WriteString
    
    ; Get user input
    call ReadChar
    
    ; Handle input
    cmp ah, 72  ; Up arrow
    je move_up
    cmp ah, 80  ; Down arrow
    je move_down
    cmp al, 13  ; Enter
    je select_option
    jmp ShowMainMenu
    
move_up:
    cmp currentSelection, 0
    je wrap_around_top
    dec currentSelection
    jmp ShowMainMenu
    
wrap_around_top:
    mov currentSelection, 5
    jmp ShowMainMenu
    
move_down:
    cmp currentSelection, 5
    jge wrap_around_bottom
    inc currentSelection
    jmp ShowMainMenu
    
wrap_around_bottom:
    mov currentSelection, 0
    jmp ShowMainMenu
    
select_option:
    call [menuOptions + currentSelection * 4]
    ret
ShowMainMenu ENDP

; Start the game
StartGame PROC
    ; Reset game state
    mov score, 0
    mov lives, 3
    mov level, 1
    
    ; Start the game
    call GameLoop
    ret
StartGame ENDP

; Show game instructions
ShowInstructions PROC
    call Clrscr
    
    ; Draw title
    mov eax, cyan + (black * 16)
    call SetTextColor
    
    mov dl, 32
    mov dh, 2
    call Gotoxy
    mov edx, OFFSET instructionsTitle
    call WriteString
    
    ; Draw instructions
    mov eax, white + (black * 16)
    call SetTextColor
    
    mov dl, 10
    mov dh, 6
    call Gotoxy
    mov edx, OFFSET instructionsText1
    call WriteString
    
    add dh, 2
    call Gotoxy
    mov edx, OFFSET instructionsText2
    call WriteString
    
    add dh, 2
    call Gotoxy
    mov edx, OFFSET instructionsText3
    call WriteString
    
    add dh, 2
    call Gotoxy
    mov edx, OFFSET instructionsText4
    call WriteString
    
    ; Wait for key press
    mov dl, 25
    mov dh, 20
    call Gotoxy
    mov edx, OFFSET instructionsBackMsg
    call WriteString
    
    call ReadChar
    ret
ShowInstructions ENDP

; Game setup menu
GameSetup PROC
    call Clrscr
    
    ; Draw title
    mov eax, green + (black * 16)
    call SetTextColor
    
    mov dl, 35
    mov dh, 2
    call Gotoxy
    mov edx, OFFSET setupTitle
    call WriteString
    
    ; Draw options
    mov eax, white + (black * 16)
    call SetTextColor
    
    ; Number of lives
    mov dl, 20
    mov dh, 6
    call Gotoxy
    mov edx, OFFSET livesPrompt
    call WriteString
    
    ; Wall color
    add dh, 2
    call Gotoxy
    mov edx, OFFSET wallColorPrompt
    call WriteString
    
    ; Ghost speed
    add dh, 2
    call Gotoxy
    mov edx, OFFSET ghostSpeedPrompt
    call WriteString
    
    ; Ghost mode
    add dh, 2
    call Gotoxy
    mov edx, OFFSET ghostModePrompt
    call WriteString
    
    ; Sound
    add dh, 2
    call Gotoxy
    mov edx, OFFSET soundPrompt
    call WriteString
    
    ; Wait for key press
    mov dl, 20
    mov dh, 22
    call Gotoxy
    mov edx, OFFSET instructionsBackMsg
    call WriteString
    
    call ReadChar
    ret
GameSetup ENDP

; Show level selection
ShowLevels PROC
    call Clrscr
    
    ; Draw title
    mov eax, yellow + (black * 16)
    call SetTextColor
    
    mov dl, 35
    mov dh, 5
    call Gotoxy
    mov edx, OFFSET levelsTitle
    call WriteString
    
    ; Draw level options
    mov eax, white + (black * 16)
    call SetTextColor
    
    mov dl, 30
    mov dh, 10
    call Gotoxy
    mov edx, OFFSET levelsOption1
    call WriteString
    
    add dh, 2
    call Gotoxy
    mov edx, OFFSET levelsOption2
    call WriteString
    
    add dh, 2
    call Gotoxy
    mov edx, OFFSET levelsOption3
    call WriteString
    
    ; Wait for input
    mov dl, 30
    mov dh, 20
    call Gotoxy
    mov edx, OFFSET levelsPrompt
    call WriteString
    
    call ReadChar
    sub al, '1'  ; Convert to 0-based index
    
    ; Validate input
    cmp al, 2
    ja invalid_level
    
    ; Set selected level
    mov selectedLevel, al
    inc selectedLevel  ; Convert to 1-based
    
invalid_level:
    ret
ShowLevels ENDP

; Set level 1
SetLevel1 PROC
    mov selectedLevel, 1
    ret
SetLevel1 ENDP

; Set level 2
SetLevel2 PROC
    mov selectedLevel, 2
    ret
SetLevel2 ENDP

; Set level 3
SetLevel3 PROC
    mov selectedLevel, 3
    ret
SetLevel3 ENDP

; Show high scores
ShowHighScores PROC
    call Clrscr
    
    ; Draw title
    mov eax, cyan + (black * 16)
    call SetTextColor
    
    mov dl, 35
    mov dh, 2
    call Gotoxy
    mov edx, OFFSET highScoreString
    call WriteString
    
    ; TODO: Load and display high scores from file
    
    ; Wait for key press
    mov dl, 25
    mov dh, 20
    call Gotoxy
    mov edx, OFFSET instructionsBackMsg
    call WriteString
    
    call ReadChar
    ret
ShowHighScores ENDP

; Exit the game
ExitGame PROC
    mov eax, 0
    call ExitProcess
ExitGame ENDP
