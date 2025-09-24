`timescale 1ns / 1ps

module watch_fnd_controller (
    input        clk,
    input        rst,
    input        sw_sel,
    input  [2:0] pos_sel,
    input  [6:0] msec,
    input  [5:0] sec,
    input  [5:0] min,
    input  [4:0] hour,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);

    wire [3:0] w_bcd_1, w_bcd_2, w_bcd, w_msec_digit_1, w_msec_digit_10,w_sec_digit_1, w_sec_digit_10,
               w_min_digit_1, w_min_digit_10, w_hour_digit_1, w_hour_digit_10;
    wire [3:0] w_sec_digit_BK_1, w_sec_digit_BK_10, w_min_digit_BK_1, w_min_digit_BK_10, w_hour_digit_BK_1, w_hour_digit_BK_10;

    wire [2:0] fnd_sel;
    wire w_oclk, w_dot, w_blink;

    clk_div U_CLK_Div (
        .clk  (clk),
        .rst(rst),
        .o_clk(w_oclk)
    );

    comparator_50 U_Comparator_50_Watch (
        .clk(w_oclk),
        .rst(rst),
        .dot(w_dot)
    );

    comparator_50 U_Comparator_0p5s (
        .clk(w_oclk),
        .rst(rst),
        .dot(w_blink)
    );

    counter_8 U_Counter_8 (
        .clk    (w_oclk),
        .rst  (rst),
        .fnd_sel(fnd_sel)
    );

    decoder_2x4 U_Decoder_2x4_Watch (
        .fnd_sel(fnd_sel[1:0]),
        .fnd_com(fnd_com)
    );

    digit_splitter #(
        .I_TIME_BIT(7)
    ) U_DS_MSEC (
        .i_time  (msec),
        .digit_1 (w_msec_digit_1),
        .digit_10(w_msec_digit_10)
    );

    digit_splitter #(
        .I_TIME_BIT(6)
    ) U_DS_SEC (
        .i_time  (sec),
        .digit_1 (w_sec_digit_1),
        .digit_10(w_sec_digit_10)
    );

    digit_splitter #(
        .I_TIME_BIT(6)
    ) U_DS_MIN (
        .i_time  (min),
        .digit_1 (w_min_digit_1),
        .digit_10(w_min_digit_10)
    );

    digit_splitter #(
        .I_TIME_BIT(5)
    ) U_DS_HOUR (
        .i_time  (hour),
        .digit_1 (w_hour_digit_1),
        .digit_10(w_hour_digit_10)
    );

    Demux_blink U_Demux_BLINK_SEC (
        .blink_clk(w_blink),
        .i_digit_1(w_sec_digit_1),
        .i_digit_10(w_sec_digit_10),
        .pos_sel(pos_sel[0]),
        .o_digit_1(w_sec_digit_BK_1),
        .o_digit_10(w_sec_digit_BK_10)
    );

    Demux_blink U_Demux_BLINK_MIN (
        .blink_clk(w_blink),
        .i_digit_1(w_min_digit_1),
        .i_digit_10(w_min_digit_10),
        .pos_sel(pos_sel[1]),
        .o_digit_1(w_min_digit_BK_1),
        .o_digit_10(w_min_digit_BK_10)
    );

    Demux_blink U_Demux_BLINK_HOUR (
        .blink_clk(w_blink),
        .i_digit_1(w_hour_digit_1),
        .i_digit_10(w_hour_digit_10),
        .pos_sel(pos_sel[2]),
        .o_digit_1(w_hour_digit_BK_1),
        .o_digit_10(w_hour_digit_BK_10)
    );

    mux_8x1 U_MUX_8x1_1 (
        .sel       (fnd_sel),
        .digit_1   (w_msec_digit_1),
        .digit_10  (w_msec_digit_10),
        .digit_100 (w_sec_digit_BK_1),
        .digit_1000(w_sec_digit_BK_10),
        .dot       ({1'b1, 1'b1, 1'b1, w_dot}),
        .bcd       (w_bcd_1)
    );

    mux_8x1 U_MUX_8x1_2 (
        .sel       (fnd_sel),
        .digit_1   (w_min_digit_BK_1),
        .digit_10  (w_min_digit_BK_10),
        .digit_100 (w_hour_digit_BK_1),
        .digit_1000(w_hour_digit_BK_10),
        .dot       ({1'b1, 1'b1, 1'b1, w_dot}),
        .bcd       (w_bcd_2)
    );

    mux_2x1 U_MUX_2x1_Watch (
        .sel(sw_sel),
        .bcd_msec_sec(w_bcd_1),
        .bcd_min_hour(w_bcd_2),
        .o_bcd(w_bcd)
    );

    bcd U_BCD (
        .bcd(w_bcd),
        .fnd_data(fnd_data)
    );

endmodule

module comparator_50 (
    input      clk,
    input      rst,
    output reg dot
);

    reg [9:0] r_counter;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_counter <= 0;
            dot <= 1'b0;
        end else begin
            if (r_counter == 999) begin
                r_counter <= 0;
            end else begin
                r_counter <= r_counter + 1;
            end
            if (r_counter >= 499) begin
                dot <= 1;
            end else begin
                dot <= 0;
            end
        end
    end

endmodule

module Demux_blink (
    input            blink_clk,
    input      [3:0] i_digit_1,
    input      [3:0] i_digit_10,
    input            pos_sel,
    output reg [3:0] o_digit_1,
    output reg [3:0] o_digit_10
);

    always @(*) begin
        if (pos_sel) begin
            // 선택된 자리 → blink_clk 에 따라 on/off
            if (blink_clk) begin
                o_digit_1  = i_digit_1;
                o_digit_10 = i_digit_10;
            end else begin
                o_digit_1  = 4'hF;
                o_digit_10 = 4'hF;
            end
        end else begin
            // 선택되지 않은 자리 → 원래 값 그대로
            o_digit_1  = i_digit_1;
            o_digit_10 = i_digit_10;
        end
    end

endmodule

module mux_2x1 (
    input        sel,
    input  [3:0] bcd_msec_sec,
    input  [3:0] bcd_min_hour,
    output [3:0] o_bcd
);

    assign o_bcd = (sel == 0) ? bcd_msec_sec : bcd_min_hour;

endmodule

module digit_splitter #(
    parameter I_TIME_BIT = 7
) (
    input [I_TIME_BIT - 1 : 0] i_time,
    output [3:0] digit_1,
    output [3:0] digit_10
);

    assign digit_1  = i_time % 10;
    assign digit_10 = (i_time / 10) % 10;

endmodule