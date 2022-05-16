`include "common.vh"

//decode instruction
module decode_unit(
		input clk,
		input rst,
		input branch_signal_from_execute_stage,
		input[31:0] inst_from_fetch_stage,
		input[31:0] inst_addr_from_fetch_stage,
		input[31:0] rs1_reg_content_from_regfile,
		input[31:0] rs2_reg_content_from_regfile,
		output[31:0] inst_for_execute_stage,
		output[31:0] inst_addr_for_execute_stage,
		output[4:0] rs1_index,
		output[4:0] rs2_index,
		output[31:0] rs1_reg_content_for_execute_stage,
		output[31:0] rs2_reg_content_for_execute_stage,
		output stall_pipeline_signal_decode_stage
);

reg[31:0] inst_for_execute_stage_reg;//pipeline reg
reg[31:0] rs1_reg_content_for_execute_stage_reg;//pipeline reg
reg[31:0] rs2_reg_content_for_execute_stage_reg;//pipeling reg
reg[31:0] inst_addr_for_execute_stage_reg;//

wire[6:0] inst_opcode_field_from_fetch_stage;
wire[4:0] inst_rd_field_from_fetch_stage;
wire[4:0] inst_rs1_field_from_fetch_stage;
wire[4:0] inst_rs2_field_from_fetch_stage;

wire[6:0] inst_opcode_field_from_execute_stage;
wire[4:0] inst_rd_field_from_execute_stage;
wire[4:0] inst_rs1_field_from_execute_stage;
wire[4:0] inst_rs2_field_from_execute_stage;

reg stall_pipeline_signal_decode_stage_reg;

assign inst_opcode_field_from_fetch_stage = inst_from_fetch_stage[6:0];
assign inst_rd_field_from_fetch_stage = inst_from_fetch_stage[11:7];
assign inst_rs1_field_from_fetch_stage = inst_from_fetch_stage[19:15];
assign inst_rs2_field_from_fetch_stage = inst_from_fetch_stage[24:20];

assign inst_opcode_field_from_execute_stage = inst_for_execute_stage_reg[6:0];
assign inst_rd_field_from_execute_stage = inst_for_execute_stage_reg[11:7];
assign inst_rs1_field_from_execute_stage = inst_for_execute_stage_reg[19:15];
assign inst_rs2_field_from_execute_stage = inst_for_execute_stage_reg[24:20];

//data hazard
//stall
//eg:
//lw  x2,0(x0)
//add x3,x2,x2
always @(*)begin
	if(inst_opcode_field_from_execute_stage == `LOAD_TYPE_INTEGER_INST_OPCODE && 
		(inst_rd_field_from_execute_stage == inst_rs1_field_from_fetch_stage || inst_rd_field_from_execute_stage == inst_rs2_field_from_fetch_stage))
	begin
		stall_pipeline_signal_decode_stage_reg = 1'b1;
	end
	else begin
		stall_pipeline_signal_decode_stage_reg = 1'b0;
	end
end

always @(posedge clk)begin
	if(rst == 1'b1 || stall_pipeline_signal_decode_stage_reg == 1'b1 || branch_signal_from_execute_stage == 1'b1)begin
		inst_for_execute_stage_reg <= `NOP_INSTRUCTION;
		rs1_reg_content_for_execute_stage_reg <= 0;
		rs2_reg_content_for_execute_stage_reg <= 0;
		inst_addr_for_execute_stage_reg <= 0;
	end
	else begin
		inst_for_execute_stage_reg <= inst_from_fetch_stage;
		rs1_reg_content_for_execute_stage_reg <= rs1_reg_content_from_regfile;
		rs2_reg_content_for_execute_stage_reg <= rs2_reg_content_from_regfile;
		inst_addr_for_execute_stage_reg <= inst_addr_from_fetch_stage;
	end
end


assign rs1_index = inst_from_fetch_stage[19:15];
assign rs2_index = inst_from_fetch_stage[24:20];
//extern wire
assign stall_pipeline_signal_decode_stage = stall_pipeline_signal_decode_stage_reg;
//pipeline register
assign inst_for_execute_stage = inst_for_execute_stage_reg;
assign inst_addr_for_execute_stage = inst_addr_for_execute_stage_reg;
assign rs1_reg_content_for_execute_stage = rs1_reg_content_for_execute_stage_reg;
assign rs2_reg_content_for_execute_stage = rs2_reg_content_for_execute_stage_reg;

endmodule
