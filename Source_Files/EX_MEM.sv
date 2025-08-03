module EX_MEM (
    input logic clk, reset,
    input logic [31:0] alu_result_in,
    input logic [31:0] write_data_in,
    input logic [4:0] rd_in,
    input logic mem_read_in, 
    input logic mem_write_in, 
    input logic reg_write_in,
    input logic mem_to_reg_in,
    
    //output
    output logic [31:0] alu_result_out,
    output logic [31:0] write_data_out,
    output logic [4:0] rd_out,
    output logic mem_read_out, 
    output logic mem_write_out,
    output logic reg_write_out,
    output logic mem_to_reg_out
);

        
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            alu_result_out <= 0;
            write_data_out <= 0;
            rd_out         <= 0;
            mem_read_out   <= 0;
            mem_write_out  <= 0;
            reg_write_out  <= 0;
            mem_to_reg_out <= 0;
        end else begin
            alu_result_out <= alu_result_in;
            write_data_out <= write_data_in;
            rd_out         <= rd_in;
            mem_read_out   <= mem_read_in;
            mem_write_out  <= mem_write_in;
            reg_write_out  <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
        end
    end
endmodule
