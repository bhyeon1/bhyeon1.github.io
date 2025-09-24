`timescale 1ns / 1ps

module sr04_fnd_controller (
    input        clk,
    input        rst,
    input  [9:0] distance,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);

    wire [3:0] w_bcd, w_digit_1, w_digit_10, w_digit_100, w_digit_1000;
    wire [1:0] fnd_sel;
    wire w_oclk;

    clk_div U_CLK_Div (
        .clk  (clk),
        .rst(rst),
        .o_clk(w_oclk)
    );

    counter_4 U_Counter_4 (
        .clk    (w_oclk),
        .rst  (rst),
        .fnd_sel(fnd_sel)
    );

    decoder_2x4 U_Decoder_2x4 (
        .fnd_sel(fnd_sel),
        .fnd_com(fnd_com)
    );

    digit_splitter_sr04 U_DS (
        .dist_data (distance),
        .digit_1   (w_digit_1),
        .digit_10  (w_digit_10),
        .digit_100 (w_digit_100),
        .digit_1000(w_digit_1000)
    );

    mux_4x1 U_MUX_4x1 (
        .sel       (fnd_sel),
        .digit_1   (w_digit_1),
        .digit_10  (w_digit_10),
        .digit_100 (w_digit_100),
        .digit_1000(w_digit_1000),
        .bcd       (w_bcd)
    );

    bcd U_BCD (
        .bcd(w_bcd),
        .fnd_data(fnd_data)
    );

endmodule

module counter_4 (
    input        clk,
    input        rst,
    output [1:0] fnd_sel
);
    reg [1:0] r_counter;
    assign fnd_sel = r_counter;

    always @(posedge clk, posedge rst) begin  // 비동기식 rst
        if (rst) begin
            r_counter <= 0;  // non-block
        end else begin
            r_counter <= r_counter + 1;
        end
    end

endmodule

module mux_4x1 (
    input  [1:0] sel,
    input  [3:0] digit_1,
    input  [3:0] digit_10,
    input  [3:0] digit_100,
    input  [3:0] digit_1000,
    output [3:0] bcd
);

    reg [3:0] r_bcd;
    assign bcd = r_bcd;

    always @(*) begin
        case (sel)
            2'b00: r_bcd = digit_1;
            2'b01: r_bcd = digit_10;
            2'b10: r_bcd = digit_100;
            2'b11: r_bcd = digit_1000;
        endcase
    end

endmodule

module digit_splitter_sr04 (
    input  [9:0] dist_data,
    output [3:0] digit_1,
    output [3:0] digit_10,
    output [3:0] digit_100,
    output [3:0] digit_1000
);

    assign digit_1    = dist_data % 10;
    assign digit_10   = (dist_data / 10) % 10;
    assign digit_100  = (dist_data / 100) % 10;
    assign digit_1000 = 0;

endmodule