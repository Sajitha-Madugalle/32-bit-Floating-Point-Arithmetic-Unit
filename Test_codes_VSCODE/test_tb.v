'timescale 1ns/1ps

module test_tb;
    reg A;
    wire B;

    test uut(
        .A(A),
        .B(B)
    );


    initial begin
        $dumpfile("test_tb.vcd");
        $dumpvars(0, test_tb);

        A=0;
        #10 A=1;
        #10 A=0;
        #10 A=1;
        #10 A=0;
        #10

        $display("Simulation done");
        $finish;
    end

 endmodule