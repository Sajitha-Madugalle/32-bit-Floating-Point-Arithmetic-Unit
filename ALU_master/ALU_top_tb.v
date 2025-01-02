`timescale 1ns / 1ps
`include "add_sub.v"
`include "multiplier.v"
`include "divider.v"
`include "instructions.v"
`include "ALU_top.v"
`include "hexDisplay.v"

module ALU_top_tb;
    // Clock and control signals
    reg clk;
    reg loadData;
    reg control;
    reg reset;
    reg [1:0] select;
    reg[6:0] digit7;      // Seven-segment display for most significant digit
    reg [6:0] digit6;      // Seven-segment display
    reg [6:0] digit5;      // Seven-segment display
    reg [6:0] digit4;      // Seven-segment display
    reg [6:0] digit3;      // Seven-segment display
    reg [6:0] digit2;      // Seven-segment display
    reg [6:0] digit1;      // Seven-segment display
    reg [6:0] digit0;

    // Outputs from the ALU_top module
    wire [31:0] out;
    wire exception;
    wire zeroDiv;

    // Include all modules


    // Instantiate the ALU_top module
    ALU_top uut (
        .clk(clk),
        .loadData(loadData),
        .control(control),
        .reset(reset),
        .select(select),
        .exception(exception),
        .zeroDiv(zeroDiv)
    );

    // Clock generation: 50 Hz (20 ms period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // Toggle every 10 ms
    end

    // Simulation initialization
    initial begin
        // Initialize variables
        loadData = 0;
        control = 0;
        reset = 0;
        select = 2'b00; // Default to addition

        // Dump waveform
        $dumpfile("ALU_top_tb.vcd");
        $dumpvars(0, ALU_top_tb);

        // Reset the design
        reset = 1;
        #20; // Wait for 20 ns
        reset = 0;
        #50
        // Load first data and perform addition
        #10
        select = 2'b00;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b00;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b00;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b00;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b01;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b01;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b01;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b01;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b10;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b10;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b10;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b10;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b11;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b11;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b11;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b11;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b11;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b11;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b11;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b11;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b00;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b01;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b10;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b11;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b00;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b01;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b10;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b11;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b00;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b01;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b10;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;

        #10
        select = 2'b11;
        loadData = 1;
        #100 loadData = 0;
        #10 control = 1;
        #100 control = 0;


        // Wait and finish simulation
        #200;
        $finish;
    end
endmodule
