`timescale 10 ns / 1 ns
`include "define.v"

module Control (
	input [5:0] opcode,
	input [5:0] r_opcode,
	output RegDst,//寄存器目的地址，为1则目的地址为current_Instruction[15:11]
	output [2:0] Branch,//Branch[2]是不是分支，Branch[1]是不是条件分支，Branch[0]是不是Zero为1是跳转
	output MemRead_tmp,//内存读使能
	output mr,//为1代表读ALU result中的地址，为0代表读地址为pc_next
	output MemtoReg,//1代表WB阶段由内存写入寄存器，0代表alu result写入寄存器
	output [2:0] ALUOp,//ALU的操作码
	output MemWrite,//内存写使能
	output [1:0] ALUSrc,//00代表寄存器读2,01代表指令低16位的有符号扩展，11代表指令低16位左移16位，10代表sll读2左移sa位
	output RegWrite,//是否需要写回寄存器;
	output [3:0] Write_strb
);
	assign RegWrite = (opcode == `BNE 
			|| opcode == `BEQ
			|| opcode == `SW 
			|| opcode == `JJ 
			||(r_opcode == `JR && opcode==`SPECIAL))?1'b0:1'b1;

	assign RegDst = (opcode == `SPECIAL)?1'b1:1'b0;

	assign MemtoReg = (opcode == `LW)?1'b1:1'b0;
	assign ALUSrc = (opcode == `ADDIU || opcode == `LW || opcode == `SW || opcode == `SLTI || opcode == `SLTIU)?2'b01:
			(opcode == `LUI)?2'b11:
			(r_opcode == `SLL)?3'b010:2'b00;
	assign ALUOp = (opcode == `LUI || ( opcode==`SPECIAL && r_opcode == `SLL) || (opcode==`SPECIAL && r_opcode == `OR) )?3'b001:
				   (opcode == `ADDIU || opcode == `SW || opcode == `LW || (opcode==`SPECIAL && r_opcode == `ADDU))?3'b010:
				   (opcode == `BNE || opcode == `BEQ || opcode == `SLTIU)?3'b110:
				   (opcode == `SLTI || (opcode ==`SPECIAL && r_opcode == `SLT))?3'b111:3'b000;
	assign MemRead_tmp = (opcode == `LW)?1'b1:1'b0;
	assign mr = 1'b0;
	assign MemWrite = (opcode == `SW)?1'b1:1'b0;
	assign Branch = (opcode == `BNE)?3'b110:
			(opcode == `BEQ)?3'b111:
			(opcode == `JJ || opcode ==`JAL)?3'b100:
			(r_opcode == `JR && opcode==`SPECIAL)?3'b100:
			3'b000;
	assign Write_strb = 4'b1111;
endmodule

