`timescale 10 ns / 1 ns

`define DATA_WIDTH 32
`define AND 3'b000
`define  OR 3'b001
`define ADD 3'b010
`define SUB 3'b110
`define SLT 3'b111
`define MIN 32'h80000000
module alu(
	input [`DATA_WIDTH - 1:0] A,
	input [`DATA_WIDTH - 1:0] B,
	input [2:0] ALUop,
	output Overflow,
	output CarryOut,
	output Zero,
	output [`DATA_WIDTH - 1:0] Result
);

	// TODO: Please add your logic code here
	wire [`DATA_WIDTH:0] complete_result; //result with carry
	wire [`DATA_WIDTH-1:0] b_comp; //complement of b
	wire [`DATA_WIDTH-1:0] middle_result; //store the result when adding and subtracting

	assign b_comp = (ALUop==`SUB || ALUop==`SLT)? ~B + 32'b1:B; // A - B = A + b_comp
	assign complete_result = A + b_comp; 
	assign middle_result = A + b_comp;

	assign Overflow =(B==0)?1'b0:(ALUop==`SUB && B==`MIN)?(A[31]^1):(ALUop==`SUB && A==`MIN)?B[31]^1:(A[31]^ ~b_comp[31])&(A[31]^middle_result[31]);
	
	assign slt_result = (ALUop!=`SLT)? 1'b0:(b_comp==`MIN)? 1'b0:(A==`MIN)?1'b1:(middle_result[31]^Overflow);
	assign Result = (ALUop==`AND)?(A&B):(ALUop==`OR)?(A|B):(ALUop==`ADD || ALUop==`SUB)?middle_result:(ALUop==`SLT)?slt_result:1'b0;
	assign Zero = (Result==0)?1:0;
	assign CarryOut = (A==32'b0&&ALUop==`SUB &&B!=32'b0)?1'b1:(ALUop==`ADD)?complete_result[32]:(ALUop==`SUB && b_comp!=32'b0)?~complete_result[32]:1'b0;
endmodule
