**5-Stage Pipelined RISC-V Processor (RV32I)**

This repository contains my academic project implementing a 5-stage pipelined RISC-V RV32I processor in SystemVerilog, designed for simulation and synthesis using Xilinx Vivado. The processor is built to demonstrate core CPU architecture concepts such as pipelining, hazard detection, and data forwarding, along with enhanced reliability using fault tolerance.

5-Stage Pipelined Architecture
1. IF – Instruction Fetch
2. ID - Instruction Decode
3. EX – Execute
4. MEM – Memory Access
5. WB – Write Back

Between each of these stages, there will be pipelined Registers
and aslo other modules are there :
6. Hazard Handling
7. Load-use hazard detection
8. Data forwarding unit to minimize pipeline stalls

**Fault-Tolerant ALU**

Implements Triple Modular Redundancy (TMR) to ensure reliable execution of arithmetic and logic operations
Designed for edge AI and aerospace use-cases where error resilience is essential
Custom SystemVerilog testbenches for functional verification of instruction execution and hazard behavior

Tools & Technologies
SystemVerilog – Hardware Description Language (HDL)
Xilinx Vivado – Used for simulation and synthesis

**Highlights**
Developed as part of academic coursework to demonstrate core principles of computer architecture
Emphasis on both functionality and reliability through pipelining and fault-tolerant design
Modular design for easy extension with more instructions or stages
