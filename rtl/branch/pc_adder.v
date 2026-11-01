/*
=============================================
				ADDER MODULE      
=============================================
*/

`timescale 1ns/100ps

// Adder module to calculate next PC
module pc_adder (
		input   [31:0]  PC_IN,
		output  [31:0]  PC_OUT
	);

	// Calculate PC + 4
	assign #1 PC_OUT = PC_IN + 32'd4;

endmodule