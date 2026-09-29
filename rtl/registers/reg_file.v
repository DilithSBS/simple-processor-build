/*
=========================================================================
        RRRRR   EEEEE    GGGG      FFFFF III  L       EEEEE
        R    R  E       G          F      I   L       E
        RRRR    EEEE   G   GG      FFFF   I   L       EEEE
        R   R   E       G   G      F      I   L       E
        R    R  EEEEE    GGGG      F     III  LLLLLL  EEEEE
=========================================================================
*/

`timescale 1ns/100ps

module reg_file(IN, OUT1, OUT2, INADDRESS, OUT1ADDRESS, OUT2ADDRESS, WRITE, CLK, RESET);

    /*
    ============================================
        Port Declarations
    ============================================
    */

    // Inputs

    // Input value to store
    input [7:0] IN;

    // Clock input, Write command, Reset commmand
    input CLK, WRITE, RESET;

    // Input register address to store
    // Output register adress 1 to output value 1
    // Output register adress 2 to output value 2
    input [2:0] INADDRESS, OUT1ADDRESS, OUT2ADDRESS;

    // OUT1 and OUT2 is not declared as reg becuase continuous assignment doesn't allow that.
    // Therefore, they are kept as net values
    output wire [7:0] OUT1, OUT2;


    /*
    ============================================
    Internal Storage (8x8 register)
    ============================================*/

    // Declaring an array of 8, 8-byte arrays
    reg [7:0] reg_array [7:0];

    // Declaring integer i for the 'for' loop
    integer i;


    /*
    ============================================
    Reading Logic (Asynchronous)
    ============================================*/

    // Continuous assignment to OUT1 and OUT2
    // the values obtained from OUT1ADDRESS and OUT2ADDRESS
    assign #2 OUT1 = reg_array[OUT1ADDRESS];
    assign #2 OUT2 = reg_array[OUT2ADDRESS];


    /*
    ============================================
    Write and Reset Logic (Synchronous)
    ============================================*/

    // This 'always' block triggers when the clock is set to 1
    always @ (posedge CLK)
    begin
        
        #1; // Delay to allow BUSYWAIT and other signals to settle from race conditions

        // If reset input is 1, all of the registers will be cleared
        if (RESET == 1'b1)
        begin

        // Clearing every byte of the register in a loop
        for (i = 0; i < 8 ; i = i + 1)
        begin
            reg_array[i] <= 8'b00000000;
        end

        end

        // If write input is 1, right the IN value into the register[INADDRES]
        else if (WRITE == 1'b1)
        begin
        // Non-blocking assignment to the register
        reg_array[INADDRESS] <= IN;

        end

    end

endmodule
