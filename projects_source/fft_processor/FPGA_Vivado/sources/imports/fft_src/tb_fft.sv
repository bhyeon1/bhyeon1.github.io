`timescale 1ns / 1ps

module tb_top_fft_module;

    localparam DATA = 9;
    localparam ARRAY = 16;

    logic clk, rstn, valid_in;
    logic signed [DATA-1:0] din_re_t[ARRAY-1:0];
    logic signed [DATA-1:0] din_im_t[ARRAY-1:0];
    logic valid_out;
    logic signed [12:0] dout_re_t[15:0];
    logic signed [12:0] dout_im_t[15:0];
    logic [6:0] cycle_count;

    // DUT
    top_fft_module dut (
        .clk(clk),
        .rstn(rstn),
        .valid_in(valid_in),
        .din_re_t(din_re_t),
        .din_im_t(din_im_t),
        .valid_out(valid_out),
        .dout_re_t(dout_re_t),
        .dout_im_t(dout_im_t)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // File handles
    integer real_fd, imag_fd;
    integer real_val, imag_val;
    integer real_module_1, imag_module_1;
    integer fd_out, fd_out_re, fd_out_im;
    int output_module_1;

    // 입력 공급 초기화
    initial begin
        real_fd = $fopen("cos_i_dat.txt", "r");
        imag_fd = $fopen("cos_q_dat.txt", "r");
        if (!real_fd || !imag_fd) begin
            $display("❌ ERROR: Failed to open input files!");
            $finish;
        end

        fd_out = $fopen("fft_output_cos.txt", "w");
        if (!fd_out) begin
            $display("❌ ERROR: Failed to open output file!");
            $finish;
        end

        // 초기화
        rstn = 0;
        valid_in = 0;
        for (int j = 0; j < ARRAY; j++) begin
            din_re_t[j] = 0;
            din_im_t[j] = 0;
        end

        repeat (2) @(posedge clk);
        #5;
		rstn = 1;
        #15;
        valid_in = 1;

        // 32 클럭 동안 입력
        for (cycle_count = 0; cycle_count < 32; cycle_count++) begin
            for (int j = 0; j < ARRAY; j++) begin
                void'($fscanf(real_fd, "%d\n", real_val));
                void'($fscanf(imag_fd, "%d\n", imag_val));
                din_re_t[j] = real_val;
                din_im_t[j] = imag_val;
            end
            #10;
        end

        // 입력 종료
        valid_in = 0;
        for (int j = 0; j < ARRAY; j++) begin
            din_re_t[j] = 0;
            din_im_t[j] = 0;
        end

        $fclose(real_fd);
        $fclose(imag_fd);
    end


    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            output_module_1 <= 0;
        end else if (valid_out) begin
            int local_module_1 = output_module_1;
            for (int j = 0; j < ARRAY; j++) begin
                real_module_1 = dout_re_t[j];
                imag_module_1 = dout_im_t[j];
                $fwrite(fd_out, "dout(%0d)=%d+j%d\n", local_module_1 + 1,
                        real_module_1, imag_module_1);
                local_module_1++;
            end
            output_module_1 <= local_module_1;
        end
    end

    initial begin
        repeat (150) @(posedge clk);
        $fclose(fd_out);
        $finish;
    end

endmodule
