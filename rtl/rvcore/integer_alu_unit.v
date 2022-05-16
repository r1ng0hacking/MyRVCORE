`include "common.vh"

module integer_alu_unit(
		input[31:0] rs1_reg_content,
		input[31:0] rs2_reg_content,
		input[31:0] i_type_integer_inst_imm_extend,
		input[6:0]  inst_opcode_field,
		input[2:0]  inst_funct3_field,
		input[6:0]  inst_funct7_field,
		output[31:0] alu_result
);

reg[31:0] alu_result_reg;

wire[31:0] rs1;
wire[31:0] rs2;

assign rs1 = rs1_reg_content;
assign rs2 = inst_opcode_field == `R_TYPE_INTEGER_INST_OPCODE ? rs2_reg_content : i_type_integer_inst_imm_extend;

always @(*)begin
	case(inst_funct3_field)
			`R_I_TYPE_INTEGER_INST_FUNCT3_ADD:begin
				if(inst_opcode_field == `R_TYPE_INTEGER_INST_OPCODE && inst_funct7_field)begin
					alu_result_reg = rs1 - rs2;
				end
				else begin
					alu_result_reg = rs1 + rs2;
				end
			end
			`R_I_TYPE_INTEGER_INST_FUNCT3_SLL:begin
				alu_result_reg = rs1 << (rs2 & 32'h0x1F);
			end
			`R_I_TYPE_INTEGER_INST_FUNCT3_SLT:begin
				
				if(~(rs1[31] ^ rs2[31]))begin
					alu_result_reg = rs1 < rs2;
				end
				else if(rs1[31] == 1'b1 && rs2[31] == 1'b0)begin
					alu_result_reg = 32'd1;
				end
				else begin
					alu_result_reg = 32'd0;
				end

			end
			`R_I_TYPE_INTEGER_INST_FUNCT3_SLTU:begin
				alu_result_reg = rs1 < rs2;
			end
			`R_I_TYPE_INTEGER_INST_FUNCT3_SRL:begin
				if(inst_opcode_field == `R_TYPE_INTEGER_INST_OPCODE && inst_funct7_field)begin//sra
					alu_result_reg = rs1 >>> (rs2 & 32'h0x1F);
				end
				else begin
					alu_result_reg = rs1 >> (rs2 & 32'h0x1f);
				end
			end
			`R_I_TYPE_INTEGER_INST_FUNCT3_XOR:begin
				alu_result_reg = rs1 ^ rs2;
			end
			`R_I_TYPE_INTEGER_INST_FUNCT3_OR:begin
				alu_result_reg = rs1 | rs2;
			end
			`R_I_TYPE_INTEGER_INST_FUNCT3_AND:begin
				alu_result_reg = rs1 & rs2;
			end
			default:begin
				alu_result_reg = 32'd0;
			end
	endcase
end

assign alu_result = alu_result_reg;

endmodule
