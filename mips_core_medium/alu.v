`timescale 10 ns / 1 ns

`define DATA_WIDTH 32


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

	assign b_comp =( (ALUop==3'b110 || ALUop==3'b111)&(b_comp!=32'b0)) ? ~B + 32'b1:B; // A - B = A + b_comp
	assign complete_result = A + b_comp; 
	assign middle_result = A + b_comp;
	
	//assign Overflow =(A[30:0]!=0 && b_comp[30:0]!=0)?(A[31]^~b_comp[31])&(A[31]^middle_result[31]):1'b0;
	assign Overflow = (ALUop==3'b111 || ALUop==3'b110)?((B==32'h8000000)?(A[31]^1):
				((A[31]^middle_result[31])&(b_comp[31]^middle_result[31]))):(ALUop==3'b010)?
				((A[31]^middle_result[31])&(B[31]^middle_result[31])):1'b0;
	assign slt_result = (ALUop==3'b111)?((B==32'h80000000)?1'b0:(middle_result[31]^Overflow)):1'b0;
	
	assign Result = (ALUop==3'b000)?(A&B):(ALUop==3'b001)?(A|B):(ALUop==3'b010 || ALUop==3'b110)?middle_result:(ALUop==3'b111)?slt_result:1'b0;
	assign Zero = (Result==0)?1:0;
	assign CarryOut = (ALUop==3'b010)?complete_result[32]:(ALUop==3'b110 && b_comp!=32'b0)?~complete_result[32]:1'b0;//the Carry of the adding and subtracting is different.


endmodule
