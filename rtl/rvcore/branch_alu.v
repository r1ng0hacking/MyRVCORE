`include "common.vh"

module branch_alu(
		input[31:0] rs1_reg_content,
		input[31:0] rs2_reg_content,
		input[2:0] inst_funct3_field,
		output branch_signal
);

reg branch_signal_reg;

always@(*)begin
	case(inst_funct3_field)
		`B_TYPE_INTEGER_INST_FUNCT3_EQ:begin
			if(rs1_reg_content == rs2_reg_content)begin
				branch_signal_reg = 1'b1;
			end
			else begin
				branch_signal_reg = 1'b0;
			end
		end
		`B_TYPE_INTEGER_INST_FUNCT3_NE:begin
			if(rs1_reg_content != rs2_reg_content)begin
				branch_signal_reg = 1'b1;
			end
			else begin
				branch_signal_reg = 1'b0;
			end
		end
		`B_TYPE_INTEGER_INST_FUNCT3_LT:begin
			if( (~(rs1_reg_content[31]^rs2_reg_content[31]) && 
				(rs1_reg_content < rs2_reg_content)))
			begin
				branch_signal_reg = 1'b1;
			end
			else if(rs1_reg_content[31] == 1'b1 && rs2_reg_content[31] == 1'b0)begin
				branch_signal_reg = 1'b1;
			end
			else begin
				branch_signal_reg = 1'b0;
			end
		end
		`B_TYPE_INTEGER_INST_FUNCT3_GE:begin
			if( (~(rs1_reg_content[31]^rs2_reg_content[31]) && 
				(rs1_reg_content >= rs2_reg_content)))
			begin
				branch_signal_reg = 1'b1;
			end
			else if(rs1_reg_content[31] == 1'b0 && rs2_reg_content[31] == 1'b1)begin
				branch_signal_reg = 1'b1;
			end
			else begin
				branch_signal_reg = 1'b0;
			end
		end
		`B_TYPE_INTEGER_INST_FUNCT3_LTU:begin
			if(rs1_reg_content < rs2_reg_content)begin
				branch_signal_reg = 1'b1;
			end
			else begin
				branch_signal_reg = 1'b0;
			end
		end
		`B_TYPE_INTEGER_INST_FUNCT3_GEU:begin
			if(rs1_reg_content >= rs2_reg_content)begin
				branch_signal_reg = 1'b1;
			end
			else begin
				branch_signal_reg = 1'b0;
			end
		end
		default:begin
			branch_signal_reg = 1'b1;
		end
	endcase
end

assign branch_signal = branch_signal_reg;

endmodule
