module mux4to2 #(
    parameter int ARRAY = 16,  // 배열 길이
    parameter int DATA  = 10   // 각 원소 비트 폭
) (
    input  logic                   sel,
    input  logic signed [DATA-1:0] u_in_re[ARRAY-1:0],
    input  logic signed [DATA-1:0] u_in_im[ARRAY-1:0],
    input  logic signed [DATA-1:0] v_in_re[ARRAY-1:0],
    input  logic signed [DATA-1:0] v_in_im[ARRAY-1:0],
    output logic signed [DATA-1:0] out_re [ARRAY-1:0],
    output logic signed [DATA-1:0] out_im [ARRAY-1:0]
);

    assign out_re = sel ? v_in_re : u_in_re;
    assign out_im = sel ? v_in_im : u_in_im;

endmodule
