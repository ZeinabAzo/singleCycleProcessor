# 16-Bit Single-Cycle Processor in Verilog 💻⚙️

## Overview
This repository contains the RTL implementation of a custom 16-bit Single-Cycle Processor written in Verilog. The processor features a Harvard Architecture and was designed, built, and verified entirely from scratch. 

## Features & Architecture
* **Data Width:** 16-bit data and instruction words.
* **Architecture:** Harvard Architecture (Separate Data and Instruction memories).
* **Registers:** 8 General-Purpose Registers (16-bit), with `R0` acting as the Accumulator.
* **Memory:** 4K x 16-bit synchronous RAM.
* **ALU:** Custom Arithmetic Logic Unit supporting ADD, SUB, AND, OR, and NOT operations.
* **Control Flow:** Supports direct Jumps and Conditional Branching (`BRANCHZ`).

## Instruction Set Architecture (ISA)
The processor supports 16 unique instructions divided into four main categories:
* **Type A (Memory & Jump):** `LOAD`, `STORE`, `JUMP`
* **Type B (Branching):** `BRANCHZ`
* **Type C (Register Math & Data Move):** `MOVETO`, `MOVEFROM`, `ADD`, `SUB`, `AND`, `OR`, `NOT`, `NOP`
* **Type D (Immediate Math):** `ADDI`, `SUBI`, `ANDI`, `ORI`

## Testing & Verification 🛡️
The processor was verified using ModelSim. Two testing methodologies were used:
1. **The Execution Gauntlet (`tb_processor_full.v`):** A custom dependency-chain testbench that executes all 16 instructions sequentially. The result of every instruction is required for the next one to calculate correctly. The processor successfully passed 18/18 tests.
2. **Automated Judging Tool (`single_cycle_tb.v`):** A top-level testbench that loads machine code from a `.hex` file into instruction memory to verify final register states.

*(Check the `/docs` folder for detailed waveforms and the datapath schematic!)*

## How to Run (ModelSim)
1. Clone the repository.
2. Open ModelSim and add all `.v` files from the `/src` and `/test` folders to your project.
3. Compile all files.
4. To run the full gauntlet, type:
   ```bash
   vsim -voptargs="+acc" work.tb_processor
   run -all