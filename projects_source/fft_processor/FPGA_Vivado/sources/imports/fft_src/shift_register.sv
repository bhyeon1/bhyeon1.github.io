`timescale 1ns / 1ps

module shift_register #(
	parameter DATA = 9,
	parameter ARRAY = 16,
	parameter INDEX = 16
)(
	input  logic                    clk,
	input  logic                    rstn,
	input  logic signed [DATA-1:0]  data_in_re [ARRAY-1:0],
	input  logic signed [DATA-1:0]  data_in_im [ARRAY-1:0],
	output logic signed [DATA-1:0]  data_out_re [ARRAY-1:0],
	output logic signed [DATA-1:0]  data_out_im [ARRAY-1:0]
);

	logic signed [DATA-1:0] shift_re [INDEX-1:0][ARRAY-1:0];
	logic signed [DATA-1:0] shift_im [INDEX-1:0][ARRAY-1:0];

	integer i, j;

	always_ff @(posedge clk or negedge rstn) begin
		if (!rstn) begin
			for (i = 0; i < INDEX; i++) begin
				for (j = 0; j < ARRAY; j++) begin
					shift_re[i][j] <= '0;
					shift_im[i][j] <= '0;
				end
			end
		end else begin
			for (i = INDEX-1; i > 0; i--) begin
				for (j = 0; j < ARRAY; j++) begin
					shift_re[i][j] <= shift_re[i-1][j];
					shift_im[i][j] <= shift_im[i-1][j];
				end
			end
			for (j = 0; j < ARRAY; j++) begin
				shift_re[0][j] <= data_in_re[j];
				shift_im[0][j] <= data_in_im[j];
			end
		end 
	end

	assign data_out_re = shift_re[INDEX-1];
	assign data_out_im = shift_im[INDEX-1];

endmodule


