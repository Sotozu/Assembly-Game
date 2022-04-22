*--------------GENERAL FUNCTIONS--------------*
*General use case functions


*EXPLANATION: Converts data into little endian for proper reading of data.
*-
*TOTAL REGISTERS USED: d1
*PARAMETERS: d1 -> (Big Endian formated data)
*RETURNS: d1 -> (Data in Little Endian format)    
BigEndianToLittleEndian:
    
    rol.w #8,d1
    swap.w d1
    rol.w #8,d1
     
    rts

*EXPLANATION: In my research there is no multiply function in EASy68k that will go beyond WORD size.
* This function can go beyond WORD size. One application is to traverse large amounts of memory for printing a crop.
*-  
*TOTAL REGISTERS USED: d1,d2,d3
*PARAMETERS: d1,d2 -> ('d1' number of times to multiply, 'd2' number to be multiplied)
*RETURNS: d2 -> (The product of d1*d2)  
MULTIPLY_FUNCTION:
    cmp #0,d1
    beq mult_0
    cmp #1,d1
    beq mult_1
    move.l d2,d3
    subi.l #1,d1
cont_mult
    add.l d3,d2
    subi.l #1,d1
    bne cont_mult
    rts
mult_0
    move.l #0,d2
    rts
mult_1
    rts


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
