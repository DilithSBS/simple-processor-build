module cpu (PC, INSTRUCTION, CLK, RESET);
/*
=============================================
            Port Declarations
=============================================
*/
    input               CLK, RESET;         // For PC and the reg_file
    input       [31:0]  INSTRUCTION;

    // adder ports
    output  reg [7:0]  PC;
    wire        [7:0]  next_pc;

    // control_unit ports
    wire        [7:0]   op_code;

    //reg_file ports
    wire                write_enable;
    wire        [2:0]   write_reg;
    wire        [2:0]   read_reg_1;
    wire        [2:0]   read_reg_2;

    wire        [7:0]   write_val;          // Output of the ALU
    

    // twos_complement ports
    wire        [7:0]   in_val;

    // mux1 ports
    wire        [7:0]   regout2;
    wire        [7:0]   twos_comp_res;
    wire                reg2_or_twos_comp;


    // mux2 ports
    wire        [7:0]   mux1_res;
    wire        [7:0]   immediate;
    wire                reg_or_imm;


    // ALU ports
    wire        [7:0]   alu_op_1;
    wire        [7:0]   alu_op_2;
    wire        [2:0]   select;

/*
=============================================
            Instruction Memory      
=============================================
*/

    // // 32-bits wide 64 instructions (256 bytes)
    // reg [31:0] instruction_memory [0:64];


/*
=============================================
        External Module Instantiation      
=============================================
*/

    adder my_adder(
        .PC_IN(PC),
        .PC_OUT(next_pc)
    );

    twos_complement my_twos_complement(
        .IN_VAL(in_val),
        .OUT_VAL(twos_comp_res)
    );

    control_unit my_control_unit(
        .OP_CODE(op_code),
        .WRITE_ENABLE(write_enable),
        .ORIG_OR_TWOS_COMP(reg2_or_twos_comp),
        .REG_OR_IMM(reg_or_imm),
        .ALU_OP(select)
    );

    alu my_alu(
        .DATA1(alu_op_1),
        .DATA2(alu_op_2),
        .SELECT(select),
        .RESULT(write_val)

    );

    reg_file my_reg_file (
        .IN(write_val),
        .INADDRESS(write_reg),
        .OUT1ADDRESS(read_reg_1),
        .OUT2ADDRESS(read_reg_2),
        .OUT1(alu_op_1),
        .OUT2(regout2),
        .WRITE(write_enable),
        .CLK(CLK),
        .RESET(RESET)
    );

    mux_2to1 my_mux_1 (
        .INPUT1(regout2),
        .INPUT2(twos_comp_res),
        .SELECT(reg2_or_twos_comp),
        .OUT_VAL(mux1_res)
    );

    mux_2to1 my_mux_2 (
        .INPUT1(mux1_res),
        .INPUT2(immediate),
        .SELECT(reg_or_imm),
        .OUT_VAL(alu_op_2)
    );


/*
=============================================
        Decoding an instruction      
=============================================
*/

    // derive immediate and twos-complement input
    assign in_val = regout2;
    assign immediate = INSTRUCTION[7:0];

    assign op_code    = INSTRUCTION[31:24];
    assign write_reg  = INSTRUCTION[18:16];
    assign read_reg_1 = INSTRUCTION[10:8];
    assign read_reg_2 = INSTRUCTION[2:0];



    always @(posedge CLK) begin
        if (RESET == 1) begin
            #1 PC = 0;
        end
        else begin
            #1 PC = next_pc;
        end
    end

endmodule


module adder (
    input   [7:0]  PC_IN,
    output  [7:0]  PC_OUT
);
    
    assign #1 PC_OUT = PC_IN + 8'd4;
    
endmodule



module control_unit(
    
    input       [7:0]   OP_CODE,

    output reg          WRITE_ENABLE, ORIG_OR_TWOS_COMP, REG_OR_IMM,
    output reg  [2:0]   ALU_OP

);

    always @(*) begin
        
        #1;

        ORIG_OR_TWOS_COMP = 1'b0;
        REG_OR_IMM = 1'b0;
        WRITE_ENABLE = 1'b0;
        ALU_OP = 3'b000;


        case (OP_CODE)
            
            // ADD reg_dest, reg_read1, reg_read2
            8'h00: begin
                
                WRITE_ENABLE = 1'b1;
                ALU_OP = 3'd1;

            end

            // SUB reg_dest, reg_read1, reg_read2
            8'h01: begin
                
                WRITE_ENABLE = 1'b1;
                ALU_OP = 3'd1;
                ORIG_OR_TWOS_COMP = 1'b1;      // TO choose the twos' complement value

            end
            
            // AND reg_dest, reg_read1, reg_read2
            8'h02: begin
                
                WRITE_ENABLE = 1'b1;
                ALU_OP = 3'd3;

            end

            // OR reg_dest, reg_read1, reg_read2
            8'h03: begin
                
                WRITE_ENABLE = 1'b1;
                ALU_OP = 3'd4;

            end

            // MOV reg_dest, reg_read1
            8'h06: begin
                
                WRITE_ENABLE = 1'b1;
                ALU_OP = 3'd0;
                REG_OR_IMM = 1'b0;

            end
            
            // LOADI reg_dest, imm
            8'h07: begin
                
                WRITE_ENABLE = 1'b1;
                ALU_OP = 3'd0;
                REG_OR_IMM = 1'b1;         

            end

            default: begin
                WRITE_ENABLE = 1'b0;
            end

        endcase

    end

endmodule



/*
=============================================
                2-to-1 MUX      
=============================================
*/

module mux_2to1(
    input [7:0] INPUT1, INPUT2,
    input SELECT,
    output reg [7:0] OUT_VAL
);

    always @(*) begin
        case (SELECT)
            0: begin
                OUT_VAL = INPUT1;
            end

            1: begin
                OUT_VAL = INPUT2;
            
            end
            default: begin
                OUT_VAL = INPUT1;
            end 
        endcase
    end

endmodule



module twos_complement(
    input [7:0] IN_VAL,
    output [7:0] OUT_VAL
);

    assign OUT_VAL = (~IN_VAL) + 1;

endmodule


/*
=========================================================================
                            A      L       U     U
                           A A     L       U     U
                          AAAAA    L       U     U
                         A     A   L       U     U
                        A       A  LLLLLL    UUU
=========================================================================
*/

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



/*
=========================================================================
        RRRRR   EEEEE    GGGG      FFFFF III  L       EEEEE
        R    R  E       G          F      I   L       E
        RRRR    EEEE   G   GG      FFFF   I   L       EEEE
        R   R   E       G   G      F      I   L       E
        R    R  EEEEE    GGGG      F     III  LLLLLL  EEEEE
=========================================================================
*/


module reg_file(IN, OUT1, OUT2, INADDRESS, OUT1ADDRESS, OUT2ADDRESS, WRITE, CLK, RESET);
    
                                                /*
    ============================================
                Port Declarations
    ============================================*/

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
    always @ (posedge CLK) begin
        
        // If reset input is 1, all of the registers will be cleared
        if (RESET == 1'b1) begin
            
            // Clearing every byte of the register in a loop
            for (i = 0; i < 8 ; i = i + 1) begin
                reg_array[i] <= #1 8'b00000000;
            end

        end

        // If write input is 1, right the IN value into the register[INADDRES]
        else if (WRITE == 1'b1) begin
            
            // Non-blocking assignment to the register
            reg_array[INADDRESS] <= #1 IN;

        end    
        
    end

endmodule