`timescale 1ns / 1ps
`include "instructions.v"
module instructions_tb;
    // Testbench signals
    reg clk;
    reg loadData;
    wire [31:0] A;
    wire [31:0] B;

    // Instantiate the module under test (MUT)
    instructions uut (
        .clk(clk),
        .loadData(loadData),
        .A(A),
        .B(B)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 100 MHz clock (10 ns period)
    end

    // Test procedure
    initial begin
        $dumpfile("instructions_tb.vcd");
        $dumpvars(0, instructions_tb);
        // Initialize signals
        loadData = 0;

        // Wait for a few clock cycles
        #20;

        // Test 1: Load the first data set
        loadData = 1;
        #100; // Hold loadData high for at least one clock cycle
        loadData = 0;
        #50; // Wait for the next data set to be loaded

        // Test 2: Load the next data set
        loadData = 1;
        #15000; // Hold loadData high for at least one clock cycle
        loadData = 0;
        #10000; // Wait for the next data set to be loaded

        // Test 3: Load another data set
        loadData = 1;
        #10000; // Hold loadData high for at least one clock cycle
        loadData = 0;
        #20000; // Wait for the next data set to be loaded

        // Test 4: Attempt rapid toggling of loadData
        loadData = 1;
        #2 loadData = 0; // Short pulse, should be ignored
        #10;
        loadData = 1;
        #10; // Hold for one clock cycle
        loadData = 0;
        #20;

        // End the simulation
        $finish;
    end

    // Monitor the outputs
    initial begin
        $monitor("Time: %0t | loadData: %b | A: %h | B: %h", $time, loadData, A, B);
    end
endmodule
