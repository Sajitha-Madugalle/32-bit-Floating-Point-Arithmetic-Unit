module ALU_top (
    input [31:0] A, B,        // 32-bit IEEE 754 inputs
    input control, reset,     // Control and reset signals
    input [1:0] select,       // Operation select (00: add, 01: sub, 10: mul, 11: div)
    output reg [31:0] out,    // 32-bit IEEE 754 output
    output reg exception,     // General exception signal
    output reg zeroDiv        // Division by zero signal
);
    // Internal signals
    wire [31:0] add_sub_out, mul_out, div_out;
    wire add_sub_exception, mul_exception, div_exception, div_zeroDiv;
    reg addsub_signal;

    // Instantiate add_sub module
    add_sub add_sub_inst (
        .A(A),
        .B(B),
        .control(control),
        .reset(reset),
        .addsub(addsub_signal),
        .out(add_sub_out),
        .exception(add_sub_exception)
    );

    // Instantiate multiplier module
    multiplier mul_inst (
        .A(A),
        .B(B),
        .control(control),
        .reset(reset),
        .out(mul_out),
        .exception(mul_exception)
    );

    // Instantiate divider module
    divider div_inst (
        .DD(A),        // Dividend
        .DS(B),        // Divisor
        .control(control),
        .reset(reset),
        .out(div_out),
        .exception(div_exception),
        .zeroDiv(div_zeroDiv)
    );

    // ALU Operation
    always @(*) begin
        // Initialize outputs
        out = 32'b0;
        exception = 1'b0;
        zeroDiv = 1'b0;

        case (select)
            2'b00: begin // Addition
                addsub_signal = 1'b0; // Set addsub to 0 for addition
                out = add_sub_out;
                exception = add_sub_exception;
            end
            2'b01: begin // Subtraction
                addsub_signal = 1'b1; // Set addsub to 1 for subtraction
                out = add_sub_out;
                exception = add_sub_exception;
            end
            2'b10: begin // Multiplication
                out = mul_out;
                exception = mul_exception;
            end
            2'b11: begin // Division
                out = div_out;
                exception = div_exception;
                zeroDiv = div_zeroDiv;
            end
        endcase
    end

endmodule
