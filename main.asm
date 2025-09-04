; Main entry point for Pacman game
; This file includes all necessary modules and starts the game

.686
.model flat, stdcall
.stack 4096

; Include Irvine32 library
INCLUDE Irvine32.inc
INCLUDELIB Irvine32.lib
INCLUDELIB kernel32.lib
INCLUDELIB user32.lib
INCLUDELIB Winmm.lib

; Include all our custom modules
INCLUDE constants.inc
INCLUDE data.asm
INCLUDE utils.asm
INCLUDE sound.asm
INCLUDE ghosts.asm
INCLUDE menu.asm
INCLUDE game.asm

; External procedures from Windows API
EXTERN PlaySoundA:PROC

.code
main PROC
    ; Set up console window
    call Clrscr
    mov eax, white + (black * 16)
    call SetTextColor
    
    ; Set console title
    push OFFSET windowTitle
    call SetConsoleTitleA
    
    ; Hide the cursor
    call HideCursor
    
    ; Initialize random number generator
    call Randomize
    
    ; Show start screen
    call ShowStartScreen
    
    ; Main game loop
    .WHILE gameRunning == 1
        ; Show main menu
        call ShowMainMenu
        
        ; If game was selected, run the game
        .IF gameSelected == 1
            call GameLoop
            mov gameSelected, 0
        .ENDIF
    .ENDW
    
    ; Exit the program
    call Clrscr
    exit
main ENDP

; Show the start screen
ShowStartScreen PROC
    call Clrscr
    
    ; Draw Pacman title
    mov eax, yellow + (black * 16)
    call SetTextColor
    
    mov dl, 30
    mov dh, 5
    call Gotoxy
    mov edx, OFFSET gameTitle
    call WriteString
    
    ; Draw creator info
    mov eax, white + (black * 16)
    call SetTextColor
    
    mov dl, 20
    mov dh, 10
    call Gotoxy
    mov edx, OFFSET createdByMsg
    call WriteString
    
    ; Draw controls
    mov dl, 20
    mov dh, 15
    call Gotoxy
    mov edx, OFFSET controlsMsg1
    call WriteString
    
    add dh, 1
    call Gotoxy
    mov edx, OFFSET controlsMsg2
    call WriteString
    
    add dh, 1
    call Gotoxy
    mov edx, OFFSET controlsMsg3
    call WriteString
    
    ; Draw press any key message
    mov dl, 30
    mov dh, 22
    call Gotoxy
    mov edx, OFFSET pressAnyKeyMsg
    call WriteString
    
    ; Wait for key press
    call ReadChar
    
    ; Play start sound
    call PlayOpeningSound
    
    ret
ShowStartScreen ENDP

; Hide the console cursor
HideCursor PROC
    LOCAL cursorInfo:CONSOLE_CURSOR_INFO
    
    pushad
    
    ; Get console handle
    push -11  ; STD_OUTPUT_HANDLE
    call GetStdHandle
    mov hConsoleOutput, eax
    
    ; Get current cursor info
    push OFFSET cursorInfo
    push hConsoleOutput
    call GetConsoleCursorInfo
    
    ; Hide the cursor
    mov cursorInfo.bVisible, 0
    
    ; Set cursor info
    push OFFSET cursorInfo
    push hConsoleOutput
    call SetConsoleCursorInfo
    
    popad
    ret
HideCursor ENDP

; Show the console cursor
ShowCursor PROC
    LOCAL cursorInfo:CONSOLE_CURSOR_INFO
    
    pushad
    
    ; Get console handle
    push -11  ; STD_OUTPUT_HANDLE
    call GetStdHandle
    mov hConsoleOutput, eax
    
    ; Get current cursor info
    push OFFSET cursorInfo
    push hConsoleOutput
    call GetConsoleCursorInfo
    
    ; Show the cursor
    mov cursorInfo.bVisible, 1
    
    ; Set cursor info
    push OFFSET cursorInfo
    push hConsoleOutput
    call SetConsoleCursorInfo
    
    popad
    ret
ShowCursor ENDP

END main
