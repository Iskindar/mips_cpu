`timescale 10 ns / 1 ns
`include "define.v"
module pc_target(
	input [5:0] opcode,
	input [5:0] r_opcode,
	input [31:0] RF_rdata1,
	input [31:0] pc_next,
	input [31:0] offset,
	input [31:0] instr_index,
	output [31:0] pc_target
);
	wire [31:0] pc_branch,pc_jump;
	
	alu alu_branch(.A(pc_next),
		.B({offset[29:0],2'b00}),
		.ALUop(3'b010),
		.Overflow(),
		.CarryOut(),
		.Zero(),
		.Result(pc_branch));
	
	assign pc_jump = (opcode == `JAL || opcode == `JJ)?{pc_next[31:28] ,instr_index[25:0] ,2'b00 }:0;
	assign pc_target = (opcode == `BNE || opcode == `BEQ)?pc_branch:
					   (opcode == `JJ || opcode == `JAL)?pc_jump:
					   RF_rdata1;
	
endmodule
