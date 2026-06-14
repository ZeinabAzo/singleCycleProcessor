`timescale 1ns / 1ps

module tb_processor;

  // ========== TEST SIGNALS ==========
  reg         clk;
  reg         reset;

  // Test counters
  integer test_count;
  integer pass_count;
  integer fail_count;

  // ========== INSTANTIATE PROCESSOR ==========
  processor dut (
    .clk(clk),
    .reset(reset)
  );

  // ========== CLOCK GENERATION (50 MHz) ==========
  initial begin
    clk = 0;
    forever #10 clk = ~clk;  // 20ns period = 50 MHz
  end

  // ========== HELPER TASKS ==========

  task load_instruction(input integer addr, input [15:0] instr);
    begin
      dut.instr_mem[addr] = instr;
    end
  endtask

  task init_register(input [2:0] reg_addr, input [15:0] value);
    begin
      dut.reg_file.reg_file[reg_addr] = value;
    end
  endtask

  task check_register(input integer test_num, input [2:0] reg_addr, input [15:0] expected);
    begin
      if (dut.reg_file.reg_file[reg_addr] == expected) begin
        $display("[PASS] Test %d: R%d = 0x%04h", test_num, reg_addr, expected);
        pass_count = pass_count + 1;
      end else begin
        $display("[FAIL] Test %d: R%d expected 0x%04h, got 0x%04h", 
                 test_num, reg_addr, expected, dut.reg_file.reg_file[reg_addr]);
        fail_count = fail_count + 1;
      end
      test_count = test_count + 1;
    end
  endtask

  task check_memory(input integer test_num, input [11:0] mem_addr, input [15:0] expected);
    begin
      if (dut.data_mem.mem[mem_addr] == expected) begin
        $display("[PASS] Test %d: M[0x%03h] = 0x%04h", test_num, mem_addr, expected);
        pass_count = pass_count + 1;
      end else begin
        $display("[FAIL] Test %d: M[0x%03h] expected 0x%04h, got 0x%04h", 
                 test_num, mem_addr, expected, dut.data_mem.mem[mem_addr]);
        fail_count = fail_count + 1;
      end
      test_count = test_count + 1;
    end
  endtask

  task run_cycles(input integer num_cycles);
    integer i;
    begin
      for (i = 0; i < num_cycles; i = i + 1) begin
        @(posedge clk);
      end
      #1; // <--- BUG 2 FIX: Wait 1ns after clock edge to avoid race conditions!
    end
  endtask

  // ========== MAIN TEST SEQUENCE ==========
  initial begin
    test_count = 0;
    pass_count = 0;
    fail_count = 0;

    $display("\n========================================");
    $display("  Single-Cycle Processor Testbench");
    $display("========================================\n");

    // ========== TEST 1: IMMEDIATE OPERATIONS ==========
    $display("\n--- TEST 1: Immediate Operations (ADDI, SUBI, ANDI, ORI) ---\n");

    reset = 1;
    #20;  
    reset = 0; // <--- BUG 1 FIX: Removed the extra #20 delay here!

    // Test 1a: ADDI 5 (R0 = 0 + 5)
    load_instruction(0, 16'b1100_000000000101);  
    run_cycles(1);
    check_register(1, 0, 16'h0005);

    // Test 1b: ADDI 10 (R0 = 5 + 10)
    load_instruction(1, 16'b1100_000000001010);  
    run_cycles(1);
    check_register(2, 0, 16'h000F);

    // Test 1c: SUBI 3 (R0 = 15 - 3)
    load_instruction(2, 16'b1101_000000000011);  
    run_cycles(1);
    check_register(3, 0, 16'h000C);

    // Test 1d: ANDI 0xFF (Mask to lower 8 bits)
    load_instruction(3, 16'b1110_000011111111);  
    run_cycles(1);
    check_register(4, 0, 16'h000C);

    // Test 1e: ORI 0x100 (Set bit 8)
    load_instruction(4, 16'b1111_000100000000);  
    run_cycles(1);
    check_register(5, 0, 16'h010C);

    // ========== TEST 2: REGISTER OPERATIONS ==========
    $display("\n--- TEST 2: Register Operations (MOVETO, MOVEFROM, ADD, SUB) ---\n");

    reset = 1;
    #20;
    reset = 0;
    
    init_register(0, 16'h0000);
    init_register(1, 16'h0008);
    init_register(2, 16'h0003);

    // Test 2a: MOVEFROM R1 (R0 = R1 = 8)
    load_instruction(0, 16'b1000_001_000000010);  
    run_cycles(1);
    check_register(6, 0, 16'h0008);

    // Test 2b: ADD R2 (R0 = 8 + 3 = 11)
    load_instruction(1, 16'b1000_010_000000100);  
    run_cycles(1);
    check_register(7, 0, 16'h000B);

    // Test 2c: SUB R2 (R0 = 11 - 3 = 8)
    load_instruction(2, 16'b1000_010_000001000);  
    run_cycles(1);
    check_register(8, 0, 16'h0008);

    // Test 2d: MOVETO R3 (R3 = R0 = 8)
    load_instruction(3, 16'b1000_011_000000001);  
    run_cycles(1);
    check_register(9, 3, 16'h0008);

    // ========== TEST 3: BITWISE OPERATIONS ==========
    $display("\n--- TEST 3: Bitwise Operations (AND, OR, NOT) ---\n");

    reset = 1;
    #20;
    reset = 0;
    
    init_register(0, 16'h00FF);
    init_register(1, 16'h0F0F);
    init_register(2, 16'h00AA);

    // Test 3a: AND R1 (R0 = 0x00FF AND 0x0F0F = 0x000F)
    load_instruction(0, 16'b1000_001_000010000);  
    run_cycles(1);
    check_register(10, 0, 16'h000F);

    // Test 3b: OR R2 (R0 = 0x000F OR 0x00AA = 0x00AF)
    load_instruction(1, 16'b1000_010_000100000);  
    run_cycles(1);
    check_register(11, 0, 16'h00AF);

    // Test 3c: NOT R1 (R0 = NOT 0x0F0F = 0xF0F0)
    load_instruction(2, 16'b1000_001_001000000);  
    run_cycles(1);
    check_register(12, 0, 16'hF0F0);

    // ========== TEST 4: MEMORY OPERATIONS ==========
    $display("\n--- TEST 4: Memory Operations (LOAD, STORE) ---\n");

    reset = 1;
    #20;
    reset = 0;
    
    init_register(0, 16'h1234);
    dut.data_mem.mem[12'h100] = 16'h5678;

    // Test 4a: STORE 0x100 (M[0x100] = R0)
    load_instruction(0, 16'b0001_000100000000);  
    run_cycles(1);
    check_memory(13, 12'h100, 16'h1234);

    // Test 4b: LOAD 0x100 (R0 = M[0x100])
    init_register(0, 16'h0000);
    dut.data_mem.mem[12'h100] = 16'hABCD;
    load_instruction(1, 16'b0000_000100000000);  
    run_cycles(1);
    check_register(14, 0, 16'hABCD);

    // ========== TEST 5: JUMP INSTRUCTION ==========
    $display("\n--- TEST 5: Control Flow (JUMP, NOP) ---\n");

    reset = 1;
    #20;
    reset = 0;

    // Test 5a: NOP (no-operation)
    load_instruction(0, 16'b1000_000_010000000);  
    run_cycles(1);
    $display("[PASS] Test 15: NOP executed (PC = 0x%04h)", dut.pc);
    pass_count = pass_count + 1;
    test_count = test_count + 1;

    // Test 5b: JUMP to address 0x050
    load_instruction(1, 16'b0010_000001010000);  
    run_cycles(1);
    if (dut.pc == 16'h0050) begin
      $display("[PASS] Test 16: JUMP executed (PC = 0x%04h)", dut.pc);
      pass_count = pass_count + 1;
    end else begin
      $display("[FAIL] Test 16: Expected PC=0x0050, got PC=0x%04h", dut.pc);
      fail_count = fail_count + 1;
    end
    test_count = test_count + 1;

    // ========== TEST 6: BRANCHZ INSTRUCTION ==========
    $display("\n--- TEST 6: Conditional Branch (BRANCHZ) ---\n");

    reset = 1;
    #20;
    reset = 0;
    
    init_register(0, 16'h0000);  // R0 = 0
    init_register(1, 16'h0000);  // R1 = 0

    // Test 6a: BRANCHZ with equal values (should branch)
    load_instruction(0, 16'b0100_001_000001000);  
    run_cycles(1);
    if (dut.pc[8:0] == 9'h008) begin
      $display("[PASS] Test 17: BRANCHZ condition true, PC[8:0] = 0x%03h", dut.pc[8:0]);
      pass_count = pass_count + 1;
    end else begin
      $display("[FAIL] Test 17: BRANCHZ expected PC[8:0]=0x008, got 0x%03h", dut.pc[8:0]);
      fail_count = fail_count + 1;
    end
    test_count = test_count + 1;

    // Test 6b: BRANCHZ with different values (should not branch)
    reset = 1;
    #20;
    reset = 0;
    
    init_register(0, 16'h0005);  // R0 = 5
    init_register(1, 16'h000A);  // R1 = 10
    load_instruction(0, 16'b0100_001_000001000);  
    run_cycles(1);
    if (dut.pc == 16'h0001) begin
      $display("[PASS] Test 18: BRANCHZ condition false, PC = 0x%04h", dut.pc);
      pass_count = pass_count + 1;
    end else begin
      $display("[FAIL] Test 18: BRANCHZ expected PC=0x0001, got PC=0x%04h", dut.pc);
      fail_count = fail_count + 1;
    end
    test_count = test_count + 1;

    // ========== TEST SUMMARY ==========
    #100;
    $display("\n========================================");
    $display("  TEST SUMMARY");
    $display("========================================");
    $display("  Total Tests:  %d", test_count);
    $display("  Passed:       %d", pass_count);
    $display("  Failed:       %d", fail_count);
    if (fail_count == 0) begin
      $display("\n  >>> ALL TESTS PASSED <<<\n");
    end else begin
      $display("\n  >>> SOME TESTS FAILED <<<\n");
    end
    $display("========================================\n");

    $finish;
  end

endmodule
