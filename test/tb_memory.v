
`timescale 1ns / 1ps
module tb_memory;
  reg clk, reset, we;
  reg [11:0] addr;
  reg [15:0] data_in;
  wire [15:0] data_out;

  memory dut (
    .clk(clk), .reset(reset), .we(we), 
    .addr(addr), .data_in(data_in), .data_out(data_out)
  );

  always #5 clk = ~clk;

  initial begin
    clk = 0; reset = 1; we = 0; #10;
    
    reset = 0; we = 1; 
    addr = 12'h050;          // Choose address 0x050
    data_in = 16'h1234; #10; // Write "1234"
    
    we = 0; #10;             // Turn off write, just read
    
    $finish;
  end
endmodule