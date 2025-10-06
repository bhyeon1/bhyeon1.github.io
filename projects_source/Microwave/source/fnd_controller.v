`timescale 1ns / 1ps

module fnd_controller (
    input        clk,
    input        rst,
    input        done,
    input  [5:0] sec,
    input  [5:0] min,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);

    wire [3:0] w_bcd;
    wire [1:0] fnd_sel;
    wire w_oclk, w_blink;
    wire [3:0] w_digit_1, w_digit_10, w_digit_100, w_digit_1000;
    wire [3:0] w_bk_digit_1, w_bk_digit_10, w_bk_digit_100, w_bk_digit_1000;

    clk_div U_CLK_DIV (
        .clk  (clk),
        .rst  (rst),
        .o_clk(w_oclk)
    );

    comparator_50 U_COMP_50 (
        .clk  (w_oclk),
        .rst  (rst),
        .blink(w_blink)
    );

    counter_4 U_CNTR_4 (
        .clk(w_oclk),
        .rst(rst),
        .fnd_sel(fnd_sel)
    );

    decoder_2x4 U_DECODER_2x4 (
        .fnd_sel(fnd_sel),
        .fnd_com(fnd_com)
    );

    digit_splitter U_DS (
        .sec(sec),
        .min(min),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000)
    );

    Demux_blink U_DEMUX_BLINK (
        .blink_clk(w_blink),
        .i_digit_1(w_digit_1),
        .i_digit_10(w_digit_10),
        .i_digit_100(w_digit_100),
        .i_digit_1000(w_digit_1000),
        .done(done),
        .o_digit_1(w_bk_digit_1),
        .o_digit_10(w_bk_digit_10),
        .o_digit_100(w_bk_digit_100),
        .o_digit_1000(w_bk_digit_1000)
    );

    mux_4x1 U_MUX_4x1 (
        .sel(fnd_sel),
        .digit_1(w_bk_digit_1),
        .digit_10(w_bk_digit_10),
        .digit_100(w_bk_digit_100),
        .digit_1000(w_bk_digit_1000),
        .bcd(w_bcd)
    );

    bcd U_BCD (
        .bcd(w_bcd),
        .fnd_data(fnd_data)
    );

endmodule

// 1khz 바꾸기
module clk_div (
    input  clk,
    input  rst,
    output o_clk
);
    //reg [16:0] r_counter;
    reg [$clog2(100_000)-1:0] r_counter;
    reg r_clk;
    assign o_clk = r_clk;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_counter <= 0;
            r_clk     <= 1'b0;
        end else begin
            if (r_counter == 100_000 - 1) begin  // 1khz period
                r_counter <= 0;
                r_clk <= 1'b1;
            end else begin
                r_counter <= r_counter + 1;
                r_clk <= 1'b0;
            end
        end
    end

endmodule

module comparator_50 (
    input      clk,
    input      rst,
    output reg blink
);

    reg [9:0] r_counter;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_counter <= 0;
            blink <= 1'b0;
        end else begin
            if (r_counter == 9) begin
                r_counter <= 0;
            end else begin
                r_counter <= r_counter + 1;
            end
            if (r_counter >= 4) begin
                blink <= 1;
            end else begin
                blink <= 0;
            end
        end
    end

endmodule

module counter_4 (
    input        clk,
    input        rst,
    output [1:0] fnd_sel
);
    reg [1:0] r_counter;
    assign fnd_sel = r_counter;

    always @(posedge clk, posedge rst) begin  // 비동기식 reset
        if (rst) begin
            r_counter <= 0;  // non-block
        end else begin
            r_counter <= r_counter + 1;
        end
    end

endmodule

module decoder_2x4 (
    input      [1:0] fnd_sel,
    output reg [3:0] fnd_com
);

    always @(fnd_sel) begin
        case (fnd_sel)
            2'b00:   fnd_com = 4'b1110;
            2'b01:   fnd_com = 4'b1101;
            2'b10:   fnd_com = 4'b1011;
            2'b11:   fnd_com = 4'b0111;
            default: fnd_com = 4'b1111;
        endcase
    end

endmodule

module digit_splitter (
    input  [5:0] sec,
    input  [5:0] min,
    output [3:0] digit_1,
    output [3:0] digit_10,
    output [3:0] digit_100,
    output [3:0] digit_1000
);
    assign digit_1 = sec % 10;
    assign digit_10 = (sec / 10) % 10;
    assign digit_100 = min % 10;
    assign digit_1000 = (min / 10) % 10;

endmodule

module Demux_blink (
    input            blink_clk,
    input      [3:0] i_digit_1,
    input      [3:0] i_digit_10,
    input      [3:0] i_digit_100,
    input      [3:0] i_digit_1000,
    input            done,
    output reg [3:0] o_digit_1,
    output reg [3:0] o_digit_10,
    output reg [3:0] o_digit_100,
    output reg [3:0] o_digit_1000
);

    always @(*) begin
        if (done) begin
            if (blink_clk) begin
                o_digit_1 = i_digit_1;
                o_digit_10 = i_digit_10;
                o_digit_100 = i_digit_100;
                o_digit_1000 = i_digit_1000;
            end else begin
                o_digit_1 = 4'hf;
                o_digit_10 = 4'hf;
                o_digit_100 = 4'hf;
                o_digit_1000 = 4'hf;
            end
        end else begin
            o_digit_1 = i_digit_1;
            o_digit_10 = i_digit_10;
            o_digit_100 = i_digit_100;
            o_digit_1000 = i_digit_1000;
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
            2'b00:   r_bcd = digit_1;
            2'b01:   r_bcd = digit_10;
            2'b10:   r_bcd = digit_100;
            2'b11:   r_bcd = digit_1000;
            default: r_bcd = 4'hf;
        endcase
    end

endmodule

module bcd (
    input [3:0] bcd,
    output [7:0] fnd_data   // always 블록의 출력은 reg 타입이여야 함. (값을 저장하기 위해)
);

    reg [7:0] r_fnd_data;

    assign fnd_data = r_fnd_data;

    // 조합논리 combinational, 행위 수준 모델링
    always @(bcd) begin // 항상 이벤트가 발생하면 begin ~ end 실행 (행위 수준 모델링)
        case (bcd)
            4'h0: r_fnd_data = 8'hc0;
            4'h1: r_fnd_data = 8'hf9;
            4'h2: r_fnd_data = 8'ha4;
            4'h3: r_fnd_data = 8'hb0;
            4'h4: r_fnd_data = 8'h99;
            4'h5: r_fnd_data = 8'h92;
            4'h6: r_fnd_data = 8'h82;
            4'h7: r_fnd_data = 8'hf8;
            4'h8: r_fnd_data = 8'h80;
            4'h9: r_fnd_data = 8'h90;
            default: r_fnd_data = 8'hff;
        endcase
    end

endmodule
