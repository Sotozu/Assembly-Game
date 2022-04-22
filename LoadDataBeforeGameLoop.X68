*--------------DRAW THE GAME--------------*
*Initializes all values required for the game to run.
LoadDataBeforeGameLoop:

    jsr InitVarAndProcess
    jsr SetScreenResolution
    jsr LoadSpriteData
    jsr LoadConditionScreenFileData
    
    jsr LoadBackgroundPrint
    jsr LoadCropData
    jsr InitializeBallon
    jsr InitializeRock
    
    rts
    
SetScreenResolution:
    move.b #TRAP_SET_OUTPUT_RESOLUTION,d0
    move.l #(SCREEN_WIDTH<<16 + SCREEN_HEIGHT),d1
    trap #15
    rts

LoadConditionScreenFileData:

*---------------------WIN SCREEN---------------------*

*Get image width (in pixels) into d3
    move.l WIN_PWIDTH_MEM_LOC,d1
    jsr BigEndianToLittleEndian
    subi.l #1,d1
    move.l d1,d3
    move.l d1,(V_Win_ImageW)
    
    *Get image height (in pixels) into d4        
    move.l WIN_PHEIGHT_MEM_LOC,d1
    jsr BigEndianToLittleEndian
    subi.l #1,d1
    move.l d1,d4
    move.l d1,(V_Win_ImageH) 
    
    *Get bitdepth
    move.l WIN_BITDEPTH_MEM_LOC,d1
    jsr BigEndianToLittleEndian
    divu #8,d1
    move.l d1,(V_Win_ImageBD)
    
    *Get image color data start location
    lea WIN_COLOR_DATA_MEM_LOC,a1
    move.l a1,(M_Win_DataSLocation)
    
**---------------------LOSE SCREEN---------------------*
*Get image width (in pixels) into d3
    move.l LOSE_PWIDTH_MEM_LOC,d1
    jsr BigEndianToLittleEndian
    subi.l #1,d1
    move.l d1,d3
    move.l d1,(V_Lose_ImageW)
    
    *Get image height (in pixels) into d4        
    move.l LOSE_PHEIGHT_MEM_LOC,d1
    jsr BigEndianToLittleEndian
    subi.l #1,d1
    move.l d1,d4
    move.l d1,(V_Lose_ImageH) 
    
    *Get bitdepth
    move.l LOSE_BITDEPTH_MEM_LOC,d1
    jsr BigEndianToLittleEndian
    divu #8,d1
    move.l d1,(V_Lose_ImageBD)
    
    *Get image color data start location
    lea LOSE_COLOR_DATA_MEM_LOC,a1
    move.l a1,(M_Lose_DataSLocation)
      
    rts

*EXPLANATION: Sets up arrays that will be used to house the memory locations and dimensions of each unique sprite.
* Items here should be loaded in the print order they will be required to print. 
*-
*TOTAL REGISTERS USED: a1,a2,a3,d1,d3,d4,d5,d6,d7 
*PARAMETERS: VOID
*RETURNS: VOID    
LoadSpriteData:*

    lea ArrM_Sprite_Mem_Loc,a2
    lea ArrV_Sprite_Dimensions,a3
*---------------------ARCHER---------------------*
    
    *Get image width (in pixels) into d3
    move.l ARCHER_PWIDTH_MEM_LOC,d1
    jsr BigEndianToLittleEndian
    subi.l #1,d1
    move.l d1,d3
    move.l d1,(V_Archer_ImageW)
    *add to WIDTH the sprite dimensions array
    move.l d1,(a3)+ 
    
    *Get image height (in pixels) into d4        
    move.l ARCHER_PHEIGHT_MEM_LOC,d1
    jsr BigEndianToLittleEndian
    subi.l #1,d1
    move.l d1,d4
    move.l d1,(V_Archer_ImageH)
    *add to HEIGHT the sprite dimensions array
    move.l d1,(a3)+ 
    
    *Get bitdepth
    move.l ARCHER_BITDEPTH_MEM_LOC,d1
    jsr BigEndianToLittleEndian
    divu #8,d1
    move.l d1,(V_Archer_ImageBD)
    
    *Get image color data start location
    lea ARCHER_COLOR_DATA_MEM_LOC,a1
    move.l a1,(M_Archer_DataSLocation)
    
    *add to the sprite mem array.
    move.l a1,(a2)+
      
    rts

