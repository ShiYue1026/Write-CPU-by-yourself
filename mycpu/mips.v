`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/07 10:58:03
// Design Name: 
// Module Name: mips
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


module mips(
	input wire clk,rst,
	input wire [5:0] ext_int,
//	output wire[31:0] pcF,
//	input wire[31:0] instrF,
//	output wire memwriteM,
	
//	input wire[31:0] readdataM,
    //instr
    output wire inst_req,
    output wire inst_wr,
    output wire [1:0] inst_size,
    output wire [31:0] inst_addr,        
    output wire [31:0] inst_wdata,
    input wire inst_addr_ok,
    input wire inst_data_ok,
    input wire [31:0] inst_rdata,

    //data
    output wire data_req,
    output wire data_wr,
    output wire [1:0] data_size,
    output wire [31:0] data_addr,
    output wire [31:0] data_wdata,
    input wire data_addr_ok,
    input wire data_data_ok,
    input wire [31:0] data_rdata,

    //debug
    output wire [31:0]  debug_wb_pc,      
    output wire [3:0]   debug_wb_rf_wen,
    output wire [4:0]   debug_wb_rf_wnum, 
    output wire [31:0]  debug_wb_rf_wdata

    );
	
//	wire [5:0] opD,functD;
//	wire [4:0] rtD;
	wire [31:0] instrD;
	wire branchD;
	wire [1:0] alusrcE;
	wire regdstE,pcsrcD,memtoregE,memtoregM,memtoregW,regwriteE,regwriteM,memwriteM;
	wire [4:0] alucontrolE;
	wire flushE,equalD;
    wire hilo_weE;
    wire div_validE,div_signE;
    wire stallD,stallE;
    wire jrD,jalD,jalrD,balD,jumpD;
    wire cp0weM;
    wire invalidD;
    wire flushD,flushM,flushW;
    wire[31:0] aluoutM,writedataM;
    wire memenM;
    wire stallM;
    wire flush_except;
    wire [31:0] resultW;
    wire [4:0] writeregW;
    wire regwriteW;
    wire [31:0] pcW;
    wire [3:0] selM;
    wire [31:0] pcF;
    wire longest_stall;
    wire i_stall,d_stall;
    wire stallW;
    //inst_sram
    wire inst_sram_en;
    wire [3 :0] inst_sram_wen;
    wire [31:0] inst_sram_addr;
    wire [31:0] inst_sram_wdata;
    wire [31:0] inst_sram_rdata;
    
    //data_sram
    wire data_sram_en;
    wire [3 :0] data_sram_wen;
    wire [31:0] data_sram_addr;
    wire [31:0] data_sram_wdata;
    wire [31:0] data_sram_rdata;
    
    
	controller c(
		clk,rst,
		//decode stage
//		opD,functD,
//		rtD,
        instrD,
		pcsrcD,branchD,equalD,jumpD,
		stallD,
		jrD,jalD,jalrD,balD,
		invalidD,
		//execute stage
		flushE,
		memtoregE,alusrcE,
		regdstE,regwriteE,	
		alucontrolE,
		hilo_weE,
		div_validE,
		div_signE,
		stallE,
		//mem stage
		memtoregM,memwriteM,
		regwriteM,
		memenM,
		cp0weM,
		flushM,
		stallM,
		//write back stage
		memtoregW,regwriteW,
		flushW,
		stallW
		);
		
	datapath dp(
		clk,rst,
		ext_int,
		//fetch stage
		pcF,
//		instrF,
        inst_sram_rdata,
		//decode stage
		pcsrcD,branchD,
		jumpD,
		equalD,
        instrD,
		stallD,
		jrD,jalD,jalrD,balD,
		invalidD,
		flushD,
		//execute stage
		memtoregE,
		alusrcE,regdstE,
		regwriteE,
		alucontrolE,
		flushE,
		hilo_weE,
		div_validE,
		div_signE,
		stallE,
		//mem stage
		memtoregM,
		regwriteM,
		aluoutM,writedataM,
//		readdataM,
        data_sram_rdata,
		selM,
		cp0weM,
		flush_except,
		flushM,
		stallM,
		//writeback stage
		memtoregW,
		regwriteW,
//		mfhi_loM
        pcW,
        writeregW,
        resultW,
        flushW,
        stallW,
        longest_stall,
        i_stall,d_stall
	    );
	    

    
//    wire [31:0] data_sram_vaddr,inst_sram_vaddr;//�����ַ
    
    assign inst_sram_en = ~flush_except;     //如果有inst_en，就用inst_en
    assign inst_sram_wen = 4'b0;
    assign inst_sram_addr = pcF;
    assign inst_sram_wdata = 32'b0;
//    assign instr = inst_sram_rdata;
    
    assign data_sram_en = memenM &(~flush_except);     //如果有data_en，就用data_en
    assign data_sram_wen = selM;
    assign data_sram_addr = aluoutM;
    assign data_sram_wdata = writedataM;
//    assign readdata = data_sram_rdata;

    assign debug_wb_pc=pcW;
    assign debug_wb_rf_wen={4{regwriteW & ~stallW}};
    assign debug_wb_rf_wnum=writeregW;
    assign debug_wb_rf_wdata=resultW;
    
//    mmu mmu(
//    .inst_vaddr (inst_sram_vaddr ),
//    .inst_paddr(inst_sram_addr),
//    .data_vaddr(data_sram_vaddr ),
//    .data_paddr(data_sram_addr),
//    .no_dcache (no_dcache )
//);
	
	inst_sram_like inst_sram_like(
        .clk(clk), .rst(rst),
        //sram
        .inst_sram_en(inst_sram_en),
        .inst_sram_addr(inst_sram_addr),
        .inst_sram_rdata(inst_sram_rdata),
        .i_stall(i_stall),
        //sram like
        .inst_req(inst_req), 
        .inst_wr(inst_wr),
        .inst_size(inst_size),
        .inst_addr(inst_addr),   
        .inst_wdata(inst_wdata),
        .inst_addr_ok(inst_addr_ok),
        .inst_data_ok(inst_data_ok),
        .inst_rdata(inst_rdata),

        .longest_stall(longest_stall)
    );
    
   data_sram_like data_sram_like(
        .clk(clk), .rst(rst),
        //sram
        .data_sram_en(data_sram_en),
        .data_sram_addr(data_sram_addr),
        .data_sram_rdata(data_sram_rdata),
        .data_sram_wen(data_sram_wen),
        .data_sram_wdata(data_sram_wdata),
        .d_stall(d_stall),
        //sram like
        .data_req(data_req),    
        .data_wr(data_wr),
        .data_size(data_size),
        .data_addr(data_addr),   
        .data_wdata(data_wdata),
        .data_addr_ok(data_addr_ok),
        .data_data_ok(data_data_ok),
        .data_rdata(data_rdata),

        .longest_stall(longest_stall)
    );
    
        //ascii
    instdec instdec(
        .instr(inst_sram_rdata)
    );
endmodule
