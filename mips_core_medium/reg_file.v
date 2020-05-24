`timescale 10 ns / 1 ns

`define DATA_WIDTH 32  
`define ADDR_WIDTH 5 
`define NUM 32 //amount of register
module reg_file(
	input clk,		//clock
	input rst,		//reset
	input [`ADDR_WIDTH - 1:0] waddr, //address for writing
	input [`ADDR_WIDTH - 1:0] raddr1,//address 1 for reading
	input [`ADDR_WIDTH - 1:0] raddr2,//address 2 for reading 
	input wen, // write enable
	input [`DATA_WIDTH - 1:0] wdata,//data to write
	output [`DATA_WIDTH - 1:0] rdata1,//data1 to read
	output [`DATA_WIDTH - 1:0] rdata2//data2 to read
);

	// TODO: Please add your logic code here
	reg  [`DATA_WIDTH :1]reg_data[0:`NUM-1];//define register file
	
	//write data synchronously
	always@(posedge clk) 
	begin
		if(rst)
			reg_data[0]<=0; //reset reg0
		else
			if(wen && waddr!=0) //reg0 can't be wrote 
				reg_data[waddr]<=wdata ; //write data to the specified register in the register file
	end
	//read data asynchronously
	assign rdata1 = reg_data[raddr1];
	assign rdata2 = reg_data[raddr2];
endmodule
