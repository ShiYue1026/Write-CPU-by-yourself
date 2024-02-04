`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/23 15:37:05
// Design Name: 
// Module Name: hilo_reg
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


`timescale 1ns / 1ps

module hilo_reg(
	input wire clk,rst,we,
	input wire[31:0] hi_i,lo_i,   //要写入hilo的数据
	output reg[31:0] hi_o,lo_o
    );
	
	always @(posedge clk) begin
		if(rst) begin
			hi_o <= 0;
			lo_o <= 0;
		end 
		else if (we) begin
			hi_o <= hi_i;
			lo_o <= lo_i;
		end else begin
			hi_o <= hi_o;
			lo_o <= lo_o;
		end
	end
endmodule

