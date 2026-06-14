
`timescale 1ns/1ps

module processor_tb;

    // Clock and reset
    reg clk;
    reg rst;

    processor DUT (
        .clk(clk),
        .reset(rst) 
    );


    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reset sequence
    initial begin
        rst = 1;
        #20;
        rst = 0;
    end

    // Program loading and monitoring
    initial begin
        $readmemh("program.hex", DUT.instr_mem);

        // Run simulation for enough time
        #200;

        $display("=================================");
        $display(" Simulation finished");
        $display("=================================");
    end

    // "Judge" Block
    initial begin
        #150; // Wait for the program to finish running

        // Check if R1 equals 10 (16'd10)
        if (DUT.reg_file.reg_file[1] == 16'd10) begin
            $display(">>>> FINAL RESULT: PASS <<<<");
            $display("R1 successfully holds 10!");
        end else begin
            $display(">>>> FINAL RESULT: FAIL <<<<");
            $display("R1 expected 10, but got %d", DUT.reg_file.reg_file[1]);
        end

        $finish;
    end

endmodule