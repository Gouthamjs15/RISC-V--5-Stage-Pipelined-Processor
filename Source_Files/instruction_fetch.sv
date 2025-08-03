
module instruction_fetch (
    input  logic        clk,           
    input  logic        rst,           
    input  logic [31:0] branch_target, // Branch target address (for jumps/branches)
    input  logic        branch_taken,  
    input  logic        stall,
    output logic [31:0] pc,            // Current Program Counter (PC)
    output logic [31:0] instruction,   
    output logic [31:0] next_pc
);

    
    always_comb begin
            
        if (branch_taken)
            next_pc = branch_target;
        else 
            next_pc = pc + 4; 
       
    end

    
    program_counter pc_module (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .next_pc(next_pc),
        .pc(pc)
    );

    
    instruction_memory imem (
        .address(pc),
        .instruction(instruction)
    );

endmodule



//====================================instruction_memory====================================================


module instruction_memory (
    input  logic [31:0] address,          
    output logic [31:0] instruction       
);

    
    logic [31:0] mem [0:1023];

    
    initial begin
        integer i;
        for (i = 0; i < 1024; i = i + 1)
            mem[i] = 32'h00000000; // Default NOP (addi x0, x0, 0)

        // Program Instructions
       // Instruction Memory Content (each mem[i] is a 32-bit word)
       mem[0] = 32'h00000013; // NOP (addi x0, x0, 0)
       mem[1] = 32'h00A00093; // addi x1, x0, 10   ; x1 = 10 == a
       mem[2] = 32'h01400113; // addi x2, x0, 20   ; x2 = 20 == 14
       mem[3] = 32'h002081B3; // add  x3, x1, x2    ; x3 = x1 + x2 = 10 + 20 = 30  ==  1E
       mem[4] = 32'h40210233; // sub  x4, x2, 20    
       
       
       mem[5] = 32'h0020C063; // beq x1, x2, +8 (offset = 2 instructions = 8 bytes)
       mem[6] = 32'hFFF00193; 
       mem[7] = 32'h00300113; 
       
       
       mem[8] = 32'h00508193; // ori  x5, x1, 5     ; x5 = x1 | 5 (bitwise OR)
       mem[9] = 32'h00F10113; // andi x6, x2, 15    ; x6 = x2 & 15 (bitwise AND)
       mem[10] = 32'h03200093; // addi x7, x0, 50   ; x7 = 50
       mem[11] = 32'h00038283; // lw   x8, 0(x7)    ; x8 = MEM[x7] (loads data from memory at address in x7)

    end

    
    assign instruction = mem[address[31:2]]; 

endmodule



//========================================program_counter=====================================================



 module program_counter (
    input  logic        clk,         
    input  logic        rst,         
    input  logic [31:0] next_pc,     
    input logic         stall,
    output logic [31:0] pc           
);

 
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            pc <= 32'h0000_0000;     
        else if (! stall)
            pc <= next_pc;           
    end

endmodule



