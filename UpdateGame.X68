*--------------MAIN GAME LOOP--------------*
*First get the time values
*Perform math calculations
*Update all dynamic game objects
UpdateGame:
    
    jsr GetDeltaTime                            *MUST BE FIRST SUBROUTINE TO RUN
    jsr RandomColorLFSR
    jsr SetCosSin
    jsr UpdateFireLine
    jsr UpdateBallon
    jsr UpdateRock
    jsr CheckIfRockCollided  
    jsr CalcWhichSevSeg
    
    rts
    
DontUpdate:
    rts 
    
GetDeltaTime:
    move.l #TRAP_GET_TIME,d0                    *Get NEW CurrentTime into d1
    trap #15
    move.l #0,(TimeUpdateBool)                  *Set FALSE
    move.l #0,(B_Second_Passed)                 *Set FALSE
    move.l d1,d2                                *Save Current Time
    move.l d1,d3                                *Save Current Time
    
    sub.l (SecondCounter),d3
    
    sub.l (PreviousTime),d1                     *subtract the previoius time from the current time
                                                *Example PT = 3, CT = 5, thus...(5 - 3) = 2 <-- delta time
                                                *d1 has delta time
    cmpi.l #100,d3
    blt SkipSecondBoolSet
    move.l #1,(B_Second_Passed)                 *set true
    move.l d2,(SecondCounter)                   *set second counter
SkipSecondBoolSet
                                 
    cmpi.l #FRAME_UPDATE_RATE,d1
    blt ReachUpdateRate

TimeUpdateRateReached:    
    move.l d2,(PreviousTime)                    *Set the new previous time
    move.l #1,(TimeUpdateBool)                  *Set TRUE
    
    move.l #0,d1 
    move.l #0,d2 
    move.l #0,d3
    move.l #0,d4
    rts

ReachUpdateRate:
                                                *d1 holds delta time. It has not meet our FRAME_UPDATE_RATE
    move.l #FRAME_UPDATE_RATE,d3
    sub.l d1,d3                                 *d3 will hold the difference in time that needs to pass to get to the target FRAME_UPDATE_RATE
LoopTimer:
      
    move.l #TRAP_GET_TIME,d0                    *Get NEW CurrentTime into d1
    trap #15
    move.l d1,d4                                *save new current time
    sub.l d2,d1
    cmp d3,d1
    ble LoopTimer
    
    
    move.l d4,d2                                *d4 holds the current time and it needs to be passed to d2 because                                               
                                                *The TimeUpdateRateRached function uses d2 to store the current time as previous time
    rts
    

*We are moving the balloon vertically. At the beginnig we set the ballon velocity to a negative value. SUBTRACTING because the ballon spawns at the bottom of the screen. 
*Why subtract you ask? Silly output window coordinate conventions where when going DOWN you are INCREASING in the Y-direction...
*So thus we must DECREASE to go UP!
UpdateBallon:
    cmpi.l #1,(TimeUpdateBool)                  *is the update bool set to true?
    bne DontUpdate                              *If not true then DONT update
    
                                                *start by moving up
    move.l (V_Balloon_Velocity),d5
    move.l (V_Balloon_Current_UYPOS),d6
    cmpi #100,d6
    ble BallonMaxHeight
    cmp #100,d6
    bgt BalloonRise
    rts

BallonMaxHeight:
    move.b #1,(B_Balloon_Reached_MY)            *REACHED THE TOP   
BalloonRise:
    cmpi.b #1,(B_Balloon_Reached_MY)            *if reached the rop then DON'T sub
    beq BallonFall
    sub.l d5,(V_Balloon_Current_UYPOS)          *Upper Y
    sub.l d5,(V_Balloon_Current_LYPOS)          *Lower Y
    
    rts
    
BallonFall:
    add.l d5,(V_Balloon_Current_UYPOS)          *Upper Y
    add.l d5,(V_Balloon_Current_LYPOS)          *Lower Y
    
    move.l (V_Balloon_Current_LYPOS),d6
    cmp #400,d6
    bgt BalloonLowest
    
    rts

   
