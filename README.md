# Custom 8-Bit Educational Processor (CO2070 Architecture)

[![Verilog HDL](https://img.shields.io/badge/Language-Verilog%20HDL-blue.svg)](https://en.wikipedia.org/wiki/Verilog)
[![Simulation](https://img.shields.io/badge/Simulator-Icarus%20Verilog-green.svg)](http://iverilog.icarus.com/)
[![Waveform](https://img.shields.io/badge/Waveform-GTKWave-purple.svg)](http://gtkwave.sourceforge.net/)
[![Course](https://img.shields.io/badge/Course-CO2070%20Computer%20Architecture-orange.svg)](http://www.ce.pdn.ac.lk/)

A custom 8-bit load-store processor with 32-bit fixed-length instructions, designed and implemented in Verilog HDL. Built as part of the **CO2070 Computer Architecture** curriculum at the **Department of Computer Engineering, University of Peradeniya**.

---

## Architecture Highlights

- **Datapath Width:** 8-bit data registers, buses, and ALU operations.
- **Instruction Width:** Fixed 32-bit instruction word format.
- **Register File:** 8 general-purpose registers (`R0`–`R7`, 8 bits each) with dual asynchronous read ports and a single synchronous write-back port.
- **Memory Organization:** Two-level Harvard memory architecture with physical separation between instruction and data subsystems:
  - **Instruction Cache (ICache):** 128 Bytes (8 blocks $\times$ 16 bytes/4 instructions per block), direct-mapped, backed by a 1024-byte Instruction Memory.
  - **Data Cache (DCache):** 16 Bytes (4 blocks $\times$ 4 bytes/words per block), direct-mapped, write-allocate, write-back with dirty-line eviction managed by a 4-state Finite State Machine (`IDLE`, `MEM_READ`, `MEM_WRITE`, `UPDATE_CACHE`).
- **Control Flow:** 32-bit Program Counter (`PC`) with relative branching (`BEQ`, `BNE`) and jumping (`J`) using word-aligned sign-extended displacements (`jumped_pc = (PC + 4) + (offset << 2)`).
- **Stall Control:** Hardware busywait handshaking stalls both PC updates and register writes during cache misses.

---

## Project Structure

```
simple-processor-build/
├── rtl/
│   ├── core/
│   │   └── cpu.v                   # Core datapath and module integration
│   ├── control/
│   │   └── control_unit.v          # Opcode decoding and control signal generation
│   ├── execute/
│   │   └── alu.v                   # Modular ALU (FORWARD, ADD, AND, OR, ROR)
│   ├── registers/
│   │   └── reg_file.v              # 8x8-bit register file (R0-R7)
│   ├── branch/
│   │   ├── pc_adder.v              # Sequential PC incrementer (PC + 4)
│   │   └── jump_branch_adder.v     # Branch/jump target calculator
│   ├── common/
│   │   ├── 2to1_mux.v              # 8-bit 2-to-1 multiplexer
│   │   └── twos_complement.v      # Hardware 2's complement negation
│   └── memory/
│       ├── icache.v                # Direct-mapped instruction cache
│       ├── imem.v                  # 1024-byte backing instruction memory
│       ├── dcacheFSM.v             # 4-state write-back data cache controller
│       └── dmem_lab6.v             # 256-byte backing data memory
├── tb/
│   └── cpu_tb.v                    # System testbench integrating CPU, caches, and memory
├── tools/
│   └── assembler/
│       └── src/
│           └── CO2070Assembler.c   # C-based 2-pass assembly cross-compiler
├── tests/
│   └── simulation/                 # Simulation scripts and test programs
├── PROCESSOR_ANALYSIS_REPORT.md    # Comprehensive architectural evaluation report
├── PROCESSOR_ANALYSIS_REPORT.pdf   # Formatted printable PDF report
├── Makefile                        # Build and test automation
└── README.md                       # Project overview and documentation
```

---

## Instruction Set Architecture (ISA)

All instructions are encoded into 32-bit words partitioned into 4 bytes:
`[31:24] Opcode` | `[23:16] Destination / Offset` | `[15:8] Source 1 (RT)` | `[7:0] Source 2 / Immediate (RS/IMM)`

| Opcode | Mnemonic | Format | Operation | Description |
|:---:|:---:|:---:|:---|:---|
| `0x00` | `LOADI` | I-Type | `R[RD] = IMM` | Load 8-bit immediate value into register |
| `0x01` | `MOV` | R-Type | `R[RD] = R[RS]` | Move contents of register RS to RD |
| `0x02` | `ADD` | R-Type | `R[RD] = R[RT] + R[RS]` | Add two registers |
| `0x03` | `SUB` | R-Type | `R[RD] = R[RT] - R[RS]` | Subtract register RS from RT (via 2's complement) |
| `0x04` | `AND` | R-Type | `R[RD] = R[RT] & R[RS]` | Bitwise AND of two registers |
| `0x05` | `OR` | R-Type | `R[RD] = R[RT] \| R[RS]` | Bitwise OR of two registers |
| `0x06` | `J` | J-Type | `PC = (PC+4) + (offset << 2)` | Unconditional relative jump |
| `0x07` | `BEQ` | B-Type | `if (R[RT] == R[RS]) PC = target` | Branch if registers are equal |
| `0x08` | `LWD` | M-Type | `R[RD] = Mem[R[RS]]` | Load word from data cache (register address) |
| `0x09` | `LWI` | M-Type | `R[RD] = Mem[IMM]` | Load word from data cache (immediate address) |
| `0x0A` | `SWD` | M-Type | `Mem[R[RS]] = R[RT]` | Store word to data cache (register address) |
| `0x0B` | `SWI` | M-Type | `Mem[IMM] = R[RT]` | Store word to data cache (immediate address) |
| `0x10` | `ROR` | I-Type | `R[RD] = R[RT] >>> IMM[2:0]` | Right rotate register RT by immediate offset |
| `0x11` | `BNE` | B-Type | `if (R[RT] != R[RS]) PC = target` | Branch if registers are not equal |

*Note: Opcodes `0x0C` (`MULT`), `0x0D` (`SLL`), `0x0E` (`SRL`), and `0x0F` (`SRA`) are reserved for future implementation.*

---

## Getting Started & Simulation

### 1. Prerequisites
- [Icarus Verilog](http://iverilog.icarus.com/) (`iverilog`, `vvp`)
- [GTKWave](http://gtkwave.sourceforge.net/) (`gtkwave`)
- [GCC](https://gcc.gnu.org/) (for compiling the assembler)

### 2. Compile the Assembler
```bash
gcc tools/assembler/src/CO2070Assembler.c -o tools/assembler/CO2070Assembler.exe
```

### 3. Compile and Run the Processor Simulation
Compile all modules with include directories specified:
```bash
iverilog -I rtl/core -I rtl/execute -I rtl/registers -I rtl/control -I rtl/branch -I rtl/common -I rtl/memory -o sim/cpu_sim.vvp rtl/core/cpu.v tb/cpu_tb.v
```

Execute simulation using `vvp`:
```bash
vvp sim/cpu_sim.vvp
```

### 4. Waveform Inspection
Open the generated VCD waveform in GTKWave:
```bash
gtkwave cpu_wavedata.vcd
```

---

## Detailed Evaluation Report
For a full deep-dive architectural analysis, cycle-by-cycle instruction execution traces, RTL defect inspection, and synthesis recommendations, refer to:
- [PROCESSOR_ANALYSIS_REPORT.md](PROCESSOR_ANALYSIS_REPORT.md)
- [PROCESSOR_ANALYSIS_REPORT.pdf](PROCESSOR_ANALYSIS_REPORT.pdf)
