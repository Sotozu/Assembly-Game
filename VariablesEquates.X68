ALL_REG                     REG D0-D7/A0-A6

*-----------------TRAP CODE EQUATES-----------------*
TRAP_GET_TIME               EQU     8
TRAP_PRINT_NULLT_DEFAULT    EQU     10
TRAP_GET_CURSOR_POS         EQU     11
TRAP_CLEAR_SCREEN           EQU     11
TRAP_DISP_NULLT_STR_CRLF    EQU     13
TRAP_DISP_NULLT_STR         EQU     14
TRAP_DISP_UNSNUM_D1         EQU     15
TRAP_DBUFFER_MODE	        EQU	    17
TRAP_GET_PRESSED_KEY        EQU     19
TRAP_SET_OUTPUT_RESOLUTION  EQU     33
TRAP_CLOSE_ALL_FILES        EQU     50
TRAP_OPEN_EXISTING_FILE     EQU     51
TRAP_READ_FILE              EQU     53
TRAP_SET_READ_POSITION      EQU     55
TRAP_CLOSE_FILE             EQU     56
TRAP_GET_MOUSE_INPUTS       EQU     61
TRAP_PLAY_WAV_SOUND         EQU     73
TRAP_SET_PEN_COLOR          EQU     80
TRAP_SET_FILL_COLOR         EQU     81
TRAP_DRAW_PIXEL             EQU     82
TRAP_DRAW_LINE              EQU     84
TRAP_DRAW_CIRCLE            EQU     88
TRAP_DRAWING_MODE	        EQU	    92
TRAP_SET_PEN_WIDTH          EQU     93
TRAP_REPAINT_SCREEN	        EQU	    94

*-----------------APPLIED GENERAL USE EQUATES-----------------*    
SCREEN_WIDTH                EQU 640
SCREEN_HEIGHT               EQU 480
TOTAL_UNIQUE_SPRITES        EQU 1           *Number of unique sprites loaded into memory from a BMP file
TOTAL_SPRITE_DIM_VALUES     EQU 2            *will always need to be 2x that of TOTAL_UNIQUE_SPRITES
FRAME_DELAY_TIME            EQU 1
FRAME_UPDATE_RATE           EQU 1
FIRE_LINE_LENGTH            EQU 30 *keep at 30
GRAVITY                     EQU 1
GRAVITY_FRAME_COUNTER       EQU 10


*-----------------COLOR EQUATES-----------------* 
WHITE                       EQU $00FFFFFF   *used to not print sprite background
RED                         EQU $000000FF
GREEN                       EQU $0000FF00
BLUE                        EQU $00FF0000
BLACK                       EQU $00000000
GREY                        EQU $00808080


*Primitive Balloon
BALLOON_WIDTH		        EQU	20
BALLOON_HEIGHT		        EQU	20
BALLOON_TOP_Y_POSITION	    EQU	100
BALLOON_INIT_VELOCITY       EQU	4
BALLOON_SPAWN_RIGHT_X       EQU 580
BALLOON_SPAWN_LOWER_Y       EQU 400
BALLOON_SPAWN_LEFT_X        EQU 540
BALLOON_SPAWN_UPPER_Y       EQU 360

*Primitive Rock
ROCK_WIDTH		            EQU 5
ROCK_HEIGHT		            EQU 5
ROCK_TOP_Y_POSITION	        EQU 100
ROCK_INIT_VELOCITY          EQU 20
ROCK_SPAWN_LEFT_X           EQU 75
ROCK_SPAWN_UPPER_Y          EQU 400
ROCK_SPAWN_RIGHT_X          EQU 80
ROCK_SPAWN_LOWER_Y          EQU 405

*Primitve Fire Line
PFIRE_LINE_ORG_X            EQU 75
PFIRE_LINE_ORG_Y            EQU 400
FIRE_LINE_WIDTH             EQU 2

*-----------------VARIABLES AND TYPES-----------------*
*V - stands for value. This data is designed to be used for value type functions
*M - stands for memory address. This data is designed to be used for memory type functions
*B - stands for Boolian. TRUE = 1 FALSE = 0
*ArrM - stands for 'array of memory address'. 
*ArrV - stands for 'array of values'.

