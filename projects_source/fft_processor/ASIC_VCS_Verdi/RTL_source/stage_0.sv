`timescale 1ns / 1ps

module fft_stage_0 #(
    parameter DATA  = 9,
    parameter ARRAY = 16,
    parameter DELAY = 17,
	parameter STAGE = 0
) (
    input  logic                   clk,
    input  logic                   rstn,
    input  logic                   valid_in,
    input  logic signed [DATA-1:0] din_re        [ARRAY-1:0],
    input  logic signed [DATA-1:0] din_im        [ARRAY-1:0],
    output logic                   valid_out_0_2d,
    output logic signed [  DATA:0] re_m_0        [ARRAY-1:0],
    output logic signed [  DATA:0] im_m_0        [ARRAY-1:0]
);

    // 내부 신호
    logic signed [DATA-1:0] sr_re_0   [ARRAY-1:0];
    logic signed [DATA-1:0] sr_im_0   [ARRAY-1:0];
    logic signed [  DATA:0] sr_v_re_0 [ARRAY-1:0];
    logic signed [  DATA:0] sr_v_im_0 [ARRAY-1:0];
    logic signed [  DATA:0] u_re_0    [ARRAY-1:0];
    logic signed [  DATA:0] u_im_0    [ARRAY-1:0];
    logic signed [  DATA:0] v_re_0    [ARRAY-1:0];
    logic signed [  DATA:0] v_im_0    [ARRAY-1:0];
    logic signed [  DATA:0] out_re_0  [ARRAY-1:0];
    logic signed [  DATA:0] out_im_0  [ARRAY-1:0];

    logic signed [  DATA:0] re_m_0_reg[ARRAY-1:0];
    logic signed [  DATA:0] im_m_0_reg[ARRAY-1:0];
    logic                   valid_out_0_1d;
    logic                   mux_sel_0;
    //logic mul_en_0;


    // Data loading to clk
    logic signed [DATA-1:0] din_re_reg[ARRAY-1:0];
    logic signed [DATA-1:0] din_im_reg[ARRAY-1:0];

    always_ff @(posedge clk or negedge rstn) begin
        integer idx;
        if (!rstn) begin
            for (idx = 0; idx < ARRAY; idx++) begin
                din_re_reg[idx] <= '0;
                din_im_reg[idx] <= '0;
            end
        end else begin
            for (idx = 0; idx < ARRAY; idx++) begin
                din_re_reg[idx] <= din_re[idx];
                din_im_reg[idx] <= din_im[idx];
            end
        end
    end

    // Shift register 인스턴스: 딜레이 라인
    shift_register #(
        .DATA (DATA),
        .ARRAY(ARRAY),
        .INDEX(DELAY)
    ) u_sr_bf00 (
        .clk        (clk),
        .rstn       (rstn),
        .data_in_re (din_re),
        .data_in_im (din_im),
        .data_out_re(sr_re_0),
        .data_out_im(sr_im_0)
    );

    // Butterfly 컨트롤러 + 연산기 인스턴스
    bf_cntr #(
        .DATA (DATA),
        .ARRAY(ARRAY),
        .DELAY(DELAY),
		.STAGE(STAGE)
    ) u_bf00 (
        .clk      (clk),
        .rstn     (rstn),
        .valid_in (valid_in),
        .din_re   (din_re_reg),
        .din_im   (din_im_reg),
        .sr_din_re(sr_re_0),
        .sr_din_im(sr_im_0),
        .u_re     (u_re_0),
        .u_im     (u_im_0),
        .v_re     (v_re_0),
        .v_im     (v_im_0),
        .valid_out(valid_out_0_1d),
        .mux_sel  (mux_sel_0)
    );

    shift_register #(
        .DATA (DATA + 1),
        .ARRAY(ARRAY),
        .INDEX(DELAY - 1)
    ) u_sr_v_reg (
        .clk        (clk),
        .rstn       (rstn),
        .data_in_re (v_re_0),
        .data_in_im (v_im_0),
        .data_out_re(sr_v_re_0),
        .data_out_im(sr_v_im_0)
    );

    mux4to2 #(
        .ARRAY(ARRAY),
        .DATA (DATA + 1)
    ) u_mux_0 (
        .sel    (mux_sel_0),
        .u_in_re(u_re_0),
        .u_in_im(u_im_0),
        .v_in_re(sr_v_re_0),
        .v_in_im(sr_v_im_0),
        .out_re (out_re_0),
        .out_im (out_im_0)
    );

    mul_fact8_0 #(
        .DATA(DATA + 1),  // 출력 비트 수
        .ARRAY(ARRAY),  // 배열 길이
        .CNT_MAX(31)  // 0..31 카운트, 내부에서 3/4 구간을 +1 처리
    ) u_mul_fact8_0 (
        .clk     (clk),
        .rstn    (rstn),
        .mul_en_0(valid_out_0_1d),  // 입력 valid
        .re_0    (out_re_0),     // real 입력 배열
        .im_0    (out_im_0),     // imag 입력 배열
        .re_m_0  (re_m_0_reg),   // real twiddle 적용 결과
        .im_m_0  (im_m_0_reg)    // imag twiddle 적용 결과
    );

    // pipeline register before final outputs
    always_ff @(posedge clk or negedge rstn) begin
        integer idx;
        if (!rstn) begin
            valid_out_0_2d <= 1'b0;
            for (idx = 0; idx < ARRAY; idx++) begin
                re_m_0[idx] <= '0;
                im_m_0[idx] <= '0;
            end
        end else begin
            valid_out_0_2d <= valid_out_0_1d;
            for (idx = 0; idx < ARRAY; idx++) begin
                re_m_0[idx] <= re_m_0_reg[idx];
                im_m_0[idx] <= im_m_0_reg[idx];
            end
        end
    end

endmodule

module mux4to2 #(
    parameter int ARRAY = 16,  // 배열 길이
    parameter int DATA  = 10   // 각 원소 비트 폭
) (
    input  logic                   sel,
    input  logic signed [DATA-1:0] u_in_re[ARRAY-1:0],
    input  logic signed [DATA-1:0] u_in_im[ARRAY-1:0],
    input  logic signed [DATA-1:0] v_in_re[ARRAY-1:0],
    input  logic signed [DATA-1:0] v_in_im[ARRAY-1:0],
    output logic signed [DATA-1:0] out_re [ARRAY-1:0],
    output logic signed [DATA-1:0] out_im [ARRAY-1:0]
);

    assign out_re = sel ? v_in_re : u_in_re;
    assign out_im = sel ? v_in_im : u_in_im;

endmodule






