
`timescale 1ns / 1ps
module tb_control;
  reg [15:0] inst, pc;
  reg z_flag;
  
  wire we, alu_sel, mem_re, mem_we;
  wire [2:0] wa, op;

  control dut (
    .instruction(inst), .zero_flag(z_flag), .pc_current(pc),
    .reg_write_en(we), .reg_write_addr(wa), .alu_src_sel(alu_sel), 
    .alu_op(op), .mem_read_en(mem_re), .mem_write_en(mem_we)
  );

  initial begin
    z_flag = 0; pc = 0;
    
    // Test ADDI (Opcode: 1100)
    inst = 16'b1100_0000_0000_0101; #10; 
    
    // Test LOAD (Opcode: 0000)
    inst = 16'b0000_0000_0000_0000; #10; 
    
    $finish;
  end
endmodule