BalloonLowest
    move.b #0,(B_Balloon_Reached_MY)            *REACHED THE TOP 
    rts
 

SetCosSin:
    move.l (B_FireKeyPressed),d0
    cmp #0,d0                                   *If the fire button HAS been pressed then DON'T UPDATE
    bne DontUpdate
    
    move.l (AngleThetaOfShot),d0  
    
    lea COS_TABLE,a1
    lea SIN_TABLE,a2
    lea VELOCITY_TABLE,a3
    
TraverseCosSinTables:    
    move.w (a1)+,d1
    move.w (a2)+,d2
    move.l (a3)+,d3
    subi.l #1,d0
    cmp #0,d0
    bge TraverseCosSinTables
    
    
    move.l d1,(CosineOfAngle)
    move.l d2,(SineOfAngle)
    move.l d3,(V_Rock_X_Velocity)
    move.l d3,(V_Rock_Y_Velocity)
    
    rts


UpdateFireLine:
    move.l (B_FireKeyPressed),d0
    cmp #0,d0                                   *If the fire button HAS been pressed then DON'T UPDATE
    bne DontUpdate
    
                                                *Begin Fractional Bit use*
                                                *We are using three fractional bits to represent Cosine and Sine
    
                                                *Calculate Cosine
                                                *d1 is # of units to move, d2 is Cosine
    
    move.l d2,d4                                *store the Sine value in d2 into d4 for later use
                                                *The multiply function requires that d2 hold the value we wish to multiply
    move.l d1,d2                                *place cosine into d2
    move.l #FIRE_LINE_LENGTH,d1                 *place the number of times to multiply into d1
    jsr MULTIPLY_FUNCTION                       *d2 will hold the product of the multiplaction function
                          
    lsr.l #3,d2                                 *Shift for fractional bit manipulation
    
    move.l #PFIRE_LINE_ORG_X,d1
    add.l d2,d1
    lea V_FireLine_X_End_POS,a1  
    move.l d1,(V_FireLine_X_End_POS)            *Store X position of FireLine
    
                                                *Calculate Sine
    
    move.l d4,d2                                *place the saved Sine value into d2
    move.l #FIRE_LINE_LENGTH,d1
    jsr MULTIPLY_FUNCTION                       *d2 will hold the new value
    
    lsr.l #3,d2
    move.l #PFIRE_LINE_ORG_Y,d1
    sub.l d2,d1
    lea V_FireLine_Y_End_POS,a1
    move.l d1,(V_FireLine_Y_End_POS)            *Store Y position of FireLine
    
UpdateRock:
    move.l (B_FireKeyPressed),d0
    cmp #1,d0                                   *If the fire button HAS NOT been pressed then DON'T UPDATE
    bne DontUpdate
    
                                                *save Y positions for reverse velocity applications
    move.l (V_Rock_Current_LYPOS),d5
    move.l (V_Rock_Current_UYPOS),d6
    
                                                *Reset positions for new calculation
    
    move.l #ROCK_SPAWN_LEFT_X,(V_Rock_Current_LXPOS)
    move.l #ROCK_SPAWN_RIGHT_X,(V_Rock_Current_RXPOS)
    
    move.l #ROCK_SPAWN_LOWER_Y,(V_Rock_Current_LYPOS)
    move.l #ROCK_SPAWN_UPPER_Y,(V_Rock_Current_UYPOS)
      
   
             
    move.l (CosineOfAngle),d2       
    
    move.l (V_Rock_X_Velocity),d1               *multiply the Cosine with the velocity will yield the the displacement of pixels to be moved in the update
    jsr MULTIPLY_FUNCTION                       *d2 will hold the product of the multiplaction function
    
    add.l (Cosine_Cumulative),d2                *add cumulative value (is 0 on first run)
    move.l d2,(Cosine_Cumulative)               *Save cumulative value
                          
    lsr.l #3,d2                                 *Shift for fractional bit manipulation
                                                *d2 now holds the displacement of pixels 
                          
                                                *apply displacement to both X positions of the rock Left and Right
    
    add.l d2,(V_Rock_Current_LXPOS)       
    add.l d2,(V_Rock_Current_RXPOS)      
    
                                                *Apply gravity every certain interval of frames
    cmpi.l #GRAVITY_FRAME_COUNTER,(Gravity_Frame_Count)
    ble SkipGravityApplication
    
                                                *Check to see if we are applying Velocity in the opposite direction
    move.l (B_Velocity_Reverse),d1
    cmp #1,d1
    beq ApplyReverseVelocity
    
    
                                                **APPLY GRAVITY AS USUAL**
    move.l (V_Rock_Y_Velocity),d1
    sub.l #GRAVITY,d1                           *LOWER velocity
    move.l d1, (V_Rock_Y_Velocity)              *Place current velocity into into variable
    
    
                                                *Check to see if velocity has reached 0 because then we must apply velocity in the opposite direction.
    jsr CheckReverseVelocity *Will check if the boolian B_Velocity_Reverse is to be set true. IF SO THEN VELOCITY REVERSED
    move.l (B_Velocity_Reverse),d1
    cmp #0,d1 *This compare is used to skip the ApplyReverVelocity section
    beq SkipGravityApplication
    
