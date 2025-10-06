`timescale 1ns / 1ps

module fft_stage_1 #(
    parameter DATA  = 10,
    parameter ARRAY = 16,
    parameter DELAY = 9,
	parameter STAGE = 1
) (
    input  logic                   clk,
    input  logic                   rstn,
    input  logic                   valid_in,
    input  logic signed [DATA-1:0] din_re        [ARRAY-1:0],
    input  logic signed [DATA-1:0] din_im        [ARRAY-1:0],
    output logic                   valid_out_1_3d,
    output logic signed [DATA+2:0] re_m_1        [ARRAY-1:0],
    output logic signed [DATA+2:0] im_m_1        [ARRAY-1:0]
);

    // 내부 신호
    logic signed [DATA-1:0] sr_re_1        [ARRAY-1:0];
    logic signed [DATA-1:0] sr_im_1        [ARRAY-1:0];
    logic signed [DATA:0] sr_v_re_1      [ARRAY-1:0];
    logic signed [DATA:0] sr_v_im_1      [ARRAY-1:0];
    logic signed [DATA:0] u_re_1         [ARRAY-1:0];
    logic signed [DATA:0] u_im_1         [ARRAY-1:0];
    logic signed [DATA:0] v_re_1         [ARRAY-1:0];
    logic signed [DATA:0] v_im_1         [ARRAY-1:0];
    logic signed [DATA:0] out_re_1       [ARRAY-1:0];
    logic signed [DATA:0] out_im_1       [ARRAY-1:0];
    logic signed [DATA:0] out_re_1_1d    [ARRAY-1:0];
    logic signed [DATA:0] out_im_1_1d    [ARRAY-1:0];
    logic signed [DATA+2:0] re_m_1_reg     [15:0];
    logic signed [DATA+2:0] im_m_1_reg     [15:0];
    logic                   valid_out_1_1d, valid_out_1_2d;
    logic                   mux_sel_1;
    //logic mul_en_1;


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
    ) u_sr_bf00 (
        .clk        (clk),
        .rstn       (rstn),
        .data_in_re (din_re),
        .data_in_im (din_im),
        .data_out_re(sr_re_1),
        .data_out_im(sr_im_1)
    );

    // Butterfly 컨트롤러 + 연산기 인스턴스
    bf_cntr #(
        .DATA (DATA),
        .ARRAY(ARRAY),
        .DELAY(DELAY),
		.STAGE(STAGE)
    ) u_bf01 (
        .clk      (clk),
        .rstn     (rstn),
        .valid_in (valid_in),
        .din_re   (din_re_reg),
        .din_im   (din_im_reg),
        .sr_din_re(sr_re_1),
        .sr_din_im(sr_im_1),
        .u_re     (u_re_1),
        .u_im     (u_im_1),
        .v_re     (v_re_1),
        .v_im     (v_im_1),
        .valid_out(valid_out_1_1d),
        .mux_sel  (mux_sel_1)
    );

    shift_register #(
        .DATA (DATA + 1),
        .ARRAY(ARRAY),
        .INDEX(DELAY - 1)
    ) u_sr_v_reg_1 (
        .clk        (clk),
        .rstn       (rstn),
        .data_in_re (v_re_1),
        .data_in_im (v_im_1),
        .data_out_re(sr_v_re_1),
        .data_out_im(sr_v_im_1)
    );

    mux4to2 #(
        .ARRAY(ARRAY),
        .DATA (DATA + 1)
    ) u_mux_1 (
        .sel    (mux_sel_1),
        .u_in_re(u_re_1),
        .u_in_im(u_im_1),
        .v_in_re(sr_v_re_1),
        .v_in_im(sr_v_im_1),
        .out_re (out_re_1),
        .out_im (out_im_1)
    );

    mul_twf0_1 u_mul_fact0_1 (
        .clk      (clk),
        .rstn     (rstn),
        .mul_en	  (valid_out_1_1d),  
		.x_re     (out_re_1), 
		.x_im     (out_im_1), 
		.y_re     (re_m_1_reg),   
		.y_im     (im_m_1_reg),
		.valid_out(valid_out_1_2d)
	);

    // pipeline register before final outputs
    always_ff @(posedge clk or negedge rstn) begin
        integer idx;
        if (!rstn) begin
            valid_out_1_3d <= 1'b0;
            for (idx = 0; idx < ARRAY; idx++) begin
                re_m_1[idx] <= '0;
                im_m_1[idx] <= '0;
            end
        end else begin
            valid_out_1_3d <= valid_out_1_2d;
            for (idx = 0; idx < ARRAY; idx++) begin
                re_m_1[idx] <= re_m_1_reg[idx];
                im_m_1[idx] <= im_m_1_reg[idx];
            end
        end
    end

endmodule

