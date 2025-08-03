module alu(
    input  logic [31:0] operand_a,    
    input  logic [31:0] operand_b,    
    input  logic [3:0]  alu_control,  
    output logic [31:0] result,       
    output logic        zero_flag     
);

  always_comb begin
    case (alu_control)
      4'b0000: result = operand_a + operand_b;  // ADD operation
      4'b0001: result = operand_a - operand_b;  // SUB operation
      4'b0010: result = operand_a & operand_b;  // AND operation
      4'b0011: result = operand_a | operand_b;  // OR operation
      4'b0100: result = operand_a ^ operand_b;  // XOR operation
      // Additional operations can be added here, such as:
      4'b0101: result = operand_a << operand_b[4:0]; // Shift left
      4'b0110: result = operand_a >> operand_b[4:0]; // Logical shift right
      default: result = 32'b0;
    endcase
  end

  assign zero_flag = (result == 32'b0);

endmodule




//==========================================fault-tolerant-alu===================================================

module fault_tolerant_alu (
  input  logic [31:0] operand_a, operand_b,
  input  logic [3:0]  alu_control,
  output logic [31:0] result,
  output logic        error_flag,
  output logic [31:0] tmr1_op, tmr2_op,tmr3_op,
  output logic [31:0] r1, r2,r3
  
);
  logic        z1, z2, z3;

  alu alu1(.operand_a(operand_a), .operand_b(operand_b), .alu_control(alu_control), .result(r1), .zero_flag(z1));
  alu alu2(.operand_a(operand_a), .operand_b(operand_b), .alu_control(alu_control), .result(r2), .zero_flag(z2));
  alu alu3(.operand_a(operand_a), .operand_b(operand_b), .alu_control(alu_control), .result(r3), .zero_flag(z3));

  // Majority vote logic
  always_comb begin
    if (r1 == r2 || r1 == r3)
      result = r1;
    else if (r2 == r3)
      result = r2;
    else
      result = 32'hxxxx_xxxx; 

    error_flag = !( (r1 == r2) || (r1 == r3) || (r2 == r3) );
  end
  assign tmr1_op = r1;
  assign tmr1_op = r2;
  assign tmr1_op = r3;
  
endmodule