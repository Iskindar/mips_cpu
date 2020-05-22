`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/29 15:47:10
// Design Name: 
// Module Name: select_5_bit
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


module select_5_bit(
    input [4:0] select_one,
    input [4:0] select_two,
    input control,
    output [4:0] result
    );
    
    assign result = (control == 1'b0 ? select_one : select_two);
endmodule
