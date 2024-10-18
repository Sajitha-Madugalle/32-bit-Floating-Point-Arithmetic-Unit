module divider (
    input [31:0] DD,   // Dividend in IEEE-754
    input [31:0] DS,   // Divisor in IEEE-754
    input control,     // Trigger on positive edge
    input reset,       // Reset process on positive edge
    output reg [31:0] out,    // IEEE-754 formatted result
    output reg exception,     // Exception flag
    output reg zeroDiv        // Zero division flag
);

    // Internal registers
    reg sign;
    reg [7:0] exp_DD, exp_DS, exp_out;
    reg [23:0] mant_DD, mant_DS;
    reg [47:0] remainder;  // Remainder register for division
    reg [23:0] quotient;   // Quotient for mantissa division
    integer i;

    always @(posedge control or posedge reset) begin
        if (reset) begin
            out <= 32'b0;
            exception <= 0;
            zeroDiv <= 0;
        end else begin
            // Step 1: Extract sign, exponent, and mantissa
            sign = DD[31] ^ DS[31];  // XOR for sign bit
            exp_DD = DD[30:23];
            exp_DS = DS[30:23];
            mant_DD = {1'b1, DD[22:0]};  // Add implicit 1
            mant_DS = {1'b1, DS[22:0]};  // Add implicit 1

            // Step 2: Check for divide by zero
            if (DS == 32'b0) begin
                out <= {sign, 8'hFF, 23'b0};  // Infinity
                exception <= 0;
                zeroDiv <= 1;
                // Stop further processing
            end

            // Step 3: Exponent calculation
            exp_out = exp_DD - exp_DS + 127;  // Bias adjustment

            // Step 4: Initialize remainder and quotient
            remainder = mant_DD << 24;  // Align dividend
            quotient = 0;

            // Step 5: SRT Division Algorithm
            for (i = 0; i < 24; i = i + 1) begin
                remainder = remainder << 1;  // Shift left
                if (remainder[47:24] >= mant_DS) begin
                    remainder[47:24] = remainder[47:24] - mant_DS;
                    quotient = (quotient << 1) | 1;  // Set LSB to 1
                end else begin
                    quotient = quotient << 1;  // Set LSB to 0
                end
            end

            // Step 6: Normalize quotient
            if (quotient[23] == 0) begin
                quotient = quotient << 1;
                exp_out = exp_out - 1;
            end

            // Step 7: Handle overflow/underflow
            if (exp_out >= 255) begin
                out <= {sign, 8'hFF, 23'b0};  // Infinity
                exception <= 1;
            end else if (exp_out <= 0) begin
                out <= {sign, 8'b0, 23'b0};  // Zero
                exception <= 1;
            end else begin
                out <= {sign, exp_out[7:0], quotient[22:0]};  // Valid result
                exception <= 0;
            end
        end
    end
endmodule
