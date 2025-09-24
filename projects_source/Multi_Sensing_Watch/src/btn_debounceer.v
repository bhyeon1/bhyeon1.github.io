`timescale 1ns / 1ps

module btn_debouncer (
    input        clk,
    input        rst,
    input  [3:0] btn,
    output [3:0] o_btn
);

    btn_debounce U_BD_1 (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btn[0]),
        .o_btn(o_btn[0])
    );

    btn_debounce U_BD_2 (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btn[1]),
        .o_btn(o_btn[1])
    );

    btn_debounce U_BD_3 (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btn[2]),
        .o_btn(o_btn[2])
    );

    btn_debounce U_BD_4 (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btn[3]),
        .o_btn(o_btn[3])
    );

endmodule
