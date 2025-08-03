module cpu(
    input  logic clk,
    input  logic rst,
    output logic [31:0] registers [0:31],  // register file contents 
    output logic        alu_zero ,
    output logic error_flag,
    output logic [31:0] r3,r2,r1,
    output logic [31:0] alu_result1
);

  // -----------------------------------------------------------------------------------------------------------------------
  // ========================================================================================Instruction Fetch (IF) Stage
  // ------------------------------------------------------------------------------------------------------------------------------------
  
  logic stall_pipeline;
  logic pc_write;
  logic if_id_write;

  // Fetched instruction pipeline register
  logic [63:0] if_id;  
  logic [127:0] id_ex; 

  logic [63:0] control_signals, data_fields;
  
  
  logic [31:0] pc;
  logic [31:0] pc_internal; 
  logic [31:0] branch_target;
  logic        branch_taken;
  logic [31:0] instruction;
  logic [31:0] pc_next;

  instruction_fetch u_if (
      .clk(clk),
      .rst(rst),
      .stall(stall_pipeline),    
      .branch_target(branch_target),
      .branch_taken(branch_taken),
      .pc(pc),       
      .instruction(instruction),
      .next_pc(pc_next)
  );
  
  
  // ------------------------------------------------------------------------------------------------------------------------------------
  // =======================================================================================    Fetch-Decode Pipeline Register (IF/ID)
  // ------------------------------------------------------------------------------------------------------------------------------------
  logic [31:0] pc_2d;
  logic [31:0] instruction_1D;
  logic [4:0] if_id_rs1;
  logic [4:0] if_id_rs2;
  
  
  fetch_decode_pipeline u_fd_p (
      .clk(clk),           
        // For simplicity, reusing pc_write here
      .rst(rst),           
      .pc_in(pc),         
      .instruction_in_FD(instruction),
      .stall(stall_pipeline),
      .pc_out(pc_2d),
      .instruction_out_FD(instruction_1D)
  );
  
        always_ff @(posedge clk) begin
      if (rst)
          if_id <= '0;
      else if (if_id_write)
          if_id <= {instruction, pc}; 
    end
  
        assign if_id_rs1 = instruction_1D[19:15];
        assign if_id_rs2 = instruction_1D[24:20];
        assign if_id_rd  = instruction_1D[11:7];

  
  
  // ---------------------------------------------------------------------------------------------------------------------
  // ====================================================================================================Decode Stage (ID)
  // ---------------------------------------------------------------------------------------------------------------------
  
  logic [31:0] pc_d;
  logic [31:0] PC_IDEX;
  logic [6:0]  opcode;
  logic [4:0]  rd;
  logic [2:0]  funct3;
  logic [4:0]  rs1;
  logic [4:0]  rs2;
  logic [6:0]  funct7;
  logic [31:0] read_data1;
  logic [31:0] read_data2;
  logic [31:0] imm_ext;
  logic       alu_src;                  
  logic       mem_to_reg;               
  logic       reg_write_ctrl;
  logic       mem_read;                 
  logic       mem_write;                
  logic       branch;  
  logic [1:0] alu_op;
  logic reg_w_en;
  logic [4:0] rd_D;
  logic [31:0] w_data_DEC_R;

  // register file 
  logic [31:0] registers_dec [0:31];
  
  // Signals from the decode stage.

  decode_stage u_decode_stage (
      .clk(clk),
      .rst(rst),
      .instruction_d1(instruction_1D),
      .pc_d(pc_2d),
      .reg_write_c4wb(reg_w_en),
      .write_data_c4wb(w_data_DEC_R),
      .rd_c4wb(rd_D),
      //output signals
      
      .pc_IDEX(PC_IDEX),
      .opcode(opcode),
      .r_d(rd),
      .funct3(funct3),
      .rs_1(rs1),
      .src_R_2(rs2),
      .funct7(funct7),
      .read_data1(read_data1),
      .read_data2(read_data2),
      .imm_ext(imm_ext),  
      .alu_src(alu_src),                  
      .mem_to_reg(mem_to_reg),               
      .reg_write_ctrl(reg_write_ctrl), 
      .mem_read(mem_read),                 
      .mem_write(mem_write),                
      .branch(branch),
      .alu_op(alu_op),
      .registers(registers_dec)
  );
  
  assign registers = registers_dec;

  // ---------------------------------------------------------------------------------------------------------------------
  // ==============================================================================================ID/EX Pipeline Register (Between Decode and Execution)
  // ---------------------------------------------------------------------------------------------------------------------
        logic [31:0] read_data1_ex;
        logic [31:0] read_data2_ex;
        logic [31:0] imm_ext_ex;
        logic [6:0]  opcode_ex;
        logic [4:0]  rd_ex;
        logic [2:0]  funct3_ex;
        logic [6:0]  funct7_ex;
        logic [4:0]  rs1_ex;
        logic [4:0]  rs2_ex;
        logic        alu_src_ex;
        logic        mem_to_reg_ex;
        logic        reg_write_ex;
        logic        mem_read_ex;
        logic        mem_write_ex;
        logic        branch_ex;
        logic [1:0]  alu_op_ex;
        logic        flush;
        logic [31:0] pc_ex;
        
        
    

  id_ex_register id_ex_reg_inst (
    .clk(clk),
    .rst(rst),
    
    // Inputs from Decode Stage
    .read_data1_in(read_data1),
    .read_data2_in(read_data2),
    .imm_ext_in(imm_ext),
    .opcode_in(opcode),
    .rd_in(rd),
    .funct3_in(funct3),
    .funct7_in(funct7),
    .rs1_in(rs1),
    .rs2_in(rs2),
    
    .stall(stall_pipeline),
    // Control signals from Decode Stage
    .alu_src_in(alu_src),
    .mem_to_reg_in(mem_to_reg),
    .reg_write_in(reg_write_ctrl),
    .mem_read_in(mem_read),
    .mem_write_in(mem_write),
    .branch_in(branch),
    .alu_op_in(alu_op),



 // =======Outputs to Execution Stage=====
    .read_data1_out(read_data1_ex),
    .read_data2_out(read_data2_ex),
    .imm_ext_out(imm_ext_ex),
    .opcode_out(opcode_ex),
    .rd_out(rd_ex),
    .funct3_out(funct3_ex),
    .funct7_out(funct7_ex),
    .rs1_out(rs1_ex),
    .rs2_out(rs2_ex),
    .alu_src_out(alu_src_ex),
    .mem_to_reg_out(mem_to_reg_ex),
    .reg_write_out(reg_write_ex),
    .mem_read_out(mem_read_ex),
    .mem_write_out(mem_write_ex),
    .branch_out(branch_ex),
    .alu_op_out(alu_op_ex),                    // Extra Signals
    .pc_in(PC_IDEX),
    .flush(flush),
    .pc_out(pc_ex)
);

            always_ff @(posedge clk) begin
      if (rst)
          id_ex <= '0;
      else if (stall_pipeline)
          id_ex <= '0;  
      else
          id_ex <= {control_signals, data_fields};
        end

    assign id_ex_rd = rd_ex;
