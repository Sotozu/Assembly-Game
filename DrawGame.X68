*--------------DRAW THE GAME--------------*
*1. Remove all dynamic objects on the screen (PREVIOUS STATES)
*2. Reapply backgound images to correct
*3. Draw all dynamic objects on the screen (UPDATED STATES)
DrawGame:
     
    jsr RemoveFireLine 
    jsr RemoveBalloon
    jsr RemoveRock
    jsr ClearSevSeg
    
    jsr DrawNextSprite      *only archer/slinger at this time
    
    jsr SetSevenSegment
    jsr DrawFireLine
    jsr DrawBalloon
    jsr DrawPrimitiveRock
    
    jsr DrawWinScreen       *only go through if condition is met in the function
    jsr DrawLoseScreen      *only go through if condition is met in the function
    jsr swapBuffers
    
    rts

*EXPLANATION: Will be called to NOT execute certain draw functions.
*-
*TOTAL REGISTERS USED:
*PARAMETERS: VOID
*RETURNS: VOID
DontDraw:
 rts

*EXPLANATION: Will draw all the sprites in the game that have been loaded with INCBIN
*-
*TOTAL REGISTERS USED: a1,a2,a3,d1,d2,d3,d4,d5,d6,d7 
*PARAMETERS: VOID
*RETURNS: VOID
DrawNextSprite:
                                            *Setup sprite data variables in registers for traversal
    lea ArrM_Sprite_Mem_Loc,a2
    lea ArrV_Sprite_Dimensions,a3 
    move.l #TOTAL_UNIQUE_SPRITES,d5         *d5 will be decremented untill all sprites are done being printed
    
BeginSpriteSetup:    
    jsr SetUpSpriteForPrint
*    move.l d1,-(sp)    
continueRow:
    move.l d7,-(sp)
    jsr getRGBValueAndPrintPixel            
    move.l (sp)+,d7
    
    addi.l #1,d6                            *Increment the inner iterator
    addi.l #1,d1                            *Increment the X print location
    cmp d3,d6                               *compare sprite pixel width count with the total sprite width pixel amount
    
    ble continueRow                         *Inner Loop
    
                                            *RESET POSITONS FOR X NEEDS TO BE UPDATED CORRECTLY. CURRENTLY NOT GOOD
    
    move.l #0,d6                            *Reset the inner iterator to 0
*    move.l (sp)+,d1
*    move.l d1,-(sp)
    move.l #50,d1                           *Reset the X print location (NEEDS TO BE A VARIABLE!!!!)
    
    addi.l #1,d7                            *Increment the outer loop iterator
    subi.l #1,d2                            *Decrement the Y print location (Prints are done in inverse fashion)
                 
    cmp d4,d7
    ble continueRow                         *Outer Loop
    
                                            *AT THIS POINT A SPRITE HAS BEEN COMPLETLY DRAWN
                                            *REPEAT UNTILL ALL SPRITES IN THE PROGRAM HAVE BEEN DRAWN
    subi.b #1,d5
    cmp #0,d5
    bne BeginSpriteSetup
    
    rts
     

*EXPLANATION: Will draw the fire line. This is what the player can use to estimate the angle of their shot.
*-
*TOTAL REGISTERS USED: d0,d1,d2,d3,d4,a1
*PARAMETERS: VOID
*RETURNS: VOID
DrawFireLine:
    move.l #RED,d1
    move.l #TRAP_SET_PEN_COLOR,d0
    trap #15
    
                                           
    move.l #TRAP_SET_PEN_WIDTH,d0           *Set fire line width
    move.l #FIRE_LINE_WIDTH,d1
    trap #15
    
    move.l #TRAP_DRAW_LINE,d0
    
    move.l #PFIRE_LINE_ORG_X,d1
    move.l #PFIRE_LINE_ORG_Y,d2
   
    move.l (V_FireLine_X_End_POS),d3
    move.l (V_FireLine_Y_End_POS),d4
    
    trap #15
    
                                            *SAVE THESE POSITIONS SO WE CAN REMOVE THE LINE LATER
    lea V_FireLine_Pre_Y_End_POS,a1
    move.l (V_FireLine_Y_End_POS),(a1)
    lea V_FireLine_Pre_X_End_POS,a1
    move.l (V_FireLine_X_End_POS),(a1)

    rts 


