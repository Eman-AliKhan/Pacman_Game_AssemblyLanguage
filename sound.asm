; Sound module for Pacman game
; Handles all sound effects and music

.code
; Include necessary headers
INCLUDE Irvine32.inc
INCLUDELIB Winmm.lib
INCLUDE constants.inc

; External procedures
EXTERN PlaySoundA:PROC

; Play the opening sound
PlayOpeningSound PROC
    cmp soundEnabled, 0
    je @@skip
    INVOKE PlaySound, OFFSET openingSound, NULL, SND_FILENAME OR SND_ASYNC
@@skip:
    ret
PlayOpeningSound ENDP

; Play the death sound
PlayDeathSound PROC
    cmp soundEnabled, 0
    je @@skip
    INVOKE PlaySound, OFFSET endingSound, NULL, SND_FILENAME OR SND_ASYNC
@@skip:
    ret
PlayDeathSound ENDP

; Play the waka sound when Pacman eats a dot
PlayWakaSound PROC
    cmp soundEnabled, 0
    je @@skip
    INVOKE PlaySound, OFFSET wakaSound, NULL, SND_FILENAME OR SND_ASYNC
@@skip:
    ret
PlayWakaSound ENDP

; Play the sound when Pacman eats a power pellet
PlayBigDotSound PROC
    cmp soundEnabled, 0
    je @@skip
    INVOKE PlaySound, OFFSET bigDotSound, NULL, SND_FILENAME OR SND_ASYNC
@@skip:
    ret
PlayBigDotSound ENDP

; Play the sound when Pacman eats a cherry
PlayCherrySound PROC
    cmp soundEnabled, 0
    je @@skip
    INVOKE PlaySound, OFFSET cherrySound, NULL, SND_FILENAME OR SND_ASYNC
@@skip:
    ret
PlayCherrySound ENDP

; Play the pause sound
PlayPauseSound PROC
    cmp soundEnabled, 0
    je @@skip
    INVOKE PlaySound, OFFSET pauseSound, NULL, SND_FILENAME OR SND_ASYNC
@@skip:
    ret
PlayPauseSound ENDP

; Play the resume sound
PlayResumeSound PROC
    cmp soundEnabled, 0
    je @@skip
    INVOKE PlaySound, OFFSET resumeSound, NULL, SND_FILENAME OR SND_ASYNC
@@skip:
    ret
PlayResumeSound ENDP

; Stop all currently playing sounds
StopAllSounds PROC
    INVOKE PlaySound, 0, 0, 0
    ret
StopAllSounds ENDP

; Toggle sound on/off
ToggleSound PROC
    xor soundEnabled, 1
    ret
ToggleSound ENDP
