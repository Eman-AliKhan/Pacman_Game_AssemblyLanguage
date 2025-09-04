; Utility procedures for Pacman game
; Contains helper functions used throughout the game

.686
.model flat, stdcall
.stack 4096

INCLUDE Irvine32.inc
INCLUDE constants.inc
INCLUDE macros.inc

.data
    ; Local utility variables if needed
    tempString db 32 DUP(0)
    
.code
; Include external procedures
EXTERN score:DWORD, highScore:DWORD, lives:BYTE, level:BYTE

; Procedure to convert a number to a string
; Input: EAX = number, ESI = pointer to output buffer
; Output: ESI points to the end of the string
NumberToString PROC
    push ebx
    push ecx
    push edx
    push edi
    
    mov edi, esi
    mov ebx, 10
    xor ecx, ecx
    
    test eax, eax
    jnz @F
    mov byte ptr [edi], '0'
    inc edi
    jmp done
    
@@: test eax, eax
    jz @F
    xor edx, edx
    div ebx
    add dl, '0'
    push edx
    inc ecx
    jmp @B
    
@@: pop eax
    stosb
    loop @B
    
done:
    mov byte ptr [edi], 0
    mov eax, edi
    
    pop edi
    pop edx
    pop ecx
    pop ebx
    ret
NumberToString ENDP

; Procedure to display the score
DisplayScore PROC
    pushad
    
    ; Display "Score: "
    mov dl, 0
    mov dh, 0
    call Gotoxy
    mov edx, OFFSET scoreString
    call WriteString
    
    ; Convert and display the score
    mov eax, score
    mov esi, OFFSET tempString
    call NumberToString
    mov byte ptr [esi], 0
    mov edx, OFFSET tempString
    call WriteString
    
    popad
    ret
DisplayScore ENDP

; Procedure to display the high score
DisplayHighScore PROC
    pushad
    
    ; Display "High Score: "
    mov dl, 20
    mov dh, 0
    call Gotoxy
    mov edx, OFFSET highScoreString
    call WriteString
    
    ; Convert and display the high score
    mov eax, highScore
    mov esi, OFFSET tempString
    call NumberToString
    mov byte ptr [esi], 0
    mov edx, OFFSET tempString
    call WriteString
    
    popad
    ret
DisplayHighScore ENDP

; Procedure to display the number of lives
DisplayLives PROC
    pushad
    
    ; Display "Lives: "
    mov dl, 40
    mov dh, 0
    call Gotoxy
    mov edx, OFFSET livesString
    call WriteString
    
    ; Display the number of lives
    mov al, lives
    add al, '0'
    call WriteChar
    
    popad
    ret
DisplayLives ENDP

; Procedure to display the current level
DisplayLevel PROC
    pushad
    
    ; Display "Level: "
    mov dl, 60
    mov dh, 0
    call Gotoxy
    mov edx, OFFSET levelString
    call WriteString
    
    ; Display the level number
    mov al, level
    add al, '0'
    call WriteChar
    
    popad
    ret
DisplayLevel ENDP

; Procedure to update the score and check for high score
UpdateScore PROC points:DWORD
    pushad
    
    ; Add points to score
    mov eax, points
    add score, eax
    
    ; Check for new high score
    mov eax, score
    cmp eax, highScore
    jle @F
    mov highScore, eax
    
@@: call DisplayScore
    call DisplayHighScore
    
    popad
    ret
UpdateScore ENDP

; Procedure to delay execution
; Input: EAX = number of milliseconds to delay
DelayMS PROC
    pushad
    call Delay
    popad
    ret
DelayMS ENDP

; Procedure to clear a line on the screen
; Input: DH = row to clear
ClearLine PROC
    pushad
    
    mov dl, 0
    call Gotoxy
    mov ecx, 80
    mov al, ' '
    
clear_loop:
    call WriteChar
    loop clear_line_loop
    
    popad
    ret
ClearLine ENDP

; Procedure to center text on the screen
; Input: EDX = offset of string to center
;        DH = row to display on
CenterText PROC
    pushad
    
    ; Calculate string length
    push edx
    mov edi, edx
    xor ecx, ecx
    dec ecx
    xor al, al
    cld
    repne scasb
    not ecx
    dec ecx
    
    ; Calculate column position
    mov eax, 80
    sub eax, ecx
    shr eax, 1
    mov dl, al
    
    ; Set cursor position and display string
    pop edx
    call Gotoxy
    call WriteString
    
    popad
    ret
CenterText ENDP

; Procedure to display a message and wait for a key press
; Input: EDX = offset of message to display
;        DH = row to display on
DisplayMessage PROC
    pushad
    
    call CenterText
    
    ; Wait for key press
    call ReadChar
    
    popad
    ret
DisplayMessage ENDP

; Procedure to check if a position contains a wall
; Input: AL = X coordinate, AH = Y coordinate
; Output: ZF = 1 if wall, 0 otherwise
IsWall PROC
    push ebx
    push ecx
    push edx
    
    ; Convert coordinates to index
    xor ebx, ebx
    mov bl, ah      ; Y coordinate
    mov bh, 80      ; Width of the screen
    imul bx, bx, 80 ; Y * 80
    xor ah, ah      ; Clear high byte of AX
    add bx, ax      ; Y * 80 + X
    
    ; Check if position is a wall
    mov al, maze[bx]
    cmp al, '#'
    je is_wall
    cmp al, '='
    je is_wall
    cmp al, '|'
    je is_wall
    cmp al, '-'
    je is_wall
    
    ; Not a wall
    or eax, 1        ; Clear ZF
    jmp done_check
    
is_wall:
    test eax, eax    ; Set ZF
    
done_check:
    pop edx
    pop ecx
    pop ebx
    ret
IsWall ENDP

; Procedure to initialize random number generator
InitRandom PROC
    push eax
    push edx
    
    call Randomize
    
    pop edx
    pop eax
    ret
InitRandom ENDP

; Procedure to generate a random number in a range
; Input: EAX = maximum value (exclusive)
; Output: EAX = random number [0..EAX-1]
RandomRange PROC
    push edx
    push ebx
    
    mov ebx, eax
    call Random32
    xor edx, edx
    div ebx
    mov eax, edx
    
    pop ebx
    pop edx
    ret
RandomRange ENDP
