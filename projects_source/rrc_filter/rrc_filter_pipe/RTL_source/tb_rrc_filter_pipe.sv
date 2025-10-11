`timescale 1ns/10ps

module tb_rrc_filter();

logic clk, rstn;
logic signed [6:0] data_in;
logic signed [6:0] data_out;
logic signed [6:0] adc_data_in [0:93696];
initial begin
	clk <= 1'b1;
	rstn <= 1'b0;
	#55 rstn <= 1'b1;
end

always #5 clk <= ~clk;

integer fd_adc_di;
integer fd_rrc_do;
integer i;
int data;
initial begin
	fd_adc_di = $fopen("./rrc_din.txt", "r");
	fd_rrc_do = $fopen("./rrc_dout.txt", "w");
	i = 0;
	while (!$feof(fd_adc_di)) begin
		void'($fscanf(fd_adc_di, "%d\n", data));
		adc_data_in[i] = data;
		//adc_data_in[i] = $signed(data[6:0]);
		i = i + 1;
	end
	#800000 $finish;
	$fclose(fd_rrc_do);
end

logic [23:0] adc_dcnt;
always_ff @(posedge clk or negedge rstn) begin
	if (~rstn)
		adc_dcnt <= 'h0;
	else
		adc_dcnt <= adc_dcnt + 1'b1;
end

always_ff @(posedge clk or negedge rstn) begin
	if (~rstn)
		data_in <= 0;
	else
		if (adc_dcnt < 93700)
			data_in <= adc_data_in[adc_dcnt];
		else
			data_in <= 0;
end

always_ff @(negedge clk) begin
	$fwrite(fd_rrc_do, "%0d\n", data_out);
end

rrc_filter_pipe #(.WIDTH(7), .COEFF_FIXED(9)) i_rrc_filter (
											.clk(clk),
											.rstn(rstn),
											.data_in(data_in),
											.data_out(data_out)
											);

endmodule

