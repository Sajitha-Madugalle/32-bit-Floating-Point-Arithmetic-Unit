module Adder (
    input [31:0] A, B,          // IEEE 754 input numbers
    input control, reset,       // Control and reset signals
    output reg [31:0] out,      // IEEE 754 result
    output reg exception        // Exception signal
);
    // Internal signals
    reg [7:0] expA, expB, expOut; // Exponent
    reg [24:0] mantA, mantB, mantOut; // Mantissa (with leading bits)
    reg signA, signB, signOut;   // Sign bits
    reg [7:0] expDiff;

    // Sequential logic triggered by control or reset
    always @(posedge control or posedge reset) begin
        if (reset) begin
            out <= 32'h00000000;      // Reset the output
            exception <= 0;           // Reset exception flag
        end else begin
            // Step 1: Extract sign, exponent, and mantissa
            signA = A[31];
            signB = B[31];
            expA = A[30:23];
            expB = B[30:23];
            mantA = {2'b01, A[22:0]}; // Add 2 leading bits
            mantB = {2'b01, B[22:0]}; // Add 2 leading bits

            // Step 2: Compute exponent difference and align mantissas
            if (expA > expB) begin
                expDiff = expA - expB;
                mantB = mantB >> expDiff;
                expOut = expA;
            end else if (expA < expB) begin
                expDiff = expB - expA;
                mantA = mantA >> expDiff;
                expOut = expB;
            end else begin
                expOut = expA;
            end

            // Step 3: Add mantissas
            mantOut = mantA + mantB;

            // Step 4: Normalize the result
            if (mantOut[24:23] == 2'b11) begin
                mantOut = mantOut >> 1;
                expOut = expOut + 1;
            end else if (mantOut[24:23] == 2'b00) begin
                while (mantOut[23] == 0) begin
                    mantOut = mantOut << 1;
                    expOut = expOut - 1;
                end
            end else if (mantOut[24:23] == 2'b10) begin
                while (mantOut[23] == 0) begin
                    mantOut = mantOut >> 1;
                    expOut = expOut + 1;
                end
            end

            // Step 5: Assemble the final IEEE 754 output
            out <= {signA, expOut, mantOut[22:0]};
            exception <= (expOut == 8'hFF) ? 1 : 0; // Check for overflow
        end
    end
endmodule
