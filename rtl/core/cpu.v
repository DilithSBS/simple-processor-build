/*
=========== OPCODE DEFINITIONS: ==============
	* 00000000 (0x00) - LOADI	: Load immediate value to register
	* 00000001 (0x01) - MOV 	: Move register to register
	* 00000010 (0x02) - ADD 	: Add two registers
	* 00000011 (0x03) - SUB 	: Subtract two registers
	* 00000100 (0x04) - AND 	: Bitwise AND of two registers
	* 00000101 (0x05) - OR 		: Bitwise OR of two registers
	* 00000110 (0x06) - J 		: Unconditional jump
	* 00000111 (0x07) - BEQ 	: Branch if equal
	* 00001000 (0x08) - LWD 	: Load word direct
	* 00001001 (0x09) - LWI 	: Load word immediate
	* 00001010 (0x0A) - SWD 	: Store word direct
	* 00001011 (0x0B) - SWI 	: Store word immediate
	* 00001100 (0x0C) - MULT 	: Multiply two registers
	* 00001101 (0x0D) - SLL 	: Shift left logical
	* 00001110 (0x0E) - SRL 	: Shift right logical
	* 00001111 (0x0F) - SRA 	: Shift right arithmetic
	* 00010000 (0x10) - ROR 	: Rotate right
	* 00010001 (0x11) - BNE 	: Branch if not equal
*/

//========== CONTROL SIGNAL ENCODING ==========
/*
============ * ALUOP Encoding: =================
	* 000 - Forward (pass-through for MOV/LOADI)
	* 001 - Add/Subtract operation
	* 010 - Bitwise AND
	* 011 - Bitwise OR
	* 100 - Rotate right ROR
*/


/*
====================================================
			External Module Importing
====================================================
*/

`include "alu.v"
`include "reg_file.v"
`include "control_unit.v"
`include "pc_adders.v"
`include "2to1_mux.v"
`include "twos_complement.v"



module cpu (
		PC,
		INSTRUCTION,
		CLK,
		RESET,
		MEM_ADDR,
		MEM_RD,
		MEM_WR,
		MEM_WRITE_DATA,
		MEM_READ_DATA,
		BUSYWAIT
	);
	/*
	=============================================
					Port Declarations
	=============================================
	*/
	input               CLK,RESET;          // For PC and the reg_file
	input       [31:0]  INSTRUCTION;        // Instruction to be executed

	input       [7:0]   MEM_READ_DATA;      // Data read from memory
	input 		        BUSYWAIT;           // Busywait control flag to indicate memory is busy due to read or write operation

	output 		[7:0]   MEM_ADDR;           // Memory address to read or write
	output 			    MEM_RD, MEM_WR;     // Read or write memory control flag
	output 		[7:0]   MEM_WRITE_DATA;     // Data to written into memory


	// adder ports
	output  reg [31:0]  PC;                 // Program Counter
	wire        [31:0]  next_pc;            // next_pc = PC + 4

	// jump_branch_adder ports
	wire        [31:0]  jumped_pc;          // jumped_pc = next_pc + offset
	wire        [7:0]   offset;             // Offset to be added to PC

	// control_unit ports
	wire        [7:0]   op_code;            // Op-code of the instruction
	wire                jump;               // 1 if a jump instruction
	wire                branch;             // 1 if a branch instruction
	wire                branch_ne;          // 1 if a branch_ne instruction


	//reg_file ports
	wire                write_enable;       // 1 if register file is to be written
	wire        [2:0]   write_reg;          // register destination
	wire        [2:0]   read_reg_1;         // register source 1
	wire        [2:0]   read_reg_2;         // register source 2

	wire        [7:0]   write_val;          // Output of mux3 to be written into the register file

	wire        [7:0]   regout1;            // reg_read1 output
	wire        [7:0]   regout2;            // reg_read2 output


	// twos_complement ports
	wire        [7:0]   twos_in_val;             // Input to twos_complement module

	// mux1 ports
	wire        [7:0]   twos_comp_res;      // Result of twos_complement module
	wire                reg2_or_twos_comp;  // 1 if twos_complement is to be used


	// mux2 ports
	wire        [7:0]   mux1_res;           // Result of mux1
	wire        [7:0]   immediate;          // Immediate value
	wire                reg_or_imm;         // 1 if immediate is to be used


	// ALU ports
	wire        [7:0]   alu_op_1;           // reg_read1
	wire        [7:0]   alu_op_2;           // reg_read2 or twos_complement result or immediate value
	wire        [2:0]   select;             // ALU operation select
	wire        [7:0]   alu_result;         // Result of ALU operation
	wire                zero;               // 1 if ALU result is zero


	// mux3 ports
	wire                memval_or_alures;  // 1 if memory value is to be used, 0 if ALU result is to be used


	/*
	=============================================
				External Module Instantiation      
	=============================================
	*/

	pc_adder my_pc_adder(
			.PC_IN(PC),
			.PC_OUT(next_pc)
		);

	jump_branch_adder my_jump_branch_adder (
			.NEXT_PC(next_pc),
			.OFFSET(offset),
			.JUMPED_PC(jumped_pc)
		);


	twos_complement my_twos_complement(
						.IN_VAL(twos_in_val),
						.OUT_VAL(twos_comp_res)
					);

	control_unit my_control_unit(
					.OP_CODE(op_code),
					.WRITE_ENABLE(write_enable),
					.ORIG_OR_TWOS_COMP(reg2_or_twos_comp),
					.REG_OR_IMM(reg_or_imm),
					.ALU_OP(select),
					.JUMP(jump),
					.BRANCH(branch),
					.BRANCH_NE(branch_ne),
					.READ_MEM(MEM_RD),
					.WRITE_MEM(MEM_WR),
					.MEMVAL_OR_ALURES(memval_or_alures),
					.BUSYWAIT(BUSYWAIT)
				);

	alu my_alu(
			.DATA1(alu_op_1),
			.DATA2(alu_op_2),
			.SELECT(select),
			.RESULT(alu_result),
			.ZERO(zero)
		);

	// Register file instantiation
	reg_file my_reg_file (
				.IN(write_val),
				.INADDRESS(write_reg),
				.OUT1ADDRESS(read_reg_1),
				.OUT2ADDRESS(read_reg_2),
				.OUT1(regout1),
				.OUT2(regout2),
				.WRITE(write_enable),  // Write enable is active only when not busy
				.CLK(CLK),
				.RESET(RESET)
			);

	// Twos complement and immediate value selection using 2-to-1 multiplexers
	mux_2to1 my_mux_1 (
				.INPUT1(regout2),
				.INPUT2(twos_comp_res),
				.SELECT(reg2_or_twos_comp),
				.OUT_VAL(mux1_res)
			);

	// Selecting between the output of mux1 and the immediate value using another 2-to-1 multiplexer
	mux_2to1 my_mux_2 (
				.INPUT1(mux1_res),
				.INPUT2(immediate),
				.SELECT(reg_or_imm),
				.OUT_VAL(alu_op_2)
			);

	// Selecting between the output of the ALU and the data read from memory using another 2-to-1 multiplexer
	mux_2to1 my_mux_3 (
				.INPUT1(alu_result),
				.INPUT2(MEM_READ_DATA),
				.SELECT(memval_or_alures),
				.OUT_VAL(write_val)
			);

	/*
	=============================================
				Decoding an instruction      
	=============================================
	*/

	// derive immediate and twos-complement input
	assign twos_in_val = regout2;

	// Immediate for loadi and ror
	assign immediate = INSTRUCTION[7:0];

	// Offset of Jump or BEQ or BNE
	assign offset = INSTRUCTION[23:16];


	// Decode the instruction
	// OP_CODE
	assign op_code    = INSTRUCTION[31:24];
	// DESTINATION_REG
	assign write_reg  = INSTRUCTION[18:16];

	// SOURCE_REG_1
	assign read_reg_1 = INSTRUCTION[10:8];
	// SOURCE_REG_2
	assign read_reg_2 = INSTRUCTION[2:0];

	// ALU input 1 is always regout1
	assign alu_op_1 = regout1;

	// Data to be written into memory
	assign MEM_WRITE_DATA = regout1;

	// Memory address is the result of the ALU operation
	assign MEM_ADDR = alu_result;




	always @(posedge CLK)
	
	begin
		if (RESET == 1)
		begin
			#1 PC <= 32'b0;
		end

		else if (BUSYWAIT != 1'b1) // Update PC only when not busy
		begin

			// Select jumped_pc if it is a jump instruction or a beq instruction or a bne instruction
			if ((jump == 1'b1) || ((branch == 1'b1) && (zero == 1'b1)) || ((branch_ne == 1'b1) && (zero == 1'b0)))
				#1 PC <= jumped_pc;

			// Else select pc+4
			else
				#1 PC <= next_pc;
		end
	end


endmodule
