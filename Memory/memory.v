module memory (
    input clk,                // Clock signal
    input dataready,          // Signal to start data sending
    input stop,               // Signal to stop data temporarily
    output reg num1_bit,      // Bitwise output of num1 (IEEE 754 floating point)
    output reg num2_bit,      // Bitwise output of num2 (IEEE 754 floating point)
    output reg select0,       // First bit of selection signal output
    output reg select1,       // Second bit of selection signal output
    output reg ok             // Output signal to indicate data sending completion
);

    // Four data sets
    reg [31:0] num1_data [3:0]; // Array of num1 values
    reg [31:0] num2_data [3:0]; // Array of num2 values
    reg [1:0] select_data [3:0]; // Array of select values
    
    reg [1:0] data_index;    // Index to track which data set is being sent
    reg [5:0] bit_index;     // Index to track which bit is being sent (0 to 31)

    // State machine states
    reg [1:0] state;  
    localparam IDLE = 2'b00, SEND_DATA = 2'b01, WAIT_STOP = 2'b10;

    // Initialization of data sets
    initial begin
        num1_data[0] = 32'h4048F5C3;  // 3.14 in IEEE 754
        num2_data[0] = 32'h41AD0651;  // 21.654 in IEEE 754
        select_data[0] = 2'b00;
        
        num1_data[1] = 32'hC0490FDB;  // -3.14 in IEEE 754
        num2_data[1] = 32'h41B2C8EC;  // 22.45 in IEEE 754
        select_data[1] = 2'b01;
        
        num1_data[2] = 32'h40C90FDB;  // 6.28318 (2 * pi) in IEEE 754
        num2_data[2] = 32'h41200000;  // 10.0 in IEEE 754
        select_data[2] = 2'b10;
        
        num1_data[3] = 32'hC1200000;  // -10.0 in IEEE 754
        num2_data[3] = 32'h412C0000;  // 10.75 in IEEE 754
        select_data[3] = 2'b11;
        
        // Initialize other signals
        data_index = 0;
        bit_index = 0;
        num1_bit = 0;
        num2_bit = 0;
        select0 = 0;
        select1 = 0;
        ok = 0;
        state = IDLE;
    end

    always @(posedge clk) begin
        case (state)
            IDLE: begin
                if (dataready == 1'b1) begin
                    // Start sending data when dataready goes high
                    bit_index <= 31;  // Start with MSB
                    select0 <= select_data[data_index][0];
                    select1 <= select_data[data_index][1];
                    ok <= 1'b0;  // Clear ok signal
                    state <= SEND_DATA;
                end
            end

            SEND_DATA: begin
                if (!stop) begin
                    // Send bits of num1 and num2 one by one
                    num1_bit <= num1_data[data_index][bit_index];  // Send MSB first
                    num2_bit <= num2_data[data_index][bit_index];  // Send MSB first
                    
                    if (bit_index > 0) begin
                        bit_index <= bit_index - 1;
                    end else begin
                        // After all 32 bits are sent, signal completion
                        ok <= 1'b1;
                        state <= WAIT_STOP;
                    end
                end
            end

            WAIT_STOP: begin
                if (stop == 1'b1) begin
                    // Stop the process temporarily
                    ok <= 1'b0;      // Clear ok
                    num1_bit <= 1'b0; // Clear num1 bit
                    num2_bit <= 1'b0; // Clear num2 bit
                    select0 <= 1'b0;  // Clear select0
                    select1 <= 1'b0;  // Clear select1

                    // Move to the next data set
                    if (data_index < 3) begin
                        data_index <= data_index + 1;
                    end else begin
                        data_index <= 0; // Loop back to the first data set
                    end
                    state <= IDLE;  // Go back to idle state
                end
            end
        endcase
    end
endmodule