`timescale 1ns / 1ps

module mul20_fact8_0 #(
    parameter int DATA    = 10,    // 출력 비트 수
    parameter int ARRAY   = 16
)(
    input  logic                     clk,
    input  logic                     rstn,
    input  logic                     mul_en,
    input  logic signed [DATA-1:0]   re   [ARRAY-1:0],
    input  logic signed [DATA-1:0]   im   [ARRAY-1:0],
    output logic signed [DATA-1:0]   re_m [ARRAY-1:0],
    output logic signed [DATA-1:0]   im_m [ARRAY-1:0]
);

    // 곱셈 없이 twiddle 적용: +1 구간은 그대로, -j 구간만 swap & negate
    integer j;
    always_comb begin
		if (mul_en) begin
			for (j = 0; j < 16; j++) begin
				if ((j < 6) || ( (j >= 8) && (j < 14) ) ) begin
					re_m[j] = re[j];
					im_m[j] = im[j];
				end else begin
					re_m[j] = im[j];
					im_m[j] = -re[j];
				end
			end
		end else begin
			for (j = 0; j < 16; j++) begin
				re_m[j] = '0;
				im_m[j] = '0;
			end
		end
	end

endmodule
