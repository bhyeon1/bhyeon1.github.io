`timescale 1ns / 1ps

module dht11_fnd_controller (
    input        clk,
    input        rst,
    input        sw_sel,
    input  [7:0] int_rh_data,
    input  [7:0] dec_rh_data,
    input  [7:0] int_t_data,
    input  [7:0] dec_t_data,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);

    wire [3:0] w_bcd, w_bcd_rh, w_bcd_t, w_int_rh_digit_1, w_int_rh_digit_10, w_dec_rh_digit_1, w_dec_rh_digit_10;
    wire [3:0] w_int_t_digit_1, w_int_t_digit_10, w_dec_t_digit_1, w_dec_t_digit_10;
    wire [2:0] fnd_sel;
    wire w_oclk;

    clk_div U_CLK_Div (
        .clk  (clk),
        .rst  (rst),
        .o_clk(w_oclk)
    );

    counter_8 U_Counter_8 (
        .clk    (w_oclk),
        .rst    (rst),
        .fnd_sel(fnd_sel)
    );

    decoder_2x4 U_Decoder_2x4 (
        .fnd_sel(fnd_sel[1:0]),
        .fnd_com(fnd_com)
    );

    digit_splitter_dht11 U_DS_RH (
        .int_data(int_rh_data),
        .dec_data(dec_rh_data),
        .digit_1(w_dec_rh_digit_1),
        .digit_10(w_dec_rh_digit_10),
        .digit_100(w_int_rh_digit_1),
        .digit_1000(w_int_rh_digit_10)
    );

    digit_splitter_dht11 U_DS_T (
        .int_data(int_t_data),
        .dec_data(dec_t_data),
        .digit_1(w_dec_t_digit_1),
        .digit_10(w_dec_t_digit_10),
        .digit_100(w_int_t_digit_1),
        .digit_1000(w_int_t_digit_10)
    );

    mux_8x1 U_MUX_8x1_RH (
        .sel(fnd_sel),
        .digit_1(w_dec_rh_digit_1),
        .digit_10(w_dec_rh_digit_10),
        .digit_100(w_int_rh_digit_1),
        .digit_1000(w_int_rh_digit_10),
        .dot(4'b1110),
        .bcd(w_bcd_rh)
    );

    mux_8x1 U_MUX_8x1_T (
        .sel(fnd_sel),
        .digit_1(w_dec_t_digit_1),
        .digit_10(w_dec_t_digit_10),
        .digit_100(w_int_t_digit_1),
        .digit_1000(w_int_t_digit_10),
        .dot(4'b1110),
        .bcd(w_bcd_t)
    );

    mux_2x1_watch U_MUX_2x1 (
        .sel(sw_sel),
        .bcd_rh(w_bcd_rh),
        .bcd_t(w_bcd_t),
        .o_bcd(w_bcd)
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

module counter_8 (
    input        clk,
    input        rst,
    output [2:0] fnd_sel
);
    reg [2:0] r_counter;
    assign fnd_sel = r_counter;

    always @(posedge clk, posedge rst) begin  // 비동기식 rst
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

module mux_8x1 (
    input  [2:0] sel,
    input  [3:0] digit_1,
    input  [3:0] digit_10,
    input  [3:0] digit_100,
    input  [3:0] digit_1000,
    input  [3:0] dot,
    output [3:0] bcd
);

    reg [3:0] r_bcd;
    assign bcd = r_bcd;

    always @(*) begin
        case (sel)
            3'b000:  r_bcd = digit_1;
            3'b001:  r_bcd = digit_10;
            3'b010:  r_bcd = digit_100;
            3'b011:  r_bcd = digit_1000;
            3'b110:  r_bcd = dot;
            default: r_bcd = 4'hf;
        endcase
    end

endmodule

module mux_2x1_watch (
    input        sel,
    input  [3:0] bcd_rh,
    input  [3:0] bcd_t,
    output [3:0] o_bcd
);

    assign o_bcd = (sel == 0) ? bcd_rh : bcd_t;

endmodule

module digit_splitter_dht11 (
    input  [7:0] int_data,
    input  [7:0] dec_data,
    output [3:0] digit_1,
    output [3:0] digit_10,
    output [3:0] digit_100,
    output [3:0] digit_1000
);

    assign digit_1    = dec_data % 10;
    assign digit_10   = (dec_data / 10) % 10;
    assign digit_100  = (int_data % 10);
    assign digit_1000 = (int_data / 10) % 10;

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
            4'h00:   r_fnd_data = 8'hc0;
            4'h01:   r_fnd_data = 8'hf9;
            4'h02:   r_fnd_data = 8'ha4;
            4'h03:   r_fnd_data = 8'hb0;
            4'h04:   r_fnd_data = 8'h99;
            4'h05:   r_fnd_data = 8'h92;
            4'h06:   r_fnd_data = 8'h82;
            4'h07:   r_fnd_data = 8'hf8;
            4'h08:   r_fnd_data = 8'h80;
            4'h09:   r_fnd_data = 8'h90;
            4'h0e:   r_fnd_data = 8'h7f;
            default: r_fnd_data = 8'hff;
        endcase
    end

endmodule
