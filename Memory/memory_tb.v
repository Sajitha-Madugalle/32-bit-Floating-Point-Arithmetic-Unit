`timescale 1ns/1ps
`include "memory.v"

module memory_tb;
    reg clk;
    reg dataready;
    reg stop;
    wire num1_bit;
    wire num2_bit;
    wire select0;
    wire select1;
    wire ok;

    // Instantiate the data_sender module
    memory dut (
        .clk(clk),
        .dataready(dataready),
        .stop(stop),
        .num1_bit(num1_bit),
        .num2_bit(num2_bit),
        .select0(select0),
        .select1(select1),
        .ok(ok)
    );

    // Generate clock signal
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        dataready = 0;
        stop = 0;
        
        // Apply test stimulus
        #10 dataready = 1; // Trigger data sending
        #10 dataready = 0; // Clear dataready after starting

        // Wait until ok goes high (data is sent)
        wait(ok == 1);
        #10 stop = 1; // Apply stop signal
        #10 stop = 0; // Clear stop signal to allow next transmission

        // Repeat for next data sets
        #50 dataready = 1;
        #10 dataready = 0;
        wait(ok == 1);
        #10 stop = 1;
        #10 stop = 0;

        #50 dataready = 1;
        #10 dataready = 0;
        wait(ok == 1);
        #10 stop = 1;
        #10 stop = 0;

        #100 dataready = 1;
        #10 dataready = 0;
        wait(ok == 1);
        #10 stop = 1;
        #10 stop = 0;

        // End simulation after all data is sent
        #200 $finish;
    end

    // Dump waveform
    initial begin
        $dumpfile("memory_tb.vcd");
        $dumpvars(0, memory_tb);
    end
endmodule
