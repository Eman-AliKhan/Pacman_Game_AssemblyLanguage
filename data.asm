.data
    ; Sound files
    openingSound db "sounds\\pacman_beginning.wav", 0
    endingSound db "sounds\\pacman_death.wav", 0
    wakaSound db "sounds\\waka.wav", 0
    bigDotSound db "sounds\\bigdot.wav", 0
    cherrySound db "sounds\\cherry.wav", 0
    pauseSound db "sounds\\pause.mp3", 0
    resumeSound db "sounds\\resume.mp3", 0

    ; User Inputs
    userName db 32 dup(0)    
    userPrompt db "Enter your name: ", 0
    userLabel db 'Player: ', 0

    ; Start Page Strings
    welcomeMsg db 'Welcome to PACMAN, ', 0
    pressAnyKeyMsg db 'Press any key to start...', 0
    gameCreatorMsg db 'Created by: Syeda Irha Azhar Kazmi', 0
    gameControlsTitle db '-- CONTROLS --', 0

    ; Menu Page Strings
    menuTitle db 'MAIN MENU', 0
    menuOption1 db '1. Start Game', 0
    menuOption2 db '2. Instructions', 0
    menuOption3 db '3. Game Setup', 0
    menuOption4 db '4. Levels', 0
    menuOption5 db '5. High Scores', 0
    menuOption6 db '6. Exit', 0
    menuPrompt db 'Enter your choice (1-6): ', 0

    ; Instructions Page Strings
    instructionsTitle db 'GAME INSTRUCTIONS', 0
    instructionsText1 db 'Use the arrow keys to move Pacman around the maze.', 0
    instructionsText2 db 'Eat all the dots to complete a level.', 0
    instructionsText3 db 'Avoid the ghosts or you will lose a life.', 0
    instructionsText4 db 'Eat power pellets to temporarily eat ghosts.', 0
    instructionsBackMsg db 'Press ESC to return to the menu...', 0

    ; Game Setup Strings
    setupTitle db "Game Setup", 0
    livesPrompt db "Number of Lives (1-5): ", 0
    wallColorPrompt db "Wall Color (1-Blue, 2-Red, 3-Green): ", 0
    ghostSpeedPrompt db "Ghost Speed (1-Slow, 2-Medium, 3-Fast): ", 0
    ghostModePrompt db "Ghost Mode (1-Chase, 2-Scatter): ", 0
    soundPrompt db "Sound (1-On, 0-Off): ", 0
    setupSavedMsg db "Settings saved successfully!", 0

    ; Game Variables
    level BYTE 1
    selectedLevel BYTE 0
    customWallColor BYTE 0    
    ghostSpeed BYTE 2         ; Default: Medium
    ghostDelay DWORD 2        ; Delay value for ghost movement
    ghostMode BYTE 1          ; Default: Chase mode
    soundEnabled BYTE 1       ; Default: Sound on
    lives BYTE 3
    score DWORD 0
    highScore DWORD 0

    ; Levels Page Strings
    levelsTitle db 'SELECT LEVEL', 0
    levelsOption1 db '1. Level 1 - Beginner', 0
    levelsOption2 db '2. Level 2 - Intermediate', 0
    levelsOption3 db '3. Level 3 - Advanced', 0
    levelsPrompt db 'Enter level (1-3): ', 0

    ; Menu Variables
    currentMenuSelection db 1    
    selectedLives db 3          
    selectedSpeed db 2         
    selectedGhostDifficulty db 2 
    selectedSound db 1          
    selectedWallColor db 1      

    ; Bonus Fruit Variables
    fruitActive db 0             ; 0 = no fruit, 1 = fruit is active
    fruitTimer DWORD 0          ; Tracks how long fruit has been active
    fruitX BYTE 0               ; X coordinate of fruit
    fruitY BYTE 0               ; Y coordinate of fruit
    fruitType BYTE 0            ; Type of fruit (for scoring)
    fruitScore DWORD 0          ; Points for current fruit

    ; Game state flags
    gameIsPaused BYTE 0         ; 0 = running, 1 = paused
    fixRightwall BYTE 0         ; Set to 0FFh when right wall is traversed
    fixLeftwall BYTE 0          ; Set to 0FFh when left wall is traversed
    gameIsOver BYTE 0           ; Set to 1 when game is over
    
    ; Maze and game board
    maze BYTE 2000 DUP(0)       ; Buffer for the maze
    
    ; Player and Ghost positions
    playerX BYTE 27             ; Player starting X position
    playerY BYTE 23             ; Player starting Y position
    playerDirection BYTE 0       ; 0=right, 1=left, 2=up, 3=down
    
    ; Ghosts' data structures
    Ghost1XCoord BYTE 15
    Ghost1YCoord BYTE 14
    Ghost1moveInst DWORD OFFSET MoveGhost1Left
    Ghost1moveCache DWORD 0
    
    Ghost2XCoord BYTE 39
    Ghost2YCoord BYTE 14
    Ghost2moveInst DWORD OFFSET MoveGhost2Left
    Ghost2moveCache DWORD 0
    
    Ghost3XCoord BYTE 15
    Ghost3YCoord BYTE 18
    Ghost3moveInst DWORD OFFSET MoveGhost3Left
    Ghost3moveCache DWORD 0
    
    Ghost4XCoord BYTE 39
    Ghost4YCoord BYTE 18
    Ghost4moveInst DWORD OFFSET MoveGhost4Left
    Ghost4moveCache DWORD 0
    
    ; High score data
    highScoreName db 32 DUP(0)   ; Name of high score holder
    highScoreFileName db "highscore.txt", 0
    fileHandle HANDLE ?
    bytesRead DWORD ?
    buffer BYTE 100 DUP(0)
    
    ; Temporary variables
    tempByte BYTE 0
    tempWord WORD 0
    tempDword DWORD 0
    
    ; UI Elements
    scoreString db 'Score: ', 0
    highScoreString db 'High Score: ', 0
    livesString db 'Lives: ', 0
    levelString db 'Level: ', 0
    
    ; Game messages
    gameOverMsg db 'GAME OVER', 0
    levelCompleteMsg db 'LEVEL COMPLETE!', 0
    pressAnyKeyMsg2 db 'Press any key to continue...', 0
    
    ; File handling
    fileErrorMsg db 'Error accessing high score file', 0
    newHighScoreMsg db 'NEW HIGH SCORE!', 0
    enterNameMsg db 'Enter your name: ', 0