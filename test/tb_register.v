
`timescale 1ns / 1ps
module tb_registers;
  reg clk, reset, we;
  reg [2:0] r_addr1, r_addr2, w_addr;
  reg [15:0] w_data;
  wire [15:0] r_data1, r_data2;

  registers dut (
    .clk(clk), .reset(reset), .we(we), 
    .rd_addr1(r_addr1), .rd_addr2(r_addr2), 
    .wr_addr(w_addr), .wr_data(w_data), 
    .rd_data1(r_data1), .rd_data2(r_data2)
  );

  always #5 clk = ~clk; // Make the clock tick

  initial begin
    clk = 0; reset = 1; we = 0; #10; 
    
    reset = 0; we = 1;     // Turn off reset, turn on write
    w_addr = 3'd1;         // Choose Register 1
    w_data = 16'hAAAA; #10; // Write the word "AAAA"
    
    we = 0; r_addr1 = 3'd1; #10; // Read from Register 1
    
    $finish;
  end
endmodule