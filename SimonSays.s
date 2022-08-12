#pragma once 

#define LED_MATRIX_0_BASE (0xf0000010)
#define LED_MATRIX_0_SIZE (0x10)
#define LED_MATRIX_0_WIDTH (0x2)
#define LED_MATRIX_0_HEIGHT (0x2)

#define D_PAD_0_BASE (0xf0000000)
#define D_PAD_0_SIZE (0x10)
#define D_PAD_0_UP_OFFSET (0x0)
#define D_PAD_0_UP (0xf0000000)
#define D_PAD_0_DOWN_OFFSET (0x4)
#define D_PAD_0_DOWN (0xf0000004)
#define D_PAD_0_LEFT_OFFSET (0x8)
#define D_PAD_0_LEFT (0xf0000008)
#define D_PAD_0_RIGHT_OFFSET (0xc)
#define D_PAD_0_RIGHT (0xf000000c)

.data
#count: .word 4
promptA: .string "\nWould you like to play again, (0 for NO, 1 for YES)\n"
currentlevel: .string "\nCurrent Level is\n"
FinalLevel: .string "\nThe level you reached was\n"
newline: .string "\n"
sequence:  .byte 0,0,0,0

.globl main
.text

main:
    #This is for the max time
    li x24, 500
    #This is for the minimum time
    li x25, 100
    #This is for delay after
    li x22, 1000
    #This is for the initial counter
    li s11, 1
    #This loads the address of the first element of sequence
    la s10, sequence
    #This initializes the inital count of 4
    li x23, 4
    #This initializes the registers for comparing
    li x19, 1
    li x20, 2
    li x21, 3
    #This code handles the increasing length of the sequence
    #mv a0, s10
    #addi a0, a0, 100
    
    #li a7, 214
    #ecall
    
    new_game:
        li a7, 4
        la a0, currentlevel
        ecall
        
        li a7, 1
        mv a0, s11
        ecall
        
        li a7, 4
        la a0, newline
        ecall
        
        addi s2, s11, 3
        
        mv a0, s10
        add a0, a0, s2
        
        li a7, 214
        ecall
        
        #la s10, sequence         
    
        li a0, 0
        mv t5, a0
        FOR_INITIAL:
            beq a0, x23, DONE_INITIAL
            jal SET_INITIAL
            mv a0, t5
            addi a0, a0, 1
            mv t5, a0
            j FOR_INITIAL
        DONE_INITIAL:
        
        li a0, 500
        jal delay
        
    # TODO: Before we deal with the LEDs, we need to generate a random
    # sequence of numbers that we will use to indicate the button/LED
    # to light up. For example, we can have 0 for UP, 1 for DOWN, 2 for
    # LEFT, and 3 for RIGHT. Store the sequence in memory. We provided 
    # a declaration above that you can use if you want.
    # HINT: Use the rand function provided to generate each number
    
        li t4, 0
    #The _S means it handles the creation of a sequence
        FOR_S:
            beq t4, s2, DONE_S
            li a0, 4
            jal rand        
            sb a0, 0(s10) 
            li a0, 350
            jal delay
            addi s10, s10, 1
            addi t4, t4, 1
            j FOR_S
        DONE_S:    

   
    # TODO: Now read the sequence and replay it on the LEDs. You will
    # need to use the delay function to ensure that the LEDs light up 
    # slowly. In general, for each number in the sequence you should:
    # 1. Figure out the corresponding LED location and colour
    # 2. Light up the appropriate LED (with the colour)
    # 2. Wait for a short delay (e.g. 500 ms)
    # 3. Turn off the LED (i.e. set it to black)
    # 4. Wait for a short delay (e.g. 1000 ms) before repeating
    
    #The _L is for displaying colours on the LED's
    
        li t4, 0
        la s10, sequence 
        FOR_L:
            beq t4, s2, DONE_L
            lb a0, 0(s10)
            mv t5, a0        
            jal LEDsetter
            jal setLED  
            #You then want to wait for a short delay of 500ms
            mv a0, x24
            jal delay
            #You then want to turn off the LED
            mv a0, t5
            jal SET_INITIAL
            #You then want to wait for a short delay of 1000ms
            ####Change the 1000ms part here.
            #li a0, 1000
            mv a0, x22
            jal delay
            addi s10, s10, 1
            addi t4, t4, 1
            j FOR_L 
        DONE_L:
      
    # TODO: Read through the sequence again and check for user input
    # using pollDpad. For each number in the sequence, check the d-pad
    # input and compare it against the sequence. If the input does not
    # match, display some indication of error on the LEDs and exit. 
    # Otherwise, keep checking the rest of the sequence and display 
    # some indication of success once you reach the end.
    
        la s10, sequence
    #The _R means we are reading for user input.
    
        li t4, 0
        FOR_R:
            beq t4, s2, DONE_R
            lb x9, 0(s10)
            jal pollDpad
            #These next few lines light up based on the button pressed.
            addi t5, a0, 0
            jal LEDsetter
            jal setLED
            li a0, 200
            jal delay
            #addi t3, t5, 0
            mv a0, t5
            jal SET_INITIAL
            #mv a0, t3
            mv a0, t5
            #Now we check to see if the button pressed is correct.
            IF_RE:
                beq a0, x9, DONEIF_R
                mv t5, a0
                jal LEDsetter #Our indication of error is that the incorrect LED will
                              #LED will light up for some time, 3000ms
                jal setLED
                li a0, 6000
                jal delay
                mv a0, t5
                jal SET_INITIAL
                j END
            DONEIF_R:
            addi t4, t4, 1
            addi s10, s10, 1
            j FOR_R
        DONE_R:
        #Our indication for a successful try is that all LED's light
        #up at the same time.
        jal SET_SUCCESS
        li a0, 1000
        jal delay
        #_T checks set the correct time for the next loop
        IF_T:
            bge x25, x24, IF2_T
            addi x24, x24, -50
        IF2_T:
            bge x22, x25, DONE_T
            addi x22, x22, -50
        DONE_T:
        addi s11, s11, 1
        j new_game

    # TODO: Ask if the user wishes to play again and either loop back to
    # start a new round or terminate, based on their input.
        END:
            li a7, 4
            la a0, FinalLevel
            ecall
            
            li a7, 1
            mv a0, s11
            ecall
            
            li a7, 4
            la a0, newline
            ecall
            
            li a7, 4
            la a0, promptA
            ecall
            call readInt
            beq a0, x0, exit
            j main
