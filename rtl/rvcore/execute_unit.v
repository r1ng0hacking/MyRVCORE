`include "common.vh"
//execute instruction
module execute_unit(
		input clk,
		input rst,
		input[31:0] inst_from_decode_stage,
		input[31:0] inst_addr_from_decode_stage,
		input[31:0] rs1_reg_content_from_decode_stage,
		input[31:0] rs2_reg_content_from_decode_stage,
		input[31:0] rd_reg_content_from_writeback_stage,
		input[4:0] rd_index_from_writeback_stage,
		input regfile_write_signal_from_writeback_stage,
		output[31:0] inst_for_mem_stage,
		output[31:0] alu_result_for_mem_stage,
		output[4:0] rd_index_for_mem_stage,
		output mem_write_signal_for_mem_stage,
		output mem_read_signal_for_mem_stage,
		output regfile_write_signal_for_mem_stage,
		output[31:0] mem_write_address_for_mem_stage,
		output[31:0] mem_read_address_for_mem_stage,
		output[31:0] rs2_reg_content_for_mem_stage,
		output[31:0] branch_address_execute_stage,
		output[31:0] inst_addr_for_mem_stage,
		output branch_signal_execute_stage
);

wire[6:0] inst_opcode_field;
wire[4:0] inst_rd_field;
wire[2:0] inst_funct3_field;
wire[4:0] inst_rs1_field;
wire[4:0] inst_rs2_field;
wire[6:0] inst_funct7_field;

wire[11:0] i_type_integer_inst_imm;
wire[11:0] s_type_integer_inst_imm;
wire[11:0] b_type_integer_inst_imm;
wire[19:0] u_type_integer_inst_imm;
wire[19:0] j_type_integer_inst_imm;

wire[31:0] alu_result_from_integer_alu;
reg[31:0] alu_result_reg;

wire regfile_write_signal_from_mem_stage;
wire[4:0] rd_index_from_mem_stage;
wire mem_read_signal_from_mem_stage;
wire mem_write_signal_from_mem_stage;
wire[31:0] rd_reg_content_from_mem_stage;

reg[31:0] alu_result_for_mem_stage_reg;
wire[31:0] u_type_integer_inst_adder_result;

reg[31:0] inst_for_mem_stage_reg;
reg[31:0] inst_addr_for_mem_stage_reg;

reg mem_read_signal_for_mem_stage_reg;
reg mem_read_signal;
reg mem_write_signal_for_mem_stage_reg;
reg mem_write_signal;
reg regfile_write_signal_for_mem_stage_reg;
reg regfile_write_signal;

reg[31:0] mem_write_address_for_mem_stage_reg;
wire[31:0] mem_write_address;

wire b_type_integer_inst_branch_signal;
reg b_type_integer_inst_branch_signal_reg;
reg j_type_integer_inst_branch_signal_reg;
reg i_type_integer_inst_branch_signal_reg;
wire[31:0] b_type_integer_inst_branch_address;
wire[31:0] j_type_integer_inst_branch_address;

reg[31:0] branch_address_reg;

wire[31:0] next_inst_addr;

reg[31:0] mem_read_address_for_mem_stage_reg;
wire[31:0] mem_read_address;

reg[4:0] rd_index_for_mem_stage_reg;

reg[31:0] rs2_reg_content_for_mem_stage_reg;

reg[31:0] rs1_reg_content;
reg[31:0] rs2_reg_content;

assign inst_opcode_field		= inst_from_decode_stage[6:0];
assign inst_rd_field 			= inst_from_decode_stage[11:7];
assign inst_funct3_field		= inst_from_decode_stage[14:12];
assign inst_rs1_field 			= inst_from_decode_stage[19:15];
assign inst_rs2_field 			= inst_from_decode_stage[24:20];
assign inst_funct7_field 		= inst_from_decode_stage[31:25];

assign i_type_integer_inst_imm = inst_from_decode_stage[31:20];

assign s_type_integer_inst_imm = {
							inst_from_decode_stage[31:25],
							inst_from_decode_stage[11:7]};

assign b_type_integer_inst_imm = {
					      	inst_from_decode_stage[31],
					      	inst_from_decode_stage[7],
					      	inst_from_decode_stage[30:25],
						  	inst_from_decode_stage[11:8]};

assign u_type_integer_inst_imm = inst_from_decode_stage[31:12];

assign j_type_integer_inst_imm = {
					      	inst_from_decode_stage[31],
					      	inst_from_decode_stage[19:12],
					      	inst_from_decode_stage[20],
						  	inst_from_decode_stage[30:21]};

//regfile write signal
always @(*)begin
	if(inst_opcode_field == `R_TYPE_INTEGER_INST_OPCODE ||
	   inst_opcode_field == `I_TYPE_INTEGER_INST_OPCODE ||
	   inst_opcode_field == `LOAD_TYPE_INTEGER_INST_OPCODE ||
	   inst_opcode_field == `J_TYPE_INTEGER_INST_OPCODE ||
	   inst_opcode_field == `I_TYPE_INTEGER_BRANCH_INST_OPCODE || 
	   inst_opcode_field == `U_TYPE_INTEGER_LUI_INST_OPCODE ||
	   inst_opcode_field == `U_TYPE_INTEGER_AUIPC_INST_OPCODE 
	)
	begin
		regfile_write_signal = 1'b1;
	end
	else begin
		regfile_write_signal = 1'b0;
	end
