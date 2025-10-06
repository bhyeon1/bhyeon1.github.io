`timescale 1ns / 1ps

module tb_time_setting ();

    reg clk, rst;
    reg i_time_up_mode, i_time_up_btn, i_time_rst_btn;
    reg [1:0] i_start_btn;
    wire [5:0] sec, min;
    wire done;
    wire [1:0] moter_start;

    time_setting DUT (
        .clk(clk),
        .rst(rst),
        .i_time_up_mode(i_time_up_mode),
        .i_time_up_btn(i_time_up_btn),
        .i_time_rst_btn(i_time_rst_btn),
        .i_start_btn(i_start_btn),
        .sec(sec),
        .min(min),
        .done(done),
        .moter_start(moter_start)
    );

    task press_btn_up;
        begin
            i_time_up_btn = 1'b1;
            #10;
            i_time_up_btn = 1'b0;
            #10;
        end
    endtask

    task press_btn_down;
        begin
            i_time_rst_btn = 1'b1;
            #10;
            i_time_rst_btn = 1'b0;
            #10;
        end
    endtask

    task press_btn_start;
        begin
            i_start_btn = 2'b01;
            #10;
            i_start_btn = 2'b00;
            #10;
        end
    endtask

    always #5 clk = ~clk;

    initial begin
        #0;
        clk = 0;
        rst = 1;
        i_time_up_mode = 0;
        i_time_up_btn = 0;
        i_time_rst_btn = 0;
        i_start_btn = 0;
        #20;
        rst = 0;
        #10;
        press_btn_up;
        press_btn_up;
        press_btn_down;
        i_time_up_mode = 1;
        #10;
        press_btn_up;
        press_btn_up;
        press_btn_up;
        press_btn_start;

        $stop;
    end

endmodule
