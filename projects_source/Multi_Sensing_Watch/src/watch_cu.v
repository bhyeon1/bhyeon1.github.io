`timescale 1ns / 1ps    

module watch_cu (
    input            clk,
    input            rst,
    input            i_digit_left,
    input            i_digit_right,
    output reg [2:0] o_digit_pos
);

    parameter DIGIT_SEC = 2'b00, DIGIT_MIN = 2'b01, DIGIT_HOUR = 2'b10;
    reg [1:0] digit_pos_reg, digit_pos_next;

    // state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            digit_pos_reg <= DIGIT_SEC;
        end else begin
            digit_pos_reg <= digit_pos_next;
        end
    end

    // next state
    always @(*) begin
        digit_pos_next = digit_pos_reg;
        case (digit_pos_reg)
            DIGIT_SEC: begin
                if (i_digit_left) digit_pos_next = DIGIT_MIN;
                else if (i_digit_right) digit_pos_next = DIGIT_HOUR;
            end
            DIGIT_MIN: begin
                if (i_digit_left) digit_pos_next = DIGIT_HOUR;
                else if (i_digit_right) digit_pos_next = DIGIT_SEC;
            end
            DIGIT_HOUR: begin
                if (i_digit_left) digit_pos_next = DIGIT_SEC;
                else if (i_digit_right) digit_pos_next = DIGIT_MIN;
            end
        endcase
    end

    // output
    always @(*) begin
        case (digit_pos_reg)
            DIGIT_SEC: begin
                o_digit_pos = 3'b001;
            end
            DIGIT_MIN: begin
                o_digit_pos = 3'b010;
            end
            DIGIT_HOUR: begin
                o_digit_pos = 3'b100;
            end
            default: begin
                o_digit_pos = 3'b000;
            end
        endcase
    end

endmodule
