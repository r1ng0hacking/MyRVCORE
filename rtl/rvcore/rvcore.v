`include "common.vh"

module rvcore(
		input			clk,
		input 			rst,
		input[31:0]		data,
		input[31:0]		inst,
		output[31:0] 	data_addr,
	  	output[31:0] 	inst_addr
);

wire[4:0] rs1_index;
wire[4:0] rs2_index;
wire[4:0] rd_index;

wire[4:0] rd_index_for_mem_stage;
wire[4:0] rd_index_for_writeback_stage;

wire[31:0] rd_reg_content;
wire[31:0] rs1_reg_content_for_decode_stage;
wire[31:0] rs2_reg_content_for_decode_stage;

wire[31:0] rs1_reg_content_for_execute_stage;
wire[31:0] rs2_reg_content_for_execute_stage;
wire[31:0] rd_reg_content_for_writeback_stage;

wire[31:0] alu_result_for_mem_stage;

wire[31:0] inst_for_decode_stage;
wire[31:0] inst_addr_for_decode_stage;
wire[31:0] inst_addr_for_execute_stage;
wire[31:0] inst_addr_for_mem_stage;
wire[31:0] inst_addr_for_writeback_stage;
wire[31:0] inst_for_execute_stage;
wire[31:0] inst_for_mem_stage;
wire[31:0] inst_for_writeback_stage;
wire[31:0] mem_write_address_for_mem_stage;
wire[31:0] mem_read_address_for_mem_stage;
wire[31:0] rs2_reg_content_for_mem_stage;

wire mem_write_signal_for_mem_stage;
wire mem_read_signal_for_mem_stage;

wire regfile_write_signal_for_mem_stage;
wire regfile_write_signal_for_writeback_stage;

wire stall_pipeline_signal_decode_stage;

wire branch_signal_execute_stage;
wire[31:0] branch_address_execute_stage;

regfile_unit regfile(
				  .clk(clk),
				  .rd_index(rd_index),
				  .rs1_index(rs1_index),
				  .rs2_index(rs2_index),
				  .rs1_reg_content(rs1_reg_content_for_decode_stage),
			      .rs2_reg_content(rs2_reg_content_for_decode_stage),
			      .rd_reg_content(rd_reg_content)
			 );

//fetch instruction
fetch_unit fetch(
				.clk(clk),
				.rst(rst),
				.inst_addr(inst_addr),
				.inst(inst),
				.inst_for_decode_stage(inst_for_decode_stage),
				.inst_addr_for_decode_stage(inst_addr_for_decode_stage),
				.stall_pipeline_signal_from_decode_stage(stall_pipeline_signal_decode_stage),
				.branch_signal_from_execute_stage(branch_signal_execute_stage),
				.branch_address_from_execute_stage(branch_address_execute_stage)
		 );

//decode instruction
decode_unit decode(
				.clk(clk),
		 		.rst(rst),
				.inst_from_fetch_stage(inst_for_decode_stage),
				.inst_for_execute_stage(inst_for_execute_stage),
				.inst_addr_from_fetch_stage(inst_addr_for_decode_stage),
				.inst_addr_for_execute_stage(inst_addr_for_execute_stage),
				.rs1_index(rs1_index),
				.rs2_index(rs2_index),
		   		.rs1_reg_content_from_regfile(rs1_reg_content_for_decode_stage),
		   		.rs2_reg_content_from_regfile(rs2_reg_content_for_decode_stage),
		   		.rs1_reg_content_for_execute_stage(rs1_reg_content_for_execute_stage),
		   		.rs2_reg_content_for_execute_stage(rs2_reg_content_for_execute_stage),
				.stall_pipeline_signal_decode_stage(stall_pipeline_signal_decode_stage),
				.branch_signal_from_execute_stage(branch_signal_execute_stage)
		);

//execute instruction
execute_unit execute(
				.clk(clk),
				.rst(rst),
				.inst_from_decode_stage(inst_for_execute_stage),
				.inst_for_mem_stage(inst_for_mem_stage),
				.inst_addr_for_mem_stage(inst_addr_for_mem_stage),
				.inst_addr_from_decode_stage(inst_addr_for_execute_stage),
				.rs1_reg_content_from_decode_stage(rs1_reg_content_for_execute_stage),
				.rs2_reg_content_from_decode_stage(rs2_reg_content_for_execute_stage),
				.rd_index_for_mem_stage(rd_index_for_mem_stage),
				.alu_result_for_mem_stage(alu_result_for_mem_stage),
				.mem_read_signal_for_mem_stage(mem_read_signal_for_mem_stage),
				.mem_write_signal_for_mem_stage(mem_write_signal_for_mem_stage),
				.regfile_write_signal_for_mem_stage(regfile_write_signal_for_mem_stage),
				.rd_index_from_writeback_stage(rd_index_for_writeback_stage),
				.rd_reg_content_from_writeback_stage(rd_reg_content_for_writeback_stage),
				.regfile_write_signal_from_writeback_stage(regfile_write_signal_for_writeback_stage),
				.mem_write_address_for_mem_stage(mem_write_address_for_mem_stage),
				.mem_read_address_for_mem_stage(mem_read_address_for_mem_stage),
				.rs2_reg_content_for_mem_stage(rs2_reg_content_for_mem_stage),
				.branch_signal_execute_stage(branch_signal_execute_stage),
				.branch_address_execute_stage(branch_address_execute_stage)
);


//memory access
mem_access_unit mem_access(
				.clk(clk),
				.rst(rst),
				.rd_index_from_execute_stage(rd_index_for_mem_stage),
				.inst_from_execute_stage(inst_for_mem_stage),
				.inst_addr_from_execute_stage(inst_addr_for_mem_stage),
				.inst_addr_for_writeback_stage(inst_addr_for_writeback_stage),
				.inst_for_writeback_stage(inst_for_writeback_stage),
				.rd_index_for_writeback_stage(rd_index_for_writeback_stage),
				.alu_result_from_execute_stage(alu_result_for_mem_stage),
				.rd_reg_content_for_writeback_stage(rd_reg_content_for_writeback_stage),
				.mem_write_signal_from_execute_stage(mem_write_signal_for_mem_stage),
				.mem_read_signal_from_execute_stage(mem_read_signal_for_mem_stage),
				.regfile_write_signal_from_execute_stage(regfile_write_signal_for_mem_stage),
				.regfile_write_signal_for_writeback_stage(regfile_write_signal_for_writeback_stage),
				.mem_write_address_from_execute_stage(mem_write_address_for_mem_stage),
				.mem_read_address_from_execute_stage(mem_read_address_for_mem_stage),
				.rs2_reg_content_from_execute_stage(rs2_reg_content_for_mem_stage)
);


//wirteback result
writeback_unit writeback(
				.clk(clk),
				.rst(rst),
				.inst_from_mem_stage(inst_for_writeback_stage),
				.inst_addr_from_mem_stage(inst_addr_for_writeback_stage),
				.rd_index_from_mem_stage(rd_index_for_writeback_stage),
				.rd_reg_content_from_mem_stage(rd_reg_content_for_writeback_stage),
				.rd_index(rd_index),
				.rd_reg_content(rd_reg_content),
				.regfile_write_signal_from_mem_stage(regfile_write_signal_for_writeback_stage)
);


endmodule
