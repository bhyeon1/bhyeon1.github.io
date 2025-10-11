`timescale 1ns/10ps

module rrc_filter_pipe #(
	parameter WIDTH = 7,
	parameter COEFF_FIXED = 9
)(
	input	clk,
	input	rstn,

	input	signed [WIDTH-1:0] 	   data_in, // format : <1.6>
	output	reg signed [WIDTH-1:0] data_out
);

// fixed <1.8> 값 (signed 9bit)

function signed [COEFF_FIXED-1:0] coeff(input integer idx);
	case (idx)
		0 :	coeff = 9'sd0;
    	1 : coeff = -9'sd1;
    	2 : coeff = 9'sd1;
    	3 : coeff = 9'sd0;
    	4 : coeff = -9'sd1;
    	5 : coeff = 9'sd2;
    	6 : coeff = 9'sd0;
    	7 : coeff = -9'sd2;
    	8 : coeff = 9'sd2;
    	9 : coeff = 9'sd0;
    	10: coeff = -9'sd6;
    	11: coeff = 9'sd8;
    	12: coeff = 9'sd10;
    	13: coeff = -9'sd28;
    	14:	coeff = -9'sd14;
    	15: coeff = 9'sd111;
    	16: coeff = 9'sd196;
    	17: coeff = 9'sd111;
    	18: coeff = -9'sd14; 
    	19: coeff = -9'sd28;
    	20: coeff = 9'sd10;
    	21: coeff = 9'sd8;
    	22: coeff = -9'sd6;
    	23: coeff = 9'sd0;
   	   	24: coeff = 9'sd2;
    	25: coeff = -9'sd2;
    	26: coeff = 9'sd0;
    	27: coeff = 9'sd2;
    	28: coeff = -9'sd1;
   	 	29: coeff = 9'sd0;
    	30: coeff = 9'sd1;
    	31: coeff = -9'sd1;
    	32: coeff = 9'sd0;
		default : coeff = 9'sd0;
	endcase
endfunction

parameter WEIGHT = WIDTH + COEFF_FIXED;

reg signed [WIDTH-1:0] shift_din [32:0];

integer i;
always @(posedge clk or negedge rstn) begin
	if (~rstn) begin
		for (i = 32; i >= 0; i = i - 1) begin
			shift_din[i] <= 0;
		end
	end else begin
		for (i = 32; i > 0; i = i - 1) begin
			shift_din[i] <= shift_din[i - 1];
		end
		shift_din[0] <= data_in;
	end
end

// <1.6> format + <1.8> format = <2.14> format --> 16bit
reg signed [WEIGHT-1:0] mult_weight [32:0];

always @(posedge clk or negedge rstn) begin
	if (~rstn) begin
		for (i = 32; i >= 0; i = i - 1) begin
			mult_weight[i] <= 0;
		end
	end else begin
		for (i = 32; i >= 0; i = i - 1) begin
			mult_weight[i] <= shift_din[i] * coeff(i);
		end
	end
end

/*
wire signed [WEIGHT+6-1:0] sum;
assign sum =
    mult_weight[0]  + mult_weight[1]  + mult_weight[2]  + mult_weight[3]  +
    mult_weight[4]  + mult_weight[5]  + mult_weight[6]  + mult_weight[7]  +
    mult_weight[8]  + mult_weight[9]  + mult_weight[10] + mult_weight[11] +
    mult_weight[12] + mult_weight[13] + mult_weight[14] + mult_weight[15] +
    mult_weight[16] + mult_weight[17] + mult_weight[18] + mult_weight[19] +
    mult_weight[20] + mult_weight[21] + mult_weight[22] + mult_weight[23] +
    mult_weight[24] + mult_weight[25] + mult_weight[26] + mult_weight[27] +
    mult_weight[28] + mult_weight[29] + mult_weight[30] + mult_weight[31] +
    mult_weight[32];
*/

/*
// Stage 1: 33개 → 17개
wire signed [WEIGHT+6-1:0] sum_s1 [0:16];
genvar j;
generate
    for (j = 0; j < 16; j = j + 1) begin
        assign sum_s1[j] = mult_weight[2*j] + mult_weight[2*j + 1];
    end
    assign sum_s1[16] = mult_weight[32]; // 홀수 하나 남은 마지막 값
endgenerate

// Stage 2: 17개 → 9개
wire signed [WEIGHT+6-1:0] sum_s2 [0:8];
generate
    for (j = 0; j < 8; j = j + 1) begin
        assign sum_s2[j] = sum_s1[2*j] + sum_s1[2*j + 1];
    end
    assign sum_s2[8] = sum_s1[16];
endgenerate

reg signed [WEIGHT+6-1:0] sum_s2_reg[0:8];
always @(posedge clk or negedge rstn) begin
	if (~rstn) begin
		for (i = 0; i < 9; i = i + 1 ) begin
			sum_s2_reg[i] <= 0;
		end
	end else begin
		for (i = 0; i < 9; i = i + 1) begin
			sum_s2_reg[i] <= sum_s2[i];
		end
	end
end

// Stage 3: 9개 → 5개
wire signed [WEIGHT+6-1:0] sum_s3 [0:4];
generate
    for (j = 0; j < 4; j = j + 1) begin
        assign sum_s3[j] = sum_s2_reg[2*j] + sum_s2_reg[2*j + 1];
    end
    assign sum_s3[4] = sum_s2_reg[8];
endgenerate

// Stage 4: 5개 → 3개
wire signed [WEIGHT+6-1:0] sum_s4 [0:2];
assign sum_s4[0] = sum_s3[0] + sum_s3[1];
assign sum_s4[1] = sum_s3[2] + sum_s3[3];
assign sum_s4[2] = sum_s3[4];

// Stage 5: 3개 → 2개
wire signed [WEIGHT+6-1:0] sum_s5 [0:1];
assign sum_s5[0] = sum_s4[0] + sum_s4[1];
assign sum_s5[1] = sum_s4[2];

// Stage 6: 2개 → 1개 (최종 합)
wire signed [WEIGHT+6-1:0] sum_tree;
assign sum_tree = sum_s5[0] + sum_s5[1];
*/

reg signed [WEIGHT+4-1:0] sum_p1;
reg signed [WEIGHT+4-1:0] sum_p2;
reg signed [WEIGHT+4-1:0] sum_p3;
reg signed [WEIGHT+4-1:0] sum_p4;

always @(posedge clk or negedge rstn) begin
	if (~rstn) begin
		sum_p1 <= 0;
		sum_p2 <= 0;
		sum_p3 <= 0;
		sum_p4 <= 0;
	end else begin
		sum_p1 <= mult_weight[0] + mult_weight[1] + mult_weight[2] + mult_weight[3] + 
				  mult_weight[4] + mult_weight[5] + mult_weight[6] + mult_weight[7];

		sum_p2 <= mult_weight[8] + mult_weight[9] + mult_weight[10] + mult_weight[11] + 
				  mult_weight[12] + mult_weight[13] + mult_weight[14] + mult_weight[15];

		sum_p3 <= mult_weight[16] + mult_weight[17] + mult_weight[18] + mult_weight[19] + 
				  mult_weight[20] + mult_weight[21] + mult_weight[22] + mult_weight[23];

		sum_p4 <= mult_weight[24] + mult_weight[25] + mult_weight[26] + mult_weight[27] + 
				  mult_weight[28] + mult_weight[29] + mult_weight[30] + mult_weight[31];
	end
end

wire signed [WEIGHT+6-1:0] total_sum;
assign total_sum = sum_p1 + sum_p2 + sum_p3 + sum_p4 + mult_weight[32];

wire signed [WEIGHT+6-1:0] sum_divide;
assign sum_divide = total_sum >>> 8;

wire signed [6:0] saturated_sum;

assign saturated_sum = (sum_divide >= 22'sd63) ? 7'sd63 : 
					 	(sum_divide <= -22'sd64) ? -7'sd64 : sum_divide;

always @(posedge clk or negedge rstn) begin
	if (~rstn) begin
		data_out <= 0;
	end else begin
		data_out <= saturated_sum;
	end
end

endmodule

