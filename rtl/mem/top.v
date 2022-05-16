`include "common.vh"

module top;

reg clk;
reg rst;
reg [31:0]addr;
reg strobe;
reg read_signal;
reg write_signal;
reg [`CACHE_LINE_SIZE*8 - 1:0]i_data;
wire [`CACHE_LINE_SIZE*8 - 1:0]o_data;
wire read_complete_signal;
wire write_complete_signal;

mem mem(.clk(clk),
		.rst(rst),
		.addr(addr),
		.strobe(strobe),
		.read_signal(read_signal),
		.write_signal(write_signal),
		.i_data(i_data),
		.o_data(o_data),
		.read_complete_signal(read_complete_signal),
		.write_complete_signal(write_complete_signal)
);

initial begin
	$fsdbDumpfile("mem.fsdb");
	$fsdbDumpvars(0);
end

initial begin
	clk = 0;
	addr = 0;
	strobe = 1'b1;
	read_signal = 1'b1;
	write_signal = 1'b0;
	rst = 1'b1;
	i_data = 0;
	#10 rst = 1'b0;


	#1000000 $finish;
end

always #5 clk = ~clk;

always @(posedge clk)begin
	if(read_complete_signal == 1'b1)begin
		$display("read complete");
	end
end

endmodule
