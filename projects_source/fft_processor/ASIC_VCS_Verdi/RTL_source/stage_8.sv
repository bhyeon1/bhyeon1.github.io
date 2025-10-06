`timescale 1ns / 1ps

module fft_stage_8 #(
    parameter DATA  = 15,
    parameter ARRAY = 16,
	parameter PAIR  = 3
) (
    input  logic                   clk,
    input  logic                   rstn,
    input  logic                   valid_in,
	input  logic  	    [4:0]	   index0,
	input  logic 		[4:0] 	   index1_0_7,
	input  logic 		[4:0] 	   index1_8_15, 		 
    input  logic signed [DATA-1:0] din_re        [ARRAY-1:0],
    input  logic signed [DATA-1:0] din_im        [ARRAY-1:0],
    output logic                   valid_out_8_2d,
    output logic signed [12:0] 	   dout_re_shift [511:0],
    output logic signed [12:0]     dout_im_shift [511:0]
);

    // 내부 신호
    logic signed [DATA:0] uv_re_8    [ARRAY-1:0];
    logic signed [DATA:0] uv_im_8    [ARRAY-1:0];
    logic                 valid_out_8_1d;

    // 비트 쉬프트 출력 추가
    logic signed [DATA-3:0] bs_re [ARRAY-1:0];
    logic signed [DATA-3:0] bs_im [ARRAY-1:0];
    logic            valid_bitshift_out;

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
    ) u_bf08 (
        .clk      	  (clk),
        .rstn     	  (rstn),
        .valid_in 	  (valid_in),
        .x_re   	  (din_re_reg),
        .x_im   	  (din_im_reg),
        .y_re         (uv_re_8),
        .y_im     	  (uv_im_8),
        .valid_out_1d (valid_out_8_1d)
    );

    // bit shift 추가
    bit_shift_2_2 #(
        .DATA (DATA + 1), // uv_re_8, uv_im_8는 DATA+1 비트이므로
        .ARRAY(ARRAY)
    ) u_bitshift (
        .clk       	 (clk),
        .rstn      	 (rstn),
        .valid_in  	 (valid_out_8_1d),
        .re_in     	 (uv_re_8),
        .im_in     	 (uv_im_8),
        .index0    	 (index0),
        .index1_0_7	 (index1_0_7),
        .index1_8_15 (index1_8_15),
        .re_out    	 (bs_re),
        .im_out    	 (bs_im),
        .valid_out 	 (valid_bitshift_out)
    );

    // Reordering 추가
    fft_reorder u_reorder_re (
        .clk      (clk),
        .rstn     (rstn),
        .valid_in (valid_bitshift_out),
        .in_data  (bs_re),
        .dout_mem (dout_re_shift),
        .valid_out(valid_out_8_2d)
);

    fft_reorder u_reorder_im (
        .clk      (clk),
        .rstn     (rstn),
        .valid_in (valid_bitshift_out),
        .in_data  (bs_im),
        .dout_mem (dout_im_shift),
        .valid_out()  
);
	
endmodule