end
//mem access signal
always @(*)begin
	if(inst_opcode_field == `LOAD_TYPE_INTEGER_INST_OPCODE)begin
		mem_read_signal = 1'b1;
		mem_write_signal = 1'b0;
	end
	else if(inst_opcode_field == `S_TYPE_INTEGER_INST_OPCODE)begin
		mem_write_signal = 1'b1;
		mem_read_signal = 1'b0;
	end
	else begin
		mem_read_signal = 1'b0;
		mem_write_signal = 1'b0;
	end
end

//branch signal
//handle control hazard
branch_alu branch_alu(
		.rs1_reg_content(rs1_reg_content),
		.rs2_reg_content(rs2_reg_content),
		.inst_funct3_field(inst_funct3_field),
		.branch_signal(b_type_integer_inst_branch_signal)
);
always @(*)begin
	if(inst_opcode_field == `B_TYPE_INTEGER_INST_OPCODE && b_type_integer_inst_branch_signal == 1'b1)begin
		b_type_integer_inst_branch_signal_reg = 1'b1;
		j_type_integer_inst_branch_signal_reg = 1'b0;
		i_type_integer_inst_branch_signal_reg = 1'b0;
		branch_address_reg = b_type_integer_inst_branch_address;
	end
	else if(inst_opcode_field == `J_TYPE_INTEGER_INST_OPCODE)begin
		b_type_integer_inst_branch_signal_reg = 1'b0;
		j_type_integer_inst_branch_signal_reg = 1'b1;
		i_type_integer_inst_branch_signal_reg = 1'b0;
		branch_address_reg = j_type_integer_inst_branch_address;
	end
	else if(inst_opcode_field == `I_TYPE_INTEGER_BRANCH_INST_OPCODE)begin
		b_type_integer_inst_branch_signal_reg = 1'b0;
		j_type_integer_inst_branch_signal_reg = 1'b0;
		i_type_integer_inst_branch_signal_reg = 1'b1;
		branch_address_reg = alu_result_from_integer_alu;
	end
	else begin
		b_type_integer_inst_branch_signal_reg = 1'b0;
		j_type_integer_inst_branch_signal_reg = 1'b0;
		i_type_integer_inst_branch_signal_reg = 1'b0;
		branch_address_reg = 32'd0;
	end
end

//handle data hazard
always @(*)begin
	//forwarding
	//mem stage => execute stage
	//eg:
	//addi x2,x0,7
	//
	//
	//writeback stage => execute stage
	//eg:
	//addi x2,x0,7
	//addi x3,x0,7
	//add  x4,x2,x2
	//add  x3,x2,x2
	//
	if(regfile_write_signal_from_mem_stage == 1'b1 &&
		mem_read_signal_from_mem_stage == 1'b0 &&
		mem_write_signal_from_mem_stage == 1'b0 &&
		inst_rs1_field == rd_index_from_mem_stage &&
		inst_rs1_field != 5'd0)
	begin//forwarding
		rs1_reg_content = rd_reg_content_from_mem_stage;
	end
	else if(regfile_write_signal_from_writeback_stage == 1'b1 &&
			inst_rs1_field == rd_index_from_writeback_stage &&
			inst_rs1_field != 5'd0)
	begin//forwarding
		rs1_reg_content = rd_reg_content_from_writeback_stage;
	end
	else begin//forwarding
		rs1_reg_content = rs1_reg_content_from_decode_stage;
	end
	
	if(regfile_write_signal_from_mem_stage == 1'b1 &&
		mem_read_signal_from_mem_stage == 1'b0 &&
		mem_write_signal_from_mem_stage == 1'b0 &&
		inst_rs2_field == rd_index_from_mem_stage &&
		inst_rs2_field != 5'd0)
	begin//forwarding
		rs2_reg_content = rd_reg_content_from_mem_stage;
	end
	else if(regfile_write_signal_from_writeback_stage == 1'b1 &&
			inst_rs2_field == rd_index_from_writeback_stage &&
			inst_rs2_field != 5'd0)
	begin//forwarding
		rs2_reg_content = rd_reg_content_from_writeback_stage;
	end
	else begin//forwarding
		rs2_reg_content = rs2_reg_content_from_decode_stage;
	end
end

adder mem_write_address_adder(
		.a(rs1_reg_content),
		.b({{20{s_type_integer_inst_imm[11]}},s_type_integer_inst_imm}),
		.result(mem_write_address)
);

adder mem_read_address_adder(
	.a(rs1_reg_content),
	.b({{20{i_type_integer_inst_imm[11]}},i_type_integer_inst_imm}),
	.result(mem_read_address)
);

adder b_type_integer_inst_branch_address_adder(
	.a(inst_addr_from_decode_stage),
	.b({{19{b_type_integer_inst_imm[11]}},b_type_integer_inst_imm,1'b0}),
	.result(b_type_integer_inst_branch_address)
);

adder j_type_integer_inst_branch_address_adder(
	.a(inst_addr_from_decode_stage),
	.b({{11{j_type_integer_inst_imm[19]}},j_type_integer_inst_imm,1'b0}),
	.result(j_type_integer_inst_branch_address)
);

adder next_inst_addr_adder(
	.a(inst_addr_from_decode_stage),
	.b(32'd4),
	.result(next_inst_addr)
);

adder u_type_integer_inst_adder(
	.a(inst_opcode_field == `U_TYPE_INTEGER_AUIPC_INST_OPCODE ? inst_addr_from_decode_stage : 32'd0),
	.b({u_type_integer_inst_imm,12'b0}),
	.result(u_type_integer_inst_adder_result)
);

integer_alu_unit integer_alu(
					.rs1_reg_content(rs1_reg_content),
					.rs2_reg_content(rs2_reg_content),
					.i_type_integer_inst_imm_extend({{20{i_type_integer_inst_imm[11]}},i_type_integer_inst_imm}),
					.inst_opcode_field(inst_opcode_field),
					.inst_funct3_field(inst_funct3_field),
					.inst_funct7_field(inst_funct7_field),
					.alu_result(alu_result_from_integer_alu)
);

//calc alu_result
always @(*)begin
	if(inst_opcode_field == `J_TYPE_INTEGER_INST_OPCODE)begin
		alu_result_reg = next_inst_addr; 
	end
	else if(inst_opcode_field == `I_TYPE_INTEGER_BRANCH_INST_OPCODE)begin
		alu_result_reg = next_inst_addr; 
	end
	else if(inst_opcode_field == `U_TYPE_INTEGER_LUI_INST_OPCODE)begin
		alu_result_reg = u_type_integer_inst_adder_result; 
	end
	else if(inst_opcode_field == `U_TYPE_INTEGER_AUIPC_INST_OPCODE)begin
		alu_result_reg = u_type_integer_inst_adder_result; 
	end
	else begin
		alu_result_reg = alu_result_from_integer_alu;
	end
end

always @(posedge clk)begin
	if(rst == 1'b1)begin
		inst_for_mem_stage_reg <= `NOP_INSTRUCTION;
		alu_result_for_mem_stage_reg <= 32'd0;
		rd_index_for_mem_stage_reg <= 5'd0;
		mem_read_signal_for_mem_stage_reg <= 1'b0;
		mem_write_signal_for_mem_stage_reg <= 1'b0;
		regfile_write_signal_for_mem_stage_reg <= 1'b0;
		mem_write_address_for_mem_stage_reg <= 32'd0;
		mem_read_address_for_mem_stage_reg <= 32'd0;
		rs2_reg_content_for_mem_stage_reg <= 32'd0;
		inst_addr_for_mem_stage_reg <=32'd0;
	end
	else begin 
		inst_for_mem_stage_reg <= inst_from_decode_stage;
		alu_result_for_mem_stage_reg <= alu_result_reg;
		rd_index_for_mem_stage_reg <= inst_rd_field;
		mem_read_signal_for_mem_stage_reg <= mem_read_signal;
		mem_write_signal_for_mem_stage_reg <= mem_write_signal;
		regfile_write_signal_for_mem_stage_reg <= regfile_write_signal;
		mem_write_address_for_mem_stage_reg <= mem_write_address;
		mem_read_address_for_mem_stage_reg <= mem_read_address;
		rs2_reg_content_for_mem_stage_reg <= rs2_reg_content;
		inst_addr_for_mem_stage_reg <= inst_addr_from_decode_stage;
	end
end

//internal wire

assign regfile_write_signal_from_mem_stage = regfile_write_signal_for_mem_stage_reg;
assign rd_index_from_mem_stage = rd_index_for_mem_stage_reg;
assign mem_read_signal_from_mem_stage = mem_read_signal_for_mem_stage_reg;
assign mem_write_signal_from_mem_stage = mem_write_signal_for_mem_stage_reg;
assign rd_reg_content_from_mem_stage = alu_result_for_mem_stage_reg;

//external wire
assign branch_signal_execute_stage = b_type_integer_inst_branch_signal_reg | 
									 j_type_integer_inst_branch_signal_reg |
									 i_type_integer_inst_branch_signal_reg;
assign branch_address_execute_stage = branch_address_reg;

//pipeline register
assign inst_for_mem_stage = inst_for_mem_stage_reg;
assign alu_result_for_mem_stage = alu_result_for_mem_stage_reg;
assign rd_index_for_mem_stage = rd_index_for_mem_stage_reg;
assign mem_read_signal_for_mem_stage = mem_read_signal_for_mem_stage_reg;
assign mem_write_signal_for_mem_stage = mem_write_signal_for_mem_stage_reg;
assign regfile_write_signal_for_mem_stage = regfile_write_signal_for_mem_stage_reg;
assign mem_write_address_for_mem_stage = mem_write_address_for_mem_stage_reg;
assign mem_read_address_for_mem_stage = mem_read_address_for_mem_stage_reg;
assign rs2_reg_content_for_mem_stage = rs2_reg_content_for_mem_stage_reg;
assign inst_addr_for_mem_stage = inst_addr_for_mem_stage_reg;
endmodule
