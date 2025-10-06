`timescale 1ns / 1ps

module bf_cntr #(
    parameter int DATA  = 9,
    parameter int ARRAY = 16,
    parameter int DELAY = 17,
	parameter int STAGE = 0
) (
    input logic                   clk,
    input logic                   rstn,
    input logic                   valid_in,
    input logic signed [DATA-1:0] din_re   [ARRAY-1:0],
    input logic signed [DATA-1:0] din_im   [ARRAY-1:0],
    input logic signed [DATA-1:0] sr_din_re[ARRAY-1:0],
    input logic signed [DATA-1:0] sr_din_im[ARRAY-1:0],

    output logic signed [DATA:0] u_re     [ARRAY-1:0],
    output logic signed [DATA:0] u_im     [ARRAY-1:0],
    output logic signed [DATA:0] v_re     [ARRAY-1:0],
    output logic signed [DATA:0] v_im     [ARRAY-1:0],
    output logic                 valid_out,
    output logic                 mux_sel
);

    // 32클록 고정
    localparam int PERIOD = 32;
    // segmentation: 2^(STAGE+1) 분할 → segment width = 32/(2^(STAGE+1))
    localparam int SEG_SHIFT = 5 - (STAGE + 1);
    //   (= 4-STAGE: STAGE=0→4, STAGE=1→3, STAGE=2→2)

    //========================================================================
    // 1) 카운터: wait_cnt(0..INIT_DELAY), region_cnt(0..31)
    //========================================================================

  	// 1) valid_in 상승 에지(pulse) 생성
	logic valid_d, valid_rise;
	logic [$clog2(DELAY)-1:0] wait_cnt;
	logic [4:0] 			  region_cnt;
	always_ff @(posedge clk or negedge rstn) begin
  		if (!rstn) valid_d <= 1'b0;
  		else       valid_d <= valid_in;
	end

	assign valid_rise = valid_in & ~valid_d;
	
	logic run_wait;
	
	// wait_cnt
	always_ff @(posedge clk or negedge rstn) begin
  		if (!rstn) begin
    		wait_cnt 	 <= 0;
    		run_wait 	 <= 0;
  		end else begin
    		if (valid_rise) begin
      			run_wait <= 1;   // valid 들어오면 시작
      			wait_cnt <= 0;     // 초기화
    		end else if (run_wait) begin
				if (wait_cnt < DELAY-2) begin
					wait_cnt <= wait_cnt + 1;
				end else begin
					run_wait <= 0; // DELAY 끝나면 멈춤
				end
			end
		end
	end
	
	logic valid_reg, start_region;
	
	assign start_region = run_wait && (wait_cnt == DELAY-2);

	// region_cnt
	always_ff @(posedge clk or negedge rstn) begin
  		if (!rstn) begin
    		region_cnt <= 0;
    		valid_reg <= 0;
  		end else begin
    		if (start_region) begin
      			valid_reg <= 1;
      			region_cnt <= 0;
    		end else if (valid_reg) begin
				if (region_cnt < PERIOD-1) begin
					region_cnt <= region_cnt + 1;
				end else begin
					valid_reg <= 0;
    			end
 		 	end
		end
	end

    //========================================================================
    // 2) valid_out 생성
    //========================================================================
    
	//========================================================================
    // 3) 2/4/8/... 분할 추출: region_cnt[MSB:MSB-STAGE]
    //    → seg_index = region_cnt >> SEG_SHIFT
    //    → seg_index[0] 로 bf/mux 토글
    //========================================================================
    wire seg_bit = region_cnt[SEG_SHIFT];
    // 설명: region_cnt >> SEG_SHIFT 의 LSB와 동일.  
    // 예: STAGE=0→SEG_SHIFT=4→ region_cnt[4] (0..15→0,16..31→1)  

    logic bf_en, mux_sel_comb;
    assign bf_en = valid_reg && (seg_bit == 1'b0);
    assign mux_sel_comb = valid_reg && (seg_bit == 1'b1);

    //==================================================================
    // 2) 조합 로직: BF 연산
    //==================================================================	

    // combinational logic variable
    logic signed [DATA:0] u_re_comb[ARRAY-1:0];
    logic signed [DATA:0] u_im_comb[ARRAY-1:0];
    logic signed [DATA:0] v_re_comb[ARRAY-1:0];
    logic signed [DATA:0] v_im_comb[ARRAY-1:0];

    always_comb begin
        integer idx;
        if (!rstn) begin
            for (idx = 0; idx < ARRAY; idx++) begin
                u_re_comb[idx] = '0;
                u_im_comb[idx] = '0;
                v_re_comb[idx] = '0;
                v_im_comb[idx] = '0;
            end
        end else if (bf_en) begin
            for (idx = 0; idx < ARRAY; idx++) begin
                u_re_comb[idx] = din_re[idx] + sr_din_re[idx];
                u_im_comb[idx] = din_im[idx] + sr_din_im[idx];
                v_re_comb[idx] = sr_din_re[idx] - din_re[idx];
                v_im_comb[idx] = sr_din_im[idx] - din_im[idx];
            end
        end else begin
            for (idx = 0; idx < ARRAY; idx++) begin
                u_re_comb[idx] = '0;
                u_im_comb[idx] = '0;
                v_re_comb[idx] = '0;
                v_im_comb[idx] = '0;
            end
        end
    end

    //==================================================================
    // 3) 파이프라인 레지스터: 1클록 지연 후 외부로 내보냄
    //==================================================================

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            valid_out <= 1'b0;
            mux_sel   <= 1'b0;
            for (int i = 0; i < ARRAY; i++) begin
                u_re[i] <= '0;
                u_im[i] <= '0;
                v_re[i] <= '0;
                v_im[i] <= '0;
            end
        end else begin
            valid_out <= valid_reg;
            mux_sel   <= mux_sel_comb;
            for (int i = 0; i < ARRAY; i++) begin
                u_re[i] <= u_re_comb[i];
                u_im[i] <= u_im_comb[i];
                v_re[i] <= v_re_comb[i];
                v_im[i] <= v_im_comb[i];
            end
        end
    end

endmodule






