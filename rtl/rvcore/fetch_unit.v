`include "common.vh"

//fetch instruction
module fetch_unit(
		input clk,
		input rst,
		input stall_pipeline_signal_from_decode_stage,
		input branch_signal_from_execute_stage,
		input[31:0] branch_address_from_execute_stage,
		input[31:0] inst,
		output[31:0] inst_addr,
		output[31:0] inst_addr_for_decode_stage,
		output[31:0] inst_for_decode_stage
);

reg[31:0] inst_addr_reg;
reg[31:0] inst_for_decode_stage_reg;//pipeline reg
reg[31:0] inst_addr_for_decode_stage_reg;

always @(posedge clk)begin
	if(rst == 1'b1)begin
		inst_addr_reg <= 32'b0;//reset ip
		inst_for_decode_stage_reg <= `NOP_INSTRUCTION;
		inst_addr_for_decode_stage_reg <= 32'd0;
	end
	else if(stall_pipeline_signal_from_decode_stage == 1'b1)begin
		inst_addr_reg <= inst_addr_reg;
		inst_for_decode_stage_reg <= inst_for_decode_stage_reg;
		inst_addr_for_decode_stage_reg <= inst_addr_for_decode_stage_reg;
	end
	else if(branch_signal_from_execute_stage == 1'b1)begin//handle control hazard
		inst_addr_reg <= branch_address_from_execute_stage + 32'd4;
		inst_for_decode_stage_reg <= inst;
		inst_addr_for_decode_stage_reg <= branch_address_from_execute_stage;
	end
	else begin
		inst_addr_reg <= inst_addr_reg + 32'd4;//Sequential execution:next instruction
		inst_for_decode_stage_reg <= inst;
		inst_addr_for_decode_stage_reg <= inst_addr_reg;
	end	
end

assign inst_addr = branch_signal_from_execute_stage ? branch_address_from_execute_stage : inst_addr_reg;

//pipeline register
assign inst_for_decode_stage = inst_for_decode_stage_reg;
assign inst_addr_for_decode_stage = inst_addr_for_decode_stage_reg;
endmodule
