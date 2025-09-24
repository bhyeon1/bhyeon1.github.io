`timescale 1ns / 1ps

module Top_sr04 (
    input        clk,
    input        rst,
    input        btn_start,
    input        echo,
    output       trig,
    output       dist_done,
    output [9:0] dist_data,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);
    wire w_btn_start;
    wire [9:0] w_distance;

    assign dist_data = w_distance;

    sr04_controller U_SR04_CTRL (
        .clk(clk),
        .rst(rst),
        .start(btn_start),
        .echo(echo),
        .trig(trig),
        .distance(w_distance),
        .dist_done(dist_done)
    );

    sr04_fnd_controller U_SR04_FND_CTRL (
        .clk(clk),
        .rst(rst),
        .distance(w_distance),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );
endmodule
