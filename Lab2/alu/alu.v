module alu(DATA1, DATA2, SELECT, RESULT);


                                                /*
    ============================================
                Port Declarations
    ============================================*/

    // 8-bit Data inputs
    input [7:0] DATA1, DATA2;
    
    // Selection input
    input [2:0] SELECT;

    // 8-bit output result
    output [7:0] RESULT;

    // 8-bit wires to hold the results of each operation
    wire [7:0] forward_result;
    wire [7:0] add_result;
    wire [7:0] and_result;
    wire [7:0] or_result;

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

    // Continuous assignment to RESULT based on the value of SELECT
    assign RESULT = (SELECT == 3'b000) ? forward_result :
                    (SELECT == 3'b001) ? add_result :
                    (SELECT == 3'b010) ? and_result :
                    (SELECT == 3'b011) ? or_result :
                    8'b0;

endmodule


                                                /*
    ============================================
                Module Declarations
    ============================================*/

// Forward module to forward DATA2 when SELECT is 000
module FORWARD(DATA2, RESULT);

    input [7:0] DATA2;
    output reg [7:0] RESULT;
    
    always @ (DATA2)
    begin
        // Forwarding DATA2 to RESULT with a delay of 1 time unit
        #1 RESULT <= DATA2;
    end

endmodule



// ADD module to add DATA1 and DATA2 when SELECT is 001
module ADD(DATA1, DATA2, RESULT);

    input [7:0] DATA1, DATA2;
    output reg [7:0] RESULT;
    
    always @ (DATA1, DATA2)
    begin
        // Adding DATA1 and DATA2 and assigning the result to RESULT with a delay of 2 time units
        #2 RESULT <= DATA1 + DATA2;
    end

endmodule

// AND module to perform bitwise AND on DATA1 and DATA2 when SELECT is 010
module AND(DATA1, DATA2, RESULT);

    input [7:0] DATA1, DATA2;
    output reg [7:0] RESULT;
    
    always @ (DATA1, DATA2)
    begin
        // Performing bitwise AND on DATA1 and DATA2 and 
        // assigning the result to RESULT with a delay of 1 time unit
        #1 RESULT <= DATA1 & DATA2;
    end

endmodule


// OR module to perform bitwise OR on DATA1 and DATA2 when SELECT is 011
module OR(DATA1, DATA2, RESULT);

    input [7:0] DATA1, DATA2;
    output reg [7:0] RESULT;
    
    always @ (DATA1, DATA2)
    begin
        // Performing bitwise OR on DATA1 and DATA2 and
        // assigning the result to RESULT with a delay of 1 time unit  
        #1 RESULT <= DATA1 | DATA2;
    end

endmodule
