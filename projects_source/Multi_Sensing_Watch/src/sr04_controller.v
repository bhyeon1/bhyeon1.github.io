
`timescale 1ns / 1ps

module sr04_controller (
    input        clk,
    input        rst,
    input        start,
    input        echo,
    output       trig,
    output [9:0] distance,
    output       dist_done
);

    wire w_tick;

    distance U_Distance (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick),
        .echo(echo),
        .distance(distance),
        .dist_done(dist_done)
    );

    start_trigger U_Start_trigg (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick),
        .start(start),
        .o_sr04_trigger(trig)
    );

    tick_gen U_Tick_Gen (
        .clk(clk),
        .rst(rst),
        .o_tick_1mhz(w_tick)
    );

endmodule

module distance (
    input        clk,
    input        rst,
    input        i_tick,
    input        echo,
    output [9:0] distance,
    output       dist_done
);

    reg echo_reg, echo_next;
    reg [5:0] count_reg, count_next;
    reg [9:0] distance_reg, distance_next;
    reg dist_done_reg, dist_done_next;

    assign distance  = distance_reg;
    assign dist_done = dist_done_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            distance_reg  <= 0;
            dist_done_reg <= 0;
            count_reg     <= 0;
            echo_reg      <= 0;
        end else begin
            distance_reg  <= distance_next;
            dist_done_reg <= dist_done_next;
            count_reg     <= count_next;
            echo_reg      <= echo_next;
        end
    end

    always @(*) begin
        distance_next  = distance_reg;
        dist_done_next = dist_done_reg;
        count_next     = count_reg;
        echo_next      = echo_reg;
        case (echo_reg)
            0: begin
                dist_done_next = 0;
                count_next = 0;
                if (echo) begin
                    echo_next = 1;
                    distance_next = 0;
                end
            end
            1: begin
                if (!echo) begin
                    echo_next = 0;
                    dist_done_next = 1;
                end else if (i_tick) begin
                    if (count_reg == 58) begin
                        count_next = 0;
                        distance_next = distance_reg + 1;
                    end else begin
                        count_next = count_reg + 1;
                    end
                end
            end
        endcase
    end

endmodule

module start_trigger (
    input  clk,
    input  rst,
    input  i_tick,
    input  start,
    output o_sr04_trigger

);
    reg start_reg, start_next;
    reg [3:0] count_reg, count_next;
    reg sr04_trigg_reg, sr04_tirgg_next;

    assign o_sr04_trigger = sr04_trigg_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            start_reg      <= 0;
            sr04_trigg_reg <= 0;
            count_reg      <= 0;

        end else begin
            start_reg      <= start_next;
            sr04_trigg_reg <= sr04_tirgg_next;
            count_reg      <= count_next;
        end
    end

    always @(*) begin
        start_next      = start_reg;
        sr04_tirgg_next = sr04_trigg_reg;
        count_next      = count_reg;

        case (start_reg)
            0: begin    // idle
                count_next      = 0;
                sr04_tirgg_next = 1'b0;
                if (start) begin
                    start_next = 1;
                end
            end
            1: begin    // start trig
                if (i_tick) begin
                    sr04_tirgg_next = 1'b1;
                    count_next = count_reg + 1;
                    if (count_reg == 10) begin
                        start_next = 0;
                    end
                end
            end
        endcase
    end

endmodule

module tick_gen (
    input  clk,
    input  rst,
    output o_tick_1mhz
);

    parameter F_COUNT = (100 - 1);

    reg [6:0] count;
    reg tick;

    assign o_tick_1mhz = tick;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count <= 0;
            tick  <= 0;
        end else begin
            if (count == F_COUNT) begin
                count <= 0;
                tick  <= 1'b1;
            end else begin
                count <= count + 1;
                tick  <= 1'b0;
            end
        end
    end

endmodule