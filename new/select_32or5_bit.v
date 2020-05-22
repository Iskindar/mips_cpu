`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/29 17:03:21
// Design Name: 
// Module Name: select_32or5_bit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module select_32or5_bit(
    input [31:0] select_one,
    input [4:0] select_two,
    input control,
    output [31:0] result
    );
    
    wire[31:0] select_three;
    assign select_three[4:0] = select_two;
    assign select_three[31:5] = 1'b000000000000000000000000000;
    assign result = (control == 1'b0 ? select_one : select_three);
endmodule
