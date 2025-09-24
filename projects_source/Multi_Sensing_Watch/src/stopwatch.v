`timescale 1ns / 1ps

module stopwatch (
    input  [3:0] btn,
    input        clk,
    input        rst,
    input  [2:0] i_uart_flag,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);
    wire w_btn_clear, w_btn_runstop;

    stopwatch_cu U_StopWatch_CU (
        .clk(clk),
        .rst(rst),
        .i_uart_flag(i_uart_flag),
        .i_clear(btn[0]),
        .i_runstop(btn[1]),
        .o_clear(w_btn_clear),
        .o_runstop(w_btn_runstop)
    );

    stopwatch_dp U_StopWatch_DP (
        .clear(w_btn_clear),
        .runstop(w_btn_runstop),
        .clk(clk),
        .rst(rst),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour)
    );

endmodule

