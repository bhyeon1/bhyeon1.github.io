`timescale 1ns / 1ps

module watch_dp (
    input        i_time_up,
    input        i_time_down,
    input  [2:0] digit_pos,
    input        clk,
    input        rst,
    input        stop,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);
    wire w_tick_100hz, w_sec_tick, w_min_tick, w_hour_tick;

    time_counter #(
        .BIT_WIDTH (7),
        .TICK_COUNT(100)
    ) U_MSEC_W (
        .clk(clk),
        .rst(rst),
        .digit_pos(),
        .i_time_up(),
        .i_time_down(),
        .i_tick(w_tick_100hz),
        .o_time(msec),
        .o_tick(w_sec_tick)
    );

    time_counter #(
        .BIT_WIDTH (6),
        .TICK_COUNT(60)
    ) U_SEC_W (
        .clk(clk),
        .rst(rst),
        .digit_pos(digit_pos[0]),
        .i_time_up(i_time_up),
        .i_time_down(i_time_down),
        .i_tick(w_sec_tick),
        .o_time(sec),
        .o_tick(w_min_tick)
    );

    time_counter #(
        .BIT_WIDTH (6),
        .TICK_COUNT(60)
    ) U_MIN_W (
        .clk(clk),
        .rst(rst),
        .digit_pos(digit_pos[1]),
        .i_time_up(i_time_up),
        .i_time_down(i_time_down),
        .i_tick(w_min_tick),
        .o_time(min),
        .o_tick(w_hour_tick)
    );

    time_counter #(
        .BIT_WIDTH (5),
        .TICK_COUNT(24),
        .INIT_COUNT(12)
    ) U_HOUR_W (
        .clk(clk),
        .rst(rst),
        .digit_pos(digit_pos[2]),
        .i_time_up(i_time_up),
        .i_time_down(i_time_down),
        .i_tick(w_hour_tick),
        .o_time(hour),
        .o_tick()
    );

    tick_gen_100hz U_Tick_100hz (
        .clk(clk),
        .rst(rst),
        .stop(stop),
        .o_tick_100(w_tick_100hz)
    );

endmodule

module time_counter #(
    parameter BIT_WIDTH  = 7,
    parameter TICK_COUNT = 100,
    parameter INIT_COUNT = 0
) (
    input                  clk,
    input                  rst,
    input                  digit_pos,
    input                  i_time_up,
    input                  i_time_down,
    input                  i_tick,
    output [BIT_WIDTH-1:0] o_time,
    output                 o_tick
);

    reg [$clog2(TICK_COUNT)-1:0] cnt_reg, cnt_next;
    reg o_tick_next, o_tick_reg;

    // state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            cnt_reg <= INIT_COUNT;
            o_tick_reg <= 0;
        end else begin
            cnt_reg <= cnt_next;
            o_tick_reg <= o_tick_next;
        end
    end

    // next state
    always @(*) begin
        cnt_next = cnt_reg;
        o_tick_next = 1'b0;
        
        if (digit_pos && i_time_up) begin
            cnt_next = (cnt_reg == TICK_COUNT - 1) ? 0 : cnt_reg + 1;
        end else if (digit_pos && i_time_down) begin
            cnt_next = (cnt_reg == 0) ? TICK_COUNT - 1 : cnt_reg - 1;
        end

        if (i_tick == 1'b1) begin
            if (cnt_reg == (TICK_COUNT - 1)) begin
                cnt_next = 0;
                o_tick_next = 1'b1;
            end else begin
                cnt_next = cnt_reg + 1;
                o_tick_next = 1'b0;
            end
        end
    end

    // output
    assign o_time = cnt_reg;
    assign o_tick = o_tick_reg;

endmodule

module tick_gen_100hz (
    input      clk,
    input      rst,
    input      stop,
    output reg o_tick_100
);
    parameter FCOUNT = 1_000_000;
    reg [$clog2(FCOUNT)-1:0] r_cnt;  // log2를 취한 후 올림 (celling.)

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_cnt <= 0;
            o_tick_100 <= 0;
        end else if (stop) begin
            r_cnt <= r_cnt;
            o_tick_100 <= 0;
        end else begin
            if (r_cnt == FCOUNT - 1) begin
                r_cnt <= 0;
                o_tick_100 <= 1'b1;
            end else begin
                o_tick_100 <= 0;
            end
            r_cnt <= r_cnt + 1;
        end
    end

endmodule