*EXPLANATION:Draws the projectile that is fired.
*-
*TOTAL REGISTERS USED: d0,d1,d2,d3,d4,a1
*PARAMETERS: VOID
*RETURNS: VOID    
DrawPrimitiveRock:
                                                      *set pen color
    move.l #TRAP_SET_PEN_COLOR,d0
    move.l #GREY,d1
    trap #15
    
                                                      *set fill color
    move.l #TRAP_SET_FILL_COLOR,d0
    move.l #GREY,d1
    trap #15
    
                                                      *Set Rock Dimensions and draw
    move.l #TRAP_DRAW_CIRCLE,d0
    
    move.l V_Rock_Current_LXPOS,d1                    *Left X
    move.l V_Rock_Current_UYPOS,d2                    *Upper Y
    
    move.l V_Rock_Current_RXPOS,d3                    *Right X
	move.l V_Rock_Current_LYPOS,d4                    *Lower Y
	
	trap #15
	
	                                                  *SAVE THE POSITIONS WE CAN REMOVE THE ROCK LATER
	move.l (V_Rock_Current_UYPOS),(V_Rock_Prev_UYPOS) *Upper Y
	move.l (V_Rock_Current_LYPOS),(V_Rock_Prev_LYPOS) *Lower Y
	
	move.l (V_Rock_Current_LXPOS),(V_Rock_Prev_LXPOS) *Left X
	move.l (V_Rock_Current_RXPOS),(V_Rock_Prev_RXPOS) *Right X
	
    rts
    
*EXPLANATION:Draws the balloon.
*-
*TOTAL REGISTERS USED: d0,d1,d2,d3,d4,a1
*PARAMETERS: VOID
*RETURNS: VOID
DrawBalloon:
                                        
    move.l #TRAP_SET_PEN_COLOR,d0                           *set pen color
    move.l #WHITE,d1
    trap #15                             
    move.l #TRAP_SET_FILL_COLOR,d0                          *set fill color
    move.l (V_Balloon_Color),d1
    trap #15
                                        
    move.l #TRAP_DRAW_CIRCLE,d0                             *Set Balloon Dimensions and draw
    move.l V_Balloon_Current_LXPOS,d1                       *Left X
    move.l V_Balloon_Current_UYPOS,d2                       *Upper Y
    move.l V_Balloon_Current_RXPOS,d3                       *Right X
	move.l V_Balloon_Current_LYPOS,d4                       *Lower Y
	trap #15
	
	                                                        *SAVE THE POSITIONS WE CAN REMOVE THE BALLOON LATER
	move.l (V_Balloon_Current_UYPOS),(V_Balloon_Prev_UYPOS) *Upper Y
	move.l (V_Balloon_Current_LYPOS),(V_Balloon_Prev_LYPOS) *Lower Y
    rts

        
**********************DELETE DYNAMIC OBJECTS**************************    

*EXPLANATION:Uses previously saved positions to delete the line. The reason we save the position is because it gets updated every loop.
*-
*TOTAL REGISTERS USED: d0,d1,d2,d3,d4
*PARAMETERS: VOID
*RETURNS: VOID
RemoveFireLine:
    move.l #BLACK,d1                        *Set fire line color to black because we are going to "remove it". Effectively coloring it the same as the background
    move.l #TRAP_SET_PEN_COLOR,d0
    trap #15
    
                                            *Set fire line width
    move.l #TRAP_SET_PEN_WIDTH,d0
    move.l #FIRE_LINE_WIDTH,d1
    trap #15
    
    move.l #TRAP_DRAW_LINE,d0
    
    move.l #PFIRE_LINE_ORG_X,d1
    move.l #PFIRE_LINE_ORG_Y,d2
   
    move.l (V_FireLine_Pre_X_End_POS),d3    *Previous positions
    move.l (V_FireLine_Pre_Y_End_POS),d4
    
    trap #15
    
    rts

*EXPLANATION:Uses previously saved positions to delete the rock.
*-
*TOTAL REGISTERS USED: d0,d1,d2,d3,d4
*PARAMETERS: VOID
*RETURNS: VOID    
RemoveRock:
                                            *set pen color to black to "delete from the screen"
    move.l #TRAP_SET_PEN_COLOR,d0
    move.l #BLACK,d1
    trap #15
    
                                            *set fill color to black to "delete from the screen"
    move.l #TRAP_SET_FILL_COLOR,d0
    move.l #BLACK,d1
    trap #15
    
                                            *Set Rock Dimensions and draw
    move.l #TRAP_DRAW_CIRCLE,d0
    
    move.l V_Rock_Prev_LXPOS,d1             *Left X (x never change)
    move.l V_Rock_Prev_UYPOS,d2             *Upper Y
    
    move.l V_Rock_Prev_RXPOS,d3             *Right X (x never change)
	move.l V_Rock_Prev_LYPOS,d4             *Lower Y 
	
	trap #15
	
    rts

