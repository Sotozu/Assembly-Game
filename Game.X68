    *-----------------------------------------------------------
* Title      : Sling Boy
* Written by : Alexander Soto
* Date       :
* Description: A game where you pop the balloons!
*-----------------------------------------------------------

*ASSIGNMENT REQUIREMENTS*

*1. User input control of game entity (i.e. paddle in Pong, aiming a turret, etc)
    
*   Implemented in moving the fireline for shooting 
*   GetInput.x68 -> GetKeyPresses subroutine
    
*2. Bitmap background with entities moving around over it

*   Implementd through the Seven Segment in the top right corner of the game.
*   DrawGame.x68 -> ClearSevSeg subroutine    

*3. Physics update of game entity, including acceleration (gravity would be good example)

*   Implemented in the rocks change in Y velocity when going accross the screen by applying gravity.
*   UpdateGame.x68 -> UpdateRock subroutine    

*4. Fixed point math

*   Implemented through the SIN COS table and applied to the fire line
*   UpdateGame.x68 -> UpdateFireLine subroutine

*5. Collision detection between game entities

*   Implemented between the rock and the balloon
*   UpdateGame.x68 -> CheckIfRockCollided

*6. A score indicator as a 7-segment LED

*   Implemented in the top right corner
*   DrawGame.x68 -> SetSevenSegment subroutine

*7. Randomness

*   LFSR implementation for random color generation in the last balloon
*   UpdateGame.x68 -> RandomColorLFSR


*--------------MAIN GAME LOOP--------------*
*Take user input
*Update data
*Draw
*Check if Loss -> if true break
*Check if Win -> if true break
*Otherwise loop
  
START: ORG    $1000
    jsr LoadDataBeforeGameLoop
    jsr MainGameLoop
    SIMHALT             ; halt simulator       

MainGameLoop:

    jsr GetInput
    jsr UpdateGame
    jsr DrawGame
    
    *Check if LOSE
    move.l (B_Is_Lose),d1
    cmp #1,d1
    beq GameLost
    
    *Check if WIN
    move.l (B_Is_Win),d1
    cmp #1,d1
    bne MainGameLoop
    
    rts
    
GameWon:
    rts
GameLost:
    rts    
    
    INCLUDE "VariablesEquates.x68"
    INCLUDE "GeneralFunctions.x68"
    INCLUDE "LoadDataBeforeGameLoop.x68"
    INCLUDE "GetInput.x68"
    INCLUDE "UpdateGame.x68"
    INCLUDE "DrawGame.x68"
    

    END    START


































































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
