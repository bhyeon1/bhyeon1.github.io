`timescale 1ns / 1ps

module bf_cntr_no_sr #(
    parameter DATA  = 9,
    parameter PAIR  = 0,  // 0 ~ 3
    parameter ARRAY = 16
) (
    input  logic                   clk,
    input  logic                   rstn,
	input  logic				   valid_in,
    input  logic signed [DATA-1:0] x_re[ARRAY-1:0],
    input  logic signed [DATA-1:0] x_im[ARRAY-1:0],
    output logic signed [  DATA:0] y_re[ARRAY-1:0],
    output logic signed [  DATA:0] y_im[ARRAY-1:0],
	output logic 				   valid_out_1d
);

    logic signed [DATA:0] y_re_comb[ARRAY-1:0];
    logic signed [DATA:0] y_im_comb[ARRAY-1:0];

    localparam logic [3:0] idx_a_arr_0[0:7] = '{0, 1, 2, 3, 4, 5, 6, 7};
    localparam logic [3:0] idx_b_arr_0[0:7] = '{8, 9, 10, 11, 12, 13, 14, 15};

    localparam logic [3:0] idx_a_arr_1[0:7] = '{0, 1, 2, 3, 8, 9, 10, 11};
    localparam logic [3:0] idx_b_arr_1[0:7] = '{4, 5, 6, 7, 12, 13, 14, 15};

    localparam logic [3:0] idx_a_arr_2[0:7] = '{0, 1, 4, 5, 8, 9, 12, 13};
    localparam logic [3:0] idx_b_arr_2[0:7] = '{2, 3, 6, 7, 10, 11, 14, 15};

    localparam logic [3:0] idx_a_arr_3[0:7] = '{0, 2, 4, 6, 8, 10, 12, 14};
    localparam logic [3:0] idx_b_arr_3[0:7] = '{1, 3, 5, 7, 9, 11, 13, 15};
	
	logic bf_en;

	always_ff @(posedge clk or negedge rstn) begin
		if (!rstn) begin
			bf_en <= 0;
		end else begin
			bf_en <= valid_in;
		end
	end

    function automatic logic [3:0] get_idx_a(int pair, int i);
        case (pair)
            0: return idx_a_arr_0[i];
            1: return idx_a_arr_1[i];
            2: return idx_a_arr_2[i];
            3: return idx_a_arr_3[i];
            default: return 0;
        endcase
    endfunction

    function automatic logic [3:0] get_idx_b(int pair, int i);
        case (pair)
            0: return idx_b_arr_0[i];
            1: return idx_b_arr_1[i];
            2: return idx_b_arr_2[i];
            3: return idx_b_arr_3[i];
            default: return 0;
        endcase
    endfunction

    always_comb begin
        int i, a, b;
		if (bf_en) begin
        	for (i = 0; i < 8; i++) begin
            	a = get_idx_a(PAIR, i);
            	b = get_idx_b(PAIR, i);
            	y_re_comb[a] = x_re[a] + x_re[b];
            	y_im_comb[a] = x_im[a] + x_im[b];
            	y_re_comb[b] = x_re[a] - x_re[b];
				y_im_comb[b] = x_im[a] - x_im[b];
        	end
		end else begin
			a = '0;
			b = '0;
        	for (i = 0; i < ARRAY; i++) begin
            	y_re_comb[i] = '0;
            	y_im_comb[i] = '0;
        	end
		end
    end

    /*
    always_comb begin
		integer i;
        for (i = 0; i < 8; i++) begin
			y_re_comb[i] = x_re[i] + x_re[i+8];
            y_im_comb[i] = x_im[i] + x_im[j+8];
            v_re_comb[i+8] = x_re[i] - x_re[j+8];
            v_im_comb[i+8] = x_im[i] - x_im[j+8];
        end
    end

	always_comb begin
		integer i;
        for (i = 0; i < 4; i++) begin
			y_re_comb[i] = x_re[i] + x_re[i+4];
            y_im_comb[i] = x_im[i] + x_im[i+4];
            v_re_comb[i+4] = x_re[i] - x_re[i+4];
            v_im_comb[i+4] = x_im[i] - x_im[i+4];
			y_re_comb[i+8] = x_re[i+8] + x_re[i+12];
            y_im_comb[i+8] = x_im[i+8] + x_im[i+12];
            v_re_comb[i+12] = x_re[i+8] - x_re[i+12];
            v_im_comb[i+12] = x_im[i+8] - x_im[i+12];
        end
    end
*/

    always_ff @(posedge clk or negedge rstn) begin
        integer i;
        if (!rstn) begin
			valid_out_1d <= 0;
            for (i = 0; i < ARRAY; i++) begin
                y_re[i] <= '0;
                y_im[i] <= '0;
            end
        end else begin
			valid_out_1d <= bf_en;
            for (i = 0; i < ARRAY; i++) begin
                y_re[i] <= y_re_comb[i];
                y_im[i] <= y_im_comb[i];
            end
        end
    end

endmodule