//------------------------------------------------------------------------------------------------------------------------------
//========================================================================================= Execution Stage Module
//-----------------------------------------------------------------------------------------------------------------------------

logic        mem_to_reg_2em;
logic        reg_write_2em;
logic        mem_read_2em;
logic        mem_write_2em;
logic [4:0]  rd_2em;
logic [31:0] read_data2_2em;
logic [31:0] alu_result_m;
logic read_data_WB;
logic [1:0] forward_a;
logic [1:0] forward_b;
logic [31:0] mem_wb_data;        
logic branch_condition_met;

execution_stage u_exec_stage (
    .clk(clk),
    .rst(rst),
    .pc(pc_ex),
    .read_data1(read_data1_ex),  
    .read_data2(read_data2_ex),    
    .imm_ext(imm_ext_ex),
    .opcode(opcode_ex),
    .rd_e(rd_ex),
    .funct3(funct3_ex),            
    .funct7(funct7_ex),
    .rs1(rs1_ex),
    .rs2(rs2_ex),
    .alu_src(alu_src_ex),
    .mem_to_reg(mem_to_reg_ex),
    .reg_write(reg_write_ex),
    .mem_read(mem_read_ex),
    .mem_write(mem_write_ex),
    .branch(branch_ex),
    .alu_op(alu_op_ex),                
    //===================================================================
    .forward_a(forward_a),         
    .forward_b(forward_b),         
    .ex_mem_alu_result(alu_result_m),
    .mem_wb_data(mem_wb_data),      
    
    
    //===================================================================
    .alu_result(alu_result1),      
    .alu_zero(alu_zero),           
    .error_flag(error_flag),
    .r3(r3),
    .r2(r2),
    .r1(r1),
    .mem_to_reg_m(mem_to_reg_2em), 
    .reg_write_m(reg_write_2em),       
    .mem_read_m(mem_read_2em),            
    .mem_write_m(mem_write_2em),          
    .rd_m(rd_2em),                        
    .read_data2_m(read_data2_2em),        
    .branch_taken(branch_taken),
    .branch_target(branch_target),
    .branch_condition_met(branch_condition_met)
);
    

//----------------------------------------------------------------------------------------------------------------------------------
//================================================================================================== EX_MEM pipeline register
//--------------------------------------------------------------------------------------------------------------------------------


