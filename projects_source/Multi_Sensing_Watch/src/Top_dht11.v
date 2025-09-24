`timescale 1ns / 1ps

module Top_dht11 (
    input         clk,
    input         rst,
    input         start,
    input         sw,
    output [ 7:0] fnd_data,
    output [ 3:0] fnd_com,
    output        valid,
    output        dht_done,
    output [31:0] dht_data,
    output [ 2:0] state_led,
    inout         dht11_io
);

    wire [7:0] w_int_rh, w_int_t, w_dec_rh, w_dec_t;

    assign dht_data = {w_int_rh, w_dec_rh, w_int_t, w_dec_t};

    dht11_controller U_DHT11 (
        .clk(clk),
        .rst(rst),
        .start(start),
        .int_rh_data(w_int_rh),
        .dec_rh_data(w_dec_rh),
        .int_t_data(w_int_t),
        .dec_t_data(w_dec_t),
        .done(dht_done),
        .valid(valid),
        .state_led(state_led),
        .dht11_io(dht11_io)
    );

    dht11_fnd_controller U_FND_CNTL (
        .clk(clk),
        .rst(rst),
        .sw_sel(sw),
        .int_rh_data(w_int_rh),
        .dec_rh_data(w_dec_rh),
        .int_t_data(w_int_t),
        .dec_t_data(w_dec_t),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );

endmodule
