`timescale 10ns / 1ns
`define ADDIU 6'b001001
`define BNE 6'b000101
`define LW 6'b100011
`define SW 6'b101011
`define SPECIAL 000000
`define SLL 000000
`define ADDU 100001
`define BEQ 000100
`define JJ 000010
`define	JAL 000011
`define JR 001000
`define LUI 001111
`define OR 100101
`define SLT 101010
`define SLTI 001010
`define SLTIU `001011

module mips_cpu(
	input  rst,
	input  clk,

	output reg [31:0] PC,
	input  [31:0] Instruction,

	output [31:0] Address,
	output MemWrite,
	output [31:0] Write_data,
	output [3:0] Write_strb,

	input  [31:0] Read_data,
	output MemRead
);

	// THESE THREE SIGNALS ARE USED IN OUR TESTBENCH
	// PLEASE DO NOT MODIFY SIGNAL NAMES
	// AND PLEASE USE THEM TO CONNECT PORTS
	// OF YOUR INSTANTIATION OF THE REGISTER FILE MODULE
	wire			RF_wen;
	wire [4:0]		RF_waddr;
	wire [31:0]		RF_wdata;

	// TODO: PLEASE ADD YOUT CODE BELO
	wire signed[31:0] pc_next,pc_next_next,pc_tmp,pc_target;
	wire [2:0] ALUop;
	wire [4:0] RF_raddr1,RF_raddr2;
	wire [5:0] opcode,r_opcode;
	wire [31:0] current_Instruction,delay_slot;
	wire [31:0] imm_or_offset,RF_rdata1,RF_rdata2,ALU_data1,ALU_data2;
	wire [31:0] Result;
	wire RegDst,MemtoReg,is_jump,need_delayslot,is_delayslot,MemRead_tmp;
	wire Overflow,CarryOut,Zero;
	wire [1:0] ALUSrc;
	wire [2:0] Branch;

	//IF
	
	//ID
	assign is_delayslot = (need_delayslot == 1'b1)?1'b1:
						  1'b0;
	assign current_Instruction = (is_delayslot == 1'b0)?Instruction:
								 delay_slot; 
	assign opcode = current_Instruction[31:26];
	assign r_opcode = current_Instruction[5:0];
	Control control(.opcode(opcode),.r_opcode(r_opcode),
					.RegDst(RegDst),.Branch(Branch),.MemRead_tmp(MemRead_tmp),
					.MemtoReg(MemtoReg),.ALUOp(ALUop),.MemWrite(MemWrite),
					.ALUSrc(ALUSrc),.RegWrite(RF_wen),.Write_strb(Write_strb));
	assign RF_raddr1 = current_Instruction[25:21];
	assign RF_raddr2 = current_Instruction[20:16];
	assign RF_waddr = (opcode == `JAL)?5'b11111:
					  (RegDst==1)?current_Instruction[15:11]:
					  current_Instruction[20:16];
	
	assign imm_or_offset = (current_Instruction[15] == 1'b0)?{16'b0,current_Instruction[15:0]}:
					   {16'hffff,current_Instruction[15:0]};
	reg_file reg_read_and_write(.clk(clk),.rst(rst),.waddr(RF_waddr),.raddr1(RF_raddr1),.raddr2(RF_raddr2),
								.wen(RF_wen),.wdata(RF_wdata),.rdata1(RF_rdata1),.rdata2(RF_rdata2));
	
	//EX
	assign ALU_data1 = RF_rdata1;
	assign ALU_data2 = (ALUSrc == 2'b00)?RF_rdata2:
					   (ALUSrc == 2'b01)?imm_or_offset:
					   (ALUSrc == 2'b11)?{current_Instruction[15:0],16'b0}:
					   RF_rdata2<<current_Instruction[10:6];

	alu alu(.A(ALU_data1),.B(ALU_data2),.ALUop(ALUop),.Overflow(Overflow),
		    .CarryOut(CarryOut),.Zero(Zero),.Result(Result));
	//MEM
	MemRead = (MemRead_tmp == 1'b1)?1'b1:
			  (need_delayslot == 1'b1)?1'b1:
			  1'b0;
	assign Address = (need_delayslot == 1'b1)?pc_next:
					 Result;
	assign Write_data = RF_rdata2;
	assign delay_slot = Read_data;

	//WB
	assign RF_wdata = (opcode == `SLTIU)?CarryOut:
					  (opcode == `JAL)?pc_next_next:
					  (MemtoReg==1)?Read_data:Result;
	//PC	
	alu alu_pc(.A(PC),.B(32'b100),.ALUop(3'b010),.Overflow(),
		    .CarryOut(),.Zero(),.Result(pc_next));
	alu alu_pc2(.A(PC),.B(32'b1000),.ALUop(3'b010),.Overflow(),
		    .CarryOut(),.Zero(),.Result(pc_next_next));
	pc_target pc_target(.opcode(opcode),.r_opcode(r_opcode),.RF_rdata1(RF_rdata1),
	                    .pc_next(pc_next),.offset(imm_or_offset),
						.instr_index(current_Instruction[25:0]),.pc_target(pc_target));
	assign is_jump = (Branch == 3'b100)?1'b1:
					 (Branch == 3'b111 && Zero == 1'b1)?1'b1:
					 (Branch == 3'b110 && Zero == 1'b0)?1'b1:
					 1'b0;
	assign need_delayslot = is_jump;
	assign pc_tmp = (is_jump == 1'b1):pc_target:pc_next;
	always @(posedge clk or posedge rst)
	begin
		if (rst)
			PC <= 32'b0;
		else
			PC <= pc_tmp;
	end
endmodule

module Control (
	input [5:0] opcode,
	input [5:0] r_opcode,
	output RegDst,//寄存器目的地址，为1则目的地址为current_Instruction[15:11]
	output [2:0] Branch,//Branch[2]是不是分支，Branch[1]是不是条件分支，Branch[0]是不是Zero为1是跳转
	output MemRead,//内存读使能
	output mr,//为1代表读ALU result中的地址，为0代表读地址为pc_next
	output MemtoReg,//1代表WB阶段由内存写入寄存器，0代表alu result写入寄存器
	output [2:0] ALUOp,//ALU的操作码
	output MemWrite_tmp,//内存写使能
	output [1:0] ALUSrc,//00代表寄存器读2,01代表指令低16位的有符号扩展，11代表指令低16位左移16位，10代表sll读2左移sa位
	output RegWrite,//是否需要写回寄存器
	output [3:0] Write_strb，
);
	assign RegWrite = (opcode == `BNE || opcode == `BEQ|| opcode == `SW)?1'b0:
					  (opcode == `JJ)?1'b0:
					  (r_opcode == `JR)?1'b0:
					  1'b1;
	assign RegDst = (opcode == `SPECIAL)?1'b1:
					1'b0;
	assign MemtoReg = (opcode == `LW)?1'b1:
					  (need_delayslot == 1'b1)?1'b1:
					  1'b0;
	assign ALUSrc = (opcode == `ADDIU || opcode == `LW || opcode == `SW ||
					 opcode == `SLTI || opode == `SLTIU)?2'b01:
					(opcode == `LUI)?2'b11:
					(r_opcode == `SLL)?2'b10:
					2'b00;
	assign ALUOp = (opcode == `LUI || r_opcode == `SLL || r_opcode == `OR )?3'b001:
				   (opcode == `ADDIU || opcode == `SW || opcode == `LW || r_opcode == `ADDU)?3'b010:
				   (opcode == `BNE || opcode == `BEQ || opcode == `SLTIU)?3'b110:
				   (opcode == `SLTI || r_opcode == `SLT)?3'b111:
				   3'b000;
	assign MemRead_tmp = (opcode == `LW)?1'b1:
					 1'b0;
	assign mr = (opcode ==)
	assign MemWrite = (opcode == `SW)?1'b1:
					  1'b0;
	assign Branch = (opcode == `BNE)?3'b110:
					(opcode == `BEQ)?3'b111:
				    (opcode == `JJ || opcode ==`JAL)?3'b100:
					3'b000;
	assign Write_strb = 4'b1111;
endmodule

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
	alu alu_branch(.A(pc_next),.B({offset[29,0],2'b00}),.ALUop(3'b010),.Overflow(),
		    .CarryOut(),.Zero(),.Result(pc_branch));
	assign pc_jump = {pc_next[31:28],instr_index[25:0],2'b00};
	assign pc_target = (opcode == `BNE || opcode == `BEQ)?pc_branch:
					   (opcode == `JJ || opcode == `JAL)?pc_jump:
					   RF_rdata1;
	
endmodule