*Location in memory where START of each unique sprite color data is located
ArrM_Sprite_Mem_Loc ds.l TOTAL_UNIQUE_SPRITES
ArrM_Sprite_ML_END *When iterating the array if the reads go beyond this point then reset

*Width and Height of each unique sprite. Two data values for one unique sprite.
*Order is respective to ArrM_Sprite_Mem_Loc
*order is |1spriteWIDTH|1spriteHEIGHT|2spriteWIDTH|2spriteHEIGHT| ....
ArrV_Sprite_Dimensions ds.l TOTAL_SPRITE_DIM_VALUES
ArrV_Sprite_D_END

*BACKGROUND1 VALUES
V_Background1_ImageH        ds.l 1
V_Background1_ImageW        ds.l 1
V_Background1_ImageBD       ds.l 1
M_Background1_DataSLocation ds.l 1

*WIN SCREEN VALUES
V_Win_ImageH                ds.l 1
V_Win_ImageW                ds.l 1
V_Win_ImageBD               ds.l 1
M_Win_DataSLocation         ds.l 1

*LOSE SCREEN VALUES
V_Lose_ImageH               ds.l 1
V_Lose_ImageW               ds.l 1
V_Lose_ImageBD              ds.l 1
M_Lose_DataSLocation        ds.l 1

*ARCHER VALUES
V_Archer_ImageH             ds.l 1
V_Archer_ImageW             ds.l 1
V_Archer_ImageBD            ds.l 1
M_Archer_DataSLocation      ds.l 1

*ROCK VALUES
V_Rock_Current_LXPOS        ds.l 1 *Left X
V_Rock_Current_UYPOS        ds.l 1 *Upper Y
V_Rock_Current_RXPOS        ds.l 1 *Right X
V_Rock_Current_LYPOS        ds.l 1 *Lower Y

V_Rock_X_Velocity           ds.l 1
V_Rock_Y_Velocity           ds.l 1 *will need to be updated by gravity when firing

V_Rock_Prev_UYPOS           ds.l 1 *previous upper y (used to remove)
V_Rock_Prev_LYPOS           ds.l 1 *previous lower y (used to remove)

V_Rock_Prev_LXPOS           ds.l 1 *previous left x (used to remove)
V_Rock_Prev_RXPOS           ds.l 1 *previous right x (used to remove)

*GRAVITY
Gravity_Cumulative          ds.l 1
Gravity_Frame_Count         ds.l 1
Gravity_Max                 ds.l 1
B_Velocity_Reverse          ds.l 1

*SINE AND COSINE
Cosine_Cumulative           ds.l 1
Sine_Cumulative             ds.l 1
AngleThetaOfShot            ds.l 1 *1 is 30 degrees, 2 is 45 degrees and 3 is 60 degrees
SineOfAngle                 ds.l 1
CosineOfAngle               ds.l 1

*FIRE LINE VALUES
V_FireLine_X_End_POS        ds.l 1
V_FireLine_Y_End_POS        ds.l 1
V_FireLine_Pre_X_End_POS    ds.l 1
V_FireLine_Pre_Y_End_POS    ds.l 1

*BALLON VALUES
V_Balloon_Current_LXPOS     ds.l 1 *Left X
V_Balloon_Current_UYPOS     ds.l 1 *Upper Y
V_Balloon_Current_RXPOS     ds.l 1 *Right X
V_Balloon_Current_LYPOS     ds.l 1 *Lower Y
V_Balloon_Velocity          ds.l 1

V_Balloon_Prev_UYPOS        ds.l 1 *previous *upper y (used to remove)
V_Balloon_Prev_LYPOS        ds.l 1 *previous *lower y (used to remove)
B_Balloon_Reached_MY        ds.l 1 *Boolian if balloon has reached the max Y position. Used for clamping 
B_Balloon_Reached_LY        ds.l 1 *Boolian if balloon has reached the lower Y position. Used for clamping.
B_Last_Balloon              ds.l 1
V_Balloon_Collision_Counter ds.l 1
V_Balloon_Color             ds.l 1

*TIME VALUES
SecondCounter               ds.l 1 *used for seven segment
CurrentTime                 ds.l 1
PreviousTime                ds.l 1
DeltaTime                   ds.l 1
TimeUpdateBool              ds.l 1 *FALSE = 0 and TRUE = 1
                                   *This will be set when the FRAME_UPDATE_RATE is met in the GetDeltaTime function in UpdateGame.x68
                                   *Objects in the game that require updating will look to this bool and see if it has been set to true or false
                                   
