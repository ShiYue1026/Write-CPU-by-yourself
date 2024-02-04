`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: controller
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


module controller(
	input wire clk,rst,
	//decode stage
//	input wire[5:0] opD,functD,
//	input wire [4:0] rtD,
    input wire [31:0] instrD,
	output wire pcsrcD,branchD,
	input wire equalD,
	output wire jumpD,
	input wire stallD,
	output wire jrD,jalD,jalrD,balD,
	output wire invalidD,
	//execute stage
	input wire flushE,
	output wire memtoregE,
	output wire [1:0] alusrcE,
	output wire regdstE,regwriteE,	
	output wire[4:0] alucontrolE,
	output wire hilo_weE,
	output wire div_validE,
	output wire div_signE,
	input wire stallE,
	//mem stage
	output wire memtoregM,memwriteM,
				regwriteM,
	output wire memenM,
	output wire cp0weM,
	input wire flushM,
	input wire stallM,
	//write back stage
	output wire memtoregW,regwriteW,
	input wire flushW,
	input wire stallW
    );
	
	//decode stage
	wire[3:0] aluopD;
	wire[1:0] alusrcD;
	wire memtoregD,memwriteD,
		regdstD,regwriteD;
	wire[4:0] alucontrolD;
    wire hilo_weD;
    wire div_validD,div_signD;
    wire memenD;
    wire cp0weD;
	//execute stage
	wire memwriteE;
    wire memenE;
    wire cp0weE;
    wire wb_temp;
    
	maindec md(
	   stallD,
//		opD,
//		functD,
//		rtD,
        instrD,
		memtoregD,memwriteD,
		branchD,alusrcD,
		regdstD,regwriteD,
		jumpD,
		aluopD,
		hilo_weD,
		div_validD,
		div_signD,
		jrD,jalD,jalrD,balD,
		memenD,
		cp0weD,
		invalidD
		);
		
	aludec ad(instrD,aluopD,stallD,alucontrolD);

	assign pcsrcD = branchD & equalD;

	//pipeline registers
	flopenrc #(16) regE(
		clk,
		rst,
		~stallE,
		flushE,
		{memtoregD,memwriteD,alusrcD,regdstD,regwriteD,alucontrolD,hilo_weD,div_validD,div_signD,memenD,cp0weD},
		{memtoregE,memwriteE,alusrcE,regdstE,regwriteE,alucontrolE,hilo_weE,div_validE,div_signE,memenE,cp0weE}
		);
		
	flopenrc #(5) regM(
		clk,rst,~stallM,flushM,
		{memtoregE,memwriteE,regwriteE,memenE,cp0weE},
		{memtoregM,memwriteM,regwriteM,memenM,cp0weM}
		);
	flopenrc #(2) regW(
		clk,rst,~stallW,flushW,
		{memtoregM,regwriteM},
		{memtoregW,regwriteW}
		);
endmodule
