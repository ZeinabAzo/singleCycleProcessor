`timescale 1ns / 1ps

module processor (
  input         clk,            // System clock
  input         reset           // Asynchronous reset (active high)
);

  // Program Counter
  reg [15:0] pc;
  wire [15:0] pc_next;
  
  // Instruction
  wire [15:0] instruction;
  
  // Register file signals
  wire        reg_write_en;
  wire [2:0]  reg_write_addr;
  wire [15:0] reg_write_data;
  wire [2:0]  reg_read_addr1;
  wire [2:0]  reg_read_addr2;
  wire [15:0] reg_data1;
  wire [15:0] reg_data2;
  
  // ALU signals
  wire [2:0]  alu_op;
  wire [15:0] alu_in1;
  wire [15:0] alu_in2;
  wire [15:0] alu_result;
  wire        zero_flag;
  wire        overflow_flag;
  
  // Memory signals
  wire        mem_read_en;
  wire        mem_write_en;
  wire [11:0] mem_addr;
  wire [15:0] mem_data_out;
  
  // Control signals
  wire [1:0]  reg_src_sel;
  wire [1:0]  pc_next_sel;
  wire [11:0] branch_addr;
  wire        alu_src_sel;      
  
  // ========== PROGRAM COUNTER (Instruction Memory Address) ==========
  
  // Instruction Memory ROM
  reg [15:0] instr_mem [0:4095];  // 4K instructions
  
  // [FIX 1] Move integer declaration OUTSIDE the initial block!
  integer i; 
  
  initial begin
    // Initialize instruction memory with zeros
    for (i = 0; i < 4096; i = i + 1) begin
      instr_mem[i] = 16'h0000;
    end
  end
  
  // Fetch instruction from program memory
  assign instruction = instr_mem[pc[11:0]];
  
  // PC update logic 
  assign pc_next = (pc_next_sel == 2'b00) ? (pc + 16'd1) :                        // PC + 1
                   (pc_next_sel == 2'b01) ? {4'b0000, branch_addr} :              // JUMP
                   (pc_next_sel == 2'b10) ? {4'b0000, branch_addr} :              // BRANCHZ
                   (pc + 16'd1);                                                  // Default
  
  // Update PC on clock edge
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      pc <= 16'h0000;
    end else begin
      pc <= pc_next;
    end
  end
  
  // ========== CONTROL UNIT ==========
  control ctrl_unit (
    .instruction(instruction),
    .zero_flag(zero_flag),
    .pc_current(pc),
    
    .reg_write_en(reg_write_en),
    .reg_write_addr(reg_write_addr),
    .reg_src_sel(reg_src_sel),
    .alu_src_sel(alu_src_sel),  
    .alu_op(alu_op),
    .mem_read_en(mem_read_en),
    .mem_write_en(mem_write_en),
    .pc_next_sel(pc_next_sel),
    .branch_addr(branch_addr),
    .reg_read_addr1(reg_read_addr1),
    .reg_read_addr2(reg_read_addr2)
  );
  
  // ========== REGISTER FILE ==========
  registers reg_file (
    .clk(clk),
    .reset(reset),
    .we(reg_write_en),
    .rd_addr1(reg_read_addr1),
    .rd_addr2(reg_read_addr2),
    .wr_addr(reg_write_addr),
    .wr_data(reg_write_data),
    
    .rd_data1(reg_data1),
    .rd_data2(reg_data2)
  );
  
  // Select memory address (from instruction)
  assign mem_addr = instruction[11:0];
  
  // ========== ARITHMETIC LOGIC UNIT ==========
  
  assign alu_in1 = reg_data1;  // Always R0 for Type A, B, C, D instructions
  
  // Using the control signal to switch between Immediate or Register
  assign alu_in2 = (alu_src_sel) ? {4'h0, instruction[11:0]} : reg_data2; 
  
  Alu alu_unit (
    .operation(alu_op),
    .in1(alu_in1),
    .in2(alu_in2),
    
    .result(alu_result),
    .zero_flag(zero_flag),
    .overflow_flag(overflow_flag)
  );
  
  // ========== DATA MEMORY ==========
  memory data_mem (
    .clk(clk),
    .reset(reset),
    .we(mem_write_en),
    .addr(mem_addr),
    .data_in(reg_data1),  // Write R0 to memory
    .data_out(mem_data_out)
  );
  
  // ========== RESULT MULTIPLEXER ==========
  // Select source for register write-back
  assign reg_write_data = (reg_src_sel == 2'b00) ? alu_result :    
                          (reg_src_sel == 2'b01) ? mem_data_out :  
                          (reg_src_sel == 2'b10) ? pc :            
                          alu_result;                              
  
endmodule