B_Second_Passed             ds.l 1 *FALSE = 0 and TRUE = 1
                                   *Updated for seven segment
                                   
*COLLISION CHECK
B_CollisionOccured          ds.l 1
                    
*KEY INPUT VALUES
B_UpKeyPressed              ds.l 1
B_DownKeyPressed            ds.l 1
B_FireKeyPressed            ds.l 1

*OTHER GENERAL VALUES
RandomSeedLFSR              ds.l 1
B_Is_Win                    ds.l 1
B_Is_Lose                   ds.l 1
B_Screen_First_Print        ds.l 1
SevenSegCounter1            ds.l 1 *inner
SevenSegCounter2            ds.l 1 *outer

*FILE I/O AND CROPPING RELATED VALUES
buffer                      ds.l 1
HexColor                    ds.l 1
FID                         ds.l 1
Bitdepth                    ds.l 1
CropStartYCoordinate        ds.l 1
CropStartXCoordinate        ds.l 1
CropHeight                  ds.l 1
CropWidth                   ds.l 1
CropPrintYCoordinate        ds.l 1
CropPrintXCoordinate        ds.l 1
TotalIntialBytePaddingOffset ds.l 1
BytePaddingOffset           ds.l 1


NumberOfRowsToSkipToGetToCrop   ds.l 1
NumBytesToSkipToGetToCrop       ds.l 1
BytesToSkipForNextRead          ds.l 1

ByteOffsetToBeginReadingCropData ds.l 1
CropReadOffsetCounter            ds.l 1
CropReadOffset                   ds.l 1

*-----------------SIN AND COS TABLES-----------------*

*3 possible shoots  their degrees are 30, 45 and 60

*30 DEGREES         *45 DEGREES         *60 DEGREES
*COS - .8660        *COS - .7071        *COS - .5000       
*SIN - .5000        *SIN - .7071        *SIN - .8660

*Approximating these values using fractional bits to the thousands position
*Using THREE (3) fractional bits

*30 DEGREES                             *45 DEGREES                           *60 DEGREES
*COS - .8750  BINARY REP: 0.111         *COS - .7500  BINARY REP: 0.110       *COS - .5000  BINARY REP: 0.100      
*SIN - .5000  BINARY REP: 0.100         *SIN - .7500  BINARY REP: 0.110       *SIN - .8750  BINARY REP: 0.111

COS_TABLE                   dc.w $7,$6,$4
SIN_TABLE                   dc.w $4,$6,$7

VELOCITY_TABLE              dc.l $F,$11,$15 *30,20,40
COLOR_TABLE                 dc.l $000000FF,$0000FF00,$00FF0000,$00FFFFFF,$00000000 *RED,GREEN,BLUE,WHITE,BLACK
COLOR_TABLE_END
                            
SEVEN_SEGMENT_BITMASK_TABLE 
                            dc.b %01101111 *9
                            dc.b %01111111 *8
                            dc.b %00000111 *7
                            dc.b %01111101 *6
                            dc.b %01101101 *5
                            dc.b %01100110 *4
                            dc.b %01001111 *3
                            dc.b %01011011 *2
                            dc.b %00000110 *1
                            dc.b %00111111 *0 GFEDCBA
                          
SEVEN_SEG_PRINT_COORDINATES 
                            dc.w 130 *x1 A
                            dc.w 10  *y1 A
                            dc.w 140 *x2 A
                            dc.w 10  *y2 A

                            dc.w 140 *x1 B
                            dc.w 10  *y1 B
                            dc.w 140 *x2 B
                            dc.w 25  *y2 B
                            
                            dc.w 140 *x1 C
                            dc.w 25  *y1 C
                            dc.w 140 *x2 C
                            dc.w 40  *y2 C
                            
                            dc.w 140 *x1 D
                            dc.w 40  *y1 D
                            dc.w 130 *x2 D
                            dc.w 40  *y2 D
                            
                            dc.w 130 *x1 E
                            dc.w 40  *y1 E
                            dc.w 130 *x2 E
                            dc.w 25  *y2 E
                            
                            dc.w 130 *x1 F
                            dc.w 25  *y1 F
                            dc.w 130 *x2 F
                            dc.w 10  *y2 F
                            
                            dc.w 130 *x1 G
                            dc.w 25  *y1 G
                            dc.w 140 *x2 G
                            dc.w 25  *y2 G
                            
                            
