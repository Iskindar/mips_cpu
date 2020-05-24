`timescale 10ns / 1ns
`include "define.v"

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
	wire [31:0] imm_or_offset,RF_rdata1,RF_rdata2,ALU_data1,ALU_data2;
	wire [31:0] Result;
	wire RegDst,MemtoReg,is_jump,MemRead_tmp;
	wire Overflow,CarryOut,Zero;
	wire [1:0] ALUSrc;
	wire [2:0] Branch;

	//IF
	
	//ID
	
	assign opcode = Instruction[31:26];
	assign r_opcode = Instruction[5:0];
	Control control(.opcode(opcode),.r_opcode(r_opcode),
					.RegDst(RegDst),.Branch(Branch),.MemRead_tmp(MemRead_tmp),
					.MemtoReg(MemtoReg),.ALUOp(ALUop),.MemWrite(MemWrite),
					.ALUSrc(ALUSrc),.RegWrite(RF_wen),.Write_strb(Write_strb));
	assign RF_raddr1 = Instruction[25:21];
	assign RF_raddr2 = Instruction[20:16];
	assign RF_waddr = (opcode == `JAL)?5'b11111:
					  (RegDst==1)?Instruction[15:11]:Instruction[20:16];
	
	assign imm_or_offset = (Instruction[15] == 1'b0)?{16'b0,Instruction[15:0]}:
					   {16'hffff,Instruction[15:0]};
	reg_file reg_read_and_write(.clk(clk),.rst(rst),.waddr(RF_waddr),.raddr1(RF_raddr1),.raddr2(RF_raddr2),
								.wen(RF_wen),.wdata(RF_wdata),.rdata1(RF_rdata1),.rdata2(RF_rdata2));
	
	//EX
	assign ALU_data1 = RF_rdata1;
	assign ALU_data2 = (ALUSrc == 2'b00)?RF_rdata2:
					   (ALUSrc == 2'b01)?imm_or_offset:
					   (ALUSrc == 2'b11)?{Instruction[15:0],16'b0}:
					   RF_rdata2<<Instruction[10:6];

	alu alu(.A(ALU_data1),.B(ALU_data2),.ALUop(ALUop),.Overflow(Overflow),
		    .CarryOut(CarryOut),.Zero(Zero),.Result(Result));
	//MEM
	assign MemRead = (MemRead_tmp == 1'b1)? 1'b1:1'b0;
	assign Address = Result;
	assign Write_data = RF_rdata2;
	

	//WB
	assign RF_wdata = (opcode == `SLTIU)?CarryOut:
			(opcode ==`JAL)?pc_next_next:
			(MemtoReg)?Read_data:Result;

	//PC	
	alu alu_pc(.A(PC),.B(32'b100),.ALUop(3'b010),.Overflow(),
		    .CarryOut(),.Zero(),.Result(pc_next));
	alu alu_pc2(.A(PC),.B(32'b1000),.ALUop(3'b010),.Overflow(),
		    .CarryOut(),.Zero(),.Result(pc_next_next));
	pc_target pc_target1(.opcode(opcode),.r_opcode(r_opcode),.RF_rdata1(RF_rdata1),
	                    .pc_next(pc_next),.offset(imm_or_offset),
						.instr_index(Instruction[25:0]),.pc_target(pc_target));
	assign is_jump = (Branch == 3'b100)?1'b1:
					 (Branch == 3'b111 && Zero == 1'b1)?1'b1:
					 (Branch == 3'b110 && Zero == 1'b0)?1'b1:
					 1'b0;
	
	assign pc_tmp = (is_jump == 1'b1)?pc_target:pc_next;
	always @(posedge clk or posedge rst)
	begin
		if (rst)
			PC <= 32'b0;
		else
			PC <= pc_tmp;
	end
endmodule

