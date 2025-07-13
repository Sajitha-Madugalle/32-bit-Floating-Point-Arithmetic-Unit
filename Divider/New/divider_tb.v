`timescale 10ns / 1ns
`include "divider.v"

module divider_tb;
    // Testbench signals
    reg [31:0] DD;          // Dividend in IEEE-754
    reg [31:0] DS;          // Divisor in IEEE-754
    reg control;            // Control signal
    reg reset;              // Reset signal
    wire [31:0] out;        // Output from the divider
    wire exception;         // Exception signal
    wire zeroDiv;           // Zero division flag

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

    // Clock generation for control signal
    initial begin
        control = 0;
        forever #10 control = ~control;  // Toggle every 10ns
    end

    // Test procedure
    initial begin
        $dumpfile("divider_tb.vcd");
        $dumpvars(0, divider_tb);

        // Initialize inputs
        reset = 0;
        DD = 32'h00000000;  // Initially zero
        DS = 32'h00000000;  // Initially zero

        // Test Case 1: Division of 2.345 by -365.214
        #5 reset = 1;  // Assert reset
        #5 reset = 0;  // De-assert reset
        DD = 32'h4012C000; // 2.345 in IEEE-754
        DS = 32'hC33B660A; // -365.214 in IEEE-754
        #2000;  // Wait for output to settle

        // Test Case 2: Division of 45.36 by 12
        DD = 32'h42356000; // 45.36 in IEEE-754
        DS = 32'h41400000; // 12 in IEEE-754
        #2000;  // Wait for output to settle

        // End the simulation
        #500 $finish;
    end

    // Monitor output and exceptions
    initial begin
        $monitor("Time: %0t | DD: %h | DS: %h | Out: %h | Exception: %b | ZeroDiv: %b",
                 $time, DD, DS, out, exception, zeroDiv);
    end
endmodule

//10111100101000010011110100011001
//10111100010010000111100010011010