SEVEN_SEG_PRINT_COORDINATES2                            
                            
                            dc.w 110 *x1 A
                            dc.w 10  *y1 A
                            dc.w 120 *x2 A
                            dc.w 10  *y2 A

                            dc.w 120 *x1 B
                            dc.w 10  *y1 B
                            dc.w 120 *x2 B
                            dc.w 25  *y2 B
                            
                            dc.w 120 *x1 C
                            dc.w 25  *y1 C
                            dc.w 120 *x2 C
                            dc.w 40  *y2 C
                            
                            dc.w 120 *x1 D
                            dc.w 40  *y1 D
                            dc.w 110 *x2 D
                            dc.w 40  *y2 D
                            
                            dc.w 110 *x1 E
                            dc.w 40  *y1 E
                            dc.w 110 *x2 E
                            dc.w 25  *y2 E
                            
                            dc.w 110 *x1 F
                            dc.w 25  *y1 F
                            dc.w 110 *x2 F
                            dc.w 10  *y2 F
                            
                            dc.w 110 *x1 G
                            dc.w 25  *y1 G
                            dc.w 120 *x2 G
                            dc.w 25  *y2 G

                                                     
                            
BMP_file_identifier dc.w $424D                            
                            
 

*-----------------FILE RELATED LOADS-----------------*

*Background1 BMP File

String_FileName             dc.b 'StaticBackground.bmp',0

*Sound Files
String_BallonPop_Sound      dc.b 'BallonPop.wav',0
String_Throw_Sound          dc.b 'Throw.wav',0

buffer2                     dc.l 1

*Archer BMP File In Memory
ARCHER_START_BMP_FILE INCBIN "Archer.bmp"
ARCHER_END_BMP_FILE

*Win BMP File In Memory
WIN_START_BMP_FILE INCBIN "You Win1.bmp"
WIN_END_BMP_FILE

*Lose BMP File In Memory
LOSE_START_BMP_FILE INCBIN "You Lose1.bmp"
LOSE_END_BMP_FILE

*Archer File Equates
ARCHER_FILE_SIZE                 EQU (ARCHER_END_BMP_FILE-ARCHER_START_BMP_FILE)
ARCHER_PWIDTH_MEM_LOC            EQU ARCHER_START_BMP_FILE+18
ARCHER_PHEIGHT_MEM_LOC           EQU ARCHER_START_BMP_FILE+22 
ARCHER_BITDEPTH_MEM_LOC          EQU ARCHER_START_BMP_FILE+28
ARCHER_COLOR_DATA_MEM_LOC        EQU ARCHER_START_BMP_FILE+54

*Win File Equates
WIN_FILE_SIZE                    EQU (WIN_END_BMP_FILE-WIN_START_BMP_FILE)
WIN_PWIDTH_MEM_LOC               EQU WIN_START_BMP_FILE+18
WIN_PHEIGHT_MEM_LOC              EQU WIN_START_BMP_FILE+22 
WIN_BITDEPTH_MEM_LOC             EQU WIN_START_BMP_FILE+28
WIN_COLOR_DATA_MEM_LOC           EQU WIN_START_BMP_FILE+54

*Lose File Equates
LOSE_FILE_SIZE                   EQU (LOSE_END_BMP_FILE-LOSE_START_BMP_FILE)
LOSE_PWIDTH_MEM_LOC              EQU LOSE_START_BMP_FILE+18
LOSE_PHEIGHT_MEM_LOC             EQU LOSE_START_BMP_FILE+22 
LOSE_BITDEPTH_MEM_LOC            EQU LOSE_START_BMP_FILE+28
LOSE_COLOR_DATA_MEM_LOC          EQU LOSE_START_BMP_FILE+54

*-----------------FILE EQUATES-----------------* 
BACKGROUND_WIDTH_BYTE_OFFSET     EQU 18
BACKGROUND_HEIGHT_BYTE_OFFSET    EQU 22 
BACKGROUND_DATA_BYTE_OFFSET      EQU 54
BACKGROUND_BITDEPTH_BYTE_READ    EQU 28














































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
