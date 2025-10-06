`timescale 1ns / 1ps

module module_1 (
    input  logic                 clk,
    input  logic                 rstn,
    input  logic                 valid_in,
    input  logic signed [   10:0] din_re   [15:0],
    input  logic signed [   10:0] din_im   [15:0],
    output logic                 valid_out,
    output logic signed [11:0] 	 dout_re  [15:0],
    output logic signed [11:0]   dout_im  [15:0],
	output logic        [4:0]      index_h,
	output logic        [4:0]      index_l
);

    logic valid_out_3_2d;
    logic signed [11:0] re_m_3[15:0];
    logic signed [11:0] im_m_3[15:0];

    fft_stage_3 #(
        .DATA (11),
        .ARRAY(16),
        .DELAY(3),
        .STAGE(3)
    ) u_fft_stage_3 (
        .clk(clk),
        .rstn(rstn),
        .valid_in(valid_in),
        .din_re(din_re),
        .din_im(din_im),
        .valid_out_3_2d(valid_out_3_2d),
        .re_m_3(re_m_3),
        .im_m_3(im_m_3)
    );

    logic valid_out_4_3d;
    logic signed [13:0] re_m_4[15:0];
    logic signed [13:0] im_m_4[15:0];

    fft_stage_4 #(
        .DATA (12),
        .ARRAY(16),
        .DELAY(2),
        .STAGE(4)
    ) u_fft_stage_4 (
        .clk(clk),
        .rstn(rstn),
        .valid_in(valid_out_3_2d),
        .din_re(re_m_3),
        .din_im(im_m_3),
        .valid_out_4_3d(valid_out_4_3d),
        .re_m_4(re_m_4),
        .im_m_4(im_m_4)
    );

    logic valid_out_5_3d;
    logic signed [24:0] re_m_5[15:0];
    logic signed [24:0] im_m_5[15:0];

    fft_stage_5 #(
        .DATA (14),
        .ARRAY(16),
        .PAIR(0)
    ) u_fft_stage_5 (
        .clk(clk),
        .rstn(rstn),
        .valid_in(valid_out_4_3d),
        .din_re(re_m_4),
        .din_im(im_m_4),
        .valid_out_5_3d(valid_out_5_3d),
        .re_m_5(re_m_5),
        .im_m_5(im_m_5)
    );
    
	logic signed [11:0]     re_out [15:0];
    logic signed [11:0]     im_out [15:0];
    logic                   val_out;
	
	fft_cbfp_1 #(
    .DATA(25),
    .ARRAY(16) 
	) u_cbfp_1 (
    .clk(clk),
	.rstn(rstn),
	.val_in(valid_out_5_3d),
	.re_in(re_m_5),
	.im_in(im_m_5),
	.re_out(re_out),
	.im_out(im_out),
	.val_out(val_out),
	.index_h(index_h),
	.index_l(index_l)
	);

	assign dout_re = re_out;
	assign dout_im = im_out;
	assign valid_out = val_out;
	
endmodule
