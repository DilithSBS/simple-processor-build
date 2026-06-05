module cpu_tb;

    // OP-CODE list    
    `define ADD_    8'd0;
    `define SUB_    8'd1;
    `define AND_    8'd2;
    `define OR_     8'd3;
    `define J_      8'd4;
    `define BEQ_    8'd5;
    `define MOV_    8'd6;
    `define LOADI_  8'd7;

    reg [7:0]   OP_CODE;
    reg [7:0]   DEST_REG_IMM;
    reg [7:0]   SOURCE_REG_1;
    reg [7:0]   SOURCE_REG_2_IMM;


    wire [31:0] instruction;
    reg         CLK;
    wire [7:0]  pc;
    reg         RESET;


    cpu my_cpu(
        .PC(pc),
        .INSTRUCTION(instruction), 
        .CLK(CLK),
        .RESET(RESET)
    );

    
    // 32-bits wide 64 instructions (256 bytes)
    reg [31:0] instruction_memory [0:63];


    // CPU drives `pc`; testbench drives `instruction` from instruction_memory
    assign instruction = instruction_memory[pc[7:2]];

    initial begin
            
        // LOADI R1, 5
        OP_CODE = 8'd7;
        DEST_REG_IMM = 8'd1;
        SOURCE_REG_1 = 8'd0;
        SOURCE_REG_2_IMM  = 8'd5;

        instruction_memory[0] = {OP_CODE, DEST_REG_IMM, SOURCE_REG_1, SOURCE_REG_2_IMM};

        #2  // 2
        // LOADI R2, 2
        OP_CODE = 8'd7;
        DEST_REG_IMM = 8'd2;
        SOURCE_REG_1 = 8'd0;
        SOURCE_REG_2_IMM  = 8'd2;

        instruction_memory[1] = {OP_CODE, DEST_REG_IMM, SOURCE_REG_1, SOURCE_REG_2_IMM};

        #8  // 10
        // ADD R4, R1, R2
        OP_CODE = 8'd0;
        DEST_REG_IMM = 8'd4;
        SOURCE_REG_1 = 8'd1;
        SOURCE_REG_2_IMM  = 8'd2;

        instruction_memory[2] = {OP_CODE, DEST_REG_IMM, SOURCE_REG_1, SOURCE_REG_2_IMM};

        #8  // 18
        // LOADI R5, 10
        OP_CODE = 8'd7;
        DEST_REG_IMM = 8'd5;
        SOURCE_REG_1 = 8'd0;
        SOURCE_REG_2_IMM  = 8'd10;

        instruction_memory[3] = {OP_CODE, DEST_REG_IMM, SOURCE_REG_1, SOURCE_REG_2_IMM};

        #8  // 26
        // LOADI R6, 20
        OP_CODE = 8'd7;
        DEST_REG_IMM = 8'd6;
        SOURCE_REG_1 = 8'd0;
        SOURCE_REG_2_IMM  = 8'd20;

        instruction_memory[4] = {OP_CODE, DEST_REG_IMM, SOURCE_REG_1, SOURCE_REG_2_IMM};

        #8  // 34
        // SUB R7, R5, R6
        OP_CODE = 8'd1;
        DEST_REG_IMM = 8'd7;
        SOURCE_REG_1 = 8'd5;
        SOURCE_REG_2_IMM  = 8'd6;

        instruction_memory[5] = {OP_CODE, DEST_REG_IMM, SOURCE_REG_1, SOURCE_REG_2_IMM};

        #8  // 42
        // AND R3, R1, R2
        OP_CODE = 8'd2;
        DEST_REG_IMM = 8'd3;
        SOURCE_REG_1 = 8'd1;
        SOURCE_REG_2_IMM  = 8'd2;

        instruction_memory[6] = {OP_CODE, DEST_REG_IMM, SOURCE_REG_1, SOURCE_REG_2_IMM};

        #40  // 50-90: NOPs
        $finish;
    end

    initial begin
        CLK = 0;
        RESET = 1;
        #6;
        RESET = 0;
    end


    initial begin
        $dumpfile("cpu_wavedata.vcd");
        $dumpvars(0, cpu_tb);
        // Force the simulator to dump the memory array elements
        $dumpvars(0, my_cpu.my_reg_file.reg_array[0]);
        $dumpvars(0, my_cpu.my_reg_file.reg_array[1]);
        $dumpvars(0, my_cpu.my_reg_file.reg_array[2]);
        $dumpvars(0, my_cpu.my_reg_file.reg_array[3]);
        $dumpvars(0, my_cpu.my_reg_file.reg_array[4]);
        $dumpvars(0, my_cpu.my_reg_file.reg_array[5]);
        $dumpvars(0, my_cpu.my_reg_file.reg_array[6]);
        $dumpvars(0, my_cpu.my_reg_file.reg_array[7]);
    end

    initial begin
        $monitor("Time: %g, OP_CODE: %b, DEST_REG: %d SOURCE_1: %d, SOURCE_2_IMM: %d", $time, OP_CODE, DEST_REG_IMM, SOURCE_REG_1, SOURCE_REG_2_IMM);
    end

    always @(posedge CLK) begin
        $display("T=%0t PC=%0d R0=%0d R1=%0d R2=%0d R3=%0d R4=%0d R5=%0d R6=%0d R7=%0d",
            $time, pc,
            my_cpu.my_reg_file.reg_array[0],
            my_cpu.my_reg_file.reg_array[1],
            my_cpu.my_reg_file.reg_array[2],
            my_cpu.my_reg_file.reg_array[3],
            my_cpu.my_reg_file.reg_array[4],
            my_cpu.my_reg_file.reg_array[5],
            my_cpu.my_reg_file.reg_array[6],
            my_cpu.my_reg_file.reg_array[7]
        );
    end

    always begin
        #4
        CLK = ~CLK;
    end

endmodule