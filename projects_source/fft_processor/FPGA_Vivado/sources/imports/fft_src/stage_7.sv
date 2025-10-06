`timescale 1ns / 1ps

module fft_stage_7 #(
    parameter DATA  = 13,
    parameter ARRAY = 16,
    parameter PAIR = 2
) (
    input  logic                    clk,
    input  logic                    rstn,
    input  logic                    valid_in,
    input  logic signed [DATA-1:0]  din_re        [ARRAY-1:0],
    input  logic signed [DATA-1:0]  din_im        [ARRAY-1:0],
    output logic                    valid_out_7_3d, 

    output logic signed [DATA+1:0] re_m_7        [ARRAY-1:0], 
    output logic signed [DATA+1:0] im_m_7        [ARRAY-1:0]
);	

    // 내부 신호
    logic signed [DATA:0] uv_re_7        [ARRAY-1:0];
    logic signed [DATA:0] uv_im_7        [ARRAY-1:0];

    logic signed [14:0] re_m_7_reg     [ARRAY-1:0];
    logic signed [14:0] im_m_7_reg     [ARRAY-1:0];
    logic               valid_out_7_1d, valid_out_7_2d;

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
        .DATA    (DATA),
        .PAIR    (PAIR),
        .ARRAY   (ARRAY)
    ) u_bf07 (
        .clk           (clk),
        .rstn          (rstn),
        .valid_in      (valid_in),
        .x_re          (din_re_reg),
        .x_im          (din_im_reg),
        .y_re          (uv_re_7),
        .y_im          (uv_im_7),
        .valid_out_1d  (valid_out_7_1d)
    );
	
   	mul_twf2_1 u_mul_twf2_1 (
        .clk       (clk),
        .rstn      (rstn),
        .mul_en    (valid_out_7_1d),  	// 입력 valid
        .x_re      (uv_re_7),     		// real 입력 배열
        .x_im      (uv_im_7),     		// imag 입력 배열
        .y_re      (re_m_7_reg),   		// real twiddle 적용 결과
        .y_im      (im_m_7_reg),    	// imag twiddle 적용 결과
		.valid_out (valid_out_7_2d) 
    );

    // pipeline register before final outputs
    always_ff @(posedge clk or negedge rstn) begin
        integer idx;
        if (!rstn) begin
            valid_out_7_3d <= 1'b0;
            for (idx = 0; idx < ARRAY; idx++) begin
                re_m_7[idx] <= '0;
                im_m_7[idx] <= '0;
            end
        end else begin
            valid_out_7_3d <= valid_out_7_2d;
            for (idx = 0; idx < ARRAY; idx++) begin
                re_m_7[idx] <= re_m_7_reg[idx];
                im_m_7[idx] <= im_m_7_reg[idx];
            end
        end
    end

endmodule

