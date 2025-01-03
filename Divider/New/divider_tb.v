`timescale 1ns/1ps
`include "divider.v"

module divider_tb;
    // Inputs
    reg [31:0] DD;
    reg [31:0] DS;
    reg control;
    reg reset;

    // Outputs
    wire [31:0] out;
    wire exception;
    wire zeroDiv;

    // Instantiate the divider module
    divider uut (
        .DD(DD),
        .DS(DS),
        .control(control),
        .reset(reset),
        .out(out),
        .exception(exception),
        .zeroDiv(zeroDiv)
    );

    // Task to print results
    task print_results;
        input [31:0] dividend;
        input [31:0] divisor;
        input [31:0] result;
        input exc;
        input zero;
        begin
            $display("Dividend: %h, Divisor: %h, Result: %h, Exception: %b, ZeroDiv: %b", dividend, divisor, result, exc, zero);
        end
    endtask

    // Task to apply test case
    task apply_test;
        input [31:0] dividend;
        input [31:0] divisor;
        begin
            DD = dividend;
            DS = divisor;
            #10 control = 1;
            #10 control = 0;
            #1000; // Increased delay to ensure operation completes
            $display("Intermediate Debug: Out=%h, Exception=%b, ZeroDiv=%b", out, exception, zeroDiv);
            print_results(DD, DS, out, exception, zeroDiv);
        end
    endtask

    initial begin
        // Initialize inputs
        control = 0;
        reset = 1;
        DD = 0;
        DS = 0;

        // Apply reset pulse
        #10 reset = 0;
        #10 reset = 1;
        #10 reset = 0;

        // Test 1: 2.36541 / 1.23654
        apply_test(32'h4016EB85, 32'h3F9E04F3); // 2.36541 / 1.23654

        // Test 2: 12.364 / 0
        apply_test(32'h4145D3A7, 32'h00000000); // 12.364 / 0

        // Test 3: -45.697 / 3.256
        apply_test(32'hC2311EB8, 32'h40503F16); // -45.697 / 3.256

        // Test 4: 0 / 0
        apply_test(32'h00000000, 32'h00000000); // 0 / 0

        // Test 5: 0 / 5.3654
        apply_test(32'h00000000, 32'h40AAF5C3); // 0 / 5.3654

        // Test 6: inf / inf
        apply_test(32'h7F800000, 32'h7F800000); // Infinity / Infinity

        // Test 7: NaN / NaN
        apply_test(32'hFFC00000, 32'hFFC00000); // NaN / NaN

        $stop;
    end
endmodule
