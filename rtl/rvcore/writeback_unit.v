`include "common.vh"

//wirteback result
module writeback_unit(
		input clk,
		input rst,
		input regfile_write_signal_from_mem_stage,
		input[4:0] rd_index_from_mem_stage,
		input[31:0] inst_from_mem_stage,
		input[31:0] inst_addr_from_mem_stage,
		input[31:0] rd_reg_content_from_mem_stage,
		output[4:0] rd_index,
		output[31:0] rd_reg_content
);

reg[4:0] rd_index_reg;
reg[31:0] rd_reg_content_reg;

always @(*)begin
	if(regfile_write_signal_from_mem_stage)begin
		rd_index_reg = rd_index_from_mem_stage;
		rd_reg_content_reg = rd_reg_content_from_mem_stage;
	end
	else begin
		rd_index_reg = 5'd0;
		rd_reg_content_reg = 32'd0;
	end
end

assign rd_index = rd_index_reg;
assign rd_reg_content = rd_reg_content_reg;

endmodule

