module MEM_WB (
    input logic clk, reset,
    input logic [31:0] mem_r_data_in,
    input logic [31:0] alu_result_in,
    input logic [4:0] rd_in,
    input logic reg_w_ctrl,
    input logic MemToReg,
    output logic [31:0] mem_wb_data,
    output logic [31:0] mem_r_data_out, 
    output logic [31:0] alu_result_out,
    output logic [4:0] rd_out,
    output logic reg_write_out,
    output logic MemToReg_out
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_r_data_out  <= 0;
            alu_result_out <= 0;
            rd_out         <= 0;
            reg_write_out  <= 0;
            MemToReg_out       <=0;
        end else begin
            mem_r_data_out  <= mem_r_data_in;
            alu_result_out <= alu_result_in;
            rd_out         <= rd_in;
            reg_write_out  <= reg_w_ctrl;
            MemToReg_out   <= MemToReg;
        end
        
    end
    
    assign mem_wb_data = MemToReg_out ? mem_r_data_out : alu_result_out;
    
endmodule
