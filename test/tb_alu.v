
`timescale 1ns / 1ps
module tb_alu;
  reg [2:0] op;
  reg [15:0] a, b;
  wire [15:0] res;
  wire z, ovf;

  Alu dut (
    .operation(op), .in1(a), .in2(b), 
    .result(res), .zero_flag(z), .overflow_flag(ovf)
  );

  initial begin
    a = 15; b = 5; 
    
    op = 3'b000; #10; // Test ADD
    op = 3'b001; #10; // Test SUBTRACT
    op = 3'b100; #10; // Test NOT
    
    $finish;
  end
endmodule