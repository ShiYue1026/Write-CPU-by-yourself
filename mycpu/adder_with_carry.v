`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/25 00:11:39
// Design Name: 
// Module Name: adder_with_carry
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


module adder_with_carry (
    input carryin,
    input [32:0] x,y,
    output [32:0] s,
    output carryout
    );
    wire [33:0] c;

    assign c[0] = carryin;
    assign carryout = c[33];
    
    full_adder fa0(c[0],x[0],y[0],s[0],c[1]);
    full_adder fa1(c[1],x[1],y[1],s[1],c[2]);
    full_adder fa2(c[2],x[2],y[2],s[2],c[3]);
    full_adder fa3(c[3],x[3],y[3],s[3],c[4]);
    full_adder fa4(c[4],x[4],y[4],s[4],c[5]);
    full_adder fa5(c[5],x[5],y[5],s[5],c[6]);
    full_adder fa6(c[6],x[6],y[6],s[6],c[7]);
    full_adder fa7(c[7],x[7],y[7],s[7],c[8]);
    full_adder fa8(c[8],x[8],y[8],s[8],c[9]);
    full_adder fa9(c[9],x[9],y[9],s[9],c[10]);
    full_adder fa10(c[10],x[10],y[10],s[10],c[11]);
    full_adder fa11(c[11],x[11],y[11],s[11],c[12]);
    full_adder fa12(c[12],x[12],y[12],s[12],c[13]);
    full_adder fa13(c[13],x[13],y[13],s[13],c[14]);
    full_adder fa14(c[14],x[14],y[14],s[14],c[15]);
    full_adder fa15(c[15],x[15],y[15],s[15],c[16]);
    full_adder fa16(c[16],x[16],y[16],s[16],c[17]);
    full_adder fa17(c[17],x[17],y[17],s[17],c[18]);
    full_adder fa18(c[18],x[18],y[18],s[18],c[19]);
    full_adder fa19(c[19],x[19],y[19],s[19],c[20]);
    full_adder fa20(c[20],x[20],y[20],s[20],c[21]);
    full_adder fa21(c[21],x[21],y[21],s[21],c[22]);
    full_adder fa22(c[22],x[22],y[22],s[22],c[23]);
    full_adder fa23(c[23],x[23],y[23],s[23],c[24]);
    full_adder fa24(c[24],x[24],y[24],s[24],c[25]);
    full_adder fa25(c[25],x[25],y[25],s[25],c[26]);
    full_adder fa26(c[26],x[26],y[26],s[26],c[27]);
    full_adder fa27(c[27],x[27],y[27],s[27],c[28]);
    full_adder fa28(c[28],x[28],y[28],s[28],c[29]);
    full_adder fa29(c[29],x[29],y[29],s[29],c[30]);
    full_adder fa30(c[30],x[30],y[30],s[30],c[31]);
    full_adder fa31(c[31],x[31],y[31],s[31],c[32]);
    
    assign s[32]  = x[32] ^ y[32] ^ c[32];
    assign c[33] = (x[32] & y[32]) | (x[32] & c[32]) | (y[32] & c[32]);
    
endmodule
