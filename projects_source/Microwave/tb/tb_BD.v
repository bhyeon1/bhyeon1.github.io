`timescale 1ns / 1ps

module tb_BD ();

    reg clk, rst, i_btn;
    wire o_btn;

    btn_debounce DUT (
        .clk  (clk),
        .rst  (rst),
        .i_btn(i_btn),
        .o_btn(o_btn)
    );

     always #5 clk = ~clk;

     initial begin
        #0;
        clk = 0;
        rst = 1;
        i_btn = 0;
        #20;
        rst = 0;
        i_btn = 1;
        #100_000_000
        #10000;
        $stop;
     end


endmodule
