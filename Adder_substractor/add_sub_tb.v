`timescale 10ns / 1ns
`include "add_sub.v"

module add_sub_tb;
    // Testbench signals
    reg [31:0] A, B;         // Inputs to the adder
    reg control, reset;       // Control and reset signals
    reg addsub;               // Add/subtract signal
    wire [31:0] out;          // Output from the adder
    wire exception;           // Exception signal

    add_sub uut (
        .A(A),
        .B(B),
        .control(control),
        .reset(reset),
        .addsub(addsub),
        .out(out),
        .exception(exception)
    );

    initial begin
        control = 0;
        forever #4 control = ~control;  
    end


    initial begin
        $dumpfile("add_sub_tb.vcd");
        $dumpvars(0, add_sub_tb);
 
        reset = 0;
        control = 0;
        addsub = 0;
        A = 32'h00000000;
        B = 32'h00000000;

        #1 reset = 1;
        #1 reset = 0;
   
        #8;     
        A = 32'h3E800000;  
        B = 32'h42C80000;  
        #8;     
        A = 32'h3FA00000; 
        B = 32'h40200000;  

        #8;
        addsub = 1;     
        A = 32'h42C80000;
        B = 32'h3E800000;
        #8 addsub = 0;

        #8;     
        A = 32'h42C80000;  
        B = 32'h43C80000;

        #8;     
        A = 32'h41c8ff1e; 
        B = 32'hbfc74b5a;

        #8;
        addsub = 1;
        A = 32'h3fa00000; 
        B = 32'h3fa00000;

        #10
        $finish;
    end

    initial begin
        $monitor("Time: %0t | A: %h | B: %h | Out: %h | Exception: %b", $time, A, B, out, exception);
    end
endmodule