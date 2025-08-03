module WB_stage (
    input logic [31:0] alu_result,
    input logic [31:0] mem_data,
    input logic mem_to_reg,
    input logic reg_write,
    input logic [4:0] rd,
    
    
    output logic [31:0] wb_data,
    output logic wb_enable,
    output logic [4:0] wb_rd
);

    // Mux to select ALU result or Memory Data
    assign wb_data = mem_to_reg ? mem_data : alu_result;
    assign wb_enable = reg_write;
    assign wb_rd = rd;

endmodule
