`timescale 1ns / 1ps

module tb_system_uart ();

    reg clk, rst, start, rx;
    reg [7:0] tx_data, send_data, rx_send_data;
    wire tx, rx_done, tx_done, tx_busy;
    wire [7:0] rx_data;
    wire dht11_io;

    integer i = 0;
    integer j = 0;

    reg [7:0] rand_data;

    Top_system_module dut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .echo(),
        .btn(),
        .sw(),
        .tx(tx),
        .trig(),
        .valid(),
        .state_led(),
        .fnd_data(),
        .fnd_com(),
        .dht11_io()
    );

    // rx로 data 보내기
    task send_data_to_rx(input [7:0] send_data);
        begin
            // uart rx start condition
            rx = 0;
            #(10416 * 10);
            // rx data lsb transfer
            for (i = 0; i < 8; i = i + 1) begin
                rx = send_data[i];
                #(10416 * 10);
            end
            rx = 1;
            #(10416 * 3);
            $display("send_data = %h", send_data);
        end
    endtask

    always #5 clk = ~clk;

    initial begin
        #0;
        clk = 0;
        rst = 1;
        start = 0;
        rx = 1;
        #20;
        rst = 0;

        $stop;
    end

endmodule
