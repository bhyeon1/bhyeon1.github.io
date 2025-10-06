`timescale 1ns/1ps

module twf2_1(
   	 input  logic             	 clk,
   	 input  logic             	 rstn,
     input  logic        [4:0]   grp_idx,
     output logic signed [9:0]   re   [15:0],
     output logic signed [9:0]   im   [15:0]
);

  // 1) grp_idx * 16 → base_addr
  logic [8:0]        base_addr;
  logic signed [9:0] re_comb [15:0];
  logic signed [9:0] im_comb [15:0];

  assign base_addr = grp_idx << 4;  // 5-bit <<4 → 9-bit

  // 2) twf2_1_rom 인스턴스 16개 (addr = base_addr + 9'd0..9'd15)
  twf2_1_rom u_rom0  (.addr(base_addr + 9'd0 ), .re(re_comb[ 0]), .im(im_comb[ 0]));
  twf2_1_rom u_rom1  (.addr(base_addr + 9'd1 ), .re(re_comb[ 1]), .im(im_comb[ 1]));
  twf2_1_rom u_rom2  (.addr(base_addr + 9'd2 ), .re(re_comb[ 2]), .im(im_comb[ 2]));
  twf2_1_rom u_rom3  (.addr(base_addr + 9'd3 ), .re(re_comb[ 3]), .im(im_comb[ 3]));
  twf2_1_rom u_rom4  (.addr(base_addr + 9'd4 ), .re(re_comb[ 4]), .im(im_comb[ 4]));
  twf2_1_rom u_rom5  (.addr(base_addr + 9'd5 ), .re(re_comb[ 5]), .im(im_comb[ 5]));
  twf2_1_rom u_rom6  (.addr(base_addr + 9'd6 ), .re(re_comb[ 6]), .im(im_comb[ 6]));
  twf2_1_rom u_rom7  (.addr(base_addr + 9'd7 ), .re(re_comb[ 7]), .im(im_comb[ 7]));
  twf2_1_rom u_rom8  (.addr(base_addr + 9'd8 ), .re(re_comb[ 8]), .im(im_comb[ 8]));
  twf2_1_rom u_rom9  (.addr(base_addr + 9'd9 ), .re(re_comb[ 9]), .im(im_comb[ 9]));
  twf2_1_rom u_rom10 (.addr(base_addr + 9'd10), .re(re_comb[10]), .im(im_comb[10]));
  twf2_1_rom u_rom11 (.addr(base_addr + 9'd11), .re(re_comb[11]), .im(im_comb[11]));
  twf2_1_rom u_rom12 (.addr(base_addr + 9'd12), .re(re_comb[12]), .im(im_comb[12]));
  twf2_1_rom u_rom13 (.addr(base_addr + 9'd13), .re(re_comb[13]), .im(im_comb[13]));
  twf2_1_rom u_rom14 (.addr(base_addr + 9'd14), .re(re_comb[14]), .im(im_comb[14]));
  twf2_1_rom u_rom15 (.addr(base_addr + 9'd15), .re(re_comb[15]), .im(im_comb[15]));

  always_ff @(posedge clk or negedge rstn) begin
    integer idx;
        if (!rstn) begin
            for (idx = 0; idx < 16; idx++) begin
                re[idx] <= '0;
                im[idx] <= '0;
            end
        end else begin
            for (idx = 0; idx < 16; idx++) begin
                re[idx] <= re_comb[idx];
                im[idx] <= im_comb[idx];
            end
        end
  end

endmodule
