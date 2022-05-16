`include "common.vh"

module mem(
		input clk,
		input rst,
		input [31:0]addr,
		input strobe,
		input read_signal,
		input write_signal,
		input [`CACHE_LINE_SIZE*8-1:0]i_data,
		output read_complete_signal,
		output write_complete_signal,
		output [`CACHE_LINE_SIZE*8-1:0]o_data
);

integer i;

parameter IDLE = 8'd0,
		START_READ = 8'd1,
		READ_COMPLETE = 8'd2,
		START_WRITE = 8'd3,
		WRITE_COMPLETE = 8'd4,
		WAIT_READ_COMPLETE = 8'd5,
		WAIT_WRITE_COMPLETE = 8'd6;
reg [7:0]state;
reg [7:0]next_state;

reg read_complete_signal_reg;
reg write_complete_signal_reg;
reg [7:0]data[`MEM_SIZE - 1:0];
reg [`CACHE_LINE_SIZE*8 - 1:0]o_data_reg;

initial begin
	$readmemh("data/imemfile.dat",data);
end

//state switch
always @(*)begin
	if(state == IDLE)begin
		if(strobe && write_signal)begin
			next_state = START_WRITE;
		end
		else if(strobe && read_signal)begin
			next_state = START_READ;
		end
		else begin
			next_state = state;
		end
	end
	else if(state == START_READ)begin
		next_state = WAIT_READ_COMPLETE;
	end
	else if(state == START_WRITE)begin
		next_state = WAIT_WRITE_COMPLETE;
	end
	else if(state == WAIT_READ_COMPLETE)begin
		if(read_complete_signal_reg == 1'b1)begin
			next_state = READ_COMPLETE;
		end
		else begin
			next_state = state;
		end
	end
	else if(state == WAIT_WRITE_COMPLETE)begin
		if(write_complete_signal_reg == 1'b1)begin
			next_state = WRITE_COMPLETE;
		end
		else begin
			next_state = state;
		end
	end
	else if(state == WRITE_COMPLETE || state == READ_COMPLETE)begin
		if(strobe && read_signal)begin
			next_state = START_READ;
		end
		else if(strobe && write_signal)begin
			next_state = START_WRITE;
		end
		else begin
			next_state =IDLE;
		end
	end
	else begin
		next_state = state;
	end
end

always @(posedge clk)begin
	if(rst)begin
		state <= IDLE;
		read_complete_signal_reg <= 1'b0;
		write_complete_signal_reg <= 1'b0;
	end
	else begin
		state <= next_state;
	end

	if(next_state == READ_COMPLETE)begin
		read_complete_signal_reg <= 1'b0;
	end
	
	if(next_state == WRITE_COMPLETE)begin
		write_complete_signal_reg <= 1'b0;
	end
end

always @(posedge clk)begin
	if(next_state == START_WRITE)begin
		for(i = 0;i<`CACHE_LINE_SIZE;i = i + 1)begin
			data[i+addr] <= i_data[i*8 +: 8];
		end
		#`MEM_WRITE_LATENCY write_complete_signal_reg <= 1'b1;
	end
	else if(next_state == START_READ)begin
		for(i = 0;i<`CACHE_LINE_SIZE;i = i + 1)begin
			o_data_reg[i*8 +: 8] <= data[i+addr];
		end
		#`MEM_READ_LATENCY read_complete_signal_reg <= 1'b1;
	end
end

assign o_data = o_data_reg;
assign read_complete_signal = state == READ_COMPLETE ? 1'b1 : 1'b0;
assign write_complete_signal = state == WRITE_COMPLETE ? 1'b1 : 1'b0;

endmodule
