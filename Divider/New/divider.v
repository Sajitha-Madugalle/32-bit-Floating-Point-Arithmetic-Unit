module divider (
    input [31:0] DD,    // Dividend in IEEE-754
    input [31:0] DS,    // Divisor in IEEE-754
    input control,      // Trigger on positive edge
    input reset,        // Reset process on positive edge
    output reg [31:0] out,      // IEEE-754 formatted result
    output reg exception,       // Exception flag
    output reg zeroDiv          // Zero division flag
);

    // Internal signals
    reg [7:0] exp_dd, exp_ds, exp_out;
    reg [23:0] mant_dd, mant_ds;
    reg [24:0] mant_out;
    reg sign_dd, sign_ds, sign_out;
    integer i;

    function [24:0] performDiv;
        input [23:0] DD; // Dividend (24-bit)
        input [23:0] DS; // Divisor (24-bit)

        reg [48:0] dividend; // Extended dividend to handle fraction bits
        reg [48:0] divisor;  // Extended divisor to align for subtraction
        reg [24:0] quotient; // Result (25-bit)
        integer i;

        begin
            // Initialize dividend and divisor
            dividend = {DD, 25'b0}; // Append 25 zeros to dividend for fractional bits
            divisor = {DS, 25'b0}; // Align divisor with the dividend
            quotient = 25'b0;      // Initialize quotient to 0

            // Perform long division for 25 steps (1 integer + 24 fraction bits)
            for (i = 24; i >= 0; i = i - 1) begin
                if (dividend >= divisor) begin
                    dividend = dividend - divisor;
                    quotient[i] = 1'b1; // Set current quotient bit to 1
                end else begin
                    quotient[i] = 1'b0; // Set current quotient bit to 0
                end
                divisor = divisor >> 1; // Shift divisor right by 1 bit
            end

            // Return the final quotient
            performDiv = quotient;
        end
    endfunction

    // Always block for control and reset logic
    always @(posedge control or posedge reset) begin
        if (reset) begin
            out <= 32'b0;
            exception <= 1'b0;
            zeroDiv <= 1'b0;
        end else begin
            // Extract fields
            sign_dd = DD[31];
            sign_ds = DS[31];
            exp_dd = DD[30:23];
            exp_ds = DS[30:23];
            mant_dd = {1'b1, DD[22:0]}; // Normalized mantissa
            mant_ds = {1'b1, DS[22:0]}; // Normalized mantissa

            // Sign of the result
            sign_out = sign_dd ^ sign_ds;

            // Check for division by zero
            if (DS == 0) begin
                zeroDiv <= 1;
                if (DD == 0) begin
                    out <= 32'hFFC00000; // NaN
                    exception <= 1;
                end else begin
                    out <= {sign_out, 8'hFF, 23'b0}; // Infinity
                    exception <= 1;
                end
            end else if (DD == 0) begin
                zeroDiv <= 0;
                exception <= 0;
                out <= 32'h00000000; // Zero result
            end else begin
                zeroDiv <= 0;
                exception <= 0;

                // Exponent calculation
                exp_out = exp_dd - exp_ds + 127;
                mant_out = performDiv(mant_dd, mant_ds);

                if (mant_out[24] == 1) begin
                    out <= {sign_out, exp_out[7:0], mant_out[23:1]};
                end else begin
                    exp_out = exp_out - 1;
                    out <= {sign_out, exp_out[7:0], mant_out[22:0]};
                end
            end
        end
    end
endmodule
