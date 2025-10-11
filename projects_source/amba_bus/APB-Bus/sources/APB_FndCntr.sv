`timescale 1ns / 1ps

module APB_FndCntr (
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 2:0] PADDR,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic        PSEL,
    input  logic [31:0] PWDATA,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    // External Port
    output logic [ 7:0] fnd_data,
    output logic [ 3:0] fnd_com
);

    logic [13:0] num_data;

    APB_SlaveIntf_FND_CNTR U_APB_SlaveIntf_FND_CNTR (.*);

    fnd_controller U_FND_CNTR (
        .clk(PCLK),
        .rst(PRESET),
        .*
    );

endmodule

module APB_SlaveIntf_FND_CNTR (
    // global signals
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 2:0] PADDR,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic        PSEL,
    input  logic [31:0] PWDATA,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    // Internal Port
    output logic [13:0] num_data
);

    logic [31:0] slv_reg0;

    assign num_data = slv_reg0;

    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            slv_reg0 <= 0;
        end else begin
            PREADY <= 1'b0;
            if (PSEL && PENABLE) begin
                PREADY <= 1'b1;
                if (PWRITE) begin
                    case (PADDR[2])
                        2'd0: slv_reg0 <= PWDATA;
                        2'd1: ;
                    endcase
                end else begin
                    case (PADDR[2])
                        2'd0: ;  //PRDATA <= slv_reg0;
                        2'd1: ;
                    endcase
                end
            end
        end
    end

endmodule

module fnd_controller (
    input  logic        clk,
    input  logic        rst,
    input  logic [13:0] num_data,
    output logic [ 7:0] fnd_data,
    output logic [ 3:0] fnd_com
);

    logic tick_1khz;
    logic [1:0] cnt;
    logic [3:0] digit_1, digit_10, digit_100, digit_1000, bcd;

    clk_div_1khz u_clk_div_1khz (
        .clk(clk),
        .rst(rst),
        .tick_1khz(tick_1khz)
    );

    counter_4 u_counter_4 (
        .clk (clk),
        .rst (rst),
        .tick(tick_1khz),
        .cnt (cnt)
    );

    decoder_2x4 u_decoder_2x4 (
        .x(cnt),
        .y(fnd_com)
    );

    digit_splitter u_DS (
        .num_data(num_data),
        .digit_1(digit_1),
        .digit_10(digit_10),
        .digit_100(digit_100),
        .digit_1000(digit_1000)
    );

    mux_4x1 u_mux_4x1 (
        .sel(cnt),
        .x0 (digit_1),
        .x1 (digit_10),
        .x2 (digit_100),
        .x3 (digit_1000),
        .y  (bcd)
    );

    bcd_decoder u_bcd_decoder (
        .bcd(bcd),
        .fnd_data(fnd_data)
    );

endmodule

// 1khz 바꾸기
module clk_div_1khz (
    input  logic clk,
    input  logic rst,
    output logic tick_1khz
);
    reg [$clog2(100_000)-1:0] div_counter;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            tick_1khz   <= 0;
            div_counter <= 1'b0;
        end else begin
            if (div_counter == 100_000 - 1) begin  // 1khz period
                div_counter <= 0;
                tick_1khz   <= 1'b1;
            end else begin
                div_counter <= div_counter + 1;
                tick_1khz   <= 1'b0;
            end
        end
    end

endmodule

module counter_4 (
    input  logic       clk,
    input  logic       rst,
    input  logic       tick,
    output logic [1:0] cnt
);

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            cnt <= 0;
        end else begin
            if (tick) begin
                cnt <= cnt + 1;
            end
        end
    end

endmodule

module decoder_2x4 (
    input  logic [1:0] x,
    output logic [3:0] y
);

    always_comb begin
        y = 4'b1111;  // latch 방지용
        case (x)
            2'b00: y = 4'b1110;
            2'b01: y = 4'b1101;
            2'b10: y = 4'b1011;
            2'b11: y = 4'b0111;
        endcase
    end

endmodule

module digit_splitter (
    input  logic [13:0] num_data,
    output logic [ 3:0] digit_1,
    output logic [ 3:0] digit_10,
    output logic [ 3:0] digit_100,
    output logic [ 3:0] digit_1000
);

    assign digit_1    = num_data % 10;
    assign digit_10   = (num_data / 10) % 10;
    assign digit_100  = (num_data / 100) % 10;
    assign digit_1000 = (num_data / 1000) % 10;

endmodule


module mux_4x1 (
    input  logic [1:0] sel,
    input  logic [3:0] x0,
    input  logic [3:0] x1,
    input  logic [3:0] x2,
    input  logic [3:0] x3,
    output logic [3:0] y
);

    always_comb begin
        y = 4'b0000;
        case (sel)
            2'b00: y = x0;
            2'b01: y = x1;
            2'b10: y = x2;
            2'b11: y = x3;
        endcase
    end

endmodule

module bcd_decoder (
    input  logic [3:0] bcd,
    output logic [7:0] fnd_data
);
    always_comb begin
        fnd_data = 8'hff;
        case (bcd)
            4'h00: fnd_data = 8'hc0;
            4'h01: fnd_data = 8'hf9;
            4'h02: fnd_data = 8'ha4;
            4'h03: fnd_data = 8'hb0;
            4'h04: fnd_data = 8'h99;
            4'h05: fnd_data = 8'h92;
            4'h06: fnd_data = 8'h82;
            4'h07: fnd_data = 8'hf8;
            4'h08: fnd_data = 8'h80;
            4'h09: fnd_data = 8'h90;
        endcase
    end

endmodule

