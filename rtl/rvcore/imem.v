`define IMEM_SIZE 1024*1024
`define IMEM_SIZE_MASK (`IMEM_SIZE-1)
module imem(
		input[31:0] inst_addr,
		output[31:0] inst
);

reg[7:0] inst_mem[1024:0];

initial begin
	$readmemh("data/imemfile.dat",inst_mem);
end

assign inst[7:0] = inst_mem[`IMEM_SIZE_MASK&(inst_addr+32'd0)];
assign inst[15:8] = inst_mem[`IMEM_SIZE_MASK&(inst_addr+32'd1)];
assign inst[23:16] = inst_mem[`IMEM_SIZE_MASK&(inst_addr+32'd2)];
assign inst[31:24] = inst_mem[`IMEM_SIZE_MASK&(inst_addr+32'd3)];

endmodule
