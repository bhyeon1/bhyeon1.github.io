`timescale 1ns / 1ps

module baudrate (
    input  clk,
    input  rst,
    output baud_tick
);
    // clk 100Mhz,
    parameter BAUD = 9600;
    parameter BAUD_COUNT = 100_000_000 / (BAUD * 8);        // 9600 x 8 Hz 주기의 baud tick 생성.
    reg [$clog2(BAUD_COUNT)-1:0] count_reg, count_next;     
    reg baud_tick_reg, baud_tick_next;

    assign baud_tick = baud_tick_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg     <= 0;
            baud_tick_reg <= 0;
        end else begin
            count_reg     <= count_next;
            baud_tick_reg <= baud_tick_next;
        end
    end

    always @(*) begin
        count_next     = count_reg;
        baud_tick_next = baud_tick_reg;
        if (count_reg == BAUD_COUNT - 1) begin
            count_next     = 0;
            baud_tick_next = 1'b1;
        end else begin
            count_next     = count_reg + 1;
            baud_tick_next = 1'b0;
        end
    end

endmodule

/*
module baudrate_2output (
    input      clk,
    input      rst,
    output reg baud_tick,
    output     baud_tick_8
);
    parameter BAUD = 9600;
    parameter BAUD_x8 = BAUD * 8;
    parameter BAUD_COUNT = 100_000_000 / BAUD_x8;

    reg  [$clog2(BAUD_COUNT)-1:0] count_reg;
    wire [$clog2(BAUD_COUNT)-1:0] count_next;

    assign count_next  = (count_reg == BAUD_COUNT - 1) ? 0 : count_reg + 1;
    assign baud_tick_8 = (count_reg == BAUD_COUNT - 1);

    reg [2:0] count_8;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count_reg <= 0;
            count_8   <= 0;
            baud_tick <= 0;
        end else begin
            count_reg <= count_next;

            if (baud_tick_8) begin
                if (count_8 == 3'd7) begin
                    count_8   <= 0;
                    baud_tick <= 1;
                end else begin
                    count_8   <= count_8 + 1;
                    baud_tick <= 0;
                end
            end else begin
                baud_tick <= 0;
            end
        end
    end
endmodule
*/

/*
module baudrate_reg (
    input         clk,        // 시스템 클럭 (예: 100 MHz)
    input         rst,
    input  [16:0] baud_rate,  // 원하는 Baud rate (예: 9600)
    output        baud_tick
);

    localparam MAX_CLK = 100_000_000;
    localparam CNT_WIDTH = $clog2(MAX_CLK);

    reg [CNT_WIDTH-1:0] count_reg, count_next;
    reg tick_reg, tick_next;

    wire [CNT_WIDTH-1:0] baud_count = MAX_CLK / baud_rate;

    // state register
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count_reg <= 0;
            tick_reg  <= 0;
        end else begin
            count_reg <= count_next;
            tick_reg  <= tick_next;
        end
    end

    // count next
    always @(*) begin
        // 기본값
        count_next = count_reg + 1;
        tick_next  = 1'b0;

        if (count_reg >= baud_count - 1) begin
            count_next = 0;
            tick_next  = 1'b1;
        end
    end

    // output
    assign baud_tick = tick_reg;

endmodule
*/
