`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/23 22:57:01
// Design Name: 
// Module Name: eqcmp
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


module eqcmp(
	input wire [31:0] a,b,
	input wire [5:0] op,
	input wire [4:0] rt,
	output wire y
    );

	assign y = (op==`BEQ)? (a==b):
			   (op==`BNE)? (a!=b):
			   (op==`BGTZ)? ((~a[31]) & a!=`ZeroWord):
			   (op==`BLEZ)? (a[31] | a==`ZeroWord):
			   (op==`REGIMM_INST & (rt==`BLTZ | rt==`BLTZAL))? (a[31]):
			   (op==`REGIMM_INST & (rt==`BGEZ | rt==`BGEZAL))? (~a[31]) :
			   1'b0;
endmodule
