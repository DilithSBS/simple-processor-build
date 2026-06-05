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
        OPERAND1 = 8'd15;
        OPERAND2 = 8'd10;
        ALUOP = 3'b000; // forward

        #5
        ALUOP = 3'b001; // add

        #5
        ALUOP = 3'b010; // and

        #5
        ALUOP = 3'b011; // or

        #5
        $finish;
    end
endmodule