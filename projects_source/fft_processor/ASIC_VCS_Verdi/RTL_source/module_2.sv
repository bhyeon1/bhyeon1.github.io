`timescale 1ns / 1ps

module module_2 (
    input  logic                    clk,
    input  logic                    rstn,
    input  logic                    valid_in,
    input  logic signed [11:0]  din_re     [15:0],
    input  logic signed [11:0]  din_im     [15:0],
	input  logic  	    [4:0]	    index0,
	input  logic 		[4:0] 	    index1_0_7,
	input  logic 		[4:0] 	    index1_8_15,  

    output logic                    valid_out,
    output logic signed [12:0]    dout_re    [511:0],
    output logic signed [12:0]    dout_im    [511:0]
);
	
 	logic signed [12:0] dout_re_shift [511:0]; // 추가
    logic signed [12:0] dout_im_shift [511:0]; // 추가
	

    logic valid_out_6_2d;
    logic signed [12:0] re_m_6[15:0];
    logic signed [12:0] im_m_6[15:0];

    fft_stage_6 #(
        .DATA (12),
        .ARRAY(16),
        .PAIR(1)
    ) u_fft_stage_6 (
        .clk(clk),
        .rstn(rstn),
        .valid_in(valid_in),
        .din_re(din_re),
        .din_im(din_im),
        .valid_out_6_2d(valid_out_6_2d),
        .re_m_6(re_m_6),
        .im_m_6(im_m_6)
    );

    logic valid_out_7_3d;
    logic signed [14:0] re_m_7[15:0];
    logic signed [14:0] im_m_7[15:0];

    fft_stage_7 #(
        .DATA (13),
        .ARRAY(16),
        .PAIR(2)
    ) u_fft_stage_7 (
        .clk(clk),
        .rstn(rstn),
        .valid_in(valid_out_6_2d),
        .din_re(re_m_6),
        .din_im(im_m_6),
        .valid_out_7_3d(valid_out_7_3d),
        .re_m_7(re_m_7),
        .im_m_7(im_m_7)
    );
	
	// 여기서부터
    logic valid_out_8_2d;

    fft_stage_8 #(
        .DATA (15),
        .ARRAY(16),
        .PAIR(3)
    ) u_fft_stage_8 (
        .clk			(clk),
        .rstn			(rstn),
        .valid_in		(valid_out_7_3d),
		.index0			(index0),
		.index1_0_7		(index1_0_7),
		.index1_8_15	(index1_8_15),
        .din_re			(re_m_7),
        .din_im			(im_m_7),
        .valid_out_8_2d (valid_out_8_2d),
        .dout_re_shift	(dout_re_shift), // reordering
        .dout_im_shift	(dout_im_shift)
    );

	assign dout_re   = dout_re_shift;
	assign dout_im   = dout_im_shift;
	assign valid_out = valid_out_8_2d;

endmodule
