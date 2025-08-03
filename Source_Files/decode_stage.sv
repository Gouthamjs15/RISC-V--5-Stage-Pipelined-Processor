module decode_stage (
    input  logic        clk, rst,         // Clock and reset
    input  logic [31:0] instruction_d1,    // 32-bit RV32I instruction
    input logic  [31:0] pc_d,
    input  logic        reg_write_c4wb,     // Register write enable from WB stage
    input  logic [31:0] write_data_c4wb,       // Data to be written back to registers from write back
    input  logic [4:0]  rd_c4wb,

    // Outputs for pipeline
    output logic [31:0] pc_IDEX,
    output logic [6:0]  opcode,           // Opcode field
    output logic [4:0]  r_d,               // Destination register
    output logic [2:0]  funct3,           // funct3 field
    output logic [4:0]  rs_1,              // Source register 1
    output logic [4:0]  src_R_2,              // Source register 2
    output logic [6:0]  funct7,           // funct7 field (R-type)
    output logic [31:0] read_data1,       // Data from rs1
    output logic [31:0] read_data2,       // Data from rs2
    output logic [31:0] registers [0:31], // Register file state
    
    // Sign-extended immediates
    output logic [31:0] imm_ext,          // Final immediate selection

    // Control Signals (Output to Next Stage)
    output logic       alu_src,
    output logic       mem_to_reg,
    output logic       reg_write_ctrl,    // Renamed to avoid conflict
    output logic       mem_read,
    output logic       mem_write,
    output logic       branch,
    output logic [1:0] alu_op

);
     logic [31:0] imm_i, imm_s, imm_b, imm_u, imm_j;

    assign pc_IDEX = pc_d;
    
    // Extract common instruction fields
    assign opcode = instruction_d1[6:0];
    assign r_d     = instruction_d1[11:7];
    assign funct3 = instruction_d1[14:12];
    assign rs_1    = instruction_d1[19:15];
    assign src_R_2    = instruction_d1[24:20];  
    assign funct7 = (opcode == 7'b0110011) ? instruction_d1[31:25] : 7'b0000000;

    // Immediate Generation (selected based on opcode)
    
    assign imm_i = {{20{instruction_d1[31]}}, instruction_d1[31:20]};
    assign imm_s = {{20{instruction_d1[31]}}, instruction_d1[31:25], instruction_d1[11:7]};
    assign imm_b = {{20{instruction_d1[31]}}, instruction_d1[7], instruction_d1[30:25], instruction_d1[11:8], 1'b0};
    assign imm_u = {instruction_d1[31:12], 12'b0};
    assign imm_j = {{12{instruction_d1[31]}}, instruction_d1[19:12], instruction_d1[20], instruction_d1[30:21], 1'b0};

    // Immediate Selection based on instruction type
    always_comb begin
        case (opcode)
            7'b0010011, 7'b0000011, 7'b1100111: imm_ext = imm_i; // I-type (addi, lw, jalr)
            7'b0100011: imm_ext = imm_s; // S-type (sw)
            7'b1100011: imm_ext = imm_b; // B-type (beq, bne)
            7'b0110111, 7'b0010111: imm_ext = imm_u; // U-type (lui, auipc)
            7'b1101111: imm_ext = imm_j; // J-type (jal)
            default: imm_ext = 32'b0;
        endcase
    end
    
              control_unit u_control_unit (
        .opcode_cu(opcode),        
        .alu_src(alu_src),      
        .mem_to_reg(mem_to_reg),
        .reg_write(reg_write_ctrl), // Avoid name conflict
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .alu_op(alu_op)
    );


      



    // Register File
    register_file rf (
        .clk(clk),
        .rst(rst),
        .reg_write_en(reg_write_c4wb),  // Comes from WB stage
        .rs1(rs_1),
        .rs2(src_R_2),
        .rd(rd_c4wb),
        .write_data(write_data_c4wb),
        .read_data1(read_data1),
        .read_data2(read_data2),
        .registers(registers)
    );

      
    

endmodule
