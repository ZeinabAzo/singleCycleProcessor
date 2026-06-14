`timescale 1ns / 1ps

module registers (
  input         clk,            // System clock
  input         reset,          // Asynchronous reset (active high)
  input         we,             // Write enable
  input  [2:0]  rd_addr1,       // Read address 1
  input  [2:0]  rd_addr2,       // Read address 2
  input  [2:0]  wr_addr,        // Write address
  input  [15:0] wr_data,        // Data to write
  
  output [15:0] rd_data1,       // Data from read address 1
  output [15:0] rd_data2        // Data from read address 2
);

  // 8 registers, each 16 bits wide
  reg [15:0] reg_file [0:7];
  
  assign rd_data1 = reg_file[rd_addr1];
  assign rd_data2 = reg_file[rd_addr2];
  
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      // Clear all registers on reset
      reg_file[0] <= 16'h0000;
      reg_file[1] <= 16'h0000;
      reg_file[2] <= 16'h0000;
      reg_file[3] <= 16'h0000;
      reg_file[4] <= 16'h0000;
      reg_file[5] <= 16'h0000;
      reg_file[6] <= 16'h0000;
      reg_file[7] <= 16'h0000;
    end else if (we) begin
      // Write to register on clock edge if write enabled
      reg_file[wr_addr] <= wr_data;
    end
  end

endmodule
