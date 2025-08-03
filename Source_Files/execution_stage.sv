`timescale 1ns/1ps
module execution_stage(
    input  logic clk,
    input logic rst,
    input logic [31:0] pc,
    // Data and control signals from the ID/EX pipeline register
    input  logic [31:0] read_data1,  // Operand A from register file
    input  logic [31:0] read_data2,  // Operand B from register file
    input  logic [31:0] imm_ext,       // Immediate value (I-type)
    input  logic [6:0]  opcode,
    input  logic [4:0]  rd_e,
    input  logic [4:0]  rs1,
    input  logic [4:0]  rs2,
    input  logic mem_to_reg,
    input  logic reg_write,
    input  logic mem_read,
    input  logic mem_write,
    input  logic branch, 
    input  logic        alu_src,     // Control signal: 1 = use immediate, 0 = use read_data2
    input  logic [1:0]  alu_op,      // High-level ALU operation from control unit
    input  logic [2:0]  funct3,      // Function field from instruction
    input  logic [6:0]  funct7,      // Function field from instruction
    
    //=========================================
    input logic [1:0] forward_a,
    input logic [1:0] forward_b,
    input logic [31:0] ex_mem_alu_result,
    input logic [31:0] mem_wb_data,
    

    // Outputs to the next pipeline stage (e.g., MEM)
    output logic [31:0] alu_result,  // Result computed by the ALU
    output logic        alu_zero,    // Zero flag from the ALU
    output logic error_flag,
    output logic [31:0] r1,r2,r3,
    // Optional: output the detailed ALU control for debugging
    output logic [3:0]  alu_control_out,
    // output to next stage (mem stage)
    output  logic [6:0]  opcode_m,   
    output  logic [4:0]  rd_m,       
    output  logic  [4:0]  rs1_m,     
    output  logic  [4:0]  rs2_m,     
    output  logic mem_to_reg_m,      
    output  logic reg_write_m,       
    output  logic mem_read_m,        
    output  logic mem_write_m,       
    output  logic branch_m,
    output  logic [31:0] read_data2_m,
    
    output logic branch_taken,
    output logic [31:0] branch_target,
    output logic branch_condition_met
         

);

        //forwading to next stage 
        assign mem_to_reg_m = mem_to_reg;
        assign reg_write_m =  reg_write;
        assign mem_read_m = mem_read;
        assign mem_write_m = mem_write;
        assign rd_m = rd_e;
        assign rs1_m = rs1;
        assign rs2_m = rs2;
        assign opcode_m = opcode;
        assign branch_m = branch;


//==================================branch_code======================================================


   

always_comb begin
    case (funct3)
        3'b000: branch_condition_met = (read_data1 == read_data2);                     // beq
        3'b001: branch_condition_met = (read_data1 != read_data2);                     // bne
        3'b100: branch_condition_met = ($signed(read_data1) < $signed(read_data2));    // blt
        3'b101: branch_condition_met = ($signed(read_data1) >= $signed(read_data2));   // bge
        3'b110: branch_condition_met = (read_data1 < read_data2);                      // bltu
        3'b111: branch_condition_met = (read_data1 >= read_data2);                     // bgeu
        default: branch_condition_met = 1'b0;
    endcase
end

    assign branch_taken = branch && branch_condition_met;
    assign branch_target = pc + imm_ext;



//============================================================================================================


            // from forwarding unit
           
            logic [31:0] alu_input_a;
            logic [31:0] alu_input_b;
            logic [31:0] forwarded_b;
            
    always_comb begin

            alu_input_a = read_data1;
            forwarded_b = read_data2;

    case (forward_a)
        2'b00: alu_input_a = read_data1;        // from ID/EX
        2'b10: alu_input_a = ex_mem_alu_result;   // from EX/MEM
        2'b01: alu_input_a = mem_wb_data;         // from MEM/WB
        default: alu_input_a = alu_input_a;
    endcase


     
    case (forward_b)
        2'b00: forwarded_b=  forwarded_b;        // from ID/EX
        2'b10: forwarded_b= ex_mem_alu_result;   // from EX/MEM
        2'b01: forwarded_b= mem_wb_data;         // from MEM/WB
        default: forwarded_b= forwarded_b;
    endcase
    
    alu_input_b = (alu_src) ? imm_ext : forwarded_b;
end

    
    
        





    // Internal signals
    logic [3:0] alu_control;     // Detailed ALU control signal

    // Instantiate ALU Control Unit
    alu_control u_acu (
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7(funct7),
        .alu_control(alu_control)
    );

    // Instantiate ALU
    fault_tolerant_alu u_fault_tolerant_alu(
        .operand_a(alu_input_a),
        .operand_b(alu_input_b),
        .alu_control(alu_control),
        .result(alu_result),
        .error_flag(error_flag),
        .r1(r1),
        .r2(r2),
        .r3(r3)
    );

    // Optional: pass the detailed ALU control to an output for debugging
    assign alu_control_out = alu_control;
    assign read_data2_m = forwarded_b;
   



endmodule
