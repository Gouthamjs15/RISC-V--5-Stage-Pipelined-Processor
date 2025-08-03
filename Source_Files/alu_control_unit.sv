module alu_control(
    input  logic [1:0] alu_op,     // High-level ALU op signal from main control unit
    input  logic [2:0] funct3,     // funct3 field from the instruction
    input  logic [6:0] funct7,     // funct7 field from the instruction
    output logic [3:0] alu_control // Detailed control signal for the ALU
);

  always_comb begin
    case (alu_op)
      2'b00: begin
        // For load and store instructions, simply perform addition
        alu_control = 4'b0000; // ADD operation
      end
      2'b01: begin
        // For branch instructions, perform subtraction for comparison
                alu_control = 4'b0001; // SUB operation
      end
      2'b10: begin
        // For R-type instructions, use funct3 (and funct7 for differentiating add vs. sub)
        case (funct3)
          3'b000: begin
            // If funct7 indicates subtraction (0100000), then SUB; otherwise ADD.
            alu_control = (funct7 == 7'b0100000) ? 4'b0001 : 4'b0000;
          end
          3'b111: alu_control = 4'b0010; // AND
          3'b110: alu_control = 4'b0011; // OR
          3'b100: alu_control = 4'b0100; // XOR
          // You can add more operations here (like SLT, SLL, etc.) as needed.
          default: alu_control = 4'b0000;
        endcase
      end
      2'b11: begin
        // For I-type arithmetic instructions (like addi, andi, ori)
        case (funct3)
          3'b000: alu_control = 4'b0000; // ADDI -> ADD
          3'b111: alu_control = 4'b0010; // ANDI -> AND
          3'b110: alu_control = 4'b0011; // ORI  -> OR
          default: alu_control = 4'b0000;
        endcase
      end
      default: alu_control = 4'b0000;
    endcase
  end

endmodule
