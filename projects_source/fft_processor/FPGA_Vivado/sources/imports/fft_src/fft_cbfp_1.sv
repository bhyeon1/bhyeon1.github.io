`timescale 1ns / 1ps

module fft_cbfp_1 #(
    parameter DATA  = 25,
    parameter ARRAY = 16 
)(
    input  logic                   clk,
    input  logic                   rstn,
    input  logic                   val_in,
    input  logic signed [24:0]     re_in [ARRAY-1:0],
    input  logic signed [24:0]     im_in [ARRAY-1:0],

    output logic signed [11:0]     re_out [ARRAY-1:0],
    output logic signed [11:0]     im_out [ARRAY-1:0],
    output logic                   val_out,
    output logic        [4:0]      index_h,
    output logic        [4:0]      index_l
);
    logic        [4:0]      re_mag [ARRAY-1:0];
    logic        [4:0]      im_mag [ARRAY-1:0];
    logic        [4:0]      re_min_8 [1:0];
    logic        [4:0]      im_min_8 [1:0];
    logic        [4:0]      min_out_h;
    logic        [4:0]      min_out_l;
    logic signed [DATA-1:0] re_shift[ARRAY-1:0];
    logic signed [DATA-1:0] im_shift[ARRAY-1:0];
    logic        [2:0]      cnt_min;
	
//==========val============================================================//
    always_ff @(posedge clk or negedge rstn) begin
		if (!rstn) begin
			val_out <= '0;
		end else begin
			val_out <= val_in;
		end
    end
//==========val============================================================//
//==========mag============================================================//
    // mag 저장 //
    always_comb begin
        if (val_in) begin
            for (int i = 0; i < ARRAY; i++) begin
                re_mag[i] = mag(re_in[i]);
                im_mag[i] = mag(im_in[i]);
            end
        end else begin
            for (int i = 0; i < ARRAY; i++) begin
                re_mag[i] = 0;
                im_mag[i] = 0;
            end
        end
    end
    // mag 저장 //

    // mag 계산 //
    function automatic [4:0] mag(input logic [24:0] data);
        logic msb;
        begin
            msb = data[24];
            case (1'b1)
                (data[23] != msb): mag = 0;
                (data[22] != msb): mag = 1;
                (data[21] != msb): mag = 2;
                (data[20] != msb): mag = 3;
                (data[19] != msb): mag = 4;
                (data[18] != msb): mag = 5;
                (data[17] != msb): mag = 6;
                (data[16] != msb): mag = 7;
                (data[15] != msb): mag = 8;
                (data[14] != msb): mag = 9;
                (data[13] != msb): mag = 10;
                (data[12] != msb): mag = 11;
                (data[11] != msb): mag = 12;
                (data[10] != msb): mag = 13;
                (data[9]  != msb): mag = 14;
                (data[8]  != msb): mag = 15;
                (data[7]  != msb): mag = 16;
                (data[6]  != msb): mag = 17;
                (data[5]  != msb): mag = 18;
                (data[4]  != msb): mag = 19;
                (data[3]  != msb): mag = 20;
                (data[2]  != msb): mag = 21;
                (data[1]  != msb): mag = 22;
                (data[0]  != msb): mag = 23;
                default:           mag = 24;
            endcase
        end
    endfunction
    // mag 계산 //
//==========mag============================================================//
//==========min============================================================//
    // min 8 계산//
    always_comb begin
        re_min_8[0] = re_mag[0];
        im_min_8[0] = im_mag[0];
        for (int j = 1; j < ARRAY/2; j++) begin
            if (re_mag[j] < re_min_8[0])
                re_min_8[0] = re_mag[j];
            if (im_mag[j] < im_min_8[0])
                im_min_8[0] = im_mag[j];
        end
        
        re_min_8[1] = re_mag[ARRAY/2];
        im_min_8[1] = im_mag[ARRAY/2];
        for (int j = ARRAY/2 + 1; j < ARRAY; j++) begin
            if (re_mag[j] < re_min_8[1])
                re_min_8[1] = re_mag[j];
            if (im_mag[j] < im_min_8[1])
                im_min_8[1] = im_mag[j];
        end
    end
    // min 8 계산//

    assign min_out_l = (re_min_8[0] <= im_min_8[0]) ? re_min_8[0] : im_min_8[0];
    assign min_out_h = (re_min_8[1] <= im_min_8[1]) ? re_min_8[1] : im_min_8[1];
//==========min============================================================//
//==========cut============================================================//
    // 시프트 //
	always_comb begin
		if (val_in) begin
			for (int n = 0; n < ARRAY/2; n++) begin
				re_shift[n] = re_in[n] <<< min_out_l;
				im_shift[n] = im_in[n] <<< min_out_l;
			end
			for (int n = ARRAY/2; n < ARRAY; n++) begin
				re_shift[n] = re_in[n] <<< min_out_h;
				im_shift[n] = im_in[n] <<< min_out_h;
			end
		end else begin
			for (int n = 0; n < ARRAY; n++) begin
                re_shift[n] = '0;
                im_shift[n] = '0;
            end
		end
	end
    // 시프트 ///
//==========cut============================================================//
//==========reg============================================================//
    // 인덱스 저장 //
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            index_h <= '0;
            index_l <= '0;
			for (int n = 0; n < ARRAY; n++) begin
				re_out[n] <= '0;
				im_out[n] <= '0;
			end
        end else begin
            index_h <= min_out_h;
            index_l <= min_out_l;
			for (int n = 0; n < ARRAY; n++) begin
				re_out[n] <= re_shift[n][DATA-1 -: 12];
				im_out[n] <= im_shift[n][DATA-1 -: 12];
			end
        end
    end
	// 인덱스 저장 //
//==========reg============================================================//
endmodule