*EXPLANATION:Uses previously saved positions to delete the balloon.
*-
*TOTAL REGISTERS USED: d0,d1,d2,d3,d4
*PARAMETERS: VOID
*RETURNS: VOID      
RemoveBalloon:
                                            *set pen color
    move.l #TRAP_SET_PEN_COLOR,d0
    move.l #BLACK,d1
    trap #15
    
                                            *set fill color
    move.l #TRAP_SET_FILL_COLOR,d0
    move.l #BLACK,d1
    trap #15
    
                                            *Set Balloon Dimensions and draw
    move.l #TRAP_DRAW_CIRCLE,d0
    
    move.l V_Balloon_Current_LXPOS,d1       *Left X (x never change)
    move.l V_Balloon_Prev_UYPOS,d2          *Upper Y
    
    move.l V_Balloon_Current_RXPOS,d3       *Right X (x never change)
	move.l V_Balloon_Prev_LYPOS,d4          *Lower Y 
	
	trap #15
	
    rts




swapBuffers
    move.l #1,(B_Screen_First_Print)        *Used in printing out the Seven Segment timer. That way it dosent update until the first image is on the screen.
	move.b  #TRAP_REPAINT_SCREEN,d0
    trap    #15
	rts




*TOTAL REGISTERS USED: d0,d1,d2,d3,d4,d5,d6
*PARAMETERS: VOID
*RETURNS: VOID 
DrawWinScreen:
    move.l (B_Is_Win),d0
    cmp #0,d0
    beq DontUpdate
    
     move.l #272,d1                         *Setting the X print coordinate to pixel 272
     move.l #270,d2                         *Y print coordinate to pixel 270
     
     move.l V_Win_ImageW,d3                 *Inner loop max (x)
     move.l V_Win_ImageH,d4                 *Outer loop max (y)
     
     move.l #0,d5                           *Inner loop iterator (x)
     move.l #0,d6                           *Outer loop iterator (y)
     
     move.l (M_Win_DataSLocation),d7        *load the data start location into a1
     move.l d7,a1

   
continueWinRow:
    
    jsr getRGBValueAndPrintPixel
    
    addi.l #1,d5                            *add 1 to the inner loop iterator
    addi.l #1,d1                            *increment print location
    cmp d3,d5                               *compare the inner loop max with the iterator
    
    ble continueWinRow                      *while the inner loop iterator is less than the max repeat\
    
    subi.l #1,d2                            *move the print location one up
    move.l #260,d1                          *reset the print location
    move.l #0,d5                            *reset inner loop iterator (x)
    addi.l #1,d6                            *increment the outer loop iterator (y)
    
    cmp d4,d6  
    ble continueWinRow                      *Outer Loop


    rts
    
*TOTAL REGISTERS USED: d0,d1,d2,d3,d4,d5,d6
*PARAMETERS: VOID
*RETURNS: VOID    
DrawLoseScreen:
    move.l (B_Is_Lose),d0
    cmp #0,d0
    beq DontUpdate
    
    
     move.l #220,d1                         *Setting the X print coordinate to pixel 272
     move.l #250,d2                         *Y print coordinate to pixel 270
     
     move.l V_Lose_ImageW,d3                *Inner loop max (x)
     move.l V_Lose_ImageH,d4                *Outer loop max (y)
     
     move.l #0,d5                           *Inner loop iterator (x)
     move.l #0,d6                           *Outer loop iterator (y)
     
     move.l (M_Lose_DataSLocation),d7       *load the data start location into a1
     move.l d7,a1

   
continueLoseRow:
    
    jsr getRGBValueAndPrintPixel
    
    addi.l #1,d5                            *add 1 to the inner loop iterator
    addi.l #1,d1                            *increment print location
    cmp d3,d5                               *compare the inner loop max with the iterator
    
    ble continueLoseRow                     *while the inner loop iterator is less than the max repeat\
    
    subi.l #1,d2                            *move the print location one up
    move.l #220,d1                          *reset the print location
    move.l #0,d5                            *reset inner loop iterator (x)
    addi.l #1,d6                            *increment the outer loop iterator (y)
    
    cmp d4,d6  
    ble continueLoseRow                     *Outer Loop

    rts

