module register_file(
    input  logic        clk,
    input  logic        rst,              // Active-high synchronous reset
    input  logic        reg_write_en,     // Write enable
    input  logic [4:0]  rs1,
    input  logic [4:0]  rs2,
    input  logic [4:0]  rd,
    input  logic [31:0] write_data,
    output logic [31:0] read_data1,
    output logic [31:0] read_data2,
    output logic [31:0] registers [0:31]  // For debug
);

    // Internal register file
    logic [31:0] reg_file [0:31];

    // Read ports (combinational)
    always_comb begin
        read_data1 = (rs1 == 5'd0) ? 32'd0 : reg_file[rs1];
        read_data2 = (rs2 == 5'd0) ? 32'd0 : reg_file[rs2];
    end

    // Write port (synchronous)
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i < 32; i++) begin
                reg_file[i] <= 32'd0;
            end
        end else if (reg_write_en && rd != 5'd0) begin
            reg_file[rd] <= write_data;
        end
    end

    // Debug output
    genvar i;
    generate
        for (i = 0; i < 32; i++) begin : reg_out
            assign registers[i] = reg_file[i];
        end
    endgenerate

endmodule
