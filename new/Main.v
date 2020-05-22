`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/29 15:59:18
// Design Name: 
// Module Name: Main
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

module Main(
    input CLK,  //ʱ��
    input Reset,    //�����ź�
    output zero,pcWre,  //ALU����Ƿ�Ϊ0�� PC�����ź�
    output[1:0] pcSrc,  //PC��ѡһѡ�����Ŀ����ź�
    output[2:0] aluop,  //ALU��ִ���ź�
    output[5:0] op, //ָ������Ĵ���
    output[31:0] readData1, readData2, extendData, writeData, o_p, currentAdd, Result   //�Ĵ���1��ȡ��ֵ���Ĵ���2��ȡ��ֵ����չ�����źţ�д��Ĵ��������ݣ� 32λ������ָ� ��ǰָ��ĵ�ַ�� ALU����Ľ��
    );
    wire Zero, PCWre, ALUSrcA, ALUSrcB, DBDataSrc, RegWre, InsMemRW, mRD, mWR, RegDst, ExtSel;
    wire[1:0] PCSrc;
    wire[2:0] ALUOp;
    wire[4:0] fiveout;
    wire[31:0] NewAdd, CurrentAdd, o_pc, WriteData, ReadData1, ReadData2, ExtendData, rega, regb, result, RAMData;
    
    assign o_p = o_pc;
    assign op = o_pc[31:26];
    assign readData1 = ReadData1;
    assign readData2 = ReadData2;
    assign aluop = ALUOp;
    assign zero = Zero;
    assign writeData = WriteData;
    assign currentAdd = CurrentAdd;
    assign pcWre = PCWre;
    assign Result = result;
    assign pcSrc = PCSrc;
    assign extendData = ExtendData;
    ControlUnit cu(
        o_pc[31:26],
        Zero,
        Reset,
        PCWre,
        ALUSrcA,
        ALUSrcB,
        DBDataSrc,
        RegWre,
        InsMemRW,
        mRD,
        mWR,
        RegDst,
        ExtSel,
        PCSrc,
        ALUOp
        );
        
    PC pc(
        CLK,
        Reset,
        PCWre,//ֵΪ0ʱ�����ģ�����ͣ��ָ�ֵΪ1��ʱ����и���
        NewAdd,
        CurrentAdd
        );
       
    ROM rom( 
        InsMemRW, 
        CurrentAdd, 
        o_pc
        );
        
    select_5_bit U5_1(
        o_pc[20:16],
        o_pc[15:11],
        RegDst,
        fiveout
        );
        
    RegFile rf(
        CLK,
        Reset,
        RegWre,
        o_pc[25:21],
        o_pc[20:16],
        fiveout,
        WriteData,
        ReadData1,
        ReadData2
        );
        
    Extend ex(
        o_pc[15:0],
        ExtSel,
        ExtendData
        );
        
    select_32or5_bit U32_1(
        ReadData1,
        o_pc[10:6],
        ALUSrcA,
        rega
        );
        
    select_32_bit U32_2(
        ReadData2,
        ExtendData,
        ALUSrcB,
        regb
        );
 
    ALU alu(
        ALUOp,
        rega,
        regb,
        result,
        Zero
        );  
        
    RAM ram(
        CLK,
        result,
        ReadData2, // [31:24], [23:16], [15:8], [7:0]
        mRD, // Ϊ0�� �������� Ϊ1,�������̬
        mWR, // Ϊ1�� д�� Ϊ0�� �޲���
        RAMData
        );
        
    select_32_bit U32_3(
        result,
        RAMData,
        DBDataSrc,
        WriteData
        );
        
    PCcounter pccounter(
        PCSrc,
        CurrentAdd,
        NewAdd,
        ExtendData,
        o_pc[25:0]
        );
endmodule
