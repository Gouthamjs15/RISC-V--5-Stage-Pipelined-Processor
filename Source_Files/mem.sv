module MEM_stage (
    input logic clk, reset,
    input logic MemRead,
    input logic MemWrite,
    input logic MemToReg,
    input logic [31:0] ALU_result,
    input logic [31:0] Write_data,
    input logic [4:0] rd,
    input logic reg_w_ctrl_IN,
    
    
    output logic [31:0] ALU_result_o,
    output logic [4:0] MEM_WB_rd,
    output logic [31:0] read_data,
    output logic reg_w_ctrl_out,
    output logic MemToReg_out
);

        assign reg_w_ctrl_out = reg_w_ctrl_IN;
        assign MemToReg_out = MemToReg;
        
    logic [31:0] Read_data;
    data_memory dmem (
        .clk(clk),
        .reset(reset),
        .mem_read(MemRead),
        .mem_write(MemWrite),
        .addr(ALU_result),
        .write_data(Write_data),
        .read_data(Read_data)
    );

    // Mux to select ALU output or Memory Read Data
    always_comb begin
        if (MemToReg)
            ALU_result_o = Read_data; // Load instruction (lw)
        else
            ALU_result_o = ALU_result; // R-type and others
    end

    assign MEM_WB_rd = rd; // Forward register destination

endmodule









module data_memory (
    input logic clk,
    input logic reset,                    // Clock signal
    input logic mem_read,               // Memory read enable
    input logic mem_write,              // Memory write enable
    input logic [31:0] addr,            // Address bus
    input logic [31:0] write_data,      // Data to be written
    output logic [31:0] read_data       // Data read from memory
);

    // 256 x 32-bit memory (adjustable size)
    logic [31:0] mem [0:255];

    // Synchronous memory write
    always_ff @(posedge clk) begin
        if (mem_write) begin
            mem[addr[9:2]] <= write_data; // Addressing in word-aligned format
        end
    end

    // Asynchronous read (for immediate read-after-write response)
    always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        // reset necessary registers, like Read_data
        read_data <= 32'b0;
    end else if (mem_read) begin
        read_data <= mem[addr[9:2]];
    end
end
;

endmodule
