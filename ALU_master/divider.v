module divider (
    input [31:0] DD,    // Dividend in IEEE-754
    input [31:0] DS,    // Divisor in IEEE-754
    input control,      // Trigger on positive edge
    input reset,        // Reset process on positive edge
    output reg [31:0] out,      // IEEE-754 formatted result
    output reg exception,       // Exception flag
    output reg zeroDiv          // Zero division flag
);

    // Internal registers
    reg sign;
    reg [7:0] exp_DD, exp_DS, exp_out;
    reg [23:0] mant_DD, mant_DS;
    reg [23:0] quotient;  // Quotient for mantissa division
    integer i;

    // Division function for normalized mantissas
    function [23:0] NRDivisor(
        input [23:0] D1,  // Dividend mantissa
        input [23:0] D2   // Divisor mantissa
    );
        reg [23:0] remainder;
        reg [23:0] temp_quotient;
        reg [23:0] temp_remainder;
        integer i;

        begin
            // Initialize quotient and remainder
            temp_quotient = 0;
            temp_remainder = 0;

            for (i = 23; i >= 0; i = i - 1) begin
                // Shift remainder left and bring down the next bit of dividend
                temp_remainder = (temp_remainder << 1) | D1[i];

                if (temp_remainder >= D2) begin
                    // Subtract divisor from remainder
                    temp_remainder = temp_remainder - D2;
                    // Set the i-th bit of the quotient to 1
                    temp_quotient = temp_quotient | (1 << i);
                end
            end

            // Return the computed quotient
            NRDivisor = temp_quotient;
        end
    endfunction

    // Always block triggered on control or reset signal
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
            mant_DD = {1'b1, DD[22:0]};  // Add implicit 1 for normalized mantissa
            mant_DS = {1'b1, DS[22:0]};  // Add implicit 1 for normalized mantissa

            // Step 2: Check for divide by zero
            if (DS == 32'b0) begin
                out <= {sign, 8'hFF, 23'b0};  // Infinity
                exception <= 0;
                zeroDiv <= 1;
            end else begin
                zeroDiv <= 0;

                // Step 3: Exponent calculation
                exp_out = exp_DD - exp_DS + 127;  // Adjust bias

                // Step 4: Perform mantissa division
                quotient = NRDivisor(mant_DD, mant_DS);

                // Step 5: Normalize quotient
						for (i = 0; i < 23 && quotient[23] == 0 && exp_out > 0; i = i + 1) begin
							 quotient = quotient << 1;
							 exp_out = exp_out - 1;
						end

                // Step 6: Handle overflow/underflow
                if (exp_out >= 255) begin
                    out <= {sign, 8'hFF, 23'b0};  // Infinity
                    exception <= 1;
                end else if (exp_out <= 0) begin
                    out <= {sign, 8'b0, 23'b0};  // Zero
                    exception <= 1;
                end else begin
                    // Step 7: Remove the leading 1 in normalized mantissa for output
                    out <= {sign, exp_out[7:0], quotient[22:0]};  // Valid result
                    exception <= 0;
                end
            end
        end
    end
endmodule