ApplyReverseVelocity:
    **Reverse Gravity**
    move.l (V_Rock_Y_Velocity),d1
    addi.l #GRAVITY,d1 *INCREASE velocity
    move.l d1, (V_Rock_Y_Velocity) *Place current velocity into into variable
    move.l d1,d2
    move.l (B_Velocity_Reverse),d1    
    cmp #1,d1
    beq ApplyReverseYChangeRock
SkipGravityApplication:
       
    move.l (SineOfAngle),d2
    move.l (V_Rock_Y_Velocity),d1               *multiply the Sine with the velocity will yield the displacement of pixels to be moved in the update
    
    
    jsr MULTIPLY_FUNCTION                       *d2 will hold the product of the multiplaction function
    
    add.l (Sine_Cumulative),d2                  *add cumulative value (is 0 on first run)
    move.l d2,(Sine_Cumulative)                 *Save cumulative value
                          
    lsr.l #3,d2                                 *Shift for fractional bit manipulation
                                                *d2 now holds the displacement of pixels
                                    

ApplyYChangeRock:
    addi.l #1,(Gravity_Frame_Count)    
    sub.l d2,(V_Rock_Current_LYPOS)       
    sub.l d2,(V_Rock_Current_UYPOS) 
    
    rts
ApplyReverseYChangeRock:
    addi.l #1,(Gravity_Frame_Count)
    
    add.l d2,d5       
    add.l d2,d6
    move.l d5,(V_Rock_Current_LYPOS)       
    move.l d6,(V_Rock_Current_UYPOS)
    rts
    
CheckReverseVelocity
   
    cmp #0,d1                                   *Check to see if gravity is equal to 0
    beq setReverse                              *if it is we must begin reversing velocity
    rts
SetReverse:
    move.l #1,(B_Velocity_Reverse)              *Once the rock is deleted this needs to be reset
    rts
    

    
CheckIfRockCollided:
    move.l #1,(B_CollisionOccured)              *Set Collision to False at the begining of the check
    
    jsr CheckIfBalloonCollision
    
                                                *If Rock already collided then skip wall and floor collisions and return
    move.l (B_CollisionOccured),d1
    cmp #4,d1
    beq returnFromCollisionCheck
    jsr CheckIfWallCollision

returnFromCollisionCheck:    
    rts

CheckIfBalloonCollision:
*CHECK IF ROCK IS HITTING BALLON
*AABB versus AABB Intersection
*If All checks return FALSE then a collision has occured
*A = ROCK
*B = BALLOON
*If there is a collision add 1 to d0
*If d3 is #4 then we have a collision.
*ALL CHECKS MUST FAIL TO HAVE COLLISION
    move.l #0,d3
    
    move.l (V_Rock_Current_RXPOS),d0
    move.l (V_Balloon_Current_LXPOS),d1
    
    cmp.l d0,d1                         
                                     *Rock.max.x < Ballon.min.x
    bgt ROCK_BALLOON_CollisionCheck2 *Branch if the Ballon min X is GREATER than the Rock max X 
                                     *DEFINETLY NOT TOUCHING IF THIS IS THE CASE
    
    addi.l #1,d3 *If the check fails add 1 to d3
    
ROCK_BALLOON_CollisionCheck2:
    
    move.l (V_Balloon_Current_RXPOS),d0
    move.l (V_Rock_Current_LXPOS),d1
   
    cmp.l d0,d1                      *Ballon.max.x < Rock.min.x
    bgt ROCK_BALLOON_CollisionCheck3 *Branch if the Rock min X is GREATER than the Balloon max X
                                     *DEFINETLY NOT TOUCHING IF THIS IS THE CASE
                                     
    addi.l #1,d3 *If the check fails add 1 to d3
***************WHEN CHECKING FOR THE Y COLLISION DO THE INVERSE BECAUSE THE COORDINATE SYSTEM FOR Y IS FLIPPED***************    
ROCK_BALLOON_CollisionCheck3:

    move.l (V_Rock_Current_UYPOS),d0
    move.l (V_Balloon_Current_LYPOS),d1
    
    cmp.l d0,d1                      *Rock.max.y < Ballon.min.y
    blt ROCK_BALLOON_CollisionCheck4 *Branch if the Balloon lower Y is GREATER than the Rock upper Y
                                     *DEFINETLY NOT TOUCHING IF THIS IS THE CASE
                                     
    addi.l #1,d3 *If the check fails add 1 to d3
    
ROCK_BALLOON_CollisionCheck4: 
    move.l (V_Balloon_Current_UYPOS),d0
    move.l (V_Rock_Current_LYPOS),d1

    cmp.l d0,d1                      *Ballon.max.y < Rock.min.y
    blt Finish_Checks                *Branch if the Rock lower Y is GREATER than the Balloon upper Y
                                     

    addi.l #1,d3 *If the check fails add 1 to d3
    
Finish_Checks:
    cmp #4,d3 *IF ALL CHECKS FAIL THEN WE HAVE A COLLISSION. RESULT IN D3 WILL THUS BE 4
    beq BalloonCollisionDetected
    rts
    
CheckIfWallCollision
    move.l (V_Rock_Current_RXPOS),d1
    cmp #585,d1  
    
    bgt WallCollisionDetected
    
    move.l (V_Rock_Current_LYPOS),d1
    cmp #425,d1
    bgt WallCollisionDetected
    
    rts
    
BalloonCollisionDetected:

    move.l #TRAP_PLAY_WAV_SOUND,d0
    lea String_BallonPop_Sound,a1
    trap #15
    
    move.l #1,(B_CollisionOccured)              *Set Collision to true
    move.l #0,(B_FireKeyPressed)                *Enable firing AND stop rock updates
    addi.l #1,(V_Balloon_Collision_Counter)     *Increment Collision counter
    move.l (V_Balloon_Collision_Counter),d0     *Load collision counter into a register
    
    cmp #7,d0
    beq WinState
    cmp #6,d0                                   *Check if collision counter is equal to final ballon.
    beq SetLastBalloon                          
    
         
    
    lea COLOR_TABLE,a1
TraverseColorTable:                             *Set the correct color
    move.l (a1)+,d1
    subi.b #1,d0
    cmp #0,d0
    bgt TraverseColorTable
    move.l d1,(V_Balloon_Color)
    jsr ResetRockPosition
    jsr ResetGravityVariables
    jsr ResetSineCosineAngle
    rts
SetLastBalloon:
    move.l #1,(B_Last_Balloon)
    jsr ResetRockPosition
    jsr ResetGravityVariables
    jsr ResetSineCosineAngle
    rts
    
WallCollisionDetected:
    move.l #1,(B_CollisionOccured)
    move.l #0,(B_FireKeyPressed)                *Enable firing AND stop rock updates
    jsr ResetRockPosition 
    jsr ResetGravityVariables
    jsr ResetSineCosineAngle
    rts



ResetRockPosition:
    move.l #ROCK_SPAWN_LEFT_X,(V_Rock_Current_LXPOS)
    move.l #ROCK_SPAWN_RIGHT_X,(V_Rock_Current_RXPOS)
    move.l #ROCK_SPAWN_LOWER_Y,(V_Rock_Current_LYPOS)
    move.l #ROCK_SPAWN_UPPER_Y,(V_Rock_Current_UYPOS)
    rts

ResetGravityVariables:
    move.l #GRAVITY,(Gravity_Cumulative)
    move.l #0,(Gravity_Frame_Count)
    move.l #0,(B_Velocity_Reverse)
    rts

ResetSineCosineAngle:
                                                    *Set angle of shot to 30 degrees ( 1- 3)
    move.l #1,(AngleThetaOfShot)
                                                    *Cosine and Sine Cumulative
                                                    *Will be reset when the rock is removed.
    move.l #0,(Cosine_Cumulative)
    move.l #0,(Sine_Cumulative)
    
                                                    *Set initial firing line
    move.l #75,(V_FireLine_X_End_POS)
    move.l #400,(V_FireLine_Y_End_POS)
    rts

RandomColorLFSR:                                    *Repeat a total of 24 times to get 24 bits
    move.l (B_Last_Balloon),d1
    cmpi #0,d1
    beq DontUpdate
    clr.l d3                                        *will hold the new color
    clr.l d4                                        *Holds the counter
    move.l #24,d4
repeatLFSR:
    move.l (RandomSeedLFSR),d1                      *Place the internal state (24 bits)                           
    move.l d1,d2                                    *copy internal state to d2 
    lsr.l #1,d2                                     *left shift internal state (d2) by one
    eor d1,d2                                       *Exclusive OR d1 and d2.
                                                    *Last bit is of interest
    
    and.l #1,d2                                     *Get the last bit. d2's last bit is the only thing retained.
    
    lsl.l #1,d3                                     *shift d3 to the left
    eor d2,d3                                       *apply bit to register
 
    
    
    lsr.l #1,d1                                     *Shift our state by one to the right
    lsl.l #8,d2                                     *Shift bit 24 to the left and that way it's positioned correctly for OR
    lsl.l #8,d2
    lsl.l #8,d2
    or.l d2,d1                                      *Create our new state
    move.l d1,(RandomSeedLFSR)                      *move state to RandomSeedLFSR
    
    subi.l #1,d4
    bgt repeatLFSR
                                                    *d3 should hold our random number
    
    move.l d3,(V_Balloon_Color)
    clr.l d3
    clr.l d4
    clr.l d1
    clr.l d2
    rts
    
    
    
WinState:
    move.l #1,(B_Is_Win)
    rts


CalcWhichSevSeg:
    move.l (B_Screen_First_Print),d0
    cmpi.b #0,d0
    beq DontUpdate                                  *Dont update until the first image is on the screen
    
    move.l (B_Second_Passed),d0
    cmp #0,d0
    beq DontUpdate                                  *If a second has NOT passed then branch
    
    move.l (SevenSegCounter1),d0
    addi.l #1,d0
    move.l d0,(SevenSegCounter1)
    move.l (SevenSegCounter1),d0
    cmp #10,d0
    beq resetSevenSegCounter
    rts
resetSevenSegCounter:
    jsr UpdateTenthsCounter
    move.l #0,(SevenSegCounter1)
    rts       

UpdateTenthsCounter:
    move.l (SevenSegCounter2),d0
    addi.l #1,d0
    move.l d0,(SevenSegCounter2)
    cmp #10,d0
    beq GameOver
    rts
GameOver:
    move.l #1,(B_Is_Lose)
    rts

























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
