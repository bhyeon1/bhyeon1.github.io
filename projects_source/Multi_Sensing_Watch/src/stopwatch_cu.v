`timescale 1ns / 1ps

module stopwatch_cu (
    input            clk,
    input            rst,
    input      [2:0] i_uart_flag,
    input            i_clear,
    input            i_runstop,
    output reg       o_clear,
    output reg       o_runstop
);

    parameter STOP = 2'b00, RUN = 2'b01, CLEAR = 2'b10;
    reg [1:0] state_reg, state_next;

    // state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state_reg <= STOP;
        end else begin
            state_reg <= state_next;
        end
    end

    // next state
    always @(*) begin
        state_next = state_reg;
        case (state_reg)
            STOP: begin
                if (i_clear | i_uart_flag[2]) state_next = CLEAR;
                else if (i_runstop | i_uart_flag[0]) state_next = RUN;
            end
            RUN: begin
                if (i_runstop | i_uart_flag[1]) state_next = STOP;
            end
            CLEAR: begin
                if (i_clear | i_uart_flag[1]) state_next = STOP;
            end
        endcase
    end

    // output
    always @(*) begin
        case (state_reg)
            STOP: begin
                o_clear   = 1'b0;
                o_runstop = 1'b0;
            end
            RUN: begin
                o_clear   = 1'b0;
                o_runstop = 1'b1;
            end
            CLEAR: begin
                o_clear   = 1'b1;
                o_runstop = 1'b0;
            end
            default: begin
                o_clear   = 1'b0;
                o_runstop = 1'b0;
            end
        endcase
    end

endmodule
