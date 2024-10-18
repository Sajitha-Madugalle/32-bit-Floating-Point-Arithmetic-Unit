`timescale 10ns / 1ns
`include "Adder.v"

module Adder_tb;
    // Testbench signals
    reg [31:0] A, B;         // Inputs to the adder
    reg control, reset;       // Control and reset signals
    wire [31:0] out;          // Output from the adder
    wire exception;           // Exception signal

    // Instantiate the Adder module
    Adder uut (
        .A(A),
        .B(B),
        .control(control),
        .reset(reset),
        .out(out),
        .exception(exception)
    );

    // Clock generation for control signal (1ms = 1_000_000ns)
    initial begin
        control = 0;
        forever #4 control = ~control;  // Toggle every 500us (1ms period)
    end

    // Test procedure
    initial begin
        $dumpfile("Adder_tb.vcd");
        $dumpvars(0, Adder_tb);
        // Initialize inputs
        reset = 0;
        A = 32'h00000000;
        B = 32'h00000000;
        // Release reset after 1ns
        #1 reset = 1;
        #1 reset = 0;
        // 1st 1ms: A = 0.25, B = 100
        #8;    // Wait for 1ms
        A = 32'h3E800000;  
        B = 32'h42C80000;  
        #8;    // Wait for 1ms
        A = 32'h3FA00000; 
        B = 32'h40200000;  

        #8;    // Wait for 1ms
        A = 32'h42C80000;
        B = 32'h3E800000;

        #8;    // Wait for 1ms
        A = 32'h42C80000;  
        B = 32'h43C80000;

        #8;    // Wait for 1ms
        A = 32'h41c8ff1e; 
        B = 32'h3faeb16d;

        #8;    // Wait for 1ms
        A = 32'h3fa00000; 
        B = 32'h3fa00000;

        #10
        $finish;
    end

    // Monitor output and exceptions
    initial begin
        $monitor("Time: %0t | A: %h | B: %h | Out: %h | Exception: %b", $time, A, B, out, exception);
    end
endmodule