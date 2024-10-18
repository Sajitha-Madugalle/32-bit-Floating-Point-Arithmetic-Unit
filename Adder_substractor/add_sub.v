module add_sub(
    input [31:0] A, B,         // IEEE 754 input numbers
    input control, reset, addsub, // Control, reset, and add/subtract signals
    output reg [31:0] out,     // IEEE 754 result
    output reg exception       // Exception signal
);
    // Internal signals
    reg [7:0] expA, expB, expOut;     // Exponents
    reg [24:0] mantA, mantB, mantOut; // Mantissas (with leading bits)
    reg signA, signB, signOut;        // Signs
    reg [7:0] expDiff;                // Exponent difference
    reg operation;                    // Actual operation: add (0) / subtract (1)

    // Sequential logic triggered by control or reset
    always @(posedge control or posedge reset) begin
        if (reset) begin
            out <= 32'h00000000;  // Reset the output
            exception <= 0;       // Reset exception flag
        end else begin
            // Step 1: Extract sign, exponent, and mantissa
            signA = A[31];
            signB = B[31] ^ addsub; // Invert sign of B if subtracting
            expA = A[30:23];
            expB = B[30:23];
            mantA = {2'b01, A[22:0]}; // Add leading bits to mantissa
            mantB = {2'b01, B[22:0]}; // Add leading bits to mantissa

            // Step 2: Align exponents and mantissas
            if (expA > expB) begin
                expDiff = expA - expB;
                mantB = mantB >> expDiff;
                expOut = expA;
            end else begin
                expDiff = expB - expA;
                mantA = mantA >> expDiff;
                expOut = expB;
            end

            // Step 3: Add or subtract mantissas based on signs
            if (signA == signB) begin
                // If signs are the same, perform addition
                mantOut = mantA + mantB;
                signOut = signA;
            end else begin
                // If signs differ, perform subtraction
                if (mantA >= mantB) begin
                    mantOut = mantA - mantB;
                    signOut = signA;
                end else begin
                    mantOut = mantB - mantA;
                    signOut = signB;
                end
            end

            // Step 4: Normalize the result
            if (mantOut[24]) begin
                mantOut = mantOut >> 1;
                expOut = expOut + 1;
            end else begin
                while (mantOut[23] == 0 && expOut > 0) begin
                    mantOut = mantOut << 1;
                    expOut = expOut - 1;
                end
            end

            // Step 5: Assemble the final IEEE 754 result
            out <= {signOut, expOut, mantOut[22:0]};
            exception <= (expOut == 8'hFF); // Set exception on overflow
        end
    end
endmodule
