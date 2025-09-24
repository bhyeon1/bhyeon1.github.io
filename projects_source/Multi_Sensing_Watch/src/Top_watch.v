`timescale 1ns / 1ps

module Top_watch (
    input        clk,
    input        rst,
    input  [2:0] sw_data,
    input  [2:0] uart_stopwatch_flag,
    input  [3:0] btn_stopwatch,
    input  [3:0] btn_watch_setting,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);

    wire [2:0] w_pos_sel;

    wire [6:0] w_msec;
    wire [5:0] w_sec, w_min;
    wire [4:0] w_hour;

    wire [6:0] w_msec_watch;
    wire [5:0] w_sec_watch, w_min_watch;
    wire [4:0] w_hour_watch;

    wire [6:0] w_msec_stopwatch;
    wire [5:0] w_sec_stopwatch, w_min_stopwatch;
    wire [4:0] w_hour_stopwatch;

    stopwatch U_STOPWATCH (
        .btn(btn_stopwatch),
        .i_uart_flag(uart_stopwatch_flag),
        .clk(clk),
        .rst(rst),
        .msec(w_msec_stopwatch),
        .sec(w_sec_stopwatch),
        .min(w_min_stopwatch),
        .hour(w_hour_stopwatch)
    );

    watch U_WATCH (
        .btn(btn_watch_setting),
        .clk(clk),
        .rst(rst),
        .stop(sw_data[1]),
        .blink_disable(sw_data[2]),
        .pos_sel(w_pos_sel),
        .msec(w_msec_watch),
        .sec(w_sec_watch),
        .min(w_min_watch),
        .hour(w_hour_watch)
    );

    mux_8x4 U_Mux_8x4 (
        .w_msec_watch(w_msec_watch),
        .w_sec_watch(w_sec_watch),
        .w_min_watch(w_min_watch),
        .w_hour_watch(w_hour_watch),
        .w_msec_stopwatch(w_msec_stopwatch),
        .w_sec_stopwatch(w_sec_stopwatch),
        .w_min_stopwatch(w_min_stopwatch),
        .w_hour_stopwatch(w_hour_stopwatch),
        .sel(sw_data[2]),
        .w_msec(w_msec),
        .w_sec(w_sec),
        .w_min(w_min),
        .w_hour(w_hour)
    );

    watch_fnd_controller U_WATCH_FND_CNTL (
        .clk(clk),
        .rst(rst),
        .sw_sel(sw_data[0]),
        .pos_sel(w_pos_sel),
        .msec(w_msec),
        .sec(w_sec),
        .min(w_min),
        .hour(w_hour),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );

endmodule

module mux_8x4 (
    input  [6:0] w_msec_watch,
    input  [5:0] w_sec_watch,
    input  [5:0] w_min_watch,
    input  [4:0] w_hour_watch,
    input  [6:0] w_msec_stopwatch,
    input  [5:0] w_sec_stopwatch,
    input  [5:0] w_min_stopwatch,
    input  [4:0] w_hour_stopwatch,
    input        sel,
    output [6:0] w_msec,
    output [5:0] w_sec,
    output [5:0] w_min,
    output [4:0] w_hour
);

    assign w_msec = (sel == 0) ? w_msec_watch : w_msec_stopwatch;
    assign w_sec  = (sel == 0) ? w_sec_watch : w_sec_stopwatch;
    assign w_min  = (sel == 0) ? w_min_watch : w_min_stopwatch;
    assign w_hour = (sel == 0) ? w_hour_watch : w_hour_stopwatch;

endmodule
