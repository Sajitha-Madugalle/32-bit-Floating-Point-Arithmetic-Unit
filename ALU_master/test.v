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
        A_mem[0]=32'h401421e6; B_mem[0]=32'h427cfb96;
        //invalid number: 45.3216789
        A_mem[1]=32'hc7f1831e; B_mem[1]=32'hc261624e;
        A_mem[2]=32'h7fc00000; B_mem[2]=32'h7fc00000;
        A_mem[3]=32'h7fc00000; B_mem[3]=32'h7f800000;
        A_mem[4]=32'hc04dd97f; B_mem[4]=32'h7fc00000;
        A_mem[5]=32'hc145d8ae; B_mem[5]=32'h3ea62cba;
        A_mem[6]=32'h490b2126; B_mem[6]=32'hc77f443d;
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

            if (index == 15) begin
                index <= 0;        // Wrap around if last data is reached
            end

            loadData_valid <= 0;   // Clear valid signal after loading
        end
    end
endmodule