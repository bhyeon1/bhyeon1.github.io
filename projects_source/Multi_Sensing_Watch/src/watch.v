`timescale 1ns / 1ps

module watch (
    input  [3:0] btn,
    input        clk,
    input        rst,
    input        stop,
    input        blink_disable,
    output [2:0] pos_sel,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);

    wire [2:0] w_pos;

    watch_cu U_Watch_CU (
        .clk(clk),
        .rst(rst),
        .i_digit_left(btn[0]),
        .i_digit_right(btn[1]),
        .o_digit_pos(w_pos)
    );

    watch_dp U_Watch_DP (
        .i_time_up(btn[2]),
        .i_time_down(btn[3]),
        .digit_pos(w_pos),
        .clk(clk),
        .rst(rst),
        .stop(stop),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour)
    );

    assign pos_sel = (blink_disable == 1) ? 0 : {3{stop}} & w_pos;

endmodule
