/*
=============================================
			Two's complement module    
=============================================
*/
module twos_complement(
		input [7:0] IN_VAL,
		output [7:0] OUT_VAL
	);

	// Calculate and assign twos complement
	assign #1 OUT_VAL = (~IN_VAL) + 1;

endmodule


