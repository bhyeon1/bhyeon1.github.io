`timescale 1ns / 1ps

module tb_gate_fft ();

    reg clk, rstn;
    reg valid_in;
    reg signed [143:0] din_re_t;
    reg signed [143:0] din_im_t;
    reg signed [8:0] re_reg[15:0];
    reg signed [8:0] im_reg[15:0];
    wire valid_out;
    wire signed [6655:0] dout_re_t;
    wire signed [6655:0] dout_im_t;
    reg signed [12:0] dout_re_reg[15:0];
    reg signed [12:0] dout_im_reg[15:0];

    initial clk = 0;
    always #5 clk = ~clk;

    integer real_fd, imag_fd;
    integer real_val, imag_val;
    integer fd_out;
    integer i, j;
    integer dummy;
    integer idx_low, idx_high;
	integer real_module_1, imag_module_1;
	integer output_module_1, local_module_1;

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
        for (i = 0; i < 16; i = i + 1) begin
            re_reg[i] = 0;
            im_reg[i] = 0;
			dout_re_reg[i] = 0;
			dout_im_reg[i] = 0;
        end
        for (i = 0; i < 512; i = i + 1) begin
            din_re_t[i] = 0;
            din_im_t[i] = 0;
        end

        repeat (1) @(posedge clk);
        #5;
		rstn = 1;
        #20;
        valid_in = 1;

        // 32 클럭 동안 입력
        for (j = 0; j < 32; j = j + 1) begin
            for (i = 0; i < 16; i = i + 1) begin
                dummy = $fscanf(real_fd, "%d\n", real_val);
                dummy = $fscanf(imag_fd, "%d\n", imag_val);
                re_reg[i] = real_val;
                im_reg[i] = imag_val;
            end
            din_re_t = {
                re_reg[15],
                re_reg[14],
                re_reg[13],
                re_reg[12],
                re_reg[11],
                re_reg[10],
                re_reg[9],
                re_reg[8],
                re_reg[7],
                re_reg[6],
                re_reg[5],
                re_reg[4],
                re_reg[3],
                re_reg[2],
                re_reg[1],
                re_reg[0]
            };
            din_im_t = {
                im_reg[15],
                im_reg[14],
                im_reg[13],
                im_reg[12],
                im_reg[11],
                im_reg[10],
                im_reg[9],
                im_reg[8],
                im_reg[7],
                im_reg[6],
                im_reg[5],
                im_reg[4],
                im_reg[3],
                im_reg[2],
                im_reg[1],
                im_reg[0]
			};
			#10;
		end

        // 입력 종료
        valid_in = 0;
        for (i = 0; i < 16; i = i + 1) begin
            re_reg[i] = 0;
            im_reg[i] = 0;
        end
        din_re_t = 0;
        din_im_t = 0;

        $fclose(real_fd);
        $fclose(imag_fd);
    end

	always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            output_module_1 <= 0;
        end else if (valid_out) begin
            local_module_1 = output_module_1;
			
			dout_re_reg[0]   = dout_re_t[12:0];
        	dout_re_reg[1]   = dout_re_t[25:13];
        	dout_re_reg[2]   = dout_re_t[38:26];
        	dout_re_reg[3]   = dout_re_t[51:39];
        	dout_re_reg[4]   = dout_re_t[64:52];
        	dout_re_reg[5]   = dout_re_t[77:65];
        	dout_re_reg[6]   = dout_re_t[90:78];
        	dout_re_reg[7]   = dout_re_t[103:91];
        	dout_re_reg[8]   = dout_re_t[116:104];
        	dout_re_reg[9]   = dout_re_t[129:117];
        	dout_re_reg[10]  = dout_re_t[142:130];
        	dout_re_reg[11]  = dout_re_t[155:143];
        	dout_re_reg[12]  = dout_re_t[168:156];
        	dout_re_reg[13]  = dout_re_t[181:169];
        	dout_re_reg[14]  = dout_re_t[194:182];
        	dout_re_reg[15]  = dout_re_t[207:195];

			dout_im_reg[0]   = dout_im_t[12:0];
        	dout_im_reg[1]   = dout_im_t[25:13];
        	dout_im_reg[2]   = dout_im_t[38:26];
        	dout_im_reg[3]   = dout_im_t[51:39];
        	dout_im_reg[4]   = dout_im_t[64:52];
        	dout_im_reg[5]   = dout_im_t[77:65];
        	dout_im_reg[6]   = dout_im_t[90:78];
        	dout_im_reg[7]   = dout_im_t[103:91];
        	dout_im_reg[8]   = dout_im_t[116:104];
        	dout_im_reg[9]   = dout_im_t[129:117];
        	dout_im_reg[10]  = dout_im_t[142:130];
        	dout_im_reg[11]  = dout_im_t[155:143];
        	dout_im_reg[12]  = dout_im_t[168:156];
        	dout_im_reg[13]  = dout_im_t[181:169];
        	dout_im_reg[14]  = dout_im_t[194:182];
        	dout_im_reg[15]  = dout_im_t[207:195];

            for (j = 0; j < 16; j = j + 1) begin
                real_module_1 = dout_re_reg[j];
                imag_module_1 = dout_im_reg[j];
                $fwrite(fd_out, "dout(%0d)=%d+j%d\n", local_module_1 + 1,
                        real_module_1, imag_module_1);
                local_module_1 = local_module_1 + 1;
            end
            output_module_1 <= local_module_1;
        end
    end


    initial begin
        repeat (160) @(posedge clk);
        $fclose(fd_out);
        $display("✅ Simulation complete.");
        $finish;
    end

endmodule

