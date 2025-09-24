`timescale 1ns / 1ps
/*
module uart_cu (
    input        clk,
    input        rst,
    input        rx_done,
    input  [7:0] rx_data,
    output [2:0] stopwatch_cntl,
    output [4:0] btn_cntl,
    output [4:0] sw_cntl
);

    localparam IDLE = 0, CNTL = 1;

    localparam GO = 8'h7a, STOP = 8'h78, CLEAR = 8'h63;
    localparam LEFT = 8'h61, RIGHT = 8'h64, UP = 8'h77, DOWN = 8'h73, RESET = 8'h1b;
    localparam DISPLAY = 8'h31, SETTING_WATCH = 8'h32, STOP_WATCH = 8'h33, SR04_MODE = 8'h34, DHT11_MODE = 8'h35;

    reg c_state, n_state;
    reg [7:0] mem;
    reg [4:0] n_btn_data, c_btn_data;
    reg [2:0] n_stopwatch_cntl, c_stopwatch_cntl;
    reg [4:0] n_sw_cntl, c_sw_cntl;

    assign btn_cntl = c_btn_data;
    assign sw_cntl = c_sw_cntl;
    assign stopwatch_cntl = c_stopwatch_cntl;

    // state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= IDLE;
            c_btn_data <= 0;
            c_stopwatch_cntl <= 0;
            c_sw_cntl <= 0;
        end else begin
            c_state <= n_state;
            c_btn_data <= n_btn_data;
            c_stopwatch_cntl <= n_stopwatch_cntl;
            c_sw_cntl <= n_sw_cntl;
        end
    end

    // next state
    always @(*) begin
        n_state = c_state;
        n_btn_data = 5'b00000;
        n_stopwatch_cntl = 3'b000;
        n_sw_cntl = c_sw_cntl;
        case (c_state)
            IDLE: begin
                if (rx_done) begin
                    mem = rx_data;
                    n_state = CNTL;
                end
            end
            CNTL: begin
                case (mem)
                    GO:            n_stopwatch_cntl = 3'b001;
                    STOP:          n_stopwatch_cntl = 3'b010;
                    CLEAR:         n_stopwatch_cntl = 3'b100;
                    LEFT:          n_btn_data = 5'b00001;
                    RIGHT:         n_btn_data = 5'b00010;
                    UP:            n_btn_data = 5'b00100;
                    DOWN:          n_btn_data = 5'b01000;
                    RESET:         n_btn_data = 5'b10000;
                    DISPLAY:       n_sw_cntl[0] = ~c_sw_cntl[0];
                    SETTING_WATCH: n_sw_cntl[1] = ~c_sw_cntl[1];
                    STOP_WATCH:    n_sw_cntl[2] = ~c_sw_cntl[2];
                    SR04_MODE:     n_sw_cntl[3] = ~c_sw_cntl[3];
                    DHT11_MODE:    n_sw_cntl[4] = ~c_sw_cntl[4];
                    default: begin
                        n_btn_data = 5'b00000;
                        n_stopwatch_cntl = 3'b000;
                        n_sw_cntl = c_sw_cntl;
                    end
                endcase
                n_state = IDLE;
            end
        endcase
    end

endmodule
*/

`timescale 1ns / 1ps

module uart_cu (
    input        clk,
    input        rst,
    input        rx_done,
    input  [7:0] rx_data,
    output [2:0] stopwatch_cntl,
    output [4:0] btn_cntl,
    output [4:0] sw_cntl
);

    localparam GO = 8'h7a, STOP = 8'h78, CLEAR = 8'h63;
    localparam LEFT = 8'h61, RIGHT = 8'h64, UP = 8'h77, DOWN = 8'h73, RESET = 8'h1b;
    localparam DISPLAY = 8'h31, SETTING_WATCH = 8'h32, STOP_WATCH = 8'h33, SR04_MODE = 8'h34, DHT11_MODE = 8'h35;
    reg [4:0] sw_cntl_reg, sw_cntl_next;
    
    assign stopwatch_cntl[2] = ((rx_data == CLEAR) && rx_done);
    assign stopwatch_cntl[1] = ((rx_data == STOP) && rx_done);
    assign stopwatch_cntl[0] = ((rx_data == GO) && rx_done);
    
    assign btn_cntl[4] = ((rx_data == RESET) && rx_done);
    assign btn_cntl[3] = ((rx_data == DOWN) && rx_done);
    assign btn_cntl[2] = ((rx_data == UP) && rx_done);
    assign btn_cntl[1] = ((rx_data == RIGHT) && rx_done);
    assign btn_cntl[0] = ((rx_data == LEFT) && rx_done);

    assign sw_cntl = sw_cntl_reg;

    // state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            sw_cntl_reg <= 0;
        end else begin
            sw_cntl_reg <= sw_cntl_next;
        end
    end

    // next state
    always @(*) begin
        sw_cntl_next = sw_cntl_reg;
        if (rx_done) begin
            case (rx_data)
                DISPLAY: begin
                    sw_cntl_next[0] = ~sw_cntl_next[0];
                end
                SETTING_WATCH: begin
                    sw_cntl_next[1] = ~sw_cntl_next[1];
                end
                STOP_WATCH: begin
                    sw_cntl_next[2] = ~sw_cntl_next[2];
                end
                SR04_MODE: begin
                    sw_cntl_next[3] = ~sw_cntl_next[3];
                end
                DHT11_MODE: begin
                    sw_cntl_next[4] = ~sw_cntl_next[4];
                end
            endcase
        end
    end

endmodule