module control_unit(
    input  logic [6:0] opcode_cu,       // Opcode from instruction
    output logic       alu_src,      // 1: Immediate as ALU operand
    output logic       mem_to_reg,   // 1: Memory to register writeback
    output logic       reg_write,    // 1: Write to register file
    output logic       mem_read,     // 1: Read from memory
    output logic       mem_write,    // 1: Write to memory
    output logic       branch,       // 1: Branch instruction
    output logic [1:0] alu_op        // ALU operation control
);

  always_comb begin
    // Default control signals
    alu_src    = 0;
    mem_to_reg = 0;
    reg_write  = 0;
    mem_read   = 0;
    mem_write  = 0;
    branch     = 0;
    alu_op     = 2'b00;
    
    case (opcode_cu)
      // R-type instructions (add, sub, etc.)
      7'b0110011: begin 
        alu_src    = 0;    // Register operands
        reg_write  = 1;    
        alu_op     = 2'b10; // Funct3/7 determine ALU operation
      end
      
      // I-type arithmetic (addi, andi, etc.)
      7'b0010011: begin 
        alu_src    = 1;    // Immediate operand
        reg_write  = 1;
        alu_op     = 2'b11; 
      end
      
      // Load instructions (lw)
      7'b0000011: begin 
        alu_src    = 1;    // Base + offset
        mem_to_reg = 1;    // Memory to register
        reg_write  = 1;
        mem_read   = 1;
      end
      
      // Store instructions (sw)
      7'b0100011: begin 
        alu_src    = 1;    // Base + offset
        mem_write  = 1;
      end
      
      // Branch instructions (beq, bne)
      7'b1100011: begin 
        branch     = 1;
        alu_op     = 2'b01; // Subtract for comparison
      end
      
      // LUI (Load Upper Immediate)
      7'b0110111: begin 
        alu_src    = 1;    // Immediate operand
        reg_write  = 1;
        alu_op     = 2'b11; // Pass immediate (assumes ALU handles this)
      end
      
      // AUIPC (Add Upper Immediate to PC)
      7'b0010111: begin 
        alu_src    = 1;    // PC + immediate (requires PC as ALU input)
        reg_write  = 1;
        alu_op     = 2'b00; // Add operation (special handling needed)
      end
      
      // JAL (Jump and Link)
      7'b1101111: begin 
        reg_write  = 1;    // Write PC+4 to rd
        branch     = 1;    // Unconditional jump (datapath must handle)
        alu_op     = 2'b00; // PC+4 calculation
      end
      
      // JALR (Jump and Link Register)
      7'b1100111: begin 
        alu_src    = 1;    // rs1 + immediate
        reg_write  = 1;    // Write PC+4 to rd
        branch     = 1;    // Treated as jump
        alu_op     = 2'b00; // Address calculation
      end
      
      default: ; // Handle other cases or NOP
    endcase
  end

endmodule