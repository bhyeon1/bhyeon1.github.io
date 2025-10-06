`timescale 1ns / 1ps

module tb_fnd_cntl ();

    reg clk, rst, done;
    reg [5:0] sec, min;
    wire [7:0] fnd_data;
    wire [3:0] fnd_com;

    fnd_controller DUT (
        .clk(clk),
        .rst(rst),
        .done(done),
        .sec(sec),
        .min(min),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );

    always #5 clk = ~clk;

    initial begin
        #0;
        clk = 0;
        rst = 1;
        done = 0;
        sec = 0;
        min = 0;
        #20;
        rst = 0;
        #20;
        sec = 30;
        min = 1;
        #30_000_000;
        done = 1;
        min = 0;
        sec = 0;
        $stop;
        
    end

endmodule
