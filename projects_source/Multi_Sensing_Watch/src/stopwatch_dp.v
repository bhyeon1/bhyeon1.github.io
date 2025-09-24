`timescale 1ns / 1ps

module stopwatch_dp (
    input        clear,
    input        runstop,
    input        clk,
    input        rst,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);
    wire w_tick_100hz, w_sec_tick, w_min_tick, w_hour_tick;
    wire w_rst;

    assign w_rst = clear | rst;

    time_counter_sw #(
        .BIT_WIDTH (7),
        .TICK_COUNT(100)
    ) U_MSEC_SW (
        .clk(clk),
        .rst(w_rst),
        .i_tick(w_tick_100hz),
        .o_time(msec),
        .o_tick(w_sec_tick)
    );

    time_counter_sw #(
        .BIT_WIDTH (6),
        .TICK_COUNT(60)
    ) U_SEC_SW (
        .clk(clk),
        .rst(w_rst),
        .i_tick(w_sec_tick),
        .o_time(sec),
        .o_tick(w_min_tick)
    );

    time_counter_sw #(
        .BIT_WIDTH (6),
        .TICK_COUNT(60)
    ) U_MIN_SW (
        .clk(clk),
        .rst(w_rst),
        .i_tick(w_min_tick),
        .o_time(min),
        .o_tick(w_hour_tick)
    );

    time_counter_sw #(
        .BIT_WIDTH (5),
        .TICK_COUNT(24)
    ) U_HOUR_SW (
        .clk(clk),
        .rst(w_rst),
        .i_tick(w_hour_tick),
        .o_time(hour),
        .o_tick()
    );

    tick_gen_100hz_sw U_Tick_100hz (
        .clk(clk),
        .rst(w_rst),
        .en(runstop),
        .o_tick_100(w_tick_100hz)
    );

endmodule

module time_counter_sw #(
    parameter BIT_WIDTH  = 7,
    parameter TICK_COUNT = 100,
    parameter INIT_COUNT = 0
) (
    input                  clk,
    input                  rst,
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
    // if 2개 사용 ver.
    always @(*) begin
        cnt_next = cnt_reg;
        o_tick_next = 1'b0;
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

module tick_gen_100hz_sw (
    input      clk,
    input      rst,
    input      en,
    output reg o_tick_100
);
    parameter FCOUNT = 1_000_000;
    reg [$clog2(FCOUNT)-1:0] r_cnt;  // log2를 취한 후 올림 (celling.)

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_cnt <= 0;
            o_tick_100 <= 0;
        end else if (!en) begin
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
