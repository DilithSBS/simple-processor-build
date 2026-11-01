// Computer Architecture (CO2070) - Lab 03
// Design: Testbench of Integrated CPU of Simple Processor
// Author: Isuru Nawinne

`timescale 1ns/100ps

`include "rtl/core/cpu.v"
`include "rtl/memory/dmem.v"
`include "rtl/memory/dcacheFSM.v"
`include "rtl/memory/imem.v"
`include "rtl/memory/icache.v"


module cpu_tb;

    reg CLK, RESET;
    wire 	[31:0] 	PC;
    wire 	[31:0] 	INSTRUCTION;

    wire 	[7:0]  	MEM_ADDRESS;
    wire        	MEM_RD, MEM_WR;
    wire 	[7:0] 	MEM_WRITE_DATA;
    wire 	[7:0] 	MEM_READ_DATA;
    wire 			    BUSYWAIT;

    wire  [5:0]   MEM_ADDRESS_MEM;
    wire        	MEM_RD_MEM, MEM_WR_MEM;
    wire 	[31:0] 	MEM_WRITE_DATA_MEM;
    wire 	[31:0] 	MEM_READ_DATA_MEM;
    wire 			    BUSYWAIT_MEM;


    wire        	I_RD;
    wire        	IMEM_RD;


    wire        	I_BUSYWAIT;
    wire        	IMEM_BUSYWAIT;

    wire [5:0]    IMEM_ADDRESS;
    wire [127:0]  IMEM_READDATA;

    /*
    ------------------------
    SIMPLE INSTRUCTION MEM
    ------------------------
    */

    // TODO: Initialize an array of registers (8x1024) named 'instr_mem' to be used as instruction memory
    // reg [7:0] instr_mem [0:1023];

    // Instruction Memory instantiation
    instruction_memory my_imem(
        .clock(CLK),
        .read(IMEM_RD),
        .address(IMEM_ADDRESS),
        .readinst(IMEM_READDATA),
        .busywait(IMEM_BUSYWAIT)
    );

    instruction_cache my_icache(
        .clock(CLK),
        .reset(RESET),
        .PC(PC),
        .inst_read(INSTRUCTION),
        .busywait(I_BUSYWAIT),
        .read(I_RD),
        
        .imem_address(IMEM_ADDRESS),
        .imem_readdata(IMEM_READDATA),
        .imem_read(IMEM_RD),
        .imem_busywait(IMEM_BUSYWAIT)
    );

/*
==================
        CPU
==================
*/
    cpu mycpu(
      .PC(PC),
      .INSTRUCTION(INSTRUCTION),
      .CLK(CLK),
      .RESET(RESET),
      .MEM_ADDR(MEM_ADDRESS),
      .MEM_RD(MEM_RD),
      .MEM_WR(MEM_WR),
      .MEM_WRITE_DATA(MEM_WRITE_DATA),
      .MEM_READ_DATA(MEM_READ_DATA),
      .BUSYWAIT(BUSYWAIT),

      .ICACHE_BUSYWAIT(I_BUSYWAIT),
      .ICACHE_READ(I_RD)

    );

/*
==================
    DATA CACHE
==================
*/
    dcache my_dcache(

        // CPU side signals
            .clock(CLK),
            .reset(RESET),
            .address(MEM_ADDRESS),
            .read(MEM_RD),
            .write(MEM_WR),
            .writedata(MEM_WRITE_DATA),
            .readdata(MEM_READ_DATA),
            .busywait(BUSYWAIT),

        // Memory side signals
            .mem_address(MEM_ADDRESS_MEM),
            .mem_read(MEM_RD_MEM),
            .mem_write(MEM_WR_MEM),
            .mem_writedata(MEM_WRITE_DATA_MEM),
            .mem_readdata(MEM_READ_DATA_MEM),
            .mem_busywait(BUSYWAIT_MEM)
    );

/*
==================
    DATA MEMORY
==================
*/
    data_memory my_dmem (
            .clock(CLK),
            .reset(RESET),
            .read(MEM_RD_MEM),
            .write(MEM_WR_MEM),
            .address(MEM_ADDRESS_MEM),
            .writedata(MEM_WRITE_DATA_MEM),
            .readdata(MEM_READ_DATA_MEM),
            .busywait(BUSYWAIT_MEM)
        );

  // TODO: Create combinational logic to support CPU instruction fetching, given the Program Counter(PC) value
  //       (make sure you include the delay for instruction fetching here)


  // assign #2 INSTRUCTION = {instr_mem[PC+3], instr_mem[PC+2], instr_mem[PC+1], instr_mem[PC]};

    // initial
    // begin
    // Initialize instruction memory with the set of instructions you need execute on CPU

    // METHOD 1: manually loading instructions to instr_mem
    // {instr_mem[10'd3], instr_mem[10'd2], instr_mem[10'd1], instr_mem[10'd0]} = 32'b00000000_00000100_00000000_00000101;
    // {instr_mem[10'd7], instr_mem[10'd6], instr_mem[10'd5], instr_mem[10'd4]} = 32'b00000000_00000010_00000000_00001001;
    // {instr_mem[10'd11], instr_mem[10'd10], instr_mem[10'd9], instr_mem[10'd8]} = 32'b00000010000001100000010000000010;

    // METHOD 2: loading instr_mem content from instr_mem.mem file
    // $readmemb("../tests/mem/instr_mem.mem", instr_mem);
    // end



  initial
  begin

    // generate files needed to plot the waveform using GTKWave

    $dumpfile("tests/wavedata/cpu_wavedata.vcd");
    $dumpvars(0, cpu_tb);

    // Force the simulator to dump the memory array elements
	for (integer i = 0; i < 8; i = i + 1) begin
		$dumpvars(0, mycpu.my_reg_file.reg_array[i]);
	end

	// Force the simulator to dump the memory array elements
	for (integer i = 0; i < 256; i = i + 1) begin
		$dumpvars(0, my_dmem.memory_array[i]);
	end

	// Force the simulator to dump the instruction cache array elements
	for (integer i = 0; i < 8; i = i + 1) begin
		$dumpvars(0, my_icache.data_array[i]);
		$dumpvars(0, my_icache.tag_array[i]);
		$dumpvars(0, my_icache.valid_array[i]);
	end

    CLK = 1'b0;

    // TODO: Reset the CPU (by giving a pulse to RESET signal) to start the program execution
    RESET = 1'b1;
    #6;
    RESET = 1'b0;

    // finish simulation after some time
    #30000
     $finish;

  end

  // clock signal generation
  always
    #4 CLK = ~CLK;

  always @(posedge CLK) begin
    $display("t=%0d PC=%d INSTR=%b zero=%b jump=%b branch=%b branch_ne=%b jumped_pc=%d next_pc=%d", $time, PC, INSTRUCTION, mycpu.zero, mycpu.jump, mycpu.branch, mycpu.branch_ne, mycpu.jumped_pc, mycpu.next_pc);
  end

endmodule
