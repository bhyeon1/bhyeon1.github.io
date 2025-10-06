`timescale 1ns / 1ps

module fft_stage_6 #(
    parameter DATA  = 12,
    parameter ARRAY = 16,
	parameter PAIR  = 1
) (
    input  logic                   clk,
    input  logic                   rstn,
    input  logic                   valid_in,
    input  logic signed [DATA-1:0] din_re        [ARRAY-1:0],
    input  logic signed [DATA-1:0] din_im        [ARRAY-1:0],
    output logic                   valid_out_6_2d,
    output logic signed [  DATA:0] re_m_6        [ARRAY-1:0],
    output logic signed [  DATA:0] im_m_6        [ARRAY-1:0]
);

    // 내부 신호
    logic signed [DATA:0] uv_re_6    [ARRAY-1:0];
    logic signed [DATA:0] uv_im_6    [ARRAY-1:0];
    logic signed [DATA:0] re_m_6_reg [ARRAY-1:0];
    logic signed [DATA:0] im_m_6_reg [ARRAY-1:0];
    logic                 valid_out_6_1d;

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

    // Butterfly 컨트롤러 + 연산기 인스턴스
    bf_cntr_no_sr #(
        .DATA (DATA),
        .ARRAY(ARRAY),
		.PAIR(PAIR)
    ) u_bf06 (
        .clk      	  (clk),
        .rstn     	  (rstn),
        .valid_in 	  (valid_in),
        .x_re   	  (din_re_reg),
        .x_im   	  (din_im_reg),
        .y_re         (uv_re_6),
        .y_im     	  (uv_im_6),
        .valid_out_1d (valid_out_6_1d)
    );

	mul20_fact8_0 #(
		.DATA(DATA + 1),
		.ARRAY(ARRAY)
	) u_fact8_0_6 (
        .clk     (clk),
        .rstn    (rstn),
        .mul_en	 (valid_out_6_1d),  // 입력 valid
        .re    	 (uv_re_6),     // real 입력 배열
        .im    	 (uv_im_6),     // imag 입력 배열
        .re_m  	 (re_m_6_reg),   // real twiddle 적용 결과
        .im_m  	 (im_m_6_reg)    // imag twiddle 적용 결과
    );

    // pipeline register before final outputs
    always_ff @(posedge clk or negedge rstn) begin
        integer idx;
        if (!rstn) begin
            valid_out_6_2d <= 1'b0;
            for (idx = 0; idx < ARRAY; idx++) begin
                re_m_6[idx] <= '0;
                im_m_6[idx] <= '0;
            end
        end else begin
            valid_out_6_2d <= valid_out_6_1d;
            for (idx = 0; idx < ARRAY; idx++) begin
                re_m_6[idx] <= re_m_6_reg[idx];
                im_m_6[idx] <= im_m_6_reg[idx];
            end
        end
    end

endmodule
