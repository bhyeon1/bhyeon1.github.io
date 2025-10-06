`timescale 1ns / 1ps

module shift_register_1 #(
	parameter DATA = 9,
	parameter INDEX = 16
)(
	input  logic                    clk,
	input  logic                    rstn,
	input  logic signed [DATA-1:0]  data_in_re,
	output logic signed [DATA-1:0]  data_out_re
);

	logic signed [DATA-1:0] shift_re [INDEX-1:0];

	integer i, j;

	always_ff @(posedge clk or negedge rstn) begin
		if (!rstn) begin
			for (i = 0; i < INDEX; i++) begin
					shift_re[i] <= '0;
			end
		end else begin
			for (i = INDEX-1; i > 0; i--) begin
				shift_re[i] <= shift_re[i-1];
			end
			shift_re[0] <= data_in_re;
		end 
	end

	assign data_out_re = shift_re[INDEX-1];

endmodule


