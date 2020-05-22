`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/25 10:03:47
// Design Name: 
// Module Name: PC
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


module PC(
    input CLK,
    input Reset,
    input PCWre,//ֵΪ0ʱ�����ģ�����ͣ��ָ�ֵΪ1��ʱ����и���
    input [31:0] NewAdd,
    output reg[31:0] CurrentAdd
    );
    
    initial begin
        CurrentAdd <= -8;
    end
    
    always@(posedge CLK or posedge Reset)
        begin
            if(Reset == 0) CurrentAdd <= 0;
            else 
                begin
                    if(PCWre == 0) CurrentAdd <= CurrentAdd;
                    else CurrentAdd <= NewAdd;
                end
        end
endmodule
