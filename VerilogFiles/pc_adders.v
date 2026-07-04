/*
=============================================
				ADDER MODULE      
=============================================
*/

// Adder module to calculate next PC
module pc_adder (
		input   [31:0]  PC_IN,
		output  [31:0]  PC_OUT
	);

	// Calculate PC + 4
	assign #1 PC_OUT = PC_IN + 32'd4;

endmodule

/*
=============================================
			JUMP-BRANCH ADDER MODULE      
=============================================
*/

// Adder module to calculate next PC
module jump_branch_adder (
		input   [31:0]  NEXT_PC,     // Next PC calculated by adder
		input   [7:0]   OFFSET,      // Jump offset
		output  [31:0]  JUMPED_PC    // jumped PC
	);

	// Sign extend the offset
	wire [31:0] sign_ext_offset;

	// Adding the MSB of the offset to the remaining bits to make it 32 bits
	assign sign_ext_offset = {{24{OFFSET[7]}}, OFFSET};

	// Branch / jump logic
	assign #2 JUMPED_PC = NEXT_PC + (sign_ext_offset << 2);

endmodule