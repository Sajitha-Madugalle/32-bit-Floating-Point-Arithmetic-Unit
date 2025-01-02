module instructions (
    input clk,
    input loadData,
    output reg [31:0] A,
    output reg [31:0] B
);
    // Memory for A and B values
    reg [31:0] A_mem [0:15];
    reg [31:0] B_mem [0:15];
    reg [3:0] index;            // Index for current data
    reg loadData_prev;          // Register to detect edge of loadData
    reg loadData_valid;         // Signal to trigger data transfer

    initial begin
        // Initialize memory
        A_mem[0]=32'h401762b7; B_mem[0]=32'h43615eb0; // 2.3654 225.36987
        A_mem[1]=32'hc3e42917; B_mem[1]=32'hc6175d4d; // -456.321 -9687.325
        A_mem[2]=32'h3f800000; B_mem[2]=32'h40000000; // 1 2
        //invalid number: 3.6547 3..2569
        A_mem[3]=32'h7f800000; B_mem[3]=32'h7fc00000; // inf nan
        A_mem[4]=32'h4069e9e2; B_mem[4]=32'h42c0b732; // 3.6549 96.3578
        A_mem[5]=32'hc4601492; B_mem[5]=32'hbebb15b5; // -896.3214 -.3654
        //invalid number: lkhbjn hfhgv
        A_mem[6]=32'hc2c4bb16; B_mem[6]=32'h43e42925; // -98.3654 456.321456
        A_mem[7]=32'h429cbae1; B_mem[7]=32'hc1b80000; // 78.365 -23.
        A_mem[8]=32'h7f800000; B_mem[8]=32'h43e2a9cb; // inf 453.3265
        A_mem[9]=32'h00000000; B_mem[9]=32'h00000000; // 0 0
        A_mem[10]=32'h40912e73; B_mem[10]=32'h00000000; // 4.53692 0
        A_mem[11]=32'h00000000; B_mem[11]=32'h3ea497b1; // 0 0.3214698
        index = 0;               // Start at first data pair 
        A = 32'b0;
        B = 32'b0;
        loadData_prev = 0;
        loadData_valid = 0;
    end

    // Detect loadData edge
    always @(posedge clk) begin
        if (loadData && !loadData_prev) begin
            // Rising edge of loadData detected
            loadData_valid <= 1;
        end

        // Update loadData_prev to track edge
        loadData_prev <= loadData;

        // Load data on the first rising edge after loadData goes high
        if (loadData_valid) begin
            A <= A_mem[index];
            B <= B_mem[index];
            index <= index + 1;

            if (index == 11) begin
                index <= 0;        // Wrap around if last data is reached
            end

            loadData_valid <= 0;   // Clear valid signal after loading
        end
    end
endmodule