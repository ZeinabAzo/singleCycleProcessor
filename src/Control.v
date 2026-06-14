`timescale 1ns / 1ps

module control (
    input  [15:0] instruction,        // 16-bit instruction
    input         zero_flag,          // Zero flag from ALU
    input  [15:0] pc_current,         // Current program counter (Restored!)
    
    output reg       reg_write_en,    // Register write enable
    output reg [2:0] reg_write_addr,  // Register write address (destination)
    output reg [1:0] reg_src_sel,     // Register source select (00: ALU, 01: Mem)
    output reg       alu_src_sel,     // ALU 2nd operand select (0: Register, 1: Immediate/Addr)
    output reg [2:0] alu_op,          // ALU operation code
    output reg       mem_read_en,     // Memory read enable
    output reg       mem_write_en,    // Memory write enable
    output reg [1:0] pc_next_sel,     // Next PC select (00: PC+1, 01: Jump, 10: Branch)
    output reg [11:0] branch_addr,    // Dynamic Branch/Jump address target
    output     [2:0] reg_read_addr1,  // Primary register read address (Always R0)
    output     [2:0] reg_read_addr2   // Secondary register read address (Ri)
);


    wire [3:0]  opcode    = instruction[15:12];
    wire [2:0]  reg_index = instruction[11:9];   
    wire [11:0] addr_12   = instruction[11:0];   
    wire [8:0]  addr_9    = instruction[8:0];    // Extracted for BranchZ
    wire [8:0]  func      = instruction[8:0];    
    
    // Constant Assignments
    assign reg_read_addr1 = 3'b000;              // R0 is the explicit Accumulator
    assign reg_read_addr2 = reg_index;           // Always output Ri to the second read port

    // Combinatorial instruction decode
    always @(*) begin
        // Default safe values (prevents latch generation)
        reg_write_en   = 1'b0;
        reg_write_addr = 3'b000;                 
        reg_src_sel    = 2'b00;                  
        alu_src_sel    = 1'b0;                   
        alu_op         = 3'b101;                 
        mem_read_en    = 1'b0;
        mem_write_en   = 1'b0;
        pc_next_sel    = 2'b00;                  
        branch_addr    = addr_12;                // Default target is the 12-bit address
        
        case (opcode)

            // Type A Instructions
            4'b0000: begin  // LOAD adr-12
                reg_write_en   = 1'b1;
                reg_write_addr = 3'b000;         
                reg_src_sel    = 2'b01;          
                mem_read_en    = 1'b1;
                alu_src_sel    = 1'b1;           
            end
            
            4'b0001: begin  // STORE adr-12
                mem_write_en   = 1'b1;
                alu_src_sel    = 1'b1;           
            end
            
            4'b0010: begin  // JUMP adr-12
                pc_next_sel    = 2'b01;          
                branch_addr    = addr_12;        // PC <- adr-12
            end
            

            // Type B Instructions
            4'b0100: begin  // BRANCHZ Ri, adr-9
                alu_op         = 3'b001;         //SUB to evaluate zero_flag
                alu_src_sel    = 1'b0;           
                
                // PC[8:0] <- adr-9. Combine top 3 bits of PC with 9-bit instruction address.
                branch_addr    = {pc_current[11:9], addr_9}; 
                
                if (zero_flag) begin
                    pc_next_sel = 2'b10;         
                end else begin
                    pc_next_sel = 2'b00;         
                end
            end
            
            // Type C Instructions (Register Operations)
            4'b1000: begin
                reg_write_en   = 1'b1;
                reg_write_addr = 3'b000;         
                reg_src_sel    = 2'b00;          
                alu_src_sel    = 1'b0;           
                
                case (func)
                    9'b000000001: begin          // MOVETO Ri 
                        reg_write_addr = reg_index; 
                        alu_op         = 3'b101; 
                    end
                    9'b000000010: alu_op = 3'b110; // MOVEFROM Ri 
                    9'b000000100: alu_op = 3'b000; // ADD  
                    9'b000001000: alu_op = 3'b001; // SUB  
                    9'b000010000: alu_op = 3'b010; // AND  
                    9'b000100000: alu_op = 3'b011; // OR   
                    9'b001000000: alu_op = 3'b100; // NOT  
                    9'b010000000: begin            // NOP
                        reg_write_en = 1'b0;
                    end
                    default: reg_write_en = 1'b0;
                endcase
            end
            
            // Type D Instructions (Immediate Operations)
            4'b1100: begin  // ADDI 
                reg_write_en   = 1'b1;
                reg_write_addr = 3'b000;
                alu_src_sel    = 1'b1;           
                alu_op         = 3'b000;         
            end
            
            4'b1101: begin  // SUBI 
                reg_write_en   = 1'b1;
                reg_write_addr = 3'b000;
                alu_src_sel    = 1'b1;           
                alu_op         = 3'b001;         
            end
            
            4'b1110: begin  // ANDI 
                reg_write_en   = 1'b1;
                reg_write_addr = 3'b000;
                alu_src_sel    = 1'b1;           
                alu_op         = 3'b010;         
            end
            
            4'b1111: begin  // ORI 
                reg_write_en   = 1'b1;
                reg_write_addr = 3'b000;
                alu_src_sel    = 1'b1;           
                alu_op         = 3'b011;         
            end
            
            default: begin
                reg_write_en = 1'b0;
            end
        endcase
    end

endmodule
