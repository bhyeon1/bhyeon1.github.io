`timescale 1ns / 1ps

module tb_dht11 ();

    parameter US = 1000;

    reg clk, rst, start, dht11_io_reg, io_en;
    reg  [39:0] dht11_test_data;
    // wire [7:0] rh_data, t_data;
    wire [ 2:0] state_led;
    wire dht11_io, valid;
    wire [31:0] dht_data;

    integer i;

    Top_dht11 dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .sw(),
        .fnd_data(),
        .fnd_com(),
        .valid(valid),
        .dht_done(),
        .dht_data(dht_data),
        .state_led(state_led),
        .dht11_io(dht11_io)
    );


    assign dht11_io = (io_en) ? 1'bz : dht11_io_reg;

    always #5 clk = ~clk;

    initial begin
        #0;
        clk = 0;
        rst = 1;
        start = 0;
        dht11_io_reg = 0;
        io_en = 1;
        dht11_test_data = 40'haa_0f_c6_00_7f;
        #20;
        rst = 0;
        #20;
        start = 1;
        #20;
        start = 0;

        wait (!dht11_io);
        wait (dht11_io);

        #(30 * US);
        io_en = 0;
        #(80 * US);
        dht11_io_reg = 1;
        #(80 * US);
        for (i = 0; i < 40; i = i + 1) begin
            dht11_io_reg = 0;
            #(50 * US);
            if (dht11_test_data[39-i] == 0) begin
                dht11_io_reg = 1;
                #(29 * US);
            end else begin
                dht11_io_reg = 1;
                #(68 * US);
            end
        end
        dht11_io_reg = 0;
        #(50 * US);
        io_en = 1;
        #50000;
        $stop;
    end

endmodule
