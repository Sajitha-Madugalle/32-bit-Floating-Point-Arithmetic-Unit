`timescale 10ns / 1ns
`include "ALU_top.v"
`include "divider.v"
`include "multiplier.v"
`include "add_sub.v"

module ALU_top_tb;
    // Testbench signals
    reg [31:0] A, B;          // Inputs to the ALU
    reg control, reset;       // Control and reset signals
    reg [1:0] select;         // Select signal for operations
    wire [31:0] out;          // Output from the ALU
    wire exception;           // Exception flag
    wire zeroDiv;             // Zero division flag

    // Instantiate the ALU_top module
    ALU_top uut (
        .A(A),
        .B(B),
        .control(control),
        .reset(reset),
        .select(select),
        .out(out),
        .exception(exception),
        .zeroDiv(zeroDiv)
    );

    // Clock generation for control signal (50Hz = 20ms period, or 200,000 clock cycles at 10ns time scale)
    initial begin
        control = 0;
        forever #50 control = ~control;  // Toggle every 100 cycles (1µs per half-cycle at 10ns scale)
    end

    // Test procedure
    initial begin
        $dumpfile("ALU_top_tb.vcd");
        $dumpvars(0, ALU_top_tb);

        // Initialize inputs
        reset = 0;
        A = 32'h00000000;
        B = 32'h00000000;
        select = 2'b00;

        // Reset signal
        #5 reset = 1;
        #5 reset = 0;

        // Test addition (++,+-,-+,--)
        select = 2'b00; // Add
        #100 A = 32'h401762b7; B = 32'h43b69f5c; // 1.0 + 2.0
        #100 A = 32'h401762b7; B = 32'hc3b69f5c; // 1.0 + (-2.0)
        #100 A = 32'hBF800000; B = 32'h40000000; // -1.0 + 2.0
        #100 A = 32'hBF800000; B = 32'hC0000000; // -1.0 + (-2.0)

        // Test subtraction (++,+-,-+,--)
        select = 2'b01; // Sub
        #100 A = 32'h3F800000; B = 32'h40000000; // 1.0 - 2.0
        #100 A = 32'h3F800000; B = 32'hC0000000; // 1.0 - (-2.0)
        #100 A = 32'hBF800000; B = 32'h40000000; // -1.0 - 2.0
        #100 A = 32'hBF800000; B = 32'hC0000000; // -1.0 - (-2.0)

        // Test multiplication (++,+-,-+,--)
        select = 2'b10; // Mul
        #100 A = 32'h3F800000; B = 32'h40000000; // 1.0 * 2.0
        #100 A = 32'h3F800000; B = 32'hC0000000; // 1.0 * (-2.0)
        #100 A = 32'hBF800000; B = 32'h40000000; // -1.0 * 2.0
        #100 A = 32'hBF800000; B = 32'hC0000000; // -1.0 * (-2.0)

        // Test division (++,+-,-+,--)
        select = 2'b11; // Div
        #100 A = 32'h3F800000; B = 32'h40000000; // 1.0 / 2.0
        #100 A = 32'h3F800000; B = 32'hC0000000; // 1.0 / (-2.0)
        #100 A = 32'hBF800000; B = 32'h40000000; // -1.0 / 2.0
        #100 A = 32'hBF800000; B = 32'hC0000000; // -1.0 / (-2.0)

        // Test exception cases
        #100 A = 32'h7F800000; B = 32'h7F800000; // Inf + Inf (exception expected)
        
        // Test zero division
        #100 A = 32'h3F800000; B = 32'h00000000; // 1.0 / 0.0 (zero division expected)

        #200 $finish; // End simulation
    end

    // Monitor outputs
initial begin
    // Monitor the signals at every positive edge of the control signal
    forever @(posedge control) begin
        #10
        $display("%0t %b %h %h %h %b %b", 
                 $time, select, A, B, out, exception, zeroDiv);
    end
end

endmodule
