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
    reg [23:0] mant_dd, mant_ds, mant_out;
    reg sign_dd, sign_ds, sign_out;
    integer i;

    function [47:0] non_restoring_division;
        input [23:0] Mant_DD;
        input [23:0] Mant_DS;
        integer i;
        reg [47:0] A, Q, M;
        begin
            Q = {Mant_DD, 24'b0};
            M = {Mant_DS, 24'b0};
            A = 48'b0;

            for (i = 0; i < 24; i = i + 1) begin
                A = {A[46:0], Q[47]};
                Q = {Q[46:0], 1'b0};

                A = A - M;
                if (A[47]) begin
                    A = A + M;
                    Q[0] = 1'b0;
                end else begin
                    Q[0] = 1'b1;
                end
            end
            non_restoring_division = Q;
        end
    endfunction

    always @(posedge control or posedge reset) begin
        if (reset) begin
            out <= 0;
            exception <= 0;
            zeroDiv <= 0;
        end else begin
            // Extract fields
            sign_dd = DD[31];
            sign_ds = DS[31];
            exp_dd = DD[30:23];
            exp_ds = DS[30:23];
            mant_dd = {1'b1, DD[22:0]}; // Normalized mantissa
            mant_ds = {1'b1, DS[22:0]}; // Normalized mantissa

            $display("Debug: Extracted Fields -> sign_dd=%b, sign_ds=%b, exp_dd=%h, exp_ds=%h, mant_dd=%h, mant_ds=%h",
                sign_dd, sign_ds, exp_dd, exp_ds, mant_dd, mant_ds);

            // Sign of the result
            sign_out = sign_dd ^ sign_ds;

            // Check for division by zero
            if (DS == 0) begin
                zeroDiv <= 1;
                if (DD == 0)
                    out <= 32'hFFC00000; // NaN
                    exception <= 1;
                else
                    out <= 32'h7F800000; // Infinity
            end else if (DD == 0) begin
                zeroDiv <= 0;
                exception <= 0;
                out <= 32'h00000000; // Zero result
            end else begin
                zeroDiv <= 0;
                exception <= 0;

                // Exponent calculation
                exp_out = exp_dd - exp_ds + 127;
                mant_out = non_restoring_division(mant_dd, mant_ds);

                $display("Debug: Before Normalization -> exp_out=%h, mant_out=%h", exp_out, mant_out);

                for (i = 0; i < 24; i = i + 1) begin
                    if (mant_out[47] != 1 && exp_out > 0) begin
                        mant_out = mant_out << 1;
                        exp_out = exp_out - 1;
                    end
                end

                $display("Debug: After Normalization -> exp_out=%h, mant_out=%h", exp_out, mant_out);
            end
            // Pack the result
            out <= {sign_out, exp_out[7:0], mant_out[46:24]};
            $display("Debug: Packed Result -> out=%h", out);
        end
    end

endmodule
