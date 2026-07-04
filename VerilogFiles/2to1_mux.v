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

	always @(*)
	begin
		case (SELECT)
		0:
		begin
			OUT_VAL = INPUT1;           // Select INPUT1 if SELECT is 0
		end

		1:
		begin
			OUT_VAL = INPUT2;           // Select INPUT2 if SELECT is 1

		end

		// Default to INPUT1
		default:
		begin
			OUT_VAL = INPUT1;
		end
		endcase
	end

endmodule
