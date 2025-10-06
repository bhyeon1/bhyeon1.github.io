`timescale 1ns / 1ps

module moter_controller (
    input  clk,
    input  rst,
    input  start,
    input  defrost_start,
    output [1:0] moter_control,
    output pwm_out
);

    reg [3:0] r_duty_cycle;
    reg [3:0] r_counter_pwm;
    reg [1:0] r_moter_control;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_duty_cycle <= 0;
            r_moter_control <= 2'b11;
        end else begin
            if (start) begin
                r_moter_control <= 2'b10;
                r_duty_cycle <= 7;
            end else if (defrost_start) begin
                r_moter_control <= 2'b10;
                r_duty_cycle <= 2;
            end else begin
                r_moter_control <= 2'b11;
                r_duty_cycle <= 0;
            end
        end
    end

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_counter_pwm <= 0;
        end else begin
            if (r_counter_pwm == 10 - 1) begin
                r_counter_pwm <= 0;
            end else begin
                r_counter_pwm <= r_counter_pwm + 1;
            end
        end
    end

    assign pwm_out = r_counter_pwm < r_duty_cycle ? 1 : 0;
    assign moter_control = r_moter_control;
    
endmodule
