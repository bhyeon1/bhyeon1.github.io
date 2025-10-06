`timescale 1ns / 1ps

module fft_stage_3 #(
    parameter DATA  = 11,
    parameter ARRAY = 16,
    parameter DELAY = 3,
	parameter STAGE = 3
) (
    input  logic                   clk,
    input  logic                   rstn,
    input  logic                   valid_in,
    input  logic signed [DATA-1:0] din_re        [ARRAY-1:0],
    input  logic signed [DATA-1:0] din_im        [ARRAY-1:0],
    output logic                   valid_out_3_2d,
    output logic signed [  DATA:0] re_m_3        [ARRAY-1:0],
    output logic signed [  DATA:0] im_m_3        [ARRAY-1:0]
);

    // 내부 신호
    logic signed [DATA-1:0] sr_re_3        [ARRAY-1:0];
    logic signed [DATA-1:0] sr_im_3        [ARRAY-1:0];
    logic signed [  DATA:0] sr_v_re_3      [ARRAY-1:0];
    logic signed [  DATA:0] sr_v_im_3      [ARRAY-1:0];
    logic signed [  DATA:0] u_re_3         [ARRAY-1:0];
    logic signed [  DATA:0] u_im_3         [ARRAY-1:0];
    logic signed [  DATA:0] v_re_3         [ARRAY-1:0];
    logic signed [  DATA:0] v_im_3         [ARRAY-1:0];
    logic signed [  DATA:0] out_re_3       [ARRAY-1:0];
    logic signed [  DATA:0] out_im_3       [ARRAY-1:0];
    logic signed [  DATA:0] out_re_3_1d    [ARRAY-1:0];
    logic signed [  DATA:0] out_im_3_1d    [ARRAY-1:0];
    logic signed [  DATA:0] re_m_3_reg     [ARRAY-1:0];
    logic signed [  DATA:0] im_m_3_reg     [ARRAY-1:0];
    logic                   valid_out_3_1d;
    logic                   mux_sel_3;
    //logic mul_en_3;


    // Data loading to clk
    logic signed [DATA-1:0] din_re_reg     [ARRAY-1:0];
    logic signed [DATA-1:0] din_im_reg     [ARRAY-1:0];

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
    ) u_sr_bf03 (
        .clk        (clk),
        .rstn       (rstn),
        .data_in_re (din_re),
        .data_in_im (din_im),
        .data_out_re(sr_re_3),
        .data_out_im(sr_im_3)
    );

    // Butterfly 컨트롤러 + 연산기 인스턴스
    bf_cntr #(
        .DATA (DATA),
        .ARRAY(ARRAY),
        .DELAY(DELAY),
		.STAGE(STAGE)
    ) u_bf03 (
        .clk      (clk),
        .rstn     (rstn),
        .valid_in (valid_in),
        .din_re   (din_re_reg),
        .din_im   (din_im_reg),
        .sr_din_re(sr_re_3),
        .sr_din_im(sr_im_3),
        .u_re     (u_re_3),
        .u_im     (u_im_3),
        .v_re     (v_re_3),
        .v_im     (v_im_3),
        .valid_out(valid_out_3_1d),
        .mux_sel  (mux_sel_3)
    );

    shift_register #(
        .DATA (DATA + 1),
        .ARRAY(ARRAY),
        .INDEX(DELAY - 1)
    ) u_sr_v_reg_3 (
        .clk        (clk),
        .rstn       (rstn),
        .data_in_re (v_re_3),
        .data_in_im (v_im_3),
        .data_out_re(sr_v_re_3),
        .data_out_im(sr_v_im_3)
    );

    mux4to2 #(
        .ARRAY(ARRAY),
        .DATA (DATA + 1)
    ) u_mux_3 (
        .sel    (mux_sel_3),
        .u_in_re(u_re_3),
        .u_in_im(u_im_3),
        .v_in_re(sr_v_re_3),
        .v_in_im(sr_v_im_3),
        .out_re (out_re_3),
        .out_im (out_im_3)
    );

	mul_fact8_0 #(
		.DATA(DATA + 1),
		.ARRAY(ARRAY),
		.CNT_MAX(3)
	) u_fact8_0_3 (
        .clk     (clk),
        .rstn    (rstn),
        .mul_en_0(valid_out_3_1d),  // 입력 valid
        .re_0    (out_re_3),     // real 입력 배열
        .im_0    (out_im_3),     // imag 입력 배열
        .re_m_0  (re_m_3_reg),   // real twiddle 적용 결과
        .im_m_0  (im_m_3_reg)    // imag twiddle 적용 결과
    );

    // pipeline register before final outputs
    always_ff @(posedge clk or negedge rstn) begin
        integer idx;
        if (!rstn) begin
            valid_out_3_2d <= 1'b0;
            for (idx = 0; idx < ARRAY; idx++) begin
                re_m_3[idx] <= '0;
                im_m_3[idx] <= '0;
            end
        end else begin
            valid_out_3_2d <= valid_out_3_1d;
            for (idx = 0; idx < ARRAY; idx++) begin
                re_m_3[idx] <= re_m_3_reg[idx];
                im_m_3[idx] <= im_m_3_reg[idx];
            end
        end
    end

endmodule


