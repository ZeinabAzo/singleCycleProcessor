`timescale 1ns/1ps
module instruction_memory (
    input  [11:0] addr,    
    output [15:0] instr    
);
    reg [15:0] mem [0:4095];
    assign instr = mem[addr];
endmodule