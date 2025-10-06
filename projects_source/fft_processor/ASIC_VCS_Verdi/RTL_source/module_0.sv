`timescale 1ns / 1ps

module module_0 (
    input  logic                 clk,
    input  logic                 rstn,
    input  logic                 valid_in,
    input  logic signed [8:0] din_re   [15:0],
    input  logic signed [8:0] din_im   [15:0],
    output logic                 valid_out,
    output logic        [4:0]    min_out,
    output logic signed [10:0] 	 dout_re  [15:0],
    output logic signed [10:0]   dout_im  [15:0]
);

    logic valid_out_0_2d;
    logic signed [9:0] re_m_0[15:0];
    logic signed [9:0] im_m_0[15:0];

    fft_stage_0 #(
        .DATA (9),
        .ARRAY(16),
        .DELAY(17),
        .STAGE(0)
    ) u_fft_stage_0 (
        .clk(clk),
        .rstn(rstn),
        .valid_in(valid_in),
        .din_re(din_re),
        .din_im(din_im),
        .valid_out_0_2d(valid_out_0_2d),
        .re_m_0(re_m_0),
        .im_m_0(im_m_0)
    );

    logic valid_out_1_3d;
    logic signed [12:0] re_m_1[15:0];
    logic signed [12:0] im_m_1[15:0];

    fft_stage_1 #(
        .DATA (10),
        .ARRAY(16),
        .DELAY(9),
        .STAGE(1)
    ) u_fft_stage_1 (
        .clk(clk),
        .rstn(rstn),
        .valid_in(valid_out_0_2d),
        .din_re(re_m_0),
        .din_im(im_m_0),
        .valid_out_1_3d(valid_out_1_3d),
        .re_m_1(re_m_1),
        .im_m_1(im_m_1)
    );

    logic valid_out_2_3d;
    logic signed [22:0] re_m_2[15:0];
    logic signed [22:0] im_m_2[15:0];

    fft_stage_2 #(
        .DATA (13),
        .ARRAY(16),
        .DELAY(5),
        .STAGE(2)
    ) u_fft_stage_2 (
        .clk(clk),
        .rstn(rstn),
        .valid_in(valid_out_1_3d),
        .din_re(re_m_1),
        .din_im(im_m_1),
        .valid_out_2_3d(valid_out_2_3d),
        .re_m_2(re_m_2),
        .im_m_2(im_m_2)
    );

	fft_cbfp_0 #(
		.DATA(23),
		.ARRAY(16),
		.INDEX(5)
	) u_cbfp_0 (
		.clk(clk),
		.rstn(rstn),
		.val_in(valid_out_2_3d),
		.re_in(re_m_2),
		.im_in(im_m_2),
		.re_out(dout_re),
		.im_out(dout_im),
        .min_out(min_out),
        .val_out(val_out)
	);

    assign valid_out = val_out;

endmodule
