/*
=========================================================================
                            A      L       U     U
                           A A     L       U     U
                          AAAAA    L       U     U
                         A     A   L       U     U
                        A       A  LLLLLL    UUU
=========================================================================
*/

module alu(DATA1, DATA2, SELECT, RESULT, ZERO);

    /*
    ============================================
        Port Declarations
    ============================================
    */

    // 8-bit Data inputs
    input   [7:0]   DATA1, DATA2;

    // Selection input
    input   [2:0]   SELECT;

    // 8-bit output result
    output  [7:0]   RESULT;

    // Zero flag output;
    output          ZERO;

    // 8-bit wires to hold the results of each operation
    wire [7:0]  forward_result;
    wire [7:0]  add_result;
    wire [7:0]  and_result;
    wire [7:0]  or_result;
    wire [7:0]  ror_result;

    /*
    ============================================
    Module Instantiations
    ============================================*/

    // Forward module to forward DATA2 when SELECT is 000
    FORWARD myforward(
                .DATA2(DATA2),
                .RESULT(forward_result)
            );

    // ADD module to add DATA1 and DATA2 when SELECT is 001
    ADD myadd(
            .DATA1(DATA1),
            .DATA2(DATA2),
            .RESULT(add_result)
        );

    // AND module to perform bitwise AND on DATA1 and DATA2 when SELECT is 010
    AND myand(
            .DATA1(DATA1),
            .DATA2(DATA2),
            .RESULT(and_result)
        );

    // OR module to perform bitwise OR on DATA1 and DATA2 when SELECT is 011
    OR myor(
        .DATA1(DATA1),
        .DATA2(DATA2),
        .RESULT(or_result)
        );

    ROR myror(
            .DATA(DATA1),
            .OFFSET(DATA2),
            .RESULT(ror_result)
        );


    // Continuous assignment to RESULT based on the value of SELECT
    assign RESULT = (SELECT == 3'b000) ? forward_result :
            (SELECT == 3'b001) ? add_result :
            (SELECT == 3'b010) ? and_result :
            (SELECT == 3'b011) ? or_result :
            (SELECT == 3'b100) ? ror_result :
            8'b0;

    // Continuous assignment to ZERO flag
    assign ZERO = (RESULT == 8'b0) ? 1'b1 : 1'b0;

endmodule


    /*
    ============================================
    Module Declarations
    ============================================*/

    // Forward module to forward DATA2 when SELECT is 000
    module FORWARD(DATA2, RESULT);

    input [7:0] DATA2;
    output reg [7:0] RESULT;

    // Forwarding DATA2 to RESULT with a delay of 1 time unit
    always @ (DATA2)
    begin
        #1 RESULT = DATA2;
    end


endmodule



// ADD module to add DATA1 and DATA2 when SELECT is 001
module ADD(DATA1, DATA2, RESULT);

    input       [7:0] DATA1, DATA2;
    output reg  [7:0] RESULT;


    // Adding DATA1 and DATA2 and assigning the result to RESULT with a delay of 2 time units
    always @ (DATA1, DATA2)
    begin
        #2 RESULT = DATA1 + DATA2;
    end


endmodule

// AND module to perform bitwise AND on DATA1 and DATA2 when SELECT is 010
module AND(DATA1, DATA2, RESULT);

    input [7:0] DATA1, DATA2;
    output reg [7:0] RESULT;


    // Performing bitwise AND on DATA1 and DATA2 and
    // assigning the result to RESULT with a delay of 1 time unit
    always @ (DATA1, DATA2)
    begin
        #1 RESULT = DATA1 & DATA2;
    end


endmodule


// OR module to perform bitwise OR on DATA1 and DATA2 when SELECT is 011
module OR(DATA1, DATA2, RESULT);

    input [7:0] DATA1, DATA2;
    output reg [7:0] RESULT;

    // Performing bitwise OR on DATA1 and DATA2 and
    // assigning the result to RESULT with a delay of 1 time unit
    always @ (DATA1, DATA2)
    begin
        #1 RESULT = DATA1 | DATA2;
    end


endmodule


// ROR module to perform bitwise right rotation on DATA
module ROR(DATA, OFFSET, RESULT);

    input 		[7:0] DATA, OFFSET;
    output reg 	[7:0] RESULT;

    // assigning the result to RESULT with a delay of 1 time unit
    // There are only 8 cases of rotation because this is an 8 bit valuw
    always @ (DATA, OFFSET)
    begin

        case (OFFSET[2:0])

        3'd0:
            #1 RESULT = DATA;

        3'd1:
            #1 RESULT = {DATA[0], DATA[7:1]};

        3'd2:
            #1 RESULT = {DATA[1:0], DATA[7:2]};

        3'd3:
            #1 RESULT = {DATA[2:0], DATA[7:3]};

        3'd4:
            #1 RESULT = {DATA[3:0], DATA[7:4]};

        3'd5:
            #1 RESULT = {DATA[4:0], DATA[7:5]};

        3'd6:
            #1 RESULT = {DATA[5:0], DATA[7:6]};

        3'd7:
            #1 RESULT = {DATA[6:0], DATA[7]};

        endcase

    end


endmodule