*-------------------------SET AND DRAW FIRST PLACE SEVEN SEGMENT-------------------------*
SetSevenSegment:
    move.l (B_Is_Lose),d0
    cmp #1,d0
    beq DontUpdate                          *If you lose DONT update the timer
    
    move.l (B_Second_Passed),d0
    cmpi.b #0,d0
    beq DontUpdate                          *If a second has NOT passed then branch
    
    jsr FirstDigitSevenSeg
    jsr TenthsDigitSevenSeg
    
    rts
    
FirstDigitSevenSeg:
   
    clr.l d6 
    move.l #0,d6                            *d6 will be our counter
    
    lea SEVEN_SEGMENT_BITMASK_TABLE,a1
                        
                                            *SevenSegCounter is the offset used to traverse the mask table
    move.l (SevenSegCounter1),d0
   
FirstTraverseSevenSegTable:                
    move.b (a1)+,d7 *mask is set
    subi.l #1,d0
    cmp #0,d0
    bge FirstTraverseSevenSegTable
    
    
FirstSevenSegLoop:
    move.b d7,d1 *saved
    and.b #1,d1 Check each bit
    beq FirstSkipDrawSegment
    jsr FirstDrawSegment
    
FirstSkipDrawSegment:
    lsr.b #1,d7
    addi.l #1,d6
    cmp.l #7,d6
    blt FirstSevenSegLoop
    rts
    
FirstDrawSegment:
    lea SEVEN_SEG_PRINT_COORDINATES,a1
    move.l d6,d1
    mulu #8,d1
    add.l d1,a1
    
    move.l #RED,d1
    move.l #TRAP_SET_PEN_COLOR,d0
    trap #15
    
    move.b #TRAP_SET_PEN_WIDTH,d0
    move.l #3,d1
    trap #15
    
    move.w (a1)+,d1 *x1
    move.w (a1)+,d2 *x2
    move.w (a1)+,d3 *y1
    move.w (a1)+,d4 *y2
    
    move.l #TRAP_DRAW_LINE,d0
    trap #15
    
    rts
*-----------------------------SET AND DRAW TENTHS PLACE SEVEN SEGMENT*-----------------------------*
TenthsDigitSevenSeg:
    clr.l d6 
    move.l #0,d6                        *d6 will be our counter
    
    lea SEVEN_SEGMENT_BITMASK_TABLE,a1
                        
                                        *SevenSegCounter is the offset used to traverse the mask table
    move.l (SevenSegCounter2),d0
   
TenthsTraverseSevenSegTable:                
    move.b (a1)+,d7 *mask is set
    subi.l #1,d0
    cmp #0,d0
    bge TenthsTraverseSevenSegTable
    
    
TenthsSevenSegLoop:
    move.b d7,d1 *saved
    and.b #1,d1 *Check each bit
    beq TenthsSkipDrawSegment
    jsr TenthsDrawSegment
    
TenthsSkipDrawSegment:
    lsr.b #1,d7
    addi.l #1,d6
    cmp.l #7,d6
    blt TenthsSevenSegLoop
    rts
    
TenthsDrawSegment:
    lea SEVEN_SEG_PRINT_COORDINATES2,a1
    move.l d6,d1
    mulu #8,d1
    add.l d1,a1
    
    move.l #RED,d1
    move.l #TRAP_SET_PEN_COLOR,d0
    trap #15
    
    move.b #TRAP_SET_PEN_WIDTH,d0
    move.l #3,d1
    trap #15
    
    move.w (a1)+,d1 *x1
    move.w (a1)+,d2 *x2
    move.w (a1)+,d3 *y1
    move.w (a1)+,d4 *y2
    
    move.l #TRAP_DRAW_LINE,d0
    trap #15
    
    rts

*-------------------------CLEAR SEVEN SEGMENT-------------------------*
ClearSevSeg:

    move.l (B_Second_Passed),d0
    cmp #0,d0
    beq DontUpdate                              *If a second has NOT passed then branch
   
    jsr GetCropMemoryLocation
    move.l FID,d1
    move.l #TRAP_SET_READ_POSITION,d0
    move.l ByteOffsetToBeginReadingCropData,d2
    trap #15
    

    
                                                *d1 and d2 will be set to print positions for pixel printing task
    move.l CropPrintXCoordinate,d1   
    move.l CropPrintYCoordinate,d2
    
    move.l (CropWidth),d6 
    add.l (CropPrintXCoordinate),d6             *d6 - Number of time the inner loop will iterate (inner loop counter)
    move.l (CropHeight),d5                      *d5 - Number of times the outer loop will iterate (outer loop counter)

ContinueCropRow:

    jsr FileRGBValueAndPrintPixel


    addi.l #1,d1
    cmp d6,d1
    bne ContinueCropRow                         *Inner Loop
    
    
    move.l d5,-(sp)                             *save the outerloop counter
    move.l d2,-(sp)                             *Save the y-positioin
    

    jsr GetCropReadOffset                       *skip bytes to get to next readposition (uses registers d5 and d2)
    
    move.l CropPrintXCoordinate,d1              *reset the x-coordinate
    
    move.l (sp)+,d2                             *save the y-positioin
    move.l (sp)+,d5                             *save the outerloop counter

    
    subi.l #1,d2
    
    subi.l #1,d5
    
    bgt ContinueCropRow                         *Outer Loop

    rts
GetCropMemoryLocation:
                                                *calc the number of rows of pixels to skip to get to the crop y-coordinate
    move.l (V_Background1_ImageH),d2
    sub.l (CropStartYCoordinate),d2
    sub.l (CropHeight),d2
    
                                                *d5 holds rows to skip

    move.l d2,d7                                *save d2 value
    
    jsr calcPadding                             *uses register d5
    
    move.l d7,d2                                *restore d2 value
    
    move.l (V_Background1_ImageW),d1
    jsr MULTIPLY_FUNCTION                       *d2 results with the number of pixels needed to be skipped from the total rows
                          
    move.l (CropStartXCoordinate),d1
    add.l d1,d2                                 *Adds the pixels that need to be traversed in the final row to reach the crop data
    
    move.l Bitdepth,d1
    jsr MULTIPLY_FUNCTION                       *d5 results with the number of bytes needed to be skipped to reach the crop data from the START of the image data
    
    move.l #BACKGROUND_DATA_BYTE_OFFSET,d1    
    add.l d1,d2                                 *We add the bytes in the header which will account for those bytes needed to get to the START of the image data.
    
    add.l (TotalIntialBytePaddingOffset),d2     *Padding needs to be added for the rows that were skipped to get to the first byte of crop data
                                            
                                                *d5 now has the total number of bytes FROM THE START OF THE FILE (including any padding) to get to the beginning of the crop data
                                            
    move.l d2,(ByteOffsetToBeginReadingCropData)
    move.l d2,(CropReadOffsetCounter)
    
  
                                                *Calculates the number of bytes needed to skip to get to the next row of crop data (adds necessary padding)
                                                *Store that result in varible ByteToSkipForNextRead
    move.l (V_Background1_ImageW),d2
    move.l Bitdepth,d1
    jsr MULTIPLY_FUNCTION
    add.l (BytePaddingOffset),d2
    move.l d2,(BytesToSkipForNextRead)
    
    rts
    
GetCropReadOffset:
                                                *set neaxt read position for the file
    move.l (CropReadOffsetCounter),d4
    move.l (BytesToSkipForNextRead),d5
    add.l d5,d4
    
    move.l d4,(CropReadOffsetCounter)           *Cumulative read offset
    
    move.l FID,d1
    move.l #TRAP_SET_READ_POSITION,d0
    move.l CropReadOffsetCounter,d2
    trap #15

    rts
    
CalcPadding:
    move.l (V_Background1_ImageW),d1
    divu #4,d1
    lsr.l #8,d1
    lsr.l #8,d1
    move.l d1,(BytePaddingOffset)
    
    
    jsr MULTIPLY_FUNCTION
 
    move.l d2,(TotalIntialBytePaddingOffset)
    rts


