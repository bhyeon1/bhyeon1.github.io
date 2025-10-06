`timescale 1ns / 1ps

module shift_register_2 #(
	parameter DATA = 9,
	parameter INDEX = 16
)(
	input  logic                    clk,
	input  logic                    rstn,
	input  logic signed [DATA-1:0]  data_in_1,
	input  logic signed [DATA-1:0]  data_in_2,
	output logic signed [DATA-1:0]  data_out_1,
	output logic signed [DATA-1:0]  data_out_2
);

	logic signed [DATA-1:0] shift_1 [INDEX-1:0];
	logic signed [DATA-1:0] shift_2 [INDEX-1:0];

	integer i, j;

	always_ff @(posedge clk or negedge rstn) begin
		if (!rstn) begin
			for (i = 0; i < INDEX; i++) begin
				shift_1[i] <= '0;
				shift_2[i] <= '0;
			end
		end else begin
			for (i = INDEX-1; i > 0; i--) begin
				shift_1[i] <= shift_1[i-1];
				shift_2[i] <= shift_2[i-1];
			end
			shift_1[0] <= data_in_1;
			shift_2[0] <= data_in_2;
		end 
	end

	assign data_out_1 = shift_1[INDEX-1];
	assign data_out_2 = shift_2[INDEX-1];

endmodule


