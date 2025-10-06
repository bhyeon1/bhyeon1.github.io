`timescale 1ns / 1ps

module mul_fact8_0 #(
    parameter int DATA    = 10,    // 출력 비트 수
    parameter int ARRAY   = 16,
	parameter int CNT_MAX = 31
)(
    input  logic                     clk,
    input  logic                     rstn,
    input  logic                     mul_en_0,
    input  logic signed [DATA-1:0]   re_0   [ARRAY-1:0],
    input  logic signed [DATA-1:0]   im_0   [ARRAY-1:0],
    output logic signed [DATA-1:0]   re_m_0 [ARRAY-1:0],
    output logic signed [DATA-1:0]   im_m_0 [ARRAY-1:0]
);

	localparam int CYCLE_LEN = ((CNT_MAX + 1) * 3) / 4;
	localparam int CNT_W  	 = $clog2(CNT_MAX + 1);

    logic [CNT_W-1:0] cnt;

    // count 증가 (valid_out_0 펄스마다 0..31 카운트)
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn)
			cnt <= 0;
        else if (mul_en_0 && cnt <= CNT_MAX)
			cnt <= cnt + 1;
		else cnt <= 0;
    end

    // 곱셈 없이 twiddle 적용: +1 구간은 그대로, -j 구간만 swap & negate
    integer j;
    always_comb begin
        for (j = 0; j < ARRAY; j++) begin
            if (cnt < CYCLE_LEN) begin
                re_m_0[j] = re_0[j];
                im_m_0[j] = im_0[j];
            end else begin
                re_m_0[j] = im_0[j];
                im_m_0[j] = -re_0[j];
            end
        end
    end

endmodule
