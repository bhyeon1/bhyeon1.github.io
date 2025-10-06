module mul_twf0_2 (
    input  logic               clk,
    input  logic               rstn,
    input  logic               mul_en,
    input  logic signed [13:0] x_re     [15:0],
    input  logic signed [13:0] x_im     [15:0],
    output logic signed [22:0] y_re     [15:0],
    output logic signed [22:0] y_im     [15:0],
    output logic               valid_out
);
	
	function automatic logic signed [12:0] sat13(
		input logic signed [13:0] in
	);
		
		// 13bit signed range
		localparam logic signed [12:0] MAX13 = 13'sd4095;
		localparam logic signed [12:0] MIN13 = -13'sd4096;

		if		(in > MAX13) sat13 = MAX13;
		else if (in < MIN13) sat13 = MIN13;
		else 				 sat13 = in[12:0];
	endfunction

    // mul counter
    logic        [4:0] cnt;  // 0~32 count

    // twiddle outputs
    logic signed [8:0] twf_re              [15:0];
    logic signed [8:0] twf_im              [15:0];
    logic signed [12:0] x_re_d              [15:0];
    logic signed [12:0] x_im_d              [15:0];
    logic              mul_start;
    logic              mul_reg;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            cnt <= '0;
			for (int i = 0; i < 16; i++) begin
                x_re_d[i] <= '0;
                x_im_d[i] <= '0;
            end
        end else begin
            if (mul_en) cnt <= cnt + 1;
			else cnt <= '0;
			for (int i = 0; i < 16; i++) begin
				x_re_d[i] <= sat13(x_re[i]);
				x_im_d[i] <= sat13(x_im[i]);
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
    twf0_2 u_twf0_2 (
        .clk(clk),
        .rstn(rstn),
        .grp_idx(cnt[4:0]),  // 최대 32개 그룹
        .re(twf_re),
        .im(twf_im)
    );

    logic signed [21:0] y_re_reg[15:0];
    logic signed [21:0] y_im_reg[15:0];

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
            if (mul_start) mul_reg <= mul_start;
            else mul_reg <= '0;
			for (i = 0; i < 16; i++) begin
				y_re_reg[i] <= x_re_d[i] * twf_re[i] - x_im_d[i] * twf_im[i];
				y_im_reg[i] <= x_re_d[i] * twf_im[i] + x_im_d[i] * twf_re[i];
			end
		end
    end

    assign valid_out = mul_reg;
    
	always_comb begin
        integer i;
        for (i = 0; i < 16; i++) begin
            y_re[i] = {y_re_reg[i][21], y_re_reg[i]};
            y_im[i] = {y_im_reg[i][21], y_im_reg[i]};
        end
    end

endmodule
