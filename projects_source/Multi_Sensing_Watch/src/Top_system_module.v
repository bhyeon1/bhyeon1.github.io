`timescale 1ns / 1ps

module Top_system_module (
    input        clk,
    input        rst,
    input        rx,
    input        echo,
    input  [3:0] btn,
    input  [4:0] sw,
    output       tx,
    output       trig,
    output       valid,
    output [2:0] state_led,
    output [4:0] mode_led,
    output [7:0] fnd_data,
    output [3:0] fnd_com,
    inout        dht11_io
);

    wire [7:0] w_dht11_fnd_data, w_sr04_fnd_data, w_watch_fnd_data;
    wire [3:0] w_dht11_fnd_com, w_sr04_fnd_com, w_watch_fnd_com;
    wire [11:0] w_bcd;
    wire [4:0] w_sw;
    wire w_rst;

    wire w_rx_done, w_dht_done, w_dist_done;
    wire [ 7:0] w_rx_data;
    wire [31:0] w_dht_data;
    wire [ 9:0] w_dist_data;

    wire [3:0] w_btn_stopwatch, w_btn_watch;
    wire [2:0] w_uart_stopwatch_cntl;

    wire w_sr04_start, w_dht11_start;

    assign fnd_data = w_bcd[11:4];
    assign fnd_com  = w_bcd[3:0];

    sender_uart U_SU (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .i_dist_data(w_dist_data),
        .i_dht_data(w_dht_data),
        .dist_done(w_dist_done),
        .dht_done(w_dht_done),
        .tx(tx),
        .tx_done(),
        .rx_done(w_rx_done),
        .rx_data(w_rx_data)
    );

    Top_cu U_Top_CU (
        .clk(clk),
        .rst(rst),
        .btn(btn),
        .sw(sw),
        .rx_data(w_rx_data),
        .rx_done(w_rx_done),
        .btn_dht11_start(w_dht11_start),
        .btn_sr04_start(w_sr04_start),
        .btn_stopwatch(w_btn_stopwatch),
        .btn_watch(w_btn_watch),
        .stopwatch_cntl(w_uart_stopwatch_cntl),
        .o_rst(w_rst),
        .o_sw(w_sw)
    );

    Top_sr04 U_SR04 (
        .clk(clk),
        .rst(w_rst),
        .btn_start(w_sr04_start),
        .echo(echo),
        .trig(trig),
        .dist_done(w_dist_done),
        .dist_data(w_dist_data),
        .fnd_data(w_sr04_fnd_data),
        .fnd_com(w_sr04_fnd_com)
    );

    Top_dht11 U_DHT11 (
        .clk(clk),
        .rst(w_rst),
        .start(w_dht11_start),
        .sw(w_sw[0]),
        .fnd_data(w_dht11_fnd_data),
        .fnd_com(w_dht11_fnd_com),
        .valid(valid),
        .dht_done(w_dht_done),
        .dht_data(w_dht_data),
        .state_led(state_led),
        .dht11_io(dht11_io)
    );

    Top_watch U_WATCH (
        .clk(clk),
        .rst(w_rst),
        .sw_data(w_sw[2:0]),
        .uart_stopwatch_flag(w_uart_stopwatch_cntl),
        .btn_stopwatch(w_btn_stopwatch),
        .btn_watch_setting(w_btn_watch),
        .fnd_com(w_watch_fnd_com),
        .fnd_data(w_watch_fnd_data)
    );

    mux_3x1_fnd U_MUX_3x1_Fnd (
        .sel(w_sw[4:3]),
        .fnd_watch({w_watch_fnd_data, w_watch_fnd_com}),
        .fnd_dht11({w_dht11_fnd_data, w_dht11_fnd_com}),
        .fnd_sr04({w_sr04_fnd_data, w_sr04_fnd_com}),
        .o_bcd(w_bcd)
    );

    led_mode_display U_MODE_DISPLAY (
        .sw (w_sw),
        .led(mode_led)
    );


endmodule

module mux_3x1_fnd (
    input      [ 1:0] sel,
    input      [11:0] fnd_watch,
    input      [11:0] fnd_dht11,
    input      [11:0] fnd_sr04,
    output reg [11:0] o_bcd
);
    always @(*) begin
        case (sel)
            2'b00:   o_bcd = fnd_watch;
            2'b01:   o_bcd = fnd_sr04;
            2'b10:   o_bcd = fnd_dht11;
            2'b11:   o_bcd = fnd_dht11;
            default: o_bcd = fnd_watch;
        endcase
    end
endmodule

module led_mode_display (
    input      [4:0] sw,
    output reg [4:0] led
);
    always @(sw) begin
        casez (sw)
            5'b00001: led = 5'b00001;
            5'b00010: led = 5'b00010;
            5'b00011: led = 5'b00011;
            5'b001?0: led = 5'b00100;
            5'b001?1: led = 5'b00101;
            5'b01??0: led = 5'b01000;
            5'b01??1: led = 5'b01001;
            5'b1???0: led = 5'b10000;
            5'b1???1: led = 5'b10001;
            default:  led = 5'b00000;
        endcase
    end

endmodule
