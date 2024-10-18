module multiplier (
    input [31:0] A, B,       // IEEE 754 inputs
    input control, reset,     // Control and reset signals
    output reg [31:0] out,    // IEEE 754 result
    output reg exception      // Exception flag
);
    // Internal signals for IEEE 754 decomposition
    reg sign_A, sign_B, sign_out;  // Signs
    reg [7:0] exp_A, exp_B, exp_out;  // Exponents
    reg [23:0] mant_A, mant_B;  // 24-bit mantissas with implied 1
    reg [47:0] product;  // Product from Booth's multiplication

    // Booth’s multiplication logic for mantissas (unsigned)
    function [47:0] booth_multiply(input [23:0] m1, input [23:0] m2);
        reg [47:0] P;  // Partial product
        integer i;
        begin
            P = 0;
            for (i = 0; i < 24; i = i + 1) begin
                if (m2[i])  // If multiplier bit is 1, add shifted multiplicand
                    P = P + (m1 << i);
            end
            booth_multiply = P;  // Return the final product
        end
    endfunction

    // Main logic: IEEE-754 multiplication using Booth’s algorithm
    always @(posedge control or posedge reset) begin
        if (reset) begin
            out <= 32'b0;
            exception <= 0;
        end else begin
            // Step 1: Decompose inputs A and B
            sign_A = A[31];
            sign_B = B[31];
            exp_A = A[30:23];
            exp_B = B[30:23];
            mant_A = {1'b1, A[22:0]};  // Add implied leading 1
            mant_B = {1'b1, B[22:0]};  // Add implied leading 1

            // Step 2: Compute output sign (XOR for signs)
            sign_out = sign_A ^ sign_B;

            // Step 3: Compute exponent
            exp_out = exp_A + exp_B - 127;

            // Step 4: Multiply mantissas using Booth’s algorithm
            product = booth_multiply(mant_A, mant_B);

            // Step 5: Normalize the product (shift if necessary)
            if (product[47]) begin
                out[22:0] = product[46:24];  // Take top 23 bits
                exp_out = exp_out + 1;       // Adjust exponent
            end else begin
                out[22:0] = product[45:23];  // Take top 23 bits
            end
            
            // Step 6: Assemble the IEEE-754 result
            out[31] = sign_out;
            out[30:23] = exp_out;

            // Step 7: Check for exceptions (overflow)
            exception = (exp_out >= 255) ? 1 : 0;
        end
    end
endmodule