exit:
    li a7, 10
    ecall
    

LEDsetter:
    #This sets the parameters of the function setLED to the appropriate values.
    beq a0, zero, IF_U
    beq a0, x19, IF_D
    beq a0, x20, IF_L
    beq a0, x21, IF_R
    IF_U:
        li a0, 0xff0000
        li a1, 0
        li a2, 0
        j DONE_LED
    IF_D:
        li a0, 0x0000ff
        li a1, 1
        li a2, 1 
        j DONE_LED                    
    IF_L:
        li a0, 0x00ff00
        li a1, 0
        li a2, 1
        j DONE_LED
    IF_R:
        li a0, 0xffff00
        li a1, 1
        li a2, 0
        #mv t6, a0
        #li a7, 4
        #la a0, promptR
        #ecall
        #mv a0, t6
        j DONE_LED
    DONE_LED:
        jr ra
        
SET_SUCCESS:
    mv a0, x0
    #These next few lines store the initial return address.
    mv t6, a0
    mv t5, ra
    FOR_SUCCESS:
        beq a0, s2, DONE_SUCCESS
        jal LEDsetter        
        jal setLED
        mv a0, t6
        addi a0, a0, 1
        mv t6, a0
        j FOR_SUCCESS
    DONE_SUCCESS:
        mv ra, t5
        jr ra

SET_INITIAL:
    ##This function sets the initial colors of the LED matrix
    mv t6, ra
    beq a0, zero, IF_ZERO
    beq a0, x19, IF_ONE
    beq a0, x20, IF_TWO
    beq a0, x21, IF_THREE
    IF_ZERO:
        jal LEDsetter
        li a0, 0x8B0000
        j ENDIF
    IF_ONE:
        jal LEDsetter
        li a0, 0x00008B
        j ENDIF
    IF_TWO:
        jal LEDsetter
        li a0, 0x3CB371
        j ENDIF
    IF_THREE:
        jal LEDsetter
        li a0, 0x9ACD32
        j ENDIF
    ENDIF:
        jal setLED
        mv ra, t6
        jr ra
    
# --- HELPER FUNCTIONS ---
# Feel free to use (or modify) them however you see fit
     
# Takes in the number of milliseconds to wait (in a0) before returning
delay:
    mv t0, a0
    li a7, 30
    ecall
    mv t1, a0
delayLoop:
    ecall
    sub t2, a0, t1
    bgez t2, delayIfEnd
    addi t2, t2, -1
delayIfEnd:
    bltu t2, t0, delayLoop
    jr ra

# Takes in a number in a0, and returns a (sort of) random number from 0 to
# this number (exclusive)
rand:
    mv t0, a0
    li a7, 30
    ecall
    remu a0, a0, t0
    jr ra
    
# Takes in an RGB color in a0, an x-coordinate in a1, and a y-coordinate
# in a2. Then it sets the led at (x, y) to the given color.
setLED:
    li t1, LED_MATRIX_0_WIDTH
    mul t0, a2, t1
    add t0, t0, a1
    li t1, 4
    mul t0, t0, t1
    li t1, LED_MATRIX_0_BASE
    add t0, t1, t0
    sw a0, (0)t0
    jr ra
    
# Polls the d-pad input until a button is pressed, then returns a number
# representing the button that was pressed in a0.
# The possible return values are:
# 0: UP
# 1: DOWN
# 2: LEFT
# 3: RIGHT
pollDpad:
    mv a0, zero
    li t1, 4
pollLoop:
    bge a0, t1, pollLoopEnd
    li t2, D_PAD_0_BASE
    slli t3, a0, 2
    add t2, t2, t3
    lw t3, (0)t2
    bnez t3, pollRelease
    addi a0, a0, 1
    j pollLoop
pollLoopEnd:
    j pollDpad
pollRelease:
    lw t3, (0)t2
    bnez t3, pollRelease
pollExit:
    jr ra

readInt:
    addi sp, sp, -12
    li a0, 0
    mv a1, sp
    li a2, 12
    li a7, 63
    ecall
    li a1, 1
    add a2, sp, a0
    addi a2, a2, -3
    mv a0, zero
parse:
    blt a2, sp, parseEnd
    lb a7, 0(a2)
    addi a7, a7, -48
    li a3, 9
    bltu a3, a7, error
    mul a7, a7, a1
    add a0, a0, a7
    li a3, 10
    mul a1, a1, a3
    addi a2, a2, -1
    j parse
parseEnd:
    addi sp, sp, 12
    ret
error:
    li a7, 93
    li a0, 1
    ecall