*EXPLANATION: Each sprites data memory location is stored in and array called ArrM_Sprite_Mem_Loc. 
* Each sprites dimensions are stored in and array called ArrV_Sprite_Dimensions.
* We traverse these in a linear fashion and get the data required for printing. 
*- 
*TOTAL REGISTERS USED: a1,a2,a3,d1,d2,d3,d4,d6,d7
*PARAMETERS: a2,a3 -> (MEMORY: Arrray of sprite memory locations, Array of sprite dimension values)
*RETURNS: d1,d2 -> (VALUES: X and Y print cooridnates of sprite respectively)
*RETURNS: d3,d4 -> (VALUES: WIDTH and HEIGHT of the specific sprite respectively)
*RETURNS: d6,d7 -> (VALUES: Inner Loop Iterator and Outer Loop iterator respectively)
SetUpSpriteForPrint:

                            *Places the begning memory address of the pixel values for the sprite in a1.
    move.l (a2)+,a1 
    
                            *Data stored in a3 is in WIDTH,HEIGHT (x,y). 
    move.l (a3)+,d3         *d3 gets the WIDTH
    move.l (a3)+,d4         *d4 gets the HEIGHT
    
                            *set the new X and Y Print coordinates for printing the sprite
    movem.l d3-d4,-(sp)
    jsr DetermineSpriteToPrint
    movem.l (sp)+,d3-d4
    
    move.l #0,d6            *Setup inner Loop iterator
    move.l #0,d7            *Setup outer Loop iterator
    
    rts

*EXPLANATION: Determines which sprite is to be drawn.
* Then branches to another routine that sets that specific print coordinates of that sprite
*-
*TOTAL REGISTERS USED: a1,d2,d4
*PARAMETERS: a1 (Begninig memory address of a specific sprite)
*RETURNS: VOID
DetermineSpriteToPrint:
     
    move.l a1,d3
    move.l (M_Archer_DataSLocation),d4
    cmp.l d3,d4
    beq IsArcherPrinting
    
*At this time Archer is the only sprite in the memory array. 
*If we added other sprites then we would have other checks here that would branch.
*Those other checks would branch to set their respect sprites print coordinates.
  

*EXPLANATION: Set print coordinates of specifc sprite
*-
*TOTAL REGISTERS USED:: d1,d2
*PARAMETERS: d1,d2 -> (X and Y print locations of sprite before calculated offsets)
*RETURNS: d1,d2 -> (New X and Y print locations of sprite)
IsArcherPrinting:
    move.l #430,d2 *Set Y print location (Currently hard coded but could be made variable to move)
    move.l #50,d1 *Set X print location (Currently hard coded but could be made variable to move)
    rts


*EXPLANATION: Uses INCBIN sprites for quick access of small images pixel data.
*-
*TOTAL REGISTERS USED: d0,d1,d2,d7
*PARAMETERS: a1 -> (Sprite pixel data start location)
*RETURNS: VOID
getRGBValueAndPrintPixel:
    movem.l d1-d2,-(sp) *save values

    move.l (a1)+,d1
    ror.l #8,d1 
    
    move.l #WHITE,d7
    cmp d7,d1
    beq SkipPixelPrint
    
    move.l #TRAP_SET_PEN_COLOR,d0
    trap #15
    
    movem.l (sp)+,d1-d2 *bring back values
    move.l #TRAP_DRAW_PIXEL,d0
    trap #15
 
    rts


*EXPLANATION: Since I used File I/O in my Bitmap assignment I use this method of getting pixel data and cropping.
*Used to draw large static images without taking memory space. Specifically used for the background in this assignment.
*-
*TOTAL REGISTERS USED: d0,d1,d2,d7
*PARAMETERS: a1,d1,d2 -> (Sprite pixel data location, X print location and Y print location of the output window)
*RETURNS: VOID
FileRGBValueAndPrintPixel:

    movem.l d1-d2,-(sp)             *save values
    lea HexColor,a1                 *address where image color data will be read into

    move.l Bitdepth,d2              *number of bytes to read (depends if 24 or 32 bit. 3 and 4 respectively)
    
    move.l FID,d1
    
    move.l #TRAP_READ_FILE,d0
    trap #15

    move.l (a1),d3                  *BBGGRR color is transfered to d3 
    lsr.l #8,d3                     *shifting is required for 24bitdepth images
    move.l d3,d1                    *Place the corrected color information into d1 for a task that is to be called
    
    move.l #WHITE,d7
    cmp d7,d1
    beq SkipPixelPrint              *Skip if white pixel
    
    
    move.l #TRAP_SET_PEN_COLOR,d0   *Print pixel at X and Y coordinate (d1,d2)
    trap #15
    movem.l (sp)+,d1-d2
    move.l #TRAP_DRAW_PIXEL,d0
    trap #15 
    
    rts

*EXPLANATION: Game is designed to skip white pixels. This just returns d1 and d2 to be incremented without printing.
*-
*TOTAL REGISTERS USED: d1,d2
*PARAMETERS: VOID
*RETURNS: d1,d2  
SkipPixelPrint:
    movem.l (sp)+,d1-d2
    rts 

















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
