`include "common.vh"
//memory access
module mem_access_unit(
		input clk,
		input rst,
		input mem_write_signal_from_execute_stage,
		input mem_read_signal_from_execute_stage,
		input regfile_write_signal_from_execute_stage,
		input[4:0] rd_index_from_execute_stage,
		input[31:0] inst_from_execute_stage,
		input[31:0] inst_addr_from_execute_stage,
		input[31:0] alu_result_from_execute_stage,
		input[31:0] mem_write_address_from_execute_stage,
		input[31:0] mem_read_address_from_execute_stage,
		input[31:0] rs2_reg_content_from_execute_stage,
		output[31:0] inst_for_writeback_stage,
		output[31:0] inst_addr_for_writeback_stage,
		output[4:0] rd_index_for_writeback_stage,
		output[31:0] rd_reg_content_for_writeback_stage,
		output regfile_write_signal_for_writeback_stage
);

reg[31:0] inst_for_writeback_stage_reg;
reg[31:0] inst_addr_for_writeback_stage_reg;
reg[4:0] rd_index_for_writeback_stage_reg;
reg[31:0] rd_reg_content_for_writeback_stage_reg;
reg regfile_write_signal_for_writeback_stage_reg;

reg[2:0] width;
wire[31:0] address;
wire[2:0] inst_funct3_field;
wire[31:0] r_data;
wire[31:0] rd_reg_content;
reg[31:0] mem_read_data;

assign inst_funct3_field = inst_from_execute_stage[14:12];
assign address = mem_write_signal_from_execute_stage == 1'b1 ? mem_write_address_from_execute_stage :(mem_read_signal_from_execute_stage == 1'b1 ? mem_read_address_from_execute_stage : 32'd0);
assign rd_reg_content = mem_read_signal_from_execute_stage == 1'b1 ? mem_read_data : alu_result_from_execute_stage;

always@(*)begin
	case(inst_funct3_field)
		3'b000:begin
			width = 3'd1;
			mem_read_data = {{24{r_data[7]}},r_data[7:0]};
		end
		3'b001:begin
			width = 3'd2;
			mem_read_data = {{16{r_data[7]}},r_data[15:0]};
		end
		3'b010:begin
			width = 3'd4;
			mem_read_data = r_data;
		end
		3'b100:begin//lbu
			width = 3'd1;
			mem_read_data = r_data;
		end
		3'b101:begin//lhu
			width = 3'd2;
			mem_read_data = r_data;
		end
		default:begin
			width = 3'd1;
			mem_read_data = 32'd0;
		end
	endcase
end

dmem dmem(
		.clk(clk),
		.addr(address),
		.width(width),
		.we(mem_write_signal_from_execute_stage),
		.w_data(rs2_reg_content_from_execute_stage),
		.r_data(r_data)
);


always @(posedge clk)begin
	if(rst == 1'b1)begin
		inst_for_writeback_stage_reg <= `NOP_INSTRUCTION;
		inst_addr_for_writeback_stage_reg <= 32'd0;
		rd_index_for_writeback_stage_reg <= 5'd0;
		rd_reg_content_for_writeback_stage_reg <= 32'd0;
		regfile_write_signal_for_writeback_stage_reg <= 1'b0;
	end
	else begin
		inst_for_writeback_stage_reg <= inst_from_execute_stage;
		inst_addr_for_writeback_stage_reg <= inst_addr_from_execute_stage;
		rd_index_for_writeback_stage_reg <= rd_index_from_execute_stage;
		rd_reg_content_for_writeback_stage_reg <= rd_reg_content;
		regfile_write_signal_for_writeback_stage_reg <= regfile_write_signal_from_execute_stage;
	end
end

//pipeline register
assign inst_for_writeback_stage = inst_for_writeback_stage_reg;
assign inst_addr_for_writeback_stage = inst_addr_for_writeback_stage_reg;
assign rd_index_for_writeback_stage = rd_index_for_writeback_stage_reg;
assign rd_reg_content_for_writeback_stage = rd_reg_content_for_writeback_stage_reg;
assign regfile_write_signal_for_writeback_stage = regfile_write_signal_for_writeback_stage_reg;

endmodule
