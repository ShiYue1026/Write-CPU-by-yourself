`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/22 10:23:13
// Design Name: 
// Module Name: hazard
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


module hazard(
	//fetch stage
	output wire stallF,
	output wire flushF,
	//decode stage
	input wire[4:0] rsD,rtD,
	input wire branchD,
	output wire [1:0] forwardaD,forwardbD,
	output wire stallD,
	output wire flushD,
	//execute stage
	input wire[4:0] rsE,rtE,
	input wire[4:0] writeregE,
	input wire regwriteE,
	input wire memtoregE,
	output reg[1:0] forwardaE,forwardbE,
	output wire flushE,
	input wire div_stallE,
	output wire stallE,
	input wire [4:0] rdE,
	output wire forwardcp0E,
	//mem stage
	input wire[4:0] writeregM,
	input wire regwriteM,
	input wire memtoregM,
    input wire cp0weM,
    input wire [4:0] rdM,
    input wire [31:0] excepttypeM,
    output wire flush_except,
    output wire flushM,
    output reg [31:0] newpcM,
    input wire [31:0] cp0_epcM,
    output wire stallM,
	//write back stage
	input wire[4:0] writeregW,
	input wire regwriteW,
	output wire flushW,
	output wire longest_stall,
	input wire i_stall,
	input wire d_stall,
	output wire stallW
    );

	wire lwstallD,branchstallD;

	//forwarding sources to D stage (branch equality)
//	assign forwardaD = (rsD != 0 & rsD == writeregM & regwriteM);
//	assign forwardbD = (rtD != 0 & rtD == writeregM & regwriteM);
    assign forwardaD =	(rsD==0)? 2'b00:
						(rsD == writeregE & regwriteE)?2'b01:
						(rsD == writeregM & regwriteM)?2'b10:2'b00;
	assign forwardbD =	(rtD==0)?2'b00:
						(rtD == writeregE & regwriteE)?2'b01:
						(rtD == writeregM & regwriteM)?2'b10:2'b00;
	
	//forwarding sources to E stage (ALU)

    assign forwardcp0E = ((cp0weM)&(rdM == rdE)&(rdE != 0))?1:0;
    
	always @(*) begin
		forwardaE = 2'b00;
		forwardbE = 2'b00;
		if(rsE != 0) begin
			/* code */
			if(rsE == writeregM & regwriteM) begin
				/* code */
				forwardaE = 2'b10;
			end else if(rsE == writeregW & regwriteW) begin
				/* code */
				forwardaE = 2'b01;
			end
		end
		if(rtE != 0) begin
			/* code */
			if(rtE == writeregM & regwriteM) begin
				/* code */
				forwardbE = 2'b10;
			end else if(rtE == writeregW & regwriteW) begin
				/* code */
				forwardbE = 2'b01;
			end
		end
	end
    
    assign flush_except = (excepttypeM != 32'b0 );
    
	//stalls
	assign lwstallD = memtoregE & (rtE == rsD | rtE == rtD);
	assign branchstallD = branchD &
				(regwriteE & 
				(writeregE == rsD | writeregE == rtD) |
				memtoregM &
				(writeregM == rsD | writeregM == rtD));
				
	assign longest_stall = i_stall | d_stall | div_stallE;
//	assign stallF = lwstallD | branchstallD | div_stallE;
//	assign stallD = lwstallD | branchstallD | div_stallE;
//	assign stallE = div_stallE;
	
	assign stallF = longest_stall|branchstallD|lwstallD;
	assign stallD = longest_stall|branchstallD|lwstallD;
	assign stallE = longest_stall;
	assign stallM = longest_stall;
    assign stallW = longest_stall;
	
		//stalling D stalls all previous stages
//	assign #1 flushE = stallD;
    assign flushF = flush_except;
    assign flushD = flush_except;
    assign flushE = (lwstallD | branchstallD|flush_except) & ~longest_stall;
    assign flushM = flush_except;
	assign flushW = flush_except;
		//stalling D flushes next stage
	// Note: not necessary to stall D stage on store
  	//       if source comes from load;
  	//       instead, another bypass network could
  	//       be added from W to M
  	
  	//跳转到异常处理地址运行异常处理程序
  	always @(*) begin
  	    newpcM=32'b0;
        if(excepttypeM != 32'b0) begin
            if(excepttypeM == 32'h0000000e) begin  //eret
                newpcM = cp0_epcM;
            end
            else begin
                newpcM = 32'hbfc00380; 
            end
        end
    end
endmodule
