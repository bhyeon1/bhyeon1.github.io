`timescale 1ns / 1ps

module dht11_controller (
    input        clk,
    input        rst,
    input        start,
    output [7:0] int_rh_data,
    output [7:0] dec_rh_data,
    output [7:0] int_t_data,
    output [7:0] dec_t_data,
    output       done,
    output       valid,
    output [2:0] state_led,
    inout        dht11_io
);

    wire w_tick;

    tick_gen_10us U_Tick (
        .clk(clk),
        .rst(rst),
        .o_tick(w_tick)
    );

    parameter IDLE = 0, START = 1, WAIT = 2, SYNCL = 3,
                SYNCH = 4, DATA_SYNC = 5, DATA_DETECT = 6, STOP = 7;
    reg [2:0] c_state, n_state;
    reg [$clog2(1900)-1:0] tick_cnt_reg, tick_cnt_next;
    reg dht11_reg, dht11_next;
    reg io_en_reg, io_en_next;
    reg [39:0] data_reg, data_next;
    reg [5:0] data_cnt_reg, data_cnt_next;
    reg valid_reg, valid_next;
    reg done_reg, done_next;

    assign dht11_io = (io_en_reg) ? dht11_reg : 1'bz;
    assign state_led = c_state;
    assign valid = valid_reg;
    assign done = done_reg;

    assign int_rh_data = data_reg[39:32];
    assign dec_rh_data = data_reg[31:24];
    assign int_t_data = data_reg[23:16];
    assign dec_t_data = data_reg[15:8];

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state      <= 0;
            tick_cnt_reg <= 0;
            dht11_reg    <= 1;
            io_en_reg    <= 1;
            data_reg     <= 0;
            data_cnt_reg <= 0;
            valid_reg    <= 0;
            done_reg     <= 0;
        end else begin
            c_state      <= n_state;
            tick_cnt_reg <= tick_cnt_next;
            dht11_reg    <= dht11_next;
            io_en_reg    <= io_en_next;
            data_reg     <= data_next;
            data_cnt_reg <= data_cnt_next;
            valid_reg    <= valid_next;
            done_reg     <= done_next;
        end
    end

    always @(*) begin
        tick_cnt_next = tick_cnt_reg;
        n_state       = c_state;
        dht11_next    = dht11_reg;
        io_en_next    = io_en_reg;
        data_next     = data_reg;
        data_cnt_next = data_cnt_reg;
        valid_next    = valid_reg;
        done_next     = done_reg;
        case (c_state)
            IDLE: begin
                dht11_next = 1'b1;
                io_en_next = 1'b1;
                done_next  = 1'b0;
                if (start) begin
                    n_state = START;
                    data_next = 0;
                    valid_next = 1'b0;
                end
            end
            START: begin
                if (w_tick) begin
                    dht11_next = 1'b0;
                    if (tick_cnt_reg == 1900) begin
                        n_state = WAIT;
                        tick_cnt_next = 1'b0;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            WAIT: begin
                // 출력 high
                dht11_next = 1'b1;
                if (w_tick) begin
                    if (tick_cnt_reg == 2) begin
                        n_state = SYNCL;
                        tick_cnt_next = 1'b0;
                        io_en_next = 1'b0;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            SYNCL: begin
                if (w_tick) begin
                    if (dht11_io) begin
                        n_state = SYNCH;
                    end
                end
            end
            SYNCH: begin
                if (w_tick) begin
                    if (!dht11_io) begin
                        n_state = DATA_SYNC;
                    end
                end
            end
            DATA_SYNC: begin
                if (w_tick) begin
                    if (dht11_io) begin
                        n_state = DATA_DETECT;
                        tick_cnt_next = 1'b0;
                    end
                end
            end
            DATA_DETECT: begin
                if (w_tick) begin
                    if (!dht11_io) begin
                        if (tick_cnt_reg <= 4) begin
                            data_next[39-data_cnt_reg] = 1'b0;
                        end else begin
                            data_next[39-data_cnt_reg] = 1'b1;
                        end
                        if (data_cnt_reg == 39) begin
                            n_state = STOP;
                            tick_cnt_next = 1'b0;
                            data_cnt_next = 1'b0;
                        end else begin
                            data_cnt_next = data_cnt_reg + 1;
                            n_state = DATA_SYNC;
                        end
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            STOP: begin
                if (w_tick) begin
                    if (tick_cnt_reg == 4) begin
                        n_state = IDLE;
                        done_next = 1'b1;
                        tick_cnt_next = 0;
                        if ((data_reg[39:32] + data_reg[31:24] + data_reg[23:16] + data_reg[15:8]) == data_reg[7:0]) begin
                            valid_next = 1'b1;
                        end else begin
                            valid_next = 1'b0;
                        end
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end

        endcase
    end

endmodule

module tick_gen_10us (
    input  clk,
    input  rst,
    output o_tick
);
    parameter F_CNT = 1000;
    reg [$clog2(F_CNT)-1:0] counter_reg;
    reg tick_reg;

    assign o_tick = tick_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
            tick_reg    <= 0;
        end else begin
            if (counter_reg == F_CNT - 1) begin
                counter_reg <= 0;
                tick_reg    <= 1'b1;
            end else begin
                counter_reg <= counter_reg + 1;
                tick_reg    <= 1'b0;
            end
        end
    end

endmodule

