`timescale 1ns / 1ps

module time_setting (
    input        clk,
    input        rst,
    input        i_time_up_mode,
    input        i_time_up_btn,
    input        i_time_rst_btn,
    input  [1:0] i_start_btn,
    output [5:0] sec,
    output [5:0] min,
    output [1:0] moter_start,
    output       done
);

    wire w_tick_100hz, w_sec_tick;

    tick_gen_100hz U_TICK_GEN_100HZ (
        .clk(clk),
        .rst(rst),
        .o_tick_100(w_tick_100hz)
    );

    tick_gen_1s U_TICK_GEN_1S (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick_100hz),
        .o_tick_1s(w_sec_tick)
    );

    time_down_counter U_TIME_DOWN_CNTR (
        .clk(clk),
        .rst(rst),
        .i_tick_sec(w_sec_tick),
        .i_time_up_mode(i_time_up_mode),
        .i_time_up_btn(i_time_up_btn),
        .i_time_rst(i_time_rst_btn),
        .i_start_btn(i_start_btn),
        .o_time_sec(sec),
        .o_time_min(min),
        .done(done),
        .moter_start(moter_start)
    );

endmodule

module time_down_counter (
    input        clk,
    input        rst,
    input        i_tick_sec,
    input        i_time_up_mode,
    input        i_time_up_btn,
    input        i_time_rst,
    input  [1:0] i_start_btn,
    output [6:0] o_time_sec,
    output [6:0] o_time_min,
    output       done,
    output [1:0] moter_start
);

    parameter IDLE = 2'b00, SETTING = 2'b01, RUNNING = 2'b10, DONE = 2'b11;

    reg [1:0] state_reg, state_next;
    reg [$clog2(60)-1:0] sec_reg, sec_next;
    reg [$clog2(60)-1:0] min_reg, min_next;
    reg o_tick_next, o_tick_reg;
    reg done_next, done_reg;
    reg [1:0] moter_start_reg, moter_start_next;

    // state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state_reg <= IDLE;
            sec_reg <= 0;
            min_reg <= 0;
            done_reg <= 0;
            moter_start_reg <= 0;
        end else begin
            state_reg <= state_next;
            sec_reg <= sec_next;
            min_reg <= min_next;
            done_reg <= done_next;
            moter_start_reg <= moter_start_next;
        end
    end

    // next state
    always @(*) begin
        state_next = state_reg;
        sec_next = sec_reg;
        min_next = min_reg;
        done_next = done_reg;
        moter_start_next = moter_start_reg;

        case (state_reg)
            // 1. 초기 대기 상태
            IDLE: begin
                sec_next  = 0;
                min_next  = 0;
                done_next = 0;
                if (i_time_up_btn | i_start_btn[0] | i_start_btn[1] | i_time_rst) begin // any btn
                    state_next = SETTING;
                end
            end

            // 2. 시간 설정 모드
            SETTING: begin
                if (i_time_up_btn) begin
                    case (i_time_up_mode)
                        1'b0: begin  // +10초
                            if (sec_reg + 10 >= 60) begin
                                sec_next = (sec_reg + 10) - 60;
                                min_next = min_reg + 1;
                            end else begin
                                sec_next = sec_reg + 10;
                            end
                        end
                        1'b1: begin  // +30초
                            if (sec_reg + 30 >= 60) begin
                                sec_next = (sec_reg + 30) - 60;
                                min_next = min_reg + 1;
                            end else begin
                                sec_next = sec_reg + 30;
                            end
                        end
                    endcase
                end

                if (i_start_btn[0]) begin
                    state_next = RUNNING;
                    moter_start_next = 2'b01;
                end

                if (i_start_btn[1]) begin
                    state_next = RUNNING;
                    moter_start_next = 2'b10;
                end

                if (i_time_rst) begin
                    sec_next = 1'b0;
                    min_next = 1'b0;
                end
            end

            // 3. 카운트다운 모드
            RUNNING: begin
                if (i_start_btn) begin  // run cancel
                    state_next = DONE;
                end

                if (i_tick_sec) begin
                    if ((sec_reg == 0) && (min_reg == 0)) begin
                        state_next = DONE;
                    end else if (sec_reg == 0) begin
                        // 초가 0인데 분이 남아 있으면
                        sec_next = 6'd59;
                        min_next = min_reg - 1;
                    end else begin
                        // 일반적인 경우
                        sec_next = sec_reg - 1;
                    end
                end
            end

            DONE: begin
                moter_start_next = 2'b00;
                done_next = 1'b1;
                sec_next = 1'b0;
                min_next = 1'b0;
                if (i_time_up_btn | i_start_btn) begin
                    state_next = IDLE;
                end
            end
        endcase
    end

    // output
    assign o_time_sec = sec_reg;
    assign o_time_min = min_reg;
    assign done = done_reg;
    assign moter_start = moter_start_reg;

endmodule

module tick_gen_100hz (
    input      clk,
    input      rst,
    output reg o_tick_100  // 100Hz 펄스 출력
);

    parameter FCOUNT = 1_000;
    reg [$clog2(FCOUNT)-1:0] r_cnt;

    // 100Hz tick 생성기
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r_cnt <= 0;
            o_tick_100 <= 0;
        end else begin
            if (r_cnt == FCOUNT - 1) begin
                r_cnt <= 0;
                o_tick_100 <= 1;
            end else begin
                r_cnt <= r_cnt + 1;
                o_tick_100 <= 0;
            end
        end
    end

endmodule

module tick_gen_1s (
    input      clk,
    input      rst,
    input      i_tick,
    output reg o_tick_1s  // 100Hz 펄스 출력
);

    parameter TICK_COUNT = 100;
    reg [$clog2(TICK_COUNT)-1:0] r_cnt;

    // 1s tick 생성기
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            o_tick_1s <= 0;
            r_cnt <= 0;
        end else begin
            if (i_tick) begin
                if (r_cnt == TICK_COUNT - 1) begin
                    r_cnt <= 0;
                    o_tick_1s <= 1;
                end else begin
                    r_cnt <= r_cnt + 1;
                    o_tick_1s <= 0;
                end
            end else begin
                o_tick_1s <= 0;
            end
        end
    end

endmodule
