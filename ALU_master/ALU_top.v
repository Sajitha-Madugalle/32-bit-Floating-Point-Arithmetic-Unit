module ALU_top (
    input clk,                // Clock signal for synchronization
    input loadData,           // Load data control signal for instructions
    input control, reset,     // Control and reset signals
    input [1:0] select,       // Operation select (00: add, 01: sub, 10: mul, 11: div)
    output [6:0] digit7,      // Seven-segment display for most significant digit
    output [6:0] digit6,      // Seven-segment display
    output [6:0] digit5,      // Seven-segment display
    output [6:0] digit4,      // Seven-segment display
    output [6:0] digit3,      // Seven-segment display
    output [6:0] digit2,      // Seven-segment display
    output [6:0] digit1,      // Seven-segment display
    output [6:0] digit0,      // Seven-segment display for least significant digit
    output reg exception,     // General exception signal
    output reg zeroDiv        // Division by zero signal
);

    // Internal signals
    wire [31:0] A_wire, B_wire;         // Wires for A and B from instructions module
    wire [31:0] add_sub_out, mul_out, div_out;
    wire add_sub_exception, mul_exception, div_exception, div_zeroDiv;
    reg addsub_signal;
    reg [31:0] result;                 // To hold the ALU result

    // Instantiate the instructions module
    instructions instructions_inst (
        .clk(clk),
        .loadData(loadData),
        .A(A_wire),
        .B(B_wire)
    );

    // Instantiate add_sub module
    add_sub add_sub_inst (
        .A(A_wire),              // Use A from instructions
        .B(B_wire),              // Use B from instructions
        .control(control),
        .reset(reset),
        .addsub(addsub_signal),
        .out(add_sub_out),
        .exception(add_sub_exception)
    );

    // Instantiate multiplier module
    multiplier mul_inst (
        .A(A_wire),              // Use A from instructions
        .B(B_wire),              // Use B from instructions
        .control(control),
        .reset(reset),
        .out(mul_out),
        .exception(mul_exception)
    );

    // Instantiate divider module
    divider div_inst (
        .DD(A_wire),             // Use A from instructions
        .DS(B_wire),             // Use B from instructions
        .control(control),
        .reset(reset),
        .out(div_out),
        .exception(div_exception),
        .zeroDiv(div_zeroDiv)
    );

    // ALU Operation
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            result <= 32'b0;
            exception <= 1'b0;
            zeroDiv <= 1'b0;
            addsub_signal <= 1'b0;
        end else begin
            case (select)
                2'b00: begin // Addition
                    addsub_signal <= 1'b0; // Set addsub to 0 for addition
                    result <= add_sub_out;
                    exception <= add_sub_exception;
                end
                2'b01: begin // Subtraction
                    addsub_signal <= 1'b1; // Set addsub to 1 for subtraction
                    result <= add_sub_out;
                    exception <= add_sub_exception;
                end
                2'b10: begin // Multiplication
                    result <= mul_out;
                    exception <= mul_exception;
                end
                2'b11: begin // Division
                    result <= div_out;
                    exception <= div_exception;
                    zeroDiv <= div_zeroDiv;
                end
                default: begin
                    result <= 32'b0;
                    exception <= 1'b0;
                    zeroDiv <= 1'b0;
                end
            endcase
        end
    end

    // Instantiate HexDisplay module for seven-segment output
    HexDisplay hex_display_inst (
        .clk(clk),             // Clock signal
        .number(result),       // Pass the result to be displayed
        .reset(reset),         // Reset signal
        .digit7(digit7),       // Seven-segment display for most significant digit
        .digit6(digit6),       // Seven-segment display
        .digit5(digit5),       // Seven-segment display
        .digit4(digit4),       // Seven-segment display
        .digit3(digit3),       // Seven-segment display
        .digit2(digit2),       // Seven-segment display
        .digit1(digit1),       // Seven-segment display
        .digit0(digit0)        // Seven-segment display for least significant digit
    );

endmodule