logic        mem_to_reg_m;
logic        reg_write_m;
logic        mem_read_m;
logic        mem_write_m;
logic [4:0]  rd_m;
logic [31:0] write_data_m;


 EX_MEM u_EX_MEM(
            // from ex stage
        .clk(clk), 
        .reset(rst),
        .alu_result_in(alu_result1),
        .mem_to_reg_in(mem_to_reg_2em),                           //
        .reg_write_in(reg_write_2em),
        .mem_read_in(mem_read_2em),
        .mem_write_in(mem_write_2em),
        .rd_in(rd_2em),
        .write_data_in(read_data2_2em),

        // to mem stage     
        .alu_result_out(alu_result_m),
        .mem_to_reg_out(mem_to_reg_m), 
        .reg_write_out(reg_write_m),   
        .mem_read_out(mem_read_m), 
        .mem_write_out(mem_write_m), 
        .rd_out(rd_m),              
        .write_data_out(write_data_m)      
 );




//----------------------------------------------------------------------------------------------------------------------------------
//================================================================================================================= MEM_stage
//--------------------------------------------------------------------------------------------------------------------------------

logic [31:0]ALU_R_MW;
logic [4:0] RD_MW;
logic reg_write_MW;
logic mem_to_reg_MW;
logic read_data_MEM;


MEM_stage u_MEM_stage(  
        .clk(clk),                                                                                                                  
        .reset(rst),                                                                                                       
        .ALU_result(alu_result_m),         
        .MemToReg(mem_to_reg_m),                   // debugged 
        .reg_w_ctrl_IN(reg_write_m),
        .MemRead(mem_read_m),                                                                                                                   
        .MemWrite(mem_write_m), 
        .rd(rd_m),
        .Write_data(write_data_m),
        //output siganls
        .ALU_result_o(ALU_R_MW),
        .MEM_WB_rd(RD_MW),
        .reg_w_ctrl_out(reg_write_MW),
        .MemToReg_out(mem_to_reg_MW),               
        .read_data(read_data_MEM)
                        
        );
        

//----------------------------------------------------------------------------------------------------------------------------------
//================================================================================================================= MEM_WB(MEMORY_WRITE_BACK) --PIPELINE REGISTER
//--------------------------------------------------------------------------------------------------------------------------------

logic [31:0] ALU_Result_WB;
logic [4:0]RD_WB;
logic reg_write_WB;
logic mem_to_reg_WB;





MEM_WB u_MEM_WB(
        .clk(clk), 
        .reset(rst),
        .alu_result_in(ALU_R_MW),
        .rd_in(RD_MW),
        .reg_w_ctrl(reg_write_MW),
        .MemToReg(mem_to_reg_MW),                    //debugged 
        .mem_r_data_in(read_data_MEM),
         
         
        // write back signals                           
        .mem_wb_data(mem_wb_data),
        .alu_result_out(ALU_Result_WB),   
        .rd_out(RD_WB),
        .reg_write_out(reg_write_WB),
        .MemToReg_out(mem_to_reg_WB),
        .mem_r_data_out(read_data_WB) 
                                 
                                  
        );
        
        
//----------------------------------------------------------------------------------------------------------------------------------
//================================================================================================================= WB (WRITE_BACK)_stage
//--------------------------------------------------------------------------------------------------------------------------------

logic [31:0 ]write_data_4wb;
logic reg_write_4wb;
logic [4:0]rd_4wb;


WB_stage u_WB_stage(
        .alu_result(ALU_Result_WB),
        .rd(RD_WB),
        .reg_write(reg_write_WB),                     
        .mem_to_reg(mem_to_reg_WB),              //debug for mem_to_reg
        .mem_data(read_data_WB),  
               
            
        
        
        //OUTPUT SIGNALS ---- TO DECODE_STAGE--REGISTER_FILE
        .wb_data(write_data_4wb),  
        .wb_enable(reg_write_4wb),
        .wb_rd(rd_4wb)      
        );        
        
        assign w_data_DEC_R = write_data_4wb;
        assign reg_w_en=reg_write_4wb;
        assign rd_D = rd_4wb;
        
       
//----------------------------------------------------------------------------------------------------------------------
//=============================================================================================HAzARD_DETECTECTION&FORWORDING UNIT
//------------------------------------------------------------------------------------------------------------------------

hazard_unit hdu (
    .if_id_rs1 (if_id_rs1),
    .if_id_rs2 (if_id_rs2),
    .id_ex_rd (rd_ex),
    .id_ex_mem_read(mem_read_ex),
    .stall_pipeline(stall_pipeline),
    .pc_write      (pc_write),
    .if_id_write   (if_id_write)
);


forwarding_unit fu (
    .id_ex_rs1         (rs1_ex),
    .id_ex_rs2         (rs2_ex),
    .ex_mem_rd         (rd_m),
    .mem_wb_rd         (RD_WB),
    .ex_mem_reg_write  (reg_write_m),
    .mem_wb_reg_write  (reg_write_WB),
    .forward_a         (forward_a),
    .forward_b         (forward_b)
);


       
        
        
        
 endmodule       