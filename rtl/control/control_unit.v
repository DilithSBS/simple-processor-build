
/*
=============================================
                CONTROL UNIT      
=============================================
*/
module control_unit(

    input       [7:0]   OP_CODE,

    output reg          WRITE_ENABLE,		// 1 to enable write
    output reg          ORIG_OR_TWOS_COMP,  // 1 to select twos complement
    output reg          REG_OR_IMM,			// 1 to select immediate value

    output reg          JUMP,				// 1 to jump
    output reg          BRANCH,				// 1 to branch if equal
    output reg          BRANCH_NE,			// 1 to branch if not equal

    output reg  [2:0]   ALU_OP,             // ALU operation select

    output reg          READ_MEM,           // 1 to read from memory
    output reg          WRITE_MEM,          // 1 to write into memory

    output reg          MEMVAL_OR_ALURES,   // 1 to select memory value, 0 to select ALU result

    input               BUSYWAIT

    );

    always @(*)
    begin


        #1; // Decoding delay
        
        // Initial values
        ORIG_OR_TWOS_COMP   = 1'b0;     // 1: twos comp
        REG_OR_IMM          = 1'b0;     // 1: immediate
        WRITE_ENABLE        = 1'b0;     // 1: enable write
        JUMP                = 1'b0;     // 1: unconditional jump
        BRANCH              = 1'b0;     // 1: branch if equal
        BRANCH_NE           = 1'b0;     // 1: branch if not equal
        READ_MEM            = 1'b0;     // 1: read from memory
        WRITE_MEM           = 1'b0;     // 1: write into memory
        MEMVAL_OR_ALURES    = 1'b0;     // 1: select memory value

        // Default ALU operation is add
        ALU_OP = 3'b000;
    
        case (OP_CODE)
    
            // ADD reg_dest, reg_read1, reg_read2
        8'd2:
        begin

            // Write enable for register file
            WRITE_ENABLE = 1'b1;
            // ALU Operation code
            ALU_OP = 3'b001;
            
        end


        // SUB reg_dest, reg_read1, reg_read2
        8'd3:
        begin
            
            // Write enable for register file
            WRITE_ENABLE = 1'b1;
            // ALU Operation code
            ALU_OP = 3'b001;
            // To choose the twos' complement value
            ORIG_OR_TWOS_COMP = 1'b1;

        end

        
        // AND reg_dest, reg_read1, reg_read2
        8'd4:
        begin

            // Write enable for register file
            WRITE_ENABLE = 1'b1;
            // ALU Operation code
            ALU_OP = 3'b010;
            
        end
        
        
        // OR reg_dest, reg_read1, reg_read2
        8'd5:
        begin
            
            // Write enable for register file
            WRITE_ENABLE = 1'b1;
            // ALU Operation code
            ALU_OP = 3'b011;
            
        end
        
        
        // MOV reg_dest, reg_read1
        8'd1:
        begin

            // Write enable for register file
            WRITE_ENABLE = 1'b1;
            // ALU Operation code
            ALU_OP = 3'b000;
            // Don't use immediate
            REG_OR_IMM = 1'b0;

        end


        // LOADI reg_dest, imm
        8'd0:
        begin

            // Write enable for register file
            WRITE_ENABLE = 1'b1;
            // ALU Operation code
            ALU_OP = 3'b000;
            // Use immediate value
            REG_OR_IMM = 1'b1;

        end
        
        
        // JUMP offset
        8'd6:
        begin
            // Not a conditional branch
            BRANCH = 1'b0;
            // Signal an unconditional jump
            JUMP = 1'b1;

            BRANCH_NE = 1'b0;
        end


        // BEQ offset, reg_dest, reg_read
        8'd7:
        begin
            // ALU performs subtraction for comparison
            ALU_OP = 3'b001;
            // Enable two's-complement path for subtraction/comparison
            ORIG_OR_TWOS_COMP = 1'b1;
            // Enable conditional branching (client of ZERO flag will use this)
            BRANCH = 1'b1;
            // Not an unconditional jump
            JUMP = 1'b0;
            // Not a bne
            BRANCH_NE = 1'b0;
        end

        
        // ror: right rotation
        8'd16:
        begin
            // ALU performs right rotation
            ALU_OP = 3'b100;
            
            // Keep original value
            ORIG_OR_TWOS_COMP = 1'b0;
            
            // Not a branch
            BRANCH = 1'b0;
            // Not a jump
            JUMP = 1'b0;
            // Not a bne
            BRANCH_NE = 1'b0;

            // Enable writing to registers
            WRITE_ENABLE = 1'b1;
            
            // Select immediate value
            REG_OR_IMM = 1'b1;

        end

        
        // BNE: Branch if not equal
        8'd17:
        begin  // BEQ - V
            // ALU performs subtraction for comparison
            ALU_OP = 3'b001;
            // Enable two's-complement path for subtraction/comparison
            ORIG_OR_TWOS_COMP = 1'b1;
            // Enable conditional branching (client of ZERO flag will use this)
            BRANCH = 1'b0;
            // Not an unconditional jump
            JUMP = 1'b0;
            
            BRANCH_NE = 1'b1;
        end


        // LWD: Load word from memory
        8'd8:          // Opcode is 8'h08 for LWD
        begin

            // ALU operation is forward to pass the address to memory            
            ALU_OP = 3'b000;

            // Enable reading from memory
            READ_MEM = 1'b1;
            
            // Enable writing to register file
            WRITE_ENABLE = 1'b1;
            
            // Select memory value to write into register file
            MEMVAL_OR_ALURES = 1'b1;
        end

        
        // LWI: Load word from memory by immediate addressing
        8'd9:          // Opcode is 8'h09 for LWI
        begin 
            
            // ALU operation is forward to pass the address
            ALU_OP = 3'b000;
            
            // Use immediate value for address calculation
            REG_OR_IMM = 1'b1; 
            
            // Enable reading from memory
            READ_MEM = 1'b1;

            // Enable writing to register file
            WRITE_ENABLE = 1'b1;
            
            // Select memory value to write into register file
            MEMVAL_OR_ALURES = 1'b1; 
            
        end

        // SWD: Store word to memory
        8'd10:          // Opcode is 8'h0A for SWD
        begin

            // ALU operation is forward to pass the address to memory            
            ALU_OP = 3'b000;
            
            // Enable writing to memory
            WRITE_MEM = 1'b1;
            
            REG_OR_IMM = 1'b0;
            
        end

        // SWI: Store word to memory
        8'd11:          // Opcode is 8'h0B for SWI
        begin

            // ALU operation is forward to pass the address to memory            
            ALU_OP = 3'b000;

            // Use immediate value for address calculation
            REG_OR_IMM = 1'b1; 

            // Enable writing to memory
            WRITE_MEM = 1'b1;
            
        end
        

        
        default:
            begin
                WRITE_ENABLE = 1'b0;        // Default: Disable write to register file
                BRANCH = 1'b0;              // Default: No branch
                JUMP = 1'b0;                // Default: No jump
                BRANCH_NE = 1'b0;           // Default: No branch if not equal
                ORIG_OR_TWOS_COMP = 1'b0;   // Default: Use original value, not two's complement
                REG_OR_IMM = 1'b0;          // Default: Use original value, not immediate
                READ_MEM = 1'b0;            // Default: No memory read
                WRITE_MEM = 1'b0;           // Default: No memory write

                ALU_OP = 3'b000;              // Default ALU operation is forward

            end
        
        endcase
    
    end
    

endmodule

