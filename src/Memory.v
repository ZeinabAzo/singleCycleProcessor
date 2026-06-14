`timescale 1ns / 1ps

module memory (
  input         clk,            // System clock
  input         reset,          // Asynchronous reset
  input         we,             // Write enable
  input  [11:0] addr,           // Memory address (12 bits)
  input  [15:0] data_in,        // Data to write (16 bits)
  output [15:0] data_out        // Data read from memory (16 bits)
);

  // 4K memory array (4096 slots of 16 bits each)
  reg [15:0] mem [0:4095];
  
  // Asynchronous read port
  assign data_out = mem[addr];
  
  // Synchronous write port
  integer i;
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      for (i = 0; i < 4096; i = i + 1) begin
        mem[i] <= 16'h0000;
      end
    end else if (we) begin
      mem[addr] <= data_in;
    end
  end

endmodule
