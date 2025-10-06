`timescale 1ns / 1ps

module bit_shift_2_2 #(
	parameter int DATA = 16,
	parameter int ARRAY = 16
) (
	input logic                   clk,
    input logic                   rstn,
    input logic                   valid_in,
    input logic signed [DATA-1:0] re_in   [ARRAY-1:0],
    input logic signed [DATA-1:0] im_in   [ARRAY-1:0],
	input logic 	   [	 4:0] index0,
	input logic 	   [	 4:0] index1_0_7,
	input logic 	   [	 4:0] index1_8_15,

	output logic signed [DATA-4:0] re_out  [ARRAY-1:0],
	output logic signed [DATA-4:0] im_out  [ARRAY-1:0],
	output logic				  valid_out

);

	logic [4:0] index0_reg;
	logic [4:0] index0_sr;
	logic [4:0] index1_h_reg;
	logic [4:0] index1_h_sr;
	logic [4:0] index1_l_reg;
	logic [4:0] index1_l_sr;
	logic [4:0] index_sum 	[1:0];
	logic [4:0] index_shift [1:0];

	
	always_ff @(posedge clk or negedge rstn) begin
		if (!rstn) begin
			index0_reg <= '0;
			index1_h_reg <= '0;
			index1_l_reg <= '0;
		end else begin
			index0_reg <= index0;
			index1_h_reg <= index1_8_15;
			index1_l_reg <= index1_0_7;
		end
	end
	

   shift_register_1 #(
        .DATA (5),
		.INDEX(26)
	) bs_sr1 (
		.clk        (clk),
        .rstn       (rstn),
        .data_in_re (index0_reg),
        .data_out_re(index0_sr)
    );

	shift_register_2 #(
		.DATA (5),
        .INDEX(9)
	) bs_sr2 (
        .clk        (clk),
        .rstn       (rstn),
        .data_in_1 (index1_h_reg),
        .data_in_2 (index1_l_reg),
        .data_out_1(index1_h_sr),
        .data_out_2(index1_l_sr)
    );

	assign index_sum[0] = index0_sr + index1_l_sr;
	assign index_sum[1] = index0_sr + index1_h_sr;

	assign index_shift[0] = index_sum[0] > 9 ? index_sum[0] - 9 : 9 - index_sum[0];
	assign index_shift[1] = index_sum[1] > 9 ? index_sum[1] - 9 : 9 - index_sum[1];
	
	logic [DATA-4:0] re_shift [ARRAY-1:0];
	logic [DATA-4:0] im_shift [ARRAY-1:0];

	always_comb begin
		integer i;
		if (valid_in) begin
			if (index_sum[0] >= 23) begin
				for (i = 0; i < 8; i++) begin
					re_shift[i] = '0;
					im_shift[i] = '0;
				end
			end else begin
				if (index_sum[0] > 9) begin
					for (i = 0; i < 8; i++) begin
						re_shift[i] = re_in[i] >>> index_shift[0];
						im_shift[i] = im_in[i] >>> index_shift[0];
					end
				end else begin
					for (i = 0; i < 8; i++) begin
						re_shift[i] = re_in[i] <<< index_shift[0];
						im_shift[i] = im_in[i] <<< index_shift[0];
					end
				end
			end
		end else begin
			for (i = 0; i < 8; i++) begin
				re_shift[i] = '0;
				im_shift[i] = '0;
			end
		end
	end

	always_comb begin
		integer j;
		if (valid_in) begin
			if (index_sum[1] >= 23) begin
				for (j = 8; j < 16; j++) begin
					re_shift[j] = '0;
					im_shift[j] = '0;
				end
			end else begin
				if (index_sum[1] > 9) begin
					for (j = 8; j < 16; j++) begin
						re_shift[j] = re_in[j] >>> index_shift[1];
						im_shift[j] = im_in[j] >>> index_shift[1];
					end
				end else begin
					for (j = 8; j < 16; j++) begin
						re_shift[j] = re_in[j] <<< index_shift[1];
						im_shift[j] = im_in[j] <<< index_shift[1];
					end
				end
			end
		end else begin
			for (j = 8; j < 16; j++) begin
				re_shift[j] = '0;
				im_shift[j] = '0;
			end
		end
	end

	always_ff @(posedge clk or negedge rstn) begin
		integer i;
		if (!rstn) begin
			valid_out <= 0;
			for (i = 0; i < ARRAY; i++) begin
				re_out[i] <= '0;
				im_out[i] <= '0;
			end
		end else begin
			valid_out <= valid_in;
			for (i = 0; i < ARRAY; i++) begin
				re_out[i] <= re_shift[i];
				im_out[i] <= im_shift[i];
			end
		end
	end

endmodule

