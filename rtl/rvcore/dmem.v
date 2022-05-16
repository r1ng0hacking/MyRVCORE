`define MEM_SIZE 		1024*1024
`define MEM_SIZE_MASK	(`MEM_SIZE - 1)
module dmem(
		input clk,
		input[2:0] width,
		input we,
		input[31:0] addr,
		input[31:0] w_data,
		output[31:0] r_data
);

reg[31:0] r_data_reg;

reg[7:0] mem[`MEM_SIZE:0];

always @(posedge clk)begin
	if(we)begin
		case(width)
			3'd1:begin
				mem[(addr+0)&`MEM_SIZE_MASK] <= w_data[7:0];
			end
			3'd2:begin
				mem[(addr+0)&`MEM_SIZE_MASK] <= w_data[7:0];
				mem[(addr+1)&`MEM_SIZE_MASK] <= w_data[15:8];
			end
			3'd4:begin
				mem[(addr+0)&`MEM_SIZE_MASK] <= w_data[7:0];
				mem[(addr+1)&`MEM_SIZE_MASK] <= w_data[15:8];
				mem[(addr+2)&`MEM_SIZE_MASK] <= w_data[23:16];
				mem[(addr+3)&`MEM_SIZE_MASK] <= w_data[31:24];
			end
		endcase
	end
end

always @(*)begin
	case(width)
		3'd1:begin
			r_data_reg[7:0] =   mem[(addr+0)&`MEM_SIZE_MASK];
			r_data_reg[31:8] = 0;
		end
		3'd2:begin
			r_data_reg[7:0] =   mem[(addr+0)&`MEM_SIZE_MASK];
			r_data_reg[15:8] =  mem[(addr+1)&`MEM_SIZE_MASK];
			r_data_reg[31:16] = 0;
		end
		3'd4:begin
			r_data_reg[7:0] =   mem[(addr+0)&`MEM_SIZE_MASK];
			r_data_reg[15:8] =  mem[(addr+1)&`MEM_SIZE_MASK];
			r_data_reg[23:16] = mem[(addr+2)&`MEM_SIZE_MASK];
			r_data_reg[31:24] = mem[(addr+3)&`MEM_SIZE_MASK];
		end
		default:begin
			r_data_reg = 32'd0;
		end
	endcase
end

assign r_data = r_data_reg;

endmodule
