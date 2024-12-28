module HexDisplay(
    input wire clk,              // 50 MHz clock signal
    input wire reset,            // Reset signal
    input wire [31:0] number,    // 32-bit input number
    output reg [6:0] digit7,     // Segments for display 7 (most significant digit)
    output reg [6:0] digit6,     // Segments for display 6
    output reg [6:0] digit5,     // Segments for display 5
    output reg [6:0] digit4,     // Segments for display 4
    output reg [6:0] digit3,     // Segments for display 3
    output reg [6:0] digit2,     // Segments for display 2
    output reg [6:0] digit1,     // Segments for display 1
    output reg [6:0] digit0,     // Segments for display 0 (least significant digit)
    output reg [31:0] debug_number // Debug output to monitor the input
);          // Slower clock at 60 Hz

    // Hexadecimal to seven-segment decoder
    function [6:0] hex_to_segments;
        input [3:0] hex;
        begin
            case (hex)
                4'h0: hex_to_segments = 7'b1000000;
                4'h1: hex_to_segments = 7'b1111001;
                4'h2: hex_to_segments = 7'b0100100;
                4'h3: hex_to_segments = 7'b0110000;
                4'h4: hex_to_segments = 7'b0011001;
                4'h5: hex_to_segments = 7'b0010010;
                4'h6: hex_to_segments = 7'b0000010;
                4'h7: hex_to_segments = 7'b1111000;
                4'h8: hex_to_segments = 7'b0000000;
                4'h9: hex_to_segments = 7'b0010000;
                4'hA: hex_to_segments = 7'b0001000;
                4'hB: hex_to_segments = 7'b0000011;
                4'hC: hex_to_segments = 7'b1000110;
                4'hD: hex_to_segments = 7'b0100001;
                4'hE: hex_to_segments = 7'b0000110;
                4'hF: hex_to_segments = 7'b0001110;
                default: hex_to_segments = 7'b1111111; // All segments off
            endcase
        end
    endfunction

    // Update the current digit and assign values to the outputs
    always@(*) begin
        if (reset) begin
            digit7 <= 7'b1111111;
            digit6 <= 7'b1111111;
            digit5 <= 7'b1111111;
            digit4 <= 7'b1111111;
            digit3 <= 7'b1111111;
            digit2 <= 7'b1111111;
            digit1 <= 7'b1111111;
            digit0 <= 7'b1111111;
            debug_number <= 32'b0; // Clear debug value on reset
        end else begin
            digit0 <= hex_to_segments(number[3:0]);
            digit1 <= hex_to_segments(number[7:4]);
            digit2 <= hex_to_segments(number[11:8]);
            digit3 <= hex_to_segments(number[15:12]);
            digit4 <= hex_to_segments(number[19:16]);
            digit5 <= hex_to_segments(number[23:20]);
            digit6 <= hex_to_segments(number[27:24]);
            digit7 <= hex_to_segments(number[31:28]);
            debug_number <= number; // Update debug value with input
        end
    end

endmodule
