`timescale 1ns / 1ps

module top_microwave (
    input clk,
    input rst,
    input [3:0] btn,
    input sw,
    output pwm_out,
    output [1:0] moter_direction,
    output [7:0] fnd_data,
    output [3:0] fnd_com,
    output [2:0] led
);

    wire [3:0] w_btn;
    wire [5:0] w_sec, w_min;
    wire w_done;
    wire [1:0] w_moter_start;

    btn_debounce BD_time_up (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btn[0]),   // Up button
        .o_btn(w_btn[0])
    );

    btn_debounce BD_time_rst (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btn[1]),   // Down button
        .o_btn(w_btn[1])
    );

    btn_debounce BD_start (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btn[2]),   // Left button
        .o_btn(w_btn[2])
    );

    btn_debounce BD_start_defrost (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btn[3]),   // Right button
        .o_btn(w_btn[3])
    );

    time_setting U_TS (
        .clk(clk),
        .rst(rst),
        .i_time_up_mode(sw),
        .i_time_up_btn(w_btn[0]),
        .i_time_rst_btn(w_btn[1]),
        .i_start_btn({w_btn[3], w_btn[2]}),
        .sec(w_sec),
        .min(w_min),
        .moter_start(w_moter_start),    // w_moter_start[0] = start, w_moter_start[1] = defrost_start
        .done(w_done)
    );

    moter_controller U_MC (
        .clk(clk),
        .rst(rst),
        .start(w_moter_start[0]),
        .defrost_start(w_moter_start[1]),
        .moter_control(moter_direction),
        .pwm_out(pwm_out)
    );

    fnd_controller U_FND_CNTR (
        .clk(clk),
        .rst(rst),
        .done(w_done),
        .sec(w_sec),
        .min(w_min),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );

    led_controller U_LED_CNTR (
        .start(w_moter_start[0]),
        .defrost_start(w_moter_start[1]),
        .led(led)
    );

endmodule

module led_controller (
    input        start,
    input        defrost_start,
    output [2:0] led
);

    assign led = (!start && !defrost_start) ? 3'b001 : ( (start && !defrost_start) ? 3'b010 : 3'b100 );

endmodule
