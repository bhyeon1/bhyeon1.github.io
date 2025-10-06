`timescale 1ns / 1ps

module mul_twf1_1 (
    input  logic               clk,
    input  logic               rstn,
    input  logic               mul_en,
    input  logic signed [12:0] x_re  [15:0],
    input  logic signed [12:0] x_im  [15:0],
    output logic signed [13:0] y_re  [15:0],
    output logic signed [13:0] y_im  [15:0],
	output logic 			   valid_out
);

    // mul counter
    logic        [4:0] cnt; // 0~32 count

    // twiddle outputs
    logic signed [9:0] twf_re    [15:0];
    logic signed [9:0] twf_im    [15:0];
    logic signed [12:0] x_re_d    [15:0];
    logic signed [12:0] x_im_d    [15:0];
    logic              mul_start;
	logic              mul_reg;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            cnt <= 0;
            for (int i = 0; i < 16; i++) begin
                x_re_d[i] <= '0;
                x_im_d[i] <= '0;
            end
        end else begin
            if (mul_en)	cnt <= cnt + 1;
			else cnt <= '0;
			for (int i = 0; i < 16; i++) begin
				x_re_d[i] <= x_re[i];
				x_im_d[i] <= x_im[i];
			end
		end
    end

	always_ff @(posedge clk or negedge rstn) begin
		if (!rstn) begin
			mul_start <= 0;
		end else begin
			mul_start <= mul_en;
		end
	end

    // twiddle 인스턴스
    twf1_1 u_twf1_1 (
        .clk(clk),
        .rstn(rstn),
        .grp_idx(cnt[4:0]),  // 최대 32개 그룹
        .re(twf_re),
        .im(twf_im)
    );

	logic signed [23:0] y_re_reg [15:0];
	logic signed [23:0] y_im_reg [15:0];

    // 곱셈
    always_ff @(posedge clk or negedge rstn) begin
        integer i;
        if (!rstn) begin
			mul_reg <= 0;
            for (i = 0; i < 16; i++) begin
                y_re_reg[i] <= '0;
                y_im_reg[i] <= '0;
            end
        end else begin
			mul_reg <= mul_start;
			for (i = 0; i < 16; i++) begin
				y_re_reg[i] <= x_re_d[i] * twf_re[i] - x_im_d[i] * twf_im[i];
				y_im_reg[i] <= x_re_d[i] * twf_im[i] + x_im_d[i] * twf_re[i];
			end
        end
    end
	
	assign valid_out = mul_reg;
	
	// truncation
	function automatic logic [14:0] output_16bit (input logic [22:0] x);
		return x[22 -: 15];
	endfunction

	// Saturation
	function automatic logic signed [13:0] sat14(
    input logic signed [14:0] in // 8 개 절삭 bit
   );
      
      // 13bit signed range
      localparam logic signed [13:0] MAX14 = 14'sd8191;
      localparam logic signed [13:0] MIN14 = -14'sd8192; // 2^13 = 8192

      if      (in > MAX14) sat14 = MAX14;
      else if (in < MIN14) sat14 = MIN14;
      else                 sat14 = in[13:0];
   endfunction

	always_comb begin
		integer i;
		for (i = 0; i < 16; i++) begin
			y_re[i] = sat14(output_16bit(y_re_reg[i]+128));
			y_im[i] = sat14(output_16bit(y_im_reg[i]+128));
		end
	end
	
endmodule


