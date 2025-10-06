`timescale 1ns/1ps
module cos_generator (
    input  logic        clk,
    input  logic        rstn,
    output logic        valid_in_1d,
    output logic signed [8:0] cos_re_1d [15:0],
    output logic signed [8:0] cos_im_1d [15:0]
);

    // FSM 상태 정의
    localparam logic [1:0] IDLE = 2'd0;
    localparam logic [1:0] SEND = 2'd1;
	localparam logic [1:0] WAIT = 2'd2;

	logic valid_in;
	logic signed [8:0] cos_re [15:0];
    logic signed [8:0] cos_im [15:0];


    logic [1:0]    state;
    logic [5:0]    send_cnt;  // 최대 31까지 필요 (SEND:0..31, IDLE:0..7)
    logic [8:0]    rom_idx;   // 0..511, 16씩 증가

    // ROM 출력 조합 신호
    logic signed [8:0] cos_re_comb [15:0];
    logic signed [8:0] cos_im_comb [15:0];

     // 1) 상태 머신 + 카운터
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state     <= IDLE;
            send_cnt  <= 0;
            rom_idx   <= 0;
            valid_in  <= 0;
        end else begin
            case (state)
				IDLE: begin
					valid_in <= 1;
					state <= SEND;
				end
                SEND: begin
                    // 마지막 SEND 비트까지 다 나가고 나면 IDLE로
                    if (send_cnt == 31) begin
                        state    <= WAIT;
                        send_cnt <= 0;
						valid_in <= 0;
                    end else begin
                        send_cnt <= send_cnt + 1;
                    end
                    // 매 SEND마다 rom_idx를 16씩 증가 (wrap-around)
                    if (send_cnt < 31) begin
                        rom_idx <= (rom_idx + 16 < 512) ? rom_idx + 16 : 0;
                    end
                end

                WAIT: begin
                    if (send_cnt == 6) begin
                        state    <= IDLE;
                        send_cnt <= 0;
                    end else begin
                        send_cnt <= send_cnt + 1;
                    end
                    // IDLE 동안 rom_idx는 유지
                    rom_idx <= 0;
                end
            endcase
        end
    end


    // 2) cos_rom 인스턴스 16개 (addr = base_addr + 9'd0..9'd15)
    cos_rom u_rom0  (.addr(rom_idx + 9'd0 ), .re(cos_re_comb[ 0]), .im(cos_im_comb[ 0]));
    cos_rom u_rom1  (.addr(rom_idx + 9'd1 ), .re(cos_re_comb[ 1]), .im(cos_im_comb[ 1]));
    cos_rom u_rom2  (.addr(rom_idx + 9'd2 ), .re(cos_re_comb[ 2]), .im(cos_im_comb[ 2]));
    cos_rom u_rom3  (.addr(rom_idx + 9'd3 ), .re(cos_re_comb[ 3]), .im(cos_im_comb[ 3]));
    cos_rom u_rom4  (.addr(rom_idx + 9'd4 ), .re(cos_re_comb[ 4]), .im(cos_im_comb[ 4]));
    cos_rom u_rom5  (.addr(rom_idx + 9'd5 ), .re(cos_re_comb[ 5]), .im(cos_im_comb[ 5]));
    cos_rom u_rom6  (.addr(rom_idx + 9'd6 ), .re(cos_re_comb[ 6]), .im(cos_im_comb[ 6]));
    cos_rom u_rom7  (.addr(rom_idx + 9'd7 ), .re(cos_re_comb[ 7]), .im(cos_im_comb[ 7]));
    cos_rom u_rom8  (.addr(rom_idx + 9'd8 ), .re(cos_re_comb[ 8]), .im(cos_im_comb[ 8]));
    cos_rom u_rom9  (.addr(rom_idx + 9'd9 ), .re(cos_re_comb[ 9]), .im(cos_im_comb[ 9]));
    cos_rom u_rom10 (.addr(rom_idx + 9'd10), .re(cos_re_comb[10]), .im(cos_im_comb[10]));
    cos_rom u_rom11 (.addr(rom_idx + 9'd11), .re(cos_re_comb[11]), .im(cos_im_comb[11]));
    cos_rom u_rom12 (.addr(rom_idx + 9'd12), .re(cos_re_comb[12]), .im(cos_im_comb[12]));
    cos_rom u_rom13 (.addr(rom_idx + 9'd13), .re(cos_re_comb[13]), .im(cos_im_comb[13]));
    cos_rom u_rom14 (.addr(rom_idx + 9'd14), .re(cos_re_comb[14]), .im(cos_im_comb[14]));
    cos_rom u_rom15 (.addr(rom_idx + 9'd15), .re(cos_re_comb[15]), .im(cos_im_comb[15]));

    always_comb begin
		integer i;
		if (valid_in) begin
			for (i = 0; i < 16; i++) begin
				cos_re[i] = cos_re_comb[i];
				cos_im[i] = cos_im_comb[i];
			end
		end else begin
			for (i = 0; i < 16; i++) begin
				cos_re[i] = '0;
				cos_im[i] = '0;
			end
		end
	end
		
	// 3) 파이프라인 레지스터: comb -> output
	always_ff @(posedge clk or negedge rstn) begin
		integer i;
		if (!rstn) begin
			valid_in_1d <= 0;
			for (i = 0; i < 16; i++) begin
				cos_re_1d[i] <= 0;
				cos_im_1d[i] <= 0;
			end
		end else begin
			valid_in_1d <= valid_in;
			for (i = 0; i < 16; i++) begin
				cos_re_1d[i] <= cos_re[i];
				cos_im_1d[i] <= cos_im[i];
			end
		end
	end
	
endmodule

