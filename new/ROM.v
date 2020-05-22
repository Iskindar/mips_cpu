`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/27 18:25:54
// Design Name: 
// Module Name: ROM
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


module ROM ( rd, addr, dataOut); // �洢��ģ��
    input rd; // ��ʹ���ź�
    input [ 31:0] addr; // �洢����ַ
    output reg [31:0] dataOut; // ���������

    reg [7:0] rom [99:0]; // �洢�����������reg���ͣ� �洢���洢��Ԫ8λ���ȣ� ��100���洢��Ԫ
    
    initial // �������ݵ��洢��rom�� ע�⣺ ����ʹ�þ���·���� �磺 E:/Xlinx/VivadoProject/ROM/���Լ�����
    begin     
        $readmemb ("D:/Xlinx/VivadoProject/CPU/rom_data.txt", rom); // �����ļ�rom_data��.coe��.txt�� �� δָ���� �ʹ�0��ַ��ʼ��š�
        //rom[addr][7:0] = 1'b00000100;
        dataOut = 0;
    end
    
    always @( rd or addr ) begin
        if (rd==1) begin // Ϊ0�� ���洢���� ������ݴ洢ģʽ
            dataOut[31:24] = rom[addr];
            dataOut[23:16] = rom[addr+1];
            dataOut[15:8] = rom[addr+2];
            dataOut[7:0] = rom[addr+3];
        end
    end
endmodule