*EXPLANATION: Loads in balloon values 
*-
*TOTAL REGISTERS USED: a1 
*PARAMETERS: VOID
*RETURNS: VOID  
InitializeBallon:

    move.b #0,(B_Balloon_Reached_MY) *Start the game by setting the balloon to move up 
    move.b #1,(B_Balloon_Reached_LY) *Start the game by telling the balloon to not move down
    
    *initialize velocity       
    move.l	#BALLOON_INIT_VELOCITY,(V_Balloon_Velocity)
    
    *initialize LEFT-X and UPPER-Y spawn position of balloon
    lea V_Balloon_Current_LXPOS,a1
	move.l	#BALLOON_SPAWN_LEFT_X,(a1)
	lea V_Balloon_Current_UYPOS,a1
    move.l  #BALLOON_SPAWN_UPPER_Y,(a1)

    *initialize RIGHT-X and LOWER-Y spawn position of balloon
    lea V_Balloon_Current_RXPOS,a1
	move.l	#BALLOON_SPAWN_RIGHT_X,(a1)
	lea V_Balloon_Current_LYPOS,a1
    move.l  #BALLOON_SPAWN_LOWER_Y,(a1)
    
    *initialize color
    move.l (COLOR_TABLE),(V_Balloon_Color)
    
    *Set last ballon to false at the start of the program
    move.l #0,(B_Last_Balloon)
    
    
        

    rts

*EXPLANATION: Loads in rock values 
*-
*TOTAL REGISTERS USED: a1 
*PARAMETERS: VOID
*RETURNS: VOID
InitializeRock:
    
    *initialize LEFT-X and UPPER-Y spawn position of balloon
    lea V_Rock_Current_LXPOS,a1
	move.l	#ROCK_SPAWN_LEFT_X,(a1)
	lea V_Rock_Current_UYPOS,a1
    move.l  #ROCK_SPAWN_UPPER_Y,(a1)

    *initialize RIGHT-X and LOWER-Y spawn position of balloon
    lea V_Rock_Current_RXPOS,a1
	move.l	#ROCK_SPAWN_RIGHT_X,(a1)
	lea V_Rock_Current_LYPOS,a1
    move.l  #ROCK_SPAWN_LOWER_Y,(a1)
    
    *initialize velocity     
    move.l #ROCK_INIT_VELOCITY,(V_Rock_X_Velocity)
    move.l #ROCK_INIT_VELOCITY,(V_Rock_Y_Velocity)

        

    rts

*EXPLANATION: Loads in rock values 
*-
*TOTAL REGISTERS USED: d0,d1 
*PARAMETERS: VOID
*RETURNS: VOID
InitVarAndProcess:
    *Set Time Variables
    move.l #0,(PreviousTime)
    move.l #0,(SecondCounter)
    *Set angle of shot to 30 degrees ( 1- 3)
    move.l #1,(AngleThetaOfShot)
    *Set is firing to false on start
    move.l #0,(B_FireKeyPressed)
    
    *Cosine and Sine Cumulative
    *Will be reset when the rock is removed.
    move.l #0,(Cosine_Cumulative)
    move.l #0,(Sine_Cumulative)
    
    *Init Gravity
    move.l #GRAVITY,(Gravity_Cumulative)
    move.l #0,(Gravity_Frame_Count)
    move.l #0,(B_Velocity_Reverse)
    
    *Collision False
    move.l #0,(B_CollisionOccured)
    move.l #1,(V_Balloon_Collision_Counter)
    
    *set double buffered mode              
    move.b	#TRAP_DRAWING_MODE,d0          
    move.b	#TRAP_DBUFFER_MODE,d1
    trap	#15
    
*Set initial firingline to to point to x =75, y =400
    move.l #75,(V_FireLine_X_End_POS)
    move.l #400,(V_FireLine_Y_End_POS)
    
