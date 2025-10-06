`timescale 1ns / 1ps

module top_cos_fft (
    //input logic clk,    // tb 돌릴때 주석풀기
    input logic clk_p,    // tb 돌릴때는 주석처리
    input logic clk_n,    // tb 돌릴때는 주석처리
    input logic rstn
    //output logic valid_out, // tb 돌릴때 주석풀기
    //output logic signed [12:0] dout_re[15:0],   // tb 돌릴때 주석풀기
    //output logic signed [12:0] dout_im[15:0]    // tb 돌릴때 주석풀기
);

    //logic valid_in;  // tb 돌릴때 주석풀기
    logic valid_in, clk, valid_out;   // tb 돌릴때는 주석처리
    logic signed [8:0] cos_re[15:0];
    logic signed [8:0] cos_im[15:0];

    logic signed [12:0] dout_re[15:0];    // tb 돌릴때는 주석처리
    logic signed [12:0] dout_im[15:0];    // tb 돌릴때는 주석처리

    cos_generator u_cos_gen (
        .clk(clk),
        .rstn(rstn),
        .valid_in_1d(valid_in),
        .cos_re_1d(cos_re),
        .cos_im_1d(cos_im)
    );

    top_fft_module u_top_fft (
        .clk(clk),
        .rstn(rstn),
        .valid_in(valid_in),
        .din_re_t(cos_re),
        .din_im_t(cos_im),
        .valid_out(valid_out),
        .dout_re_t(dout_re),
        .dout_im_t(dout_im)
    );


    // tb 돌릴때는 주석처리
    vio_0 u_vio_0 (
        .clk(clk),
        .probe_in0(dout_re[0]),
        .probe_in1(dout_re[1]),
        .probe_in2(dout_re[2]),
        .probe_in3(dout_re[3]),
        .probe_in4(dout_re[4]),
        .probe_in5(dout_re[5]),
        .probe_in6(dout_re[6]),
        .probe_in7(dout_re[7]),
        .probe_in8(dout_re[8]),
        .probe_in9(dout_re[9]),
        .probe_in10(dout_re[10]),
        .probe_in11(dout_re[11]),
        .probe_in12(dout_re[12]),
        .probe_in13(dout_re[13]),
        .probe_in14(dout_re[14]),
        .probe_in15(dout_re[15]),
        .probe_in16(dout_im[0]),
        .probe_in17(dout_im[1]),
        .probe_in18(dout_im[2]),
        .probe_in19(dout_im[3]),
        .probe_in20(dout_im[4]),
        .probe_in21(dout_im[5]),
        .probe_in22(dout_im[6]),
        .probe_in23(dout_im[7]),
        .probe_in24(dout_im[8]),
        .probe_in25(dout_im[9]),
        .probe_in26(dout_im[10]),
        .probe_in27(dout_im[11]),
        .probe_in28(dout_im[12]),
        .probe_in29(dout_im[13]),
        .probe_in30(dout_im[14]),
        .probe_in31(dout_im[15]),
        .probe_in32(valid_out)
    );

    // tb 돌릴때는 주석처리
    clk_wiz_0 u_clk_wiz_0 (
        .clk_out1(clk),
        .resetn(rstn),
        .locked(),
        .clk_in1_p(clk_p),
        .clk_in1_n(clk_n)
    );

endmodule

