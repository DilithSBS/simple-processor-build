module alu_tb;

    reg [7:0]  OPERAND1, OPERAND2;
    reg [2:0] ALUOP;
    wire [7:0] ALURESULT;

    alu myalu(OPERAND1, OPERAND2, ALUOP, ALURESULT);

    initial
    begin
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("alu_wavedata.vcd");
        $dumpvars(0, alu_tb);

        // assign values with time to input signals to see output 

        
        // forward function
        OPERAND2 = 8'd10;
        ALUOP = 3'b000; 

        // add function
        #5
        ALUOP = 3'b001; 
        OPERAND1 = 8'd15;
        OPERAND2 = 8'd8;

        // and function
        #5
        ALUOP = 3'b010; 
        OPERAND1 = 8'd100;
        OPERAND2 = 8'd32;
        
        // or function
        #5
        ALUOP = 3'b011; 
        OPERAND1 = 8'd240;
        OPERAND2 = 8'd67;

        // Test with new operands on add function
        #5
        ALUOP = 3'b001;
        OPERAND1 = 8'd200;
        OPERAND2 = 8'd55;

        #5
        // Test invalid code
        ALUOP = 3'b100; // undefined function (expecting 8'bxxxxxxxx)

        #5
        $finish;
    end

    initial
    begin
        $monitor("Time: %g, OPERAND1: %b, OPERAND2: %b, ALUOP: %b, ALURESULT: %b", $time, OPERAND1, OPERAND2, ALUOP, ALURESULT);
    end
endmodule