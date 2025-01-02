module instructions (
    input clk,
    input loadData,
    output reg [31:0] A,
    output reg [31:0] B
);
    // Memory for A and B values
    reg [31:0] A_mem [0:31];
    reg [31:0] B_mem [0:31];
    reg [4:0] index;            // Index for current data
    reg loadData_prev;          // Register to detect edge of loadData
    reg loadData_valid;         // Signal to trigger data transfer

    initial begin
        // Initialize memory
        A_mem[0]=32'h41bc587e; B_mem[0]=32'h42347e6a; // 23.54321 45.12345
        A_mem[1]=32'h426327f2; B_mem[1]=32'hc20a4585; // 56.78901 -34.56789
        A_mem[2]=32'hc29dd1fa; B_mem[2]=32'h414587dd; // -78.91011 12.34567
        A_mem[3]=32'hc14570a4; B_mem[3]=32'hc2c587ae; // -12.34 -98.765
        A_mem[4]=32'h42c587e3; B_mem[4]=32'h42347e5d; // 98.7654 45.1234
        A_mem[5]=32'h42f6e666; B_mem[5]=32'hc287c7ae; // 123.45 -67.89
        A_mem[6]=32'hc2631eb8; B_mem[6]=32'h41bb999a; // -56.78 23.45
        A_mem[7]=32'hc1bb999a; B_mem[7]=32'hc29dcccd; // -23.45 -78.90
        A_mem[8]=32'h4145851f; B_mem[8]=32'h4287c7ae; // 12.345 67.89
        A_mem[9]=32'h420a3d71; B_mem[9]=32'hc14570a4; // 34.56 -12.34
        A_mem[10]=32'hc29dd1ec; B_mem[10]=32'h41bb999a; // -78.91 23.45
        A_mem[11]=32'hc2631eb8; B_mem[11]=32'hc20a3d71; // -56.78 -34.56
        A_mem[12]=32'h42f6e979; B_mem[12]=32'h414570a4; // 123.456 12.34
        A_mem[13]=32'h4236ae14; B_mem[13]=32'hc0d8f5c3; // 45.67 -6.78
        A_mem[14]=32'hc29dd1ec; B_mem[14]=32'h41bb999a; // -78.91 23.45
        A_mem[15]=32'hc2631eb8; B_mem[15]=32'hc20a3d71; // -56.78 -34.56
        A_mem[16]=32'h4145851f; B_mem[16]=32'h00000000; // 12.345 0
        A_mem[17]=32'h00000000; B_mem[17]=32'h4145851f; // 0 12.345
        A_mem[18]=32'h00000000; B_mem[18]=32'hc29dd1ec; // 0 -78.91
        A_mem[19]=32'h00000000; B_mem[19]=32'h00000000; // 0 0
        A_mem[20]=32'h7fc00000; B_mem[20]=32'h414570a4; // NaN 12.34
        A_mem[21]=32'h7fc00000; B_mem[21]=32'h4236ae14; // NaN 45.67
        A_mem[22]=32'h7fc00000; B_mem[22]=32'h429dd1ec; // NaN 78.91
        A_mem[23]=32'h7fc00000; B_mem[23]=32'h41bb999a; // NaN 23.45
        A_mem[24]=32'h7f800000; B_mem[24]=32'h414570a4; // Infinity 12.34
        A_mem[25]=32'h7f800000; B_mem[25]=32'h4236ae14; // Infinity 45.67
        A_mem[26]=32'h7f800000; B_mem[26]=32'hc29dd1ec; // Infinity -78.91
        A_mem[27]=32'h7f800000; B_mem[27]=32'h41bb999a; // Infinity 23.45
        A_mem[28]=32'h40000000; B_mem[28]=32'h40800000; // 2.0 4.0
        A_mem[29]=32'h41000000; B_mem[29]=32'h40000000; // 8.0 2.0
        A_mem[30]=32'h40c00000; B_mem[30]=32'h40800000; // 6.0 4.0
        A_mem[31]=32'h41800000; B_mem[31]=32'h40800000; // 16.0 4.0
        //invalid number: 
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

            if (index == 31) begin
                index <= 0;        // Wrap around if last data is reached
            end

            loadData_valid <= 0;   // Clear valid signal after loading
        end
    end
endmodule