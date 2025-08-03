module fetch_decode_pipeline (
    input  logic        clk,           // Clock signal
    input  logic        rst,           // Reset signal (active high)
    input  logic [31:0] pc_in,         // PC from fetch stage
    input  logic [31:0] instruction_in_FD, // Instruction from fetch stage
    input  logic        stall,
    output logic [31:0] pc_out,        // PC forwarded to decode stage
    output logic [31:0] instruction_out_FD// Instruction forwarded to decode stage
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out          <= 32'b0;
            instruction_out_FD <= 32'b0;
        end else if(! stall ) begin
            pc_out          <= pc_in;
            instruction_out_FD <= instruction_in_FD;
        end
    end

endmodule
