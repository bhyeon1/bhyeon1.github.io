`timescale 1ns / 1ps

module tb_watch ();

    reg clk, rst, rx;
    reg [3:0] btn;
    reg [4:0] sw;
    wire tx;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;

    integer i;

    Top_system_module dut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .echo(),
        .btn(btn),
        .sw(sw),
        .tx(tx),
        .trig(),
        .valid(),
        .state_led(),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com),    
        .dht11_io()
    );

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
        clk  = 0;
        rst  = 1;
        rx   = 0;
        btn  = 4'b0000;
        sw   = 5'b00000;
        #20;
        rst = 0;
        #20;
        sw = 5'b00100;
        btn[1] = 1;
        #100000;
        btn[0] = 0;
        

        #10000;
        $stop;

    end

endmodule
