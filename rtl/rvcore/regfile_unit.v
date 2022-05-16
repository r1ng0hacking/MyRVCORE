//regfile
module regfile_unit(
		input clk,
		input[4:0] rd_index,
		input[4:0] rs1_index,
		input[4:0] rs2_index,
		input[31:0] rd_reg_content,
		output[31:0] rs1_reg_content,
		output[31:0] rs2_reg_content
);

reg[31:0] rf[31:0];

always @(posedge clk)begin
	if(rd_index != 5'd0 )begin
		rf[rd_index] <= rd_reg_content;
	end
end

assign rs1_reg_content = rs1_index == 5'd0 ? 32'd0 : (rs1_index == rd_index ? rd_reg_content : rf[rs1_index]);
assign rs2_reg_content = rs2_index == 5'd0 ? 32'd0 : (rs2_index == rd_index ? rd_reg_content : rf[rs2_index]);

endmodule
