module hazard_unit (
    input  logic [4:0] if_id_rs1,
    input  logic [4:0] if_id_rs2,
    input  logic [4:0] id_ex_rd,
    input  logic       id_ex_mem_read,
    output logic       stall_pipeline,
    output logic       pc_write,
    output logic       if_id_write
);

    always_comb begin
        // Default: no stall
        stall_pipeline = 0;
        pc_write       = 1;
        if_id_write    = 1;

        // Stall only for load-use hazard
        if (id_ex_mem_read &&
            ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2))) begin
            stall_pipeline = 1;
            pc_write       = 0;
            if_id_write    = 0;
        end
    end

endmodule
