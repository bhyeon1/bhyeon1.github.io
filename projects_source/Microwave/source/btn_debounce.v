`timescale 1ns / 1ps

module btn_debounce (
    input  clk,
    input  rst,
    input  i_btn,
    output o_btn
);

    parameter F_COUNT = 100_000;

    reg r_tick;
    reg [$clog2(F_COUNT-1):0] r_counter;
    reg [9:0] tick_counter;
    reg btn_sync1, btn_sync2, debounced_btn, debounced_btn_next_clk;

    // 1ms Tick 생성
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_counter <= 0;
            r_tick    <= 0;
        end else begin
            if (r_counter == F_COUNT - 1) begin
                r_counter <= 0;
                r_tick <= 1;
            end else begin
                r_counter <= r_counter + 1;
                r_tick <= 0;
            end
        end
    end

    // 버튼 입력 동기화
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            btn_sync1 <= 0;
            btn_sync2 <= 0;
        end else begin
            btn_sync1 <= i_btn;
            btn_sync2 <= btn_sync1;
        end
    end

    // 1ms마다 샘플링 → 버튼 상태 유지 횟수 체크
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tick_counter <= 0;
            debounced_btn <= 0;
        end else if (r_tick) begin
            if (btn_sync2 == debounced_btn)
                tick_counter <= 0; 
            else begin
                tick_counter <= tick_counter + 1;
                if (tick_counter == 9) begin 
                    debounced_btn <= btn_sync2;  
                    tick_counter  <= 0;
                end
            end
        end
    end

    // 1 클럭짜리 펄스 출력 (rising edge)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            debounced_btn_next_clk <= 0;
        end else begin
            debounced_btn_next_clk <= debounced_btn;
        end
    end

    assign o_btn = debounced_btn & (~debounced_btn_next_clk);

endmodule
