# ==============================================================================
# Makefile for CO2070 Simple Processor Build & Simulation
# ==============================================================================

# Tools
IVERILOG = iverilog
VVP      = vvp
GTKWAVE  = gtkwave
GCC      = gcc

# Directories
RTL_DIR    = rtl
TB_DIR     = tb
SIM_DIR    = sim
TOOLS_DIR  = tools
TESTS_DIR  = tests
MEM_GEN    = $(TOOLS_DIR)/memory-generator

# Include search directories for Verilog compiler
INC_DIRS = -I $(RTL_DIR)/core \
           -I $(RTL_DIR)/execute \
           -I $(RTL_DIR)/registers \
           -I $(RTL_DIR)/control \
           -I $(RTL_DIR)/branch \
           -I $(RTL_DIR)/common \
           -I $(RTL_DIR)/memory

# Sources & Prerequisites
RTL_SRCS = $(wildcard $(RTL_DIR)/*/*.v)
TB_SRC   = $(TB_DIR)/cpu_tb.v
ASM_SRC  = $(TOOLS_DIR)/assembler/src/CO2070Assembler.c
ASM_BIN  = $(TOOLS_DIR)/assembler/CO2070Assembler.exe

# Output Artifacts
VVP_OUT  = $(SIM_DIR)/cpu_sim.vvp
VCD_OUT  = cpu_wavedata.vcd
MEM_IMG  = tests/mem/instr_mem.mem

# Default program to assemble if none is specified
PROG ?= programs/fibbo_mem.s

.PHONY: all compile run sim wave asm prog clean help

# Default target: compile and run simulation
all: sim

# Compile the Verilog testbench into VVP simulation binary
# Automatically re-compiles if any RTL or testbench file is modified
compile: $(VVP_OUT)

$(VVP_OUT): $(TB_SRC) $(RTL_SRCS)
	@if not exist $(SIM_DIR) mkdir $(SIM_DIR)
	$(IVERILOG) $(INC_DIRS) -o $(VVP_OUT) $(TB_SRC)

# Compile the C Assembler
asm: $(ASM_BIN)

$(ASM_BIN): $(ASM_SRC)
	$(GCC) $(ASM_SRC) -o $(ASM_BIN)

# Generate memory image from assembly program
# Usage: make prog [PROG=programs/fibbo_mem.s]
$(MEM_IMG): asm
	call $(MEM_GEN)/generate_memory_image.bat $(PROG) $(MEM_IMG)

prog: asm
	call $(MEM_GEN)/generate_memory_image.bat $(PROG) $(MEM_IMG)

# Run simulation (ensures instr_mem.mem exists)
run: $(VVP_OUT) $(MEM_IMG)
	$(VVP) $(VVP_OUT)

# Compile and run
sim: compile run

# View waveform in GTKWave
wave: $(VCD_OUT)
	$(GTKWAVE) $(VCD_OUT)

# Clean build artifacts
clean:
	@if exist $(SIM_DIR)\*.vvp del /q $(SIM_DIR)\*.vvp
	@if exist $(VCD_OUT) del /q $(VCD_OUT)
	@if exist $(subst /,\,$(MEM_IMG)) del /q $(subst /,\,$(MEM_IMG))
	@if exist instr_mem.mem del /q instr_mem.mem
	@echo Clean completed.

# Help menu
help:
	@echo ==============================================================================
	@echo  CO2070 Processor Build Automation
	@echo ==============================================================================
	@echo  make           : Compile and execute simulation
	@echo  make compile   : Compile Verilog testbench into sim/cpu_sim.vvp
	@echo  make run       : Run the compiled simulation
	@echo  make wave      : Open simulation waveform in GTKWave
	@echo  make asm       : Compile the C assembler (CO2070Assembler.exe)
	@echo  make prog PROG=path/to/file.s : Assemble program and generate instr_mem.mem
	@echo  make clean     : Remove simulation outputs and temporary files
	@echo ==============================================================================
