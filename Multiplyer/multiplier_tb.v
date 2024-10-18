`timescale 10ns / 1ns
`include "multiplier.v"

module multiplier_tb;
    reg [31:0] A, B;         // Inputs to the multiplier
    reg control, reset;       // Control and reset signals
    wire [31:0] out;          // Output from the multiplier
    wire exception;           // Exception signal

    // Instantiate the multiplier module
    multiplier uut (
        .A(A),
        .B(B),
        .control(control),
        .reset(reset),
        .out(out),
        .exception(exception)
    );

    // Clock generation for control signal
    initial begin
        control = 0;
        forever #10 control = ~control;  // Toggle every 10ns
    end

    // Test procedure
    initial begin
        $dumpfile("multiplier_tb.vcd");
        $dumpvars(0, multiplier_tb);

        // Initialize inputs and reset
        reset = 1;
        #5 reset = 0;

        // Test Case 1: A = 0.82, B = 1.23
        #10 A = 32'h3FD3CD36;  // IEEE 754 for 0.82
            B = 32'h3F9E46F1;  // IEEE 754 for 1.23
        #20;

        A = 32'h3E800000;  // IEEE 754 for 0.25
        B = 32'h40000000;  // IEEE 754 for 2.0
        #20;

        // 2nd test: A = 1.25, B = 4.0
        A = 32'h3FA00000;  // IEEE 754 for 1.25
        B = 32'h40800000;  // IEEE 754 for 4.0
        #20;

        A = 32'h40800000;  // IEEE 754 for 1.25
        B = 32'h3FA00000;  // IEEE 754 for 4.0
        #20;

        A = 32'h7f800000;  // IEEE 754 for 1.25
        B = 32'h3f9e46f1;  // IEEE 754 for 4.0
        #20;
        // Additional Test Cases
        A = 32'h40000000;  // 2.0
        B = 32'h40400000;  // 3.0
        #20;

        A = 32'h3F800000;  // 1.0
        B = 32'h3F800000;  // 1.0
        #20;


        $finish;
    end

    // Monitor output and exceptions
    initial begin
        $monitor("Time: %0t | A: %h | B: %h | Out: %h | Exception: %b", 
                 $time, A, B, out, exception);
    end
endmodule
