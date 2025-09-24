`timescale 1ns / 1ps

module Top_cu (
    input        clk,
    input        rst,
    input  [3:0] btn,
    input  [4:0] sw,
    input  [7:0] rx_data,
    input        rx_done,
    output       btn_dht11_start,
    output       btn_sr04_start,
    output [3:0] btn_stopwatch,    // <stopwatch> btn[3:0]에 in
    output [3:0] btn_watch,        // <watch> btn[3:0]에 in
    output [2:0] stopwatch_cntl,   // <stopwatch> i_uart_flag[2:0]에 in
    output       o_rst,            // <watch/stopwatch> rst에 in
    output [4:0] o_sw              // <watch> stop, blink_disable에 in 
);

    wire [3:0] w_btn;
    wire [4:0] w_btn_uart_cntl;
    wire [3:0] w_btn_data;

    wire [2:0] w_stopwatch_uart_cntl;
    wire [4:0] w_sw_cntl;
    wire [4:0] w_sw_data;

    assign w_btn_data = w_btn | w_btn_uart_cntl[3:0];
    assign o_rst = (w_btn_uart_cntl[4] | rst);
    assign w_sw_data = sw | w_sw_cntl;
    assign o_sw = w_sw_data;

    uart_cu U_UART_CU (
        .clk(clk),
        .rst(rst),
        .rx_done(rx_done),
        .rx_data(rx_data),
        .stopwatch_cntl(w_stopwatch_uart_cntl),
        .btn_cntl(w_btn_uart_cntl),
        .sw_cntl(w_sw_cntl)
    );

    btn_debouncer U_DB (
        .clk  (clk),
        .rst  (rst),
        .btn  (btn),
        .o_btn(w_btn)
    );

    demux_2x5 U_Demux_2x5 (
        .i_btn_data         (w_btn_data),             // or된 버튼 데이터
        .i_sw_data          (w_sw_data[4:1]),         // or된 switch data
        .stopwatch_uart_cntl(w_stopwatch_uart_cntl),
        .watch_setting      (btn_watch),
        .btn_stopwatch      (btn_stopwatch),
        .stopwatch_cntl     (stopwatch_cntl),
        .sr04_start         (btn_sr04_start),
        .dht11_start        (btn_dht11_start)
    );

endmodule

module demux_2x5 (
    input  [3:0] i_btn_data,           // or된 버튼 데이터
    input  [3:0] i_sw_data,            // or된 switch data
    input  [2:0] stopwatch_uart_cntl,
    output [3:0] watch_setting,
    output [3:0] btn_stopwatch,
    output [2:0] stopwatch_cntl,
    output       sr04_start,
    output       dht11_start
);
    assign watch_setting = (!i_sw_data[3] & !i_sw_data[2] & !i_sw_data[1] & i_sw_data[0]) ? i_btn_data : 4'b0000;
    assign btn_stopwatch = (!i_sw_data[3] & !i_sw_data[2] & i_sw_data[1]) ? i_btn_data : 4'b0000;
    assign stopwatch_cntl = (!i_sw_data[3] & !i_sw_data[2] & i_sw_data[1]) ? stopwatch_uart_cntl : 3'b000;
    assign sr04_start = (!i_sw_data[3] & i_sw_data[2]) ? i_btn_data[2] : 0;
    assign dht11_start = (i_sw_data[3]) ? i_btn_data[2] : 0;

endmodule
