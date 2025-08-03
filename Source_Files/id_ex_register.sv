module id_ex_register (
    input  logic        clk,
    input  logic        rst,   // Write enable (for stalling, etc.)
    // Inputs from Decode Stage:
    input  logic [31:0] pc_in,
    input  logic [31:0] read_data1_in,
    input  logic [31:0] read_data2_in,
    input  logic [31:0] imm_ext_in,
    input  logic [6:0]  opcode_in,
    input  logic [4:0]  rd_in,
    input  logic [2:0]  funct3_in,
    input  logic [6:0]  funct7_in,
    input  logic [4:0]  rs1_in,
    input  logic [4:0]  rs2_in,
    // Control signals from the decode stage:
    input  logic        alu_src_in,
    input  logic        mem_to_reg_in,
    input  logic        reg_write_in,
    input  logic        mem_read_in,
    input  logic        mem_write_in,
    input  logic        branch_in,
    input  logic [1:0]  alu_op_in,
    // stalling 
    input logic         stall,
    // Outputs to the Execution Stage:
    output logic [31:0] pc_out,
    output logic [31:0] read_data1_out,
    output logic [31:0] read_data2_out,
    output logic [31:0] imm_ext_out,
    output logic [6:0]  opcode_out,
    output logic [4:0]  rd_out,
    output logic [2:0]  funct3_out,
    output logic [6:0]  funct7_out,
    output logic [4:0]  rs1_out,
    output logic [4:0]  rs2_out,
    output logic        alu_src_out,
    output logic        mem_to_reg_out,
    output logic        reg_write_out,
    output logic        mem_read_out,
    output logic        mem_write_out,
    output logic        branch_out,
    output logic [1:0]  alu_op_out,
    
    // extra signals ======================
    
        // Additional Inputs:
    input  logic        flush          // Pipeline flush (for control hazards)

);

  // On reset, initialize all outputs to 0.
  // Otherwise, if id_ex_write is enabled, latch the inputs.
      always_ff @(posedge clk or posedge rst) begin
        if (rst || flush) begin // Reset or flush clears the pipeline
            read_data1_out  <= 32'b0;
            read_data2_out  <= 32'b0;
            imm_ext_out     <= 32'b0;
            opcode_out      <= 7'b0;
            rd_out          <= 5'b0;
            funct3_out      <= 3'b0;
            funct7_out      <= 7'b0;
            rs1_out         <= 5'b0;
            rs2_out         <= 5'b0;
            alu_src_out     <= 1'b0;
            mem_to_reg_out  <= 1'b0;
            reg_write_out   <= 1'b0;
            mem_read_out    <= 1'b0;
            mem_write_out   <= 1'b0;
            branch_out      <= 1'b0;
            alu_op_out      <= 2'b0;
            pc_out          <= 32'b0;
        end else if (stall) begin
            read_data1_out  <= read_data1_out ;
            read_data2_out  <= read_data2_out;
            imm_ext_out     <= imm_ext_out   ;
            opcode_out      <= opcode_out    ;
            rd_out          <= rd_out        ;
            funct3_out      <= funct3_out    ;
            funct7_out      <= funct7_out    ;
            rs1_out         <= rs1_out       ;
            rs2_out         <= rs2_out       ;
            alu_src_out     <= alu_src_out   ;
            mem_to_reg_out  <= mem_to_reg_out;
            reg_write_out   <= reg_write_out ;
            mem_read_out    <= mem_read_out  ;
            mem_write_out   <= mem_write_out ;
            branch_out      <= branch_out    ;
            alu_op_out      <= alu_op_out    ;
            pc_out          <= pc_out        ;
        end else begin
            read_data1_out  <= read_data1_in;
            read_data2_out  <= read_data2_in;
            imm_ext_out     <= imm_ext_in;
            opcode_out      <= opcode_in;
            rd_out          <= rd_in;
            funct3_out      <= funct3_in;
            funct7_out      <= funct7_in;
            rs1_out         <= rs1_in;
            rs2_out         <= rs2_in;
            alu_src_out     <= alu_src_in;
            mem_to_reg_out  <= mem_to_reg_in;
            reg_write_out   <= reg_write_in;
            mem_read_out    <= mem_read_in;
            mem_write_out   <= mem_write_in;
            branch_out      <= branch_in;
            alu_op_out      <= alu_op_in;
            pc_out          <= pc_in;  // Forward PC
        end
    end


endmodule
