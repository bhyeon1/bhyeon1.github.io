`timescale 1ns / 1ps

module top_fft_module (
    input  logic               clk,
    input  logic               rstn,
    input  logic               valid_in,
    input  logic signed [ 8:0] din_re_t [15:0],
    input  logic signed [ 8:0] din_im_t [15:0],
    output logic               valid_out,
    output logic signed [12:0] dout_re_t[15:0],
    output logic signed [12:0] dout_im_t[15:0]
);

    logic valid_out_0, valid_out_1, valid_out_2, valid_reg, trigger;
    logic        [ 4:0] min_out;
    logic        [ 4:0] index_h;
    logic        [ 4:0] index_l;
    logic signed [10:0] re_m_0  [ 15:0];
    logic signed [10:0] im_m_0  [ 15:0];
    logic signed [11:0] re_m_1  [ 15:0];
    logic signed [11:0] im_m_1  [ 15:0];
    logic        [ 4:0] cnt;
    logic        [ 4:0] cnt_val;
    logic signed [12:0] re_reg_1[511:0];
    logic signed [12:0] im_reg_1[511:0];
    logic signed [12:0] re_reg_2[511:0];
    logic signed [12:0] im_reg_2[511:0];


    module_0 u_fft_module_0 (
        .clk(clk),
        .rstn(rstn),
        .valid_in(valid_in),
        .din_re(din_re_t),
        .din_im(din_im_t),
        .valid_out(valid_out_0),
        .min_out(min_out),
        .dout_re(re_m_0),
        .dout_im(im_m_0)
    );

    module_1 u_fft_module_1 (
        .clk(clk),
        .rstn(rstn),
        .valid_in(valid_out_0),
        .din_re(re_m_0),
        .din_im(im_m_0),
        .valid_out(valid_out_1),
        .dout_re(re_m_1),
        .dout_im(im_m_1),
        .index_h(index_h),
        .index_l(index_l)
    );

    module_2 u_fft_module_2 (
        .clk(clk),
        .rstn(rstn),
        .valid_in(valid_out_1),
        .din_re(re_m_1),
        .din_im(im_m_1),
        .index0(min_out),
        .index1_0_7(index_l),
        .index1_8_15(index_h),
        .valid_out(valid_out_2),
        .dout_re(re_reg_1),
        .dout_im(im_reg_1)
    );

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            trigger <= 0;
            cnt <= 0;
            valid_reg <= '0;
            cnt_val <= '0;
			valid_out <= '0;
        end else begin
			valid_out <= valid_reg;
            if (valid_out_2) cnt <= cnt + 1;
            else cnt <= '0;
            if (cnt == 5'd30) trigger <= '1;
            else trigger <= '0;
			if (cnt == 5'd31) valid_reg <= '1;
            else if (valid_reg && cnt_val < 5'd31) cnt_val <= cnt_val + 1;
            else if (cnt_val == 5'd31) begin
                valid_reg <= '0;
                cnt_val   <= '0;
            end
        end
    end

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (int i = 0; i < 512; i++) begin
                re_reg_2[i] <= '0;
                im_reg_2[i] <= '0;
            end
        end else begin
            if (trigger) begin
                for (int i = 0; i < 512; i++) begin
                    re_reg_2[i] <= re_reg_1[i];
                    im_reg_2[i] <= im_reg_1[i];
                end
            end else if (cnt_val == 5'd31) begin
                for (int i = 0; i < 512; i++) begin
                    re_reg_2[i] <= '0;
                    im_reg_2[i] <= '0;
                end
            end
        end
    end

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (int i = 0; i < 15; i++) begin
                dout_re_t[i] <= '0;
                dout_im_t[i] <= '0;
            end
        end else if (cnt_val == 'd0) begin
            dout_re_t <= re_reg_2[15:0];
            dout_im_t <= im_reg_2[15:0];
        end else if (cnt_val == 'd1) begin
            dout_re_t <= re_reg_2[31:16];
            dout_im_t <= im_reg_2[31:16];
        end else if (cnt_val == 'd2) begin
            dout_re_t <= re_reg_2[47:32];
            dout_im_t <= im_reg_2[47:32];
        end else if (cnt_val == 'd3) begin
            dout_re_t <= re_reg_2[63:48];
            dout_im_t <= im_reg_2[63:48];
        end else if (cnt_val == 'd4) begin
            dout_re_t <= re_reg_2[79:64];
            dout_im_t <= im_reg_2[79:64];
        end else if (cnt_val == 'd5) begin
            dout_re_t <= re_reg_2[95:80];
            dout_im_t <= im_reg_2[95:80];
        end else if (cnt_val == 'd6) begin
            dout_re_t <= re_reg_2[111:96];
            dout_im_t <= im_reg_2[111:96];
        end else if (cnt_val == 'd7) begin
            dout_re_t <= re_reg_2[127:112];
            dout_im_t <= im_reg_2[127:112];
        end else if (cnt_val == 'd8) begin
            dout_re_t <= re_reg_2[143:128];
            dout_im_t <= im_reg_2[143:128];
        end else if (cnt_val == 'd9) begin
            dout_re_t <= re_reg_2[159:144];
            dout_im_t <= im_reg_2[159:144];
        end else if (cnt_val == 'd10) begin
            dout_re_t <= re_reg_2[175:160];
            dout_im_t <= im_reg_2[175:160];
        end else if (cnt_val == 'd11) begin
            dout_re_t <= re_reg_2[191:176];
            dout_im_t <= im_reg_2[191:176];
        end else if (cnt_val == 'd12) begin
            dout_re_t <= re_reg_2[207:192];
            dout_im_t <= im_reg_2[207:192];
        end else if (cnt_val == 'd13) begin
            dout_re_t <= re_reg_2[223:208];
            dout_im_t <= im_reg_2[223:208];
        end else if (cnt_val == 'd14) begin
            dout_re_t <= re_reg_2[239:224];
            dout_im_t <= im_reg_2[239:224];
        end else if (cnt_val == 'd15) begin
            dout_re_t <= re_reg_2[255:240];
            dout_im_t <= im_reg_2[255:240];
        end else if (cnt_val == 'd16) begin
            dout_re_t <= re_reg_2[271:256];
            dout_im_t <= im_reg_2[271:256];
        end else if (cnt_val == 'd17) begin
            dout_re_t <= re_reg_2[287:272];
            dout_im_t <= im_reg_2[287:272];
        end else if (cnt_val == 'd18) begin
            dout_re_t <= re_reg_2[303:288];
            dout_im_t <= im_reg_2[303:288];
        end else if (cnt_val == 'd19) begin
            dout_re_t <= re_reg_2[319:304];
            dout_im_t <= im_reg_2[319:304];
        end else if (cnt_val == 'd20) begin
            dout_re_t <= re_reg_2[335:320];
            dout_im_t <= im_reg_2[335:320];
        end else if (cnt_val == 'd21) begin
            dout_re_t <= re_reg_2[351:336];
            dout_im_t <= im_reg_2[351:336];
        end else if (cnt_val == 'd22) begin
            dout_re_t <= re_reg_2[367:352];
            dout_im_t <= im_reg_2[367:352];
        end else if (cnt_val == 'd23) begin
            dout_re_t <= re_reg_2[383:368];
            dout_im_t <= im_reg_2[383:368];
        end else if (cnt_val == 'd24) begin
            dout_re_t <= re_reg_2[399:384];
            dout_im_t <= im_reg_2[399:384];
        end else if (cnt_val == 'd25) begin
            dout_re_t <= re_reg_2[415:400];
            dout_im_t <= im_reg_2[415:400];
        end else if (cnt_val == 'd26) begin
            dout_re_t <= re_reg_2[431:416];
            dout_im_t <= im_reg_2[431:416];
        end else if (cnt_val == 'd27) begin
            dout_re_t <= re_reg_2[447:432];
            dout_im_t <= im_reg_2[447:432];
        end else if (cnt_val == 'd28) begin
            dout_re_t <= re_reg_2[463:448];
            dout_im_t <= im_reg_2[463:448];
        end else if (cnt_val == 'd29) begin
            dout_re_t <= re_reg_2[479:464];
            dout_im_t <= im_reg_2[479:464];
        end else if (cnt_val == 'd30) begin
            dout_re_t <= re_reg_2[495:480];
            dout_im_t <= im_reg_2[495:480];
        end else if (cnt_val == 'd31) begin
            dout_re_t <= re_reg_2[511:496];
            dout_im_t <= im_reg_2[511:496];
        end
    end

endmodule
