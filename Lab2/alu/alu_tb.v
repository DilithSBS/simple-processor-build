module testbench;
    reg [7:0] OPERAND1, OPERAND2;
    reg [2:0] ALUOP;
    wire [7:0] ALURESULT;

    alu myalu(OPERAND1, OPERAND2, ALUOP, ALURESULT);

    initial
    begin

        // Forward 7 into result
        ALUOP = 3'b000;
        OPERAND2 = 8'b00000111;

        // Add: 5 + 3
        #5
        ALUOP = 3'b001;
        OPERAND1 = 8'b00000101;
        OPERAND2 = 8'b00000011;

        // Sub: 6 - 2
        // #5
        // ALUOP = 3'b001;
        // OPERAND1 = 8'b00000110;
        // OPERAND2 = 8'b00000010;
        

        // And: 101 & 001
        #5
        ALUOP = 3'b010;
        OPERAND1 = 8'b00000101;
        OPERAND2 = 8'b00000001;

        // Or: 1101 & 1011
        #5
        ALUOP = 3'b011;
        OPERAND1 = 8'b00001101;
        OPERAND2 = 8'b00001011;
    end


    initial
    begin
        
        $monitor("Time = %g, ALUOP = %b, OP1 = %b, OP2 = %b, RES = %b", $time, ALUOP, OPERAND1, OPERAND2, ALURESULT);
        #50 
        $finish;
    end


    initial
    begin
    
        $dumpfile("alu_wd.vcd");
        $dumpvars(0, testbench);
    
    end

endmodule