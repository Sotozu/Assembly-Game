*--------------GetInput--------------*
*Clears registers
*Gets keys pressed
*Sets bolians to be passed to update functions
GetInput:
    
    jsr clearRegisters
    jsr GetKeyPresses
    rts

*REQUIRES: d0-d7 and a0-a6
*RETURNS: VOID
clearRegisters:
    clr.l d0
    clr.l d1
    clr.l d2
    clr.l d3
    clr.l d4
    clr.l d5
    clr.l d6
    clr.l d7
    move.l #0,a1
    move.l #0,a2
    move.l #0,a3
    move.l #0,a4
    move.l #0,a5
    move.l #0,a6
    
    rts
  
GetKeyPresses:
                                    *A will be arcing the bow up and to the left
                                    *B will be arcing the bow down and to the right
                                    *F is to fire the arrow
    cmp #1,(B_FireKeyPressed)
    beq NoKeyboardInput             *If the sling has been fired then don't take in inputs    
    move.b #TRAP_GET_PRESSED_KEY,D0 
    move.l #('A'<<16+'D'<<8+'F'),D1 *check for keypress (a,d) A is 00FF0000, D is 0000FF00 and F is 000000FF
    trap  #15
    move.l d1,d2
    andi.l #$00FF0000,d2
    bne UpKeyPressed
    
    move.l d1,d2
    andi.l #$0000FF00,d2
    bne DownKeyPressed
    
    move.l d1,d2
    andi.l #$000000FF,d2
    bne FireKeyPressed
    move.l d1,d2
    
    rts

*This INCREASES the angle of the shot, clamps at 2
UpKeyPressed:
   move.l (AngleThetaOfShot),d0
   cmpi.l #2,d0
   beq ClampKeyPress
   addi.l #1,d0
   move.l d0,(AngleThetaOfShot)
   rts
    
*This DECREASES the angle of the shot, clamps at 0
DownKeyPressed:
    move.l (AngleThetaOfShot),d0
    cmpi.l #0,d0
    beq ClampKeyPress
    subi.l #1,d0
    move.l d0,(AngleThetaOfShot)
    *display x
    
    rts
*This will increase to a max of 100 if the key is held down
FireKeyPressed:
    move.l (B_FireKeyPressed),d0
    cmp #1,d0
    beq NoKeyboardInput
    
    move.l #TRAP_PLAY_WAV_SOUND,d0 *PLAY SOUND
    lea String_Throw_Sound,a1
    trap #15
    
    move.l #1,(B_FireKeyPressed)   *Set to true
    rts

NoKeyboardInput:
    rts
    
ClampKeyPress
    rts
















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
