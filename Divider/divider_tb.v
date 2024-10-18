`timescale 10ns / 1ns
`include "divider.v"

module divider_tb;
    // Testbench signals
    reg [31:0] DD;          // Dividend in IEEE-754
    reg [31:0] DS;          // Divisor in IEEE-754
    reg control;            // Control signal
    reg reset;              // Reset signal
    wire [31:0] out;       // Output from the divider
    wire exception;        // Exception signal
    wire zeroDiv;         // Zero division flag

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

        // Test Case 1: Division of 4.5 by 1.5
        #5 reset = 1;  // Assert reset
        #5 reset = 0;  // De-assert reset
        DD = 32'h40900000; // 4.5 in IEEE-754
        DS = 32'h3FC00000; // 1.5 in IEEE-754
        #20;  // Wait for output to settle
        #5;  // Allow for next control pulse

        // Test Case 2: Division of 6.0 by 3.0
        DD = 32'h40C00000; // 6.0 in IEEE-754
        DS = 32'h40400000; // 3.0 in IEEE-754
        #20;  // Wait for output to settle
        #5;  // Allow for next control pulse

        // Test Case 3: Division of 3.0 by 0.0 (should handle divide by zero)
        DD = 32'h40400000; // 3.0 in IEEE-754
        DS = 32'h00000000; // 0.0 in IEEE-754
        #20;  // Wait for output to settle
        #5;  // Allow for next control pulse

        // Test Case 4: Division of 0.0 by 3.0 (should return 0)
        DD = 32'h00000000; // 0.0 in IEEE-754
        DS = 32'h40400000; // 3.0 in IEEE-754
        #20;  // Wait for output to settle
        #5;  // Allow for next control pulse

        // Test Case 5: Division of -4.5 by 1.5
        DD = 32'hC0900000; // -4.5 in IEEE-754
        DS = 32'h3FC00000; // 1.5 in IEEE-754
        #20;  // Wait for output to settle
        #5;  // Allow for next control pulse

        // Test Case 6: Division of -6.0 by 0.0 (should handle divide by zero)
        DD = 32'hC0C00000; // -6.0 in IEEE-754
        DS = 32'h00000000; // 0.0 in IEEE-754
        #20;  // Wait for output to settle
        #5;  // Allow for next control pulse

        // Test Case 7: Division of 0.0 by -3.0 (should return 0)
        DD = 32'h00000000; // 0.0 in IEEE-754
        DS = 32'hC0400000; // -3.0 in IEEE-754
        #20;  // Wait for output to settle
        #5;  // Allow for next control pulse

        // End the simulation
        #5 $finish;
    end

    // Monitor output and exceptions
    initial begin
        $monitor("Time: %0t | DD: %h | DS: %h | Out: %h | Exception: %b | ZeroDiv: %b",
                 $time, DD, DS, out, exception, zeroDiv);
    end
endmodule
