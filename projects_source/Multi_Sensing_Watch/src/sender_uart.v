`timescale 1ns / 1ps
module sender_uart (
    input         clk,
    input         rst,
    input         rx,
    input  [ 9:0] i_dist_data,
    input  [31:0] i_dht_data,
    input         dist_done,
    input         dht_done,
    output        tx,
    output        tx_done,
    output        rx_done,
    output [ 7:0] rx_data
);
    wire w_tx_full;
    wire [23:0] w_send_dist_data;
    wire [15:0] w_send_int_rh_data;
    wire [15:0] w_send_dec_rh_data;
    wire [15:0] w_send_int_t_data;
    wire [15:0] w_send_dec_t_data;

    reg [1:0] c_state, n_state;
    reg [7:0] send_data_reg, send_data_next;
    reg send_reg, send_next;
    reg [4:0] send_cnt_reg, send_cnt_next;

    uart_controller U_UART_CNTL (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .rx_pop(),
        .tx_push_data(send_data_reg),
        .tx_push(send_reg),
        .rx_pop_data(rx_data),
        .rx_empty(),
        .rx_done(rx_done),
        .tx_full(w_tx_full),
        .tx_done(tx_done),
        .tx_busy(),
        .tx(tx)
    );

    datatoascii_3bit U_DtoA_DIST (
        .i_data(i_dist_data),
        .o_data(w_send_dist_data)
    );

    datatoascii_2bit U_DtoA_DHT_RH_INT (
        .i_data(i_dht_data[31:24]),
        .o_data(w_send_int_rh_data)
    );

    datatoascii_2bit U_DtoA_DHT_RH_DEC (
        .i_data(i_dht_data[23:16]),
        .o_data(w_send_dec_rh_data)
    );

    datatoascii_2bit U_DtoA_DHT_T_INT (
        .i_data(i_dht_data[15:8]),
        .o_data(w_send_int_t_data)
    );

    datatoascii_2bit U_DtoA_DHT_T_DEC (
        .i_data(i_dht_data[7:0]),
        .o_data(w_send_dec_t_data)
    );

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state       <= 0;
            send_data_reg <= 0;
            send_reg      <= 0;
            send_cnt_reg  <= 0;
        end else begin
            c_state       <= n_state;
            send_data_reg <= send_data_next;
            send_reg      <= send_next;
            send_cnt_reg  <= send_cnt_next;
        end
    end

    always @(*) begin
        n_state        = c_state;
        send_data_next = send_data_reg;
        send_next      = send_reg;
        send_cnt_next  = send_cnt_reg;
        case (c_state)
            0: begin
                send_cnt_next = 0;
                if (dist_done) begin
                    n_state = 1;
                end
                if (dht_done) begin
                    n_state = 2;
                end
            end

            1: begin  // send
                if (~w_tx_full) begin
                    send_next = 1;  // send tick 생성.
                    if (send_cnt_reg < 16) begin
                        // 상위부터 보내기
                        case (send_cnt_reg)
                            4'b0000: send_data_next = 8'h44;  // D
                            4'b0001: send_data_next = 8'h69;  // i
                            4'b0010: send_data_next = 8'h73;  // s
                            4'b0011: send_data_next = 8'h74;  // t
                            4'b0100: send_data_next = 8'h61;  // a
                            4'b0101: send_data_next = 8'h6E;  // n
                            4'b0110: send_data_next = 8'h63;  // c
                            4'b0111: send_data_next = 8'h65;  // e
                            4'b1000: send_data_next = 8'h3A;  // :
                            4'b1001: send_data_next = 8'h20;  // space바
                            4'b1010: send_data_next = w_send_dist_data[23:16];
                            4'b1011: send_data_next = w_send_dist_data[15:8];
                            4'b1100: send_data_next = w_send_dist_data[7:0];
                            4'b1101: send_data_next = 8'h63;
                            4'b1110: send_data_next = 8'h6D;
                            4'b1111: send_data_next = 8'h0d;
                        endcase
                        send_cnt_next = send_cnt_reg + 1;
                    end else begin
                        n_state   = 0;
                        send_next = 0;
                    end
                end else n_state = c_state;
            end
            2: begin  // send
                if (~w_tx_full) begin
                    send_next = 1;  // send tick 생성.
                    if (send_cnt_reg < 15) begin
                        // 상위부터 보내기
                        case (send_cnt_reg)
                            4'b0000: send_data_next = w_send_int_t_data[15:8];
                            4'b0001: send_data_next = w_send_int_t_data[7:0];
                            4'b0010: send_data_next = 8'h2e;
                            4'b0011: send_data_next = w_send_dec_t_data[15:8];
                            4'b0100: send_data_next = w_send_dec_t_data[7:0];
                            4'b0101: send_data_next = 8'h27;  // '
                            4'b0110: send_data_next = 8'h43;  // C
                            4'b0111: send_data_next = 8'h20;  // space바
                            4'b1000: send_data_next = w_send_int_rh_data[15:8];
                            4'b1001: send_data_next = w_send_int_rh_data[7:0];
                            4'b1010: send_data_next = 8'h2e;  // .
                            4'b1011: send_data_next = w_send_dec_rh_data[15:8];
                            4'b1100: send_data_next = w_send_dec_rh_data[7:0];
                            4'b1101: send_data_next = 8'h25;  // %
                            4'b1110: send_data_next = 8'h0d;  // \n
                        endcase
                        send_cnt_next = send_cnt_reg + 1;
                    end else begin
                        n_state   = 0;
                        send_next = 0;
                    end
                end else n_state = c_state;
            end
        endcase
    end
endmodule

// decoder, LUT
module datatoascii_3bit (
    input  [ 9:0] i_data,
    output [23:0] o_data
);
    assign o_data[7:0]   = i_data % 10 + 8'h30;  // 나머지 + 8'h30
    assign o_data[15:8]  = (i_data / 10) % 10 + 8'h30;
    assign o_data[23:16] = (i_data / 100) % 10 + 8'h30;
endmodule

module datatoascii_2bit (
    input  [ 7:0] i_data,
    output [15:0] o_data
);
    assign o_data[7:0]  = i_data % 10 + 8'h30;  // 나머지 + 8'h30
    assign o_data[15:8] = (i_data / 10) % 10 + 8'h30;
endmodule