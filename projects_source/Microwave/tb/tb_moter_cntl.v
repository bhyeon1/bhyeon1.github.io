`timescale 1ns / 1ps

module tb_moter_cntl ();

    reg clk, rst, start, defrost_start;
    wire [1:0] moter_control;
    wire pwm_out;

    moter_controller DUT(
    .clk(clk),
    .rst(rst),
    .start(start),
    .defrost_start(defrost_start),
    .moter_control(moter_control),
    .pwm_out(pwm_out)
);

    always #5 clk = ~clk;

    initial begin
        #0;
        clk = 0;
        rst = 1;
        start = 0;
        defrost_start = 0;
        #20;
        rst = 0;
        #20;
        start = 1;
        #100_000;
        start = 0;
        #10000;
        defrost_start = 1;
        #100_000;
        defrost_start = 0;
        #20;
        
        $stop;
        
    end

endmodule
