module branch_check_tb;

  // Inputs
  logic clk;
  logic rst;

  // Outputs from DUT
  logic [31:0] registers [0:31];
  logic        alu_zero;

  // Instantiate DUT
  cpu uut (
    .clk(clk),
    .rst(rst),
    .registers(registers),
    .alu_zero(alu_zero),
    .
  );
  
        initial begin
        clk=0;
        rst=0;
        #5 rst=1;
        #5 rst=0;
        end

  // Clock Generation (10ns period)
  always #5 clk = ~clk;

// Task to print result and error
  task print_status(string case_name);
    $display("---- %s ----", case_name);
    $display("operand_a = 0x%h, operand_b = 0x%h, alu_control = 0x%h", operand_a, operand_b, alu_control);
    $display("Result     = 0x%h", result);
    $display("Error Flag = %b\n", error_flag);
  endtask

  initial begin
    $display("=== Fault Tolerant ALU Testbench ===\n");

    // ---------- CASE 1: All ALUs Same ----------
    operand_a    = 32'h0000000A; // 10
    operand_b    = 32'h00000005; // 5
    alu_control  = 4'b0000;      // ADD
    #10;
    print_status("CASE 1: All ALUs same input");

    // ---------- CASE 2: Only 2 ALUs Same ----------
    operand_a    = 32'h00000008; // 15
    operand_b    = 32'h00000004; // 3
    alu_control  = 4'b0000;      // SUB
    
    // Inject fault manually into alu3 result inside DUT
    force dut.r3 = 32'hABCD1234; // Faulty output
    #5;
    print_status("CASE 2: Two ALUs same, one faulty");

    release dut.r3; // Remove force for next case

    // ---------- CASE 3: All ALUs Different ----------
    operand_a    = 32'h00000009;
    operand_b    = 32'h00000005;
    alu_control  = 4'b0000; // AND
   
    // Inject faults into alu2 and alu3
    force dut.r2= 32'h11111111;
    force dut.r3 = 32'h22222222;
    #5;
    print_status("CASE 3: All ALUs different - ERROR expected");

    release dut.r2;
    release dut.r3;

    $display("\n=== Test Completed ===");
    $finish;
  end
endmodule