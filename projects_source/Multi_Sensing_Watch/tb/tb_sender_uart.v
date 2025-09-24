`timescale 1ns / 1ps

module tb_send_uart ();

    reg rx, clk, rst;
    reg [ 9:0] i_dist_data;
    reg [31:0] i_dht_data;
    reg dist_done, dht_done;
    wire tx, tx_done;

    sender_uart dut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .i_dist_data(i_dist_data),
        .i_dht_data(i_dht_data),
        .dist_done(dist_done),
        .dht_done(dht_done),
        .tx(tx),
        .tx_done(tx_done),
        .rx_done(),
        .rx_data()
    );

    task wait_tx_done_n_times;
        input integer repeat_count;
        integer i;
        begin
            for (i = 0; i < repeat_count; i = i + 1) begin
                wait (tx_done);
                #200;
            end
        end
    endtask

    always #5 clk = ~clk;

    initial begin
        #0;
        clk = 0;
        rst = 1;
        rx = 0;
        dist_done = 0;
        dht_done = 0;
        i_dht_data = 32'haa_0f_c6_00;
        #20;
        rst = 0;
        #10;
        dist_done = 1;
        #10;
        dist_done = 0;
        wait_tx_done_n_times(32);
        
        $stop;

    end

endmodule
