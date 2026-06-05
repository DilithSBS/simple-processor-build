module alu(

    input [7:0] DATA1, DATA2,
    input [2:0] SELECT,
    output  [7:0] RESULT
);
wire [7:0] and_result, or_result, add_result, forward_result; // intermediate variables to hold the results of the and, or, add and forward modules



forward mux_forward(.DATA1(DATA1), .DATA2(DATA2), .RESULT(forward_result)); // athule thiyena ekkena thamai .data1, forward result is the intermediate variable, sort of a wire. connects the output of the forward module tot the input of the mux
my_add mux_add(.DATA1(DATA1), .DATA2(DATA2), .RESULT(add_result));
my_and mux_and(.DATA1(DATA1), .DATA2(DATA2), .RESULT(and_result));
my_or mux_or(.DATA1(DATA1), .DATA2(DATA2), .RESULT(or_result));

mux4to1 alu_mux(.DATA1(forward_result), .DATA2(add_result), .DATA3(and_result), .DATA4(or_result), .SELECT(SELECT), .RESULT(RESULT)); // connects the output of the forward module to the input of the mux, and the output of the mux to the output of the alu
endmodule


module my_and(
    input [7:0] DATA1, DATA2,
    output [7:0] RESULT
);
assign #1 RESULT = DATA1 & DATA2;
endmodule

module my_add(
    input [7:0] DATA1, DATA2,
    output  [7:0] RESULT
);
assign #2 RESULT = DATA1 + DATA2;
endmodule


module forward(
    input [7:0] DATA1, DATA2,
    output  [7:0] RESULT
);
assign #1 RESULT = DATA2;
endmodule

module my_or(
    input [7:0] DATA1, DATA2,
    output  [7:0] RESULT
);
assign #1 RESULT = DATA1 | DATA2;
endmodule


module mux4to1(
    input [7:0] DATA1, DATA2, DATA3, DATA4,
    input [2:0] SELECT,
    output reg [7:0] RESULT
);
    always @(*) begin
        case(SELECT)
            3'b000: RESULT = DATA1;
            3'b001: RESULT = DATA2;
            3'b010: RESULT = DATA3;
            3'b011: RESULT = DATA4;
            default RESULT = 8'bxxxxxxxx; // x is for low impedance
        endcase
    end
endmodule