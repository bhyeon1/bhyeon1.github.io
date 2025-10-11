`timescale 1ns / 1ps

module UART_Periph (
    // global signals
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 3:0] PADDR,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic [31:0] PWDATA,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    // External Port
    output logic        tx,
    input  logic        rx
);

    logic [1:0] cr;
    //logic [19:0] baud;
    logic [7:0] tx_data;
    logic [7:0] rx_data;
    logic       start;
    logic       tx_busy;
    logic       tx_done;
    logic       rx_done;

    APB_SlaveIntf_uart U_APB_SlaveIntf_uart (.*);

    uart U_Uart (
        .*,
        .clk(PCLK),
        .reset(PRESET),
        .tx_en(cr[0]),
        .tx_data(tx_data),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .rx_en(cr[1]),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

endmodule

module APB_SlaveIntf_uart (
    // global signals
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 3:0] PADDR,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic [31:0] PWDATA,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    // Internal Port
    output logic        start,
    output logic [ 1:0] cr,
    input  logic        tx_busy,
    input  logic        tx_done,
    input  logic        rx_done,
    //output logic [19:0] baud,
    output logic [ 7:0] tx_data,
    input  logic [ 7:0] rx_data
);

    logic [31:0] slv_reg0;
    //logic [31:0] slv_reg1;
    logic [31:0] slv_reg2;

    assign cr = slv_reg0;
    //assign baud = slv_reg1;
    assign tx_data = slv_reg2;

    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            slv_reg0 <= 0;
            //slv_reg1 <= 0;
            slv_reg2 <= 0;
        end else begin
            PREADY <= 1'b0;
            start  <= 0;
            if (rx_done) begin
                slv_reg0[4:2] <= {1'b1, rx_done, tx_busy};
            end else if (PSEL && PENABLE) begin
                PREADY <= 1'b1;
                if (PWRITE) begin
                    case (PADDR[3:2])
                        2'd0: slv_reg0[1:0] <= PWDATA[1:0];
                        2'd1: ;  //slv_reg1 <= PWDATA;
                        2'd2: begin
                            slv_reg2 <= PWDATA;
                            start <= 1'b1;
                        end
                        2'd3: ;
                    endcase
                end else begin
                    case (PADDR[3:2])
                        2'd0: PRDATA <= slv_reg0;
                        2'd1: ;  //PRDATA <= slv_reg1;
                        2'd2: PRDATA <= slv_reg2;
                        2'd3: begin
                            PRDATA <= rx_data;
                            slv_reg0[4] <= 1'b0;
                        end
                    endcase
                end
            end else begin
                slv_reg0[4:2] <= {slv_reg0[4], rx_done, tx_busy};
            end
        end
    end
endmodule

module uart (
    // global signals
    input  logic       clk,
    input  logic       reset,
    // transmitter signals
    input  logic       start,
    input  logic       tx_en,
    input  logic [7:0] tx_data,
    output logic       tx_busy,
    output logic       tx_done,
    output logic       tx,
    // receiver signals
    input  logic       rx_en,
    output logic [7:0] rx_data,
    output logic       rx_done,
    input  logic       rx
);

    logic br_tick;

    baudrate_gen U_BRAUD_GEN (
        .clk    (clk),
        .reset  (reset),
        .br_tick(br_tick)
    );

    transmitter U_Transmitter (
        .clk    (clk),
        .reset  (reset),
        .en     (tx_en),
        .br_tick(br_tick),
        .start  (start),
        .tx_data(tx_data),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .tx     (tx)
    );

    receiver U_Receiver (
        .clk    (clk),
        .reset  (reset),
        .en     (rx_en),
        .br_tick(br_tick),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .rx     (rx)
    );

endmodule

module baudrate_gen (
    input  logic clk,
    input  logic reset,
    output logic br_tick
);
    logic [$clog2(100_000_000 / 9600 / 16)-1:0] br_counter;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            br_counter <= 0;
            br_tick <= 1'b0;
        end else begin
            if (br_counter == 100_000_000 / 9600 / 16 - 1) begin
                br_counter <= 0;
                br_tick <= 1'b1;
            end else begin
                br_counter <= br_counter + 1;
                br_tick <= 1'b0;
            end
        end
    end

endmodule

module transmitter (
    input  logic       clk,
    input  logic       reset,
    input  logic       en,
    input  logic       br_tick,
    input  logic       start,
    input  logic [7:0] tx_data,
    output logic       tx_busy,
    output logic       tx_done,
    output logic       tx
);
    typedef enum {
        IDLE,
        START,
        DATA,
        STOP
    } tx_state_e;

    tx_state_e tx_state, tx_next_state;
    logic [7:0] temp_data_reg, temp_data_next;
    logic tx_reg, tx_next;
    logic [3:0] tick_cnt_reg, tick_cnt_next;
    logic [2:0] bit_cnt_reg, bit_cnt_next;
    logic tx_done_reg, tx_done_next;
    logic tx_busy_reg, tx_busy_next;

    assign tx = tx_reg;
    assign tx_busy = tx_busy_reg;
    assign tx_done = tx_done_reg;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            tx_state <= IDLE;
            temp_data_reg <= 0;
            tx_reg <= 1'b1;
            tick_cnt_reg <= 0;
            bit_cnt_reg <= 0;
            tx_done_reg <= 0;
            tx_busy_reg <= 0;
        end else begin
            tx_state <= tx_next_state;
            temp_data_reg <= temp_data_next;
            tx_reg <= tx_next;
            tick_cnt_reg <= tick_cnt_next;
            bit_cnt_reg <= bit_cnt_next;
            tx_done_reg <= tx_done_next;
            tx_busy_reg <= tx_busy_next;
        end
    end

    always_comb begin
        tx_next_state = tx_state;
        temp_data_next = temp_data_reg;
        tx_next = tx_reg;
        tick_cnt_next = tick_cnt_reg;
        bit_cnt_next = bit_cnt_reg;
        tx_done_next = tx_done_reg;
        tx_busy_next = tx_busy_reg;
        case (tx_state)
            IDLE: begin
                tx_next = 1'b1;
                tx_done_next = 0;
                tx_busy_next = 0;
                if (start && en) begin
                    tx_next_state  = START;
                    temp_data_next = tx_data;
                    tick_cnt_next  = 0;
                    bit_cnt_next   = 0;
                    tx_busy_next   = 1;
                end
            end
            START: begin
                tx_next = 1'b0;
                if (br_tick) begin
                    if (tick_cnt_reg == 15) begin
                        tx_next_state = DATA;
                        tick_cnt_next = 0;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            DATA: begin
                tx_next = temp_data_reg[0];
                if (br_tick) begin
                    if (tick_cnt_reg == 15) begin
                        tick_cnt_next = 0;
                        if (bit_cnt_reg == 7) begin
                            tx_next_state = STOP;
                            bit_cnt_next  = 0;
                        end else begin
                            temp_data_next = {1'b0, temp_data_reg[7:1]};
                            bit_cnt_next   = bit_cnt_reg + 1;
                        end
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            STOP: begin
                tx_next = 1'b1;
                if (br_tick) begin
                    if (tick_cnt_reg == 15) begin
                        tx_next_state = IDLE;
                        tx_done_next  = 1;
                        tx_busy_next  = 0;
                        tick_cnt_next = 0;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
        endcase
    end
endmodule

module receiver (
    input  logic       clk,
    input  logic       reset,
    input  logic       en,
    input  logic       br_tick,
    output logic [7:0] rx_data,
    output logic       rx_done,
    input  logic       rx
);

    typedef enum {
        IDLE,
        START,
        DATA,
        STOP
    } rx_state_e;

    rx_state_e rx_state, rx_next_state;

    logic [4:0] tick_cnt_reg, tick_cnt_next;
    logic [2:0] bit_cnt_reg, bit_cnt_next;
    logic [7:0] rx_data_reg, rx_data_next;
    logic rx_done_reg, rx_done_next;

    assign rx_data = rx_data_reg;
    assign rx_done = rx_done_reg;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            rx_state     <= IDLE;
            tick_cnt_reg <= 0;
            bit_cnt_reg  <= 0;
            rx_data_reg  <= 0;
            rx_done_reg  <= 0;
        end else begin
            rx_state     <= rx_next_state;
            tick_cnt_reg <= tick_cnt_next;
            bit_cnt_reg  <= bit_cnt_next;
            rx_data_reg  <= rx_data_next;
            rx_done_reg  <= rx_done_next;
        end
    end

    always_comb begin
        rx_next_state = rx_state;
        rx_done_next  = rx_done_reg;
        tick_cnt_next = tick_cnt_reg;
        bit_cnt_next  = bit_cnt_reg;
        rx_data_next  = rx_data_reg;
        case (rx_state)
            IDLE: begin
                rx_done_next = 0;
                if ((rx == 1'b0) && en) begin
                    rx_next_state = START;
                    tick_cnt_next = 0;
                    bit_cnt_next  = 0;
                    rx_data_next  = 0;
                end
            end
            START: begin
                if (br_tick) begin
                    if (tick_cnt_reg == 7) begin
                        tick_cnt_next = 0;
                        rx_next_state = DATA;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            DATA: begin
                if (br_tick) begin
                    if (tick_cnt_reg == 15) begin
                        tick_cnt_next = 0;
                        rx_data_next  = {rx, rx_data_reg[7:1]};
                        if (bit_cnt_reg == 7) begin
                            bit_cnt_next  = 0;
                            rx_next_state = STOP;
                        end else begin
                            bit_cnt_next = bit_cnt_reg + 1;
                        end
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            STOP: begin
                if (br_tick) begin
                    if (tick_cnt_reg == 23) begin
                        tick_cnt_next = 0;
                        rx_done_next  = 1;
                        rx_next_state = IDLE;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
        endcase
    end

endmodule
