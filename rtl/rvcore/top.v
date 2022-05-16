module top;

reg clk;
reg rst;

wire[31:0] data;
wire[31:0] data_addr;

wire[31:0] inst;
wire[31:0] inst_addr;

initial begin
	$fsdbDumpfile("rvcore.fsdb");
	$fsdbDumpvars(0);
end

rvcore rvcore(
		.clk(clk),
		.rst(rst),
		.data(data),
		.data_addr(data_addr),
		.inst(inst),
		.inst_addr(inst_addr)
);

imem imem(
		.inst_addr(inst_addr),
		.inst(inst)
);

initial begin
	clk = 0;
	rst = 1;
	#50 rst = 0;

	#10000 $finish;
end

always #25 clk  = ~ clk;

always @(posedge clk)begin
	if(rst != 1)begin
		`ifdef DEBUG_CPU_PIPELINE
		if(rvcore.mem_access.mem_read_signal_from_execute_stage == 1'b1)begin
			$display("%04t:IP 0x%08X read addr 0x%08X,content 0x%08X",$time,
															rvcore.mem_access.inst_addr_from_execute_stage,
															rvcore.mem_access.mem_read_address_from_execute_stage,
															rvcore.mem_access.rd_reg_content
			);
		end

		if(rvcore.mem_access.mem_write_signal_from_execute_stage == 1'b1)begin
			$display("%04t:IP 0x%08X write addr 0x%08X,content 0x%08X",$time,
															rvcore.mem_access.inst_addr_from_execute_stage,
															rvcore.mem_access.mem_write_address_from_execute_stage,
															rvcore.mem_access.rs2_reg_content_from_execute_stage
			);
		end

		if(rvcore.writeback.regfile_write_signal_from_mem_stage == 1'b1)begin
			$display("%04t:IP 0x%08X write x%02d register:%08d",$time,
										rvcore.writeback.inst_addr_from_mem_stage,
										rvcore.writeback.rd_index,
									  	rvcore.writeback.rd_reg_content);
		end
		`else
		`endif
	end
end

endmodule;