*Get seed for random number generator
    move.l #TRAP_GET_TIME,d0
    trap #15
    
    and.l #%00000000111111111111111111111111,d1 *We only want to have 24 bits so we must clear the upper 8bits
                                                *Reason being that we want this number for colors and don't use the Alpha
    move.l d1,(RandomSeedLFSR) 
    
    clr.l d0
    clr.l d1
    
*Set Seven Segment Counter to 0    
    move.l #4,(SevenSegCounter1) *inner (FIRST PLACE)
    move.l #7,(SevenSegCounter2) *outer (TENTHS PLACE)         

*Initialize to false and then true when first image is loaded
    move.l #0,(B_Screen_First_Print)

*Set win and lose state to false
    move.l #0,(B_Is_Win)
    move.l #0,(B_Is_Lose)
    
    rts

*---------------------BACKGROUND RELATED FILE I/O---------------------*
*EXPLANATION: Loads in background using File I/O processess 
*-
*TOTAL REGISTERS USED: d0,d1 
*PARAMETERS: VOID
*RETURNS: VOID

LoadBackgroundPrint:
    jsr OpenBackgroundFile
    jsr GatherBackgroundData
    jsr PrintBackgroundImage
    
    rts

OpenBackgroundFile:
    *Best practice to close all files first (in accordance to EASy68k file operations help section)
    move.l #TRAP_CLOSE_ALL_FILES,d0
    trap #15

    lea String_FileName,a1
    move.l #TRAP_OPEN_EXISTING_FILE,d0
    trap #15
    
    rts
GatherBackgroundData:
    jsr GetFIDGetBitdepth
    jsr GetHeightandWidth   

    rts
    
GetFIDGetBitdepth:

    *get file id
    lea FID,a1
    move.l d1,(a1)
    
    *get bitdepth
    move.l #TRAP_SET_READ_POSITION,d0
    move.l #BACKGROUND_BITDEPTH_BYTE_READ,d2
    trap #15

    lea Bitdepth,a1
    move.b #2,d2
    move.l #TRAP_READ_FILE ,d0
    trap #15
    
    *transform bitdepth data to format we can use
    move.l (a1),d1
    jsr BigEndianToLittleEndian
    and.l #%0000000011111111,d1    
    move.l #3,(a1)    *Default bitdepth is 24 so set 3 BUT...
    
    cmp #32,d1 
    
    beq Set32BitDepth *Check if the bitdepth is 32. Branch and set to 4

    rts               *Otherwise it stays 24 and return

Set32BitDepth:
    move.l #4,(a1)
    rts

GetHeightandWidth:

    *height
    move.l FID,d1

    move.l #TRAP_SET_READ_POSITION,d0
    move.l #BACKGROUND_HEIGHT_BYTE_OFFSET,d2
    trap #15

    lea V_Background1_ImageH,a1
    move.b #4,d2
    move.l #TRAP_READ_FILE ,d0
    trap #15

    move.l (a1),d1
    jsr BigEndianToLittleEndian
    move.l d1,(a1)
    
    *Width
    move.l FID,d1

    move.l #TRAP_SET_READ_POSITION,d0
    move.l #BACKGROUND_WIDTH_BYTE_OFFSET,d2
    trap #15

    lea V_Background1_ImageW,a1
    move.b #4,d2
    move.l #TRAP_READ_FILE ,d0
    trap #15

    move.l (a1),d1
    jsr BigEndianToLittleEndian
    move.l d1,(a1)
    
    rts 
    
PrintBackgroundImage:
    jsr SetBackgroundStartCoordinates
    jsr SetBackgroundDimensions
    jsr SetBackgroundPrintCoordinates
    jsr BeginBackgroundPrint
    rts

SetBackgroundStartCoordinates:  
    move.l #0,(CropStartXCoordinate)
    move.l #0,(CropStartYCoordinate)
    
    rts
    
SetBackgroundDimensions: 

    move.l (V_Background1_ImageW),d0
    move.l (V_Background1_ImageH),d1
    move.l d0,(CropWidth)
    move.l d1,(CropHeight)
    
    rts


SetBackgroundPrintCoordinates:
    move.l #0,(CropPrintXCoordinate)
    move.l #0,d1
    add.l (CropHeight),d1
    move.l d1,(CropPrintYCoordinate)
    
    rts
    
BeginBackgroundPrint:
    move.l #TRAP_CLEAR_SCREEN,d0
    move.l #$FF00,d1
    trap #15
    
    
    jsr GetBackgroundMemoryLocation
    
    move.l FID,d1
    move.l #TRAP_SET_READ_POSITION,d0
    move.l ByteOffsetToBeginReadingCropData,d2
    trap #15
    

    
    *d1 and d2 will be set to print positions for pixel printing task
    move.l CropPrintXCoordinate,d1   
    move.l CropPrintYCoordinate,d2
    
    move.l (CropWidth),d6 
    add.l (CropPrintXCoordinate),d6 *d6 - Number of time the inner loop will iterate (inner loop counter)
    move.l (CropHeight),d5          *d5 - Number of times the outer loop will iterate (outer loop counter)

ContinueBackgroundRow:

    jsr FileRGBValueAndPrintPixel


    addi.l #1,d1
    cmp d6,d1
    bne ContinueBackgroundRow *Inner Loop
    
    
    move.l d5,-(sp)                       *save the outerloop counter
    move.l d2,-(sp)                       *Save the y-positioin
    

    jsr GetBackgroundReadOffset           *skip bytes to get to next readposition (uses registers d5 and d2)
    
    move.l CropPrintXCoordinate,d1        *reset the x-coordinate
    
    move.l (sp)+,d2                       *Save the y-positioin
    move.l (sp)+,d5                       *save the outerloop counter

    
    subi.l #1,d2
    
    subi.l #1,d5
    
    bgt ContinueBackgroundRow *Outer Loop

    rts
GetBackgroundMemoryLocation:

    *calc the number of rows of pixels to skip to get to the crop y-coordinate
    move.l (V_Background1_ImageH),d2
    sub.l (CropStartYCoordinate),d2
    sub.l (CropHeight),d2
    
    *d5 holds rows to skip

    move.l d2,d7                            *save d2 value
    
    jsr calcBackgroundPadding               
    
    move.l d7,d2                            *restore d2 value
    
    move.l (V_Background1_ImageW),d1
    jsr MULTIPLY_FUNCTION                   *d2 results with the number of pixels needed to be skipped from the total rows
                          
    move.l (CropStartXCoordinate),d1
    add.l d1,d2                             *Adds the pixels that need to be traversed in the final row to reach the crop data
    
    move.l Bitdepth,d1
    jsr MULTIPLY_FUNCTION                   *d5 results with the number of bytes needed to be skipped to reach the crop data from the START of the image data
    
    move.l #BACKGROUND_DATA_BYTE_OFFSET,d1    
    add.l d1,d2                             *We add the bytes in the header which will account for those bytes needed to get to the START of the image data.
    
    add.l (TotalIntialBytePaddingOffset),d2 *Padding needs to be added for the rows that were skipped to get to the first byte of crop data
                                            
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
    
GetBackgroundReadOffset:
    *set neaxt read position for the file
    move.l (CropReadOffsetCounter),d4
    move.l (BytesToSkipForNextRead),d5
    add.l d5,d4
    
    move.l d4,(CropReadOffsetCounter) *Cumulative read offset
    
    move.l FID,d1
    move.l #TRAP_SET_READ_POSITION,d0
    move.l CropReadOffsetCounter,d2
    trap #15

    rts
    
CalcBackgroundPadding:
    move.l (V_Background1_ImageW),d1
    divu #4,d1
    lsr.l #8,d1
    lsr.l #8,d1
    move.l d1,(BytePaddingOffset) 
    
    jsr MULTIPLY_FUNCTION
 
    move.l d2,(TotalIntialBytePaddingOffset)
    rts

LoadCropData:
  *This information is preset so that when we draw we don't have to continuously set this information
  
  *Set Crop Start Coordinates
    move.l #100,(CropStartXCoordinate)
    move.l #0,(CropStartYCoordinate)

  *Set Crop Dimensions
    move.l #75,(CropWidth)
    move.l #50,(CropHeight)

  *Set Crop Print Coordinates
    move.l #100,(CropPrintXCoordinate)
    move.l #0,d1
    add.l (CropHeight),d1
    move.l d1,(CropPrintYCoordinate)
    
    rts


















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
