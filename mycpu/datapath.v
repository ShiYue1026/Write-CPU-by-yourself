`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 15:12:22
// Design Name: 
// Module Name: datapath
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


module datapath(
	input wire clk,rst,
	input wire [5:0] ext_int,
	//fetch stage
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	//decode stage
	input wire pcsrcD,branchD,
	input wire jumpD,
	output wire equalD,
    output wire [31:0] instrD,
	output wire stallD,
	input wire jrD,jalD,jalrD,balD,
	input wire invalidD,   //指令异常
	output wire flushD,
	//execute stage
	input wire memtoregE,
	input wire[1:0] alusrcE,
	input wire regdstE,
	input wire regwriteE,
	input wire[4:0] alucontrolE,
	output wire flushE,
	input wire hilo_weE,
	input wire div_validE,
	input wire div_signE,
	output wire stallE,
	//mem stage
	input wire memtoregM,
	input wire regwriteM,
	output wire[31:0] aluoutM,final_writedataM,
	input wire[31:0] readdataM,
	output wire [3:0] selM,
	input wire cp0weM,
	output wire flush_except,
	output wire flushM,
	output wire stallM,
	//writeback stage
	input wire memtoregW,
	input wire regwriteW,
	output wire [31:0] pcW,
	output wire [4:0] writeregW,
	output wire [31:0] resultW,
	output wire flushW,
	output wire stallW,
	output wire longest_stall,
	input wire i_stall,d_stall
    );
	
	//fetch stage
	wire stallF;
	wire [7:0] exceptF;   //7:F 6:D 5:D 4:D 3:D 2: 1: 0:
	wire flushF;
	wire is_in_delayslotF;
	//FD
	wire [31:0] pcnextFD,pcnextbrFD,pcplus4F,pcbranchD,pcnext2FD;
	//decode stage
	wire [31:0] pcplus4D;
	wire [1:0] forwardaD,forwardbD;
	wire[5:0] opD,functD;
	wire [4:0] rsD,rdD,rtD;
//    wire [31:0] instrD;
	wire [4:0] saD;
	wire [31:0] signimmD,signimmshD;
	wire [31:0] zeroimmD;
	wire [31:0] srcaD,srca2D,srcbD,srcb2D;
	wire [31:0] pcD;
	wire [7:0] exceptD;
	wire eretD,breakD,syscallD;
	wire invalid2D;
	wire is_in_delayslotD;
	//execute stage
	wire [1:0] forwardaE,forwardbE;
	wire [4:0] rsE,rtE,rdE;
	wire [4:0] saE;
	wire [4:0] writeregE,writereg2E;
	wire [31:0] signimmE;
	wire [31:0] zeroimmE;
	wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E;
	wire [31:0] aluoutE,aluout2E;
	wire [63:0] hilo_inE,hilo_outE,hilo_out2E;
	wire div_stallE;
	wire [63:0] div_resultE;
	wire div_signal;
	wire jrE,jalE,jalrE,balE;
	wire [31:0] pcE;
	wire [5:0] opE;
	wire [31:0] cp0_inE,cp0_in2E;
    wire overflow;
    wire [31:0] cp0_outE;
    wire forwardcp0E;
    wire [7:0] exceptE;
    wire is_in_delayslotE;
	//mem stage
	wire [4:0] writeregM;
	wire [31:0] pcM;
	wire [5:0] opM;
	wire [31:0] final_readdataM;
	wire [31:0] writedataM,resultM;
	wire [31:0] cp0_outM;
	wire [4:0] rdM;
	wire [7:0] exceptM;    //精确异常：所有异常到mem阶段处理
	wire [4:0] tlb_except2M;
	wire timer_int_o;
	wire [31:0] excepttypeM;
	wire[`RegBus] count_o,compare_o,status_o,cause_o,epc_o, config_o,prid_o,badvaddr;
	wire adelM,adesM;
	wire [31:0] bad_addrM;
	wire is_in_delayslotM;
	wire [31:0] newpcM;
//	wire [31:0] final_writedataM;

	//writeback stage
//	wire [4:0] writeregW;
	wire [31:0] aluoutW,readdataW;
	wire cp0weW;
	
//    wire [31:0] pcW;
    
	//hazard detection
	hazard h(
		//fetch stage
		stallF,
		flushF,
		//decode stage
		rsD,rtD,
		branchD,
		forwardaD,forwardbD,
		stallD,
		flushD,
		//execute stage
		rsE,rtE,
		writeregE,
		regwriteE,
		memtoregE,
		forwardaE,forwardbE,
		flushE,
		div_stallE,
		stallE,
		rdE,
		forwardcp0E,
		//mem stage
		writeregM,
		regwriteM,
		memtoregM,
		cp0weM,
		rdM,
		excepttypeM,
		flush_except,
		flushM,
		newpcM,
		epc_o,
		stallM,
		//write back stage
		writeregW,
		regwriteW,
		flushW,
		longest_stall,
		i_stall,d_stall,
		stallW
		);

    assign opD = instrD[31:26];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];
    assign saD = instrD[10:6]; 
    assign functD = instrD[5:0];
    assign div_signal = ((alucontrolE == `DIV_CONTROL)|(alucontrolE == `DIVU_CONTROL))? 1 : 0;
    assign tlb_except2M = 5'b00000;
    
	//next PC logic (operates in fetch an decode)
	mux2 #(32) pcbrmux(pcplus4F,pcbranchD,pcsrcD,pcnextbrFD);
	mux2 #(32) pcmux(pcnextbrFD,{pcplus4D[31:28],instrD[25:0],2'b00},jumpD|jalD,pcnextFD);
    mux2 #(32) pcjrmux(pcnextFD, srca2D, jrD|jalrD, pcnext2FD);
    
    assign exceptF = (pcF[1:0] == 2'b00) ? 8'b00000000 : 8'b10000000;  //判断PC是否出错
    assign is_in_delayslotF = (jumpD|jalrD|jrD|jalD|branchD);
    
	//regfile (operates in decode and writeback)
	regfile rf(clk,regwriteW,rsD,rtD,writeregW,resultW,srcaD,srcbD);
   
	//fetch stage logic
	pc #(32) pcreg(clk,rst,~stallF,flushF,pcnext2FD,newpcM,pcF);
	adder pcadd1(pcF,32'b100,pcplus4F);
	//decode stage
	flopenrc #(32) r1D(clk,rst,~stallD,flushD,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(clk,rst,~stallD,flushD,instrF,instrD);
	flopenrc #(32) r3D(clk,rst,~stallD,flushD,pcF,pcD);
	flopenrc #(8) r4D(clk,rst,~stallD,flushD,exceptF,exceptD);
	flopenrc #(1) r5D(clk,rst,~stallD,flushD,is_in_delayslotF,is_in_delayslotD);
	
	assign eretD = (instrD == 32'b01000010000000000000000000011000) && (~stallD);  //直接根据指令32位判断是否是eret指令
	assign breakD  = (opD == 6'b000000 && functD == 6'b001101) && (~stallD);
    assign syscallD  = (opD == 6'b000000 && functD == 6'b001100) && (~stallD);
	assign invalid2D = invalidD && (~stallD);
	
	signext se(instrD[15:0],signimmD);
	zeroext ze(instrD[15:0],zeroimmD);        //零扩展
	sl2 immsh(signimmD,signimmshD);
	adder pcadd2(pcplus4D,signimmshD,pcbranchD);
	mux3 #(32) forwardadmux(srcaD,aluout2E,resultM,forwardaD,srca2D);
	mux3 #(32) forwardbdmux(srcbD,aluout2E,resultM,forwardbD,srcb2D);

	eqcmp comp(srca2D,srcb2D,opD,rtD,equalD);
    
    
    
	//execute stage
	flopenrc #(32) r1E(clk,rst,~stallE,flushE,srcaD,srcaE);
	flopenrc #(32) r2E(clk,rst,~stallE,flushE,srcbD,srcbE);
	flopenrc #(32) r3E(clk,rst,~stallE,flushE,signimmD,signimmE);
	flopenrc #(32) r7E(clk,rst,~stallE,flushE,zeroimmD,zeroimmE);
	flopenrc #(5) r4E(clk,rst,~stallE,flushE,rsD,rsE);
	flopenrc #(5) r5E(clk,rst,~stallE,flushE,rtD,rtE);
	flopenrc #(5) r6E(clk,rst,~stallE,flushE,rdD,rdE);
    flopenrc #(5) r8E(clk,rst,~stallE,flushE,saD,saE);
    flopenrc #(4) r9E(clk,rst,~stallE,flushE,{jrD,jalD,jalrD,balD},{jrE,jalE,jalrE,balE});
    flopenrc #(32) r10E(clk,rst,~stallE,flushE,pcD,pcE);
    flopenrc #(6) r11E(clk,rst,~stallE,flushE,opD,opE);
    flopenrc #(8) r12E(clk,rst,~stallE,flushE,{exceptD[7],syscallD,breakD,eretD,invalid2D,exceptD[2:0]},exceptE);
    flopenrc #(1) r13E(clk,rst,~stallE,flushE,is_in_delayslotD,is_in_delayslotE);
    
    mux2 #(32) forwardcp0mux(cp0_inE,cp0_outM,forwardcp0E,cp0_in2E);
	mux3 #(32) forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E);
	mux3 #(32) forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);
	mux3 #(32) srcbmux(srcb2E,signimmE,zeroimmE,alusrcE,srcb3E);
	alu alu(srca2E,srcb3E,saE,hilo_inE,alucontrolE,cp0_in2E,aluoutE,hilo_outE,overflow,cp0_outE);
	quick_div quick_div(clk,rst,srca2E,srcb3E,div_validE,div_signE,div_stallE,div_resultE);
	mux2 #(64) div_mux(hilo_outE, div_resultE, div_signal, hilo_out2E);
	
	hilo_reg hilo(clk,rst,(hilo_weE&(~flushE)),hilo_out2E[63:32], hilo_out2E[31:0], hilo_inE[63:32], hilo_inE[31:0]);
	
	mux2 #(5) wrmux(rtE,rdE,regdstE,writeregE);
    mux2 #(5) wrmux2(writeregE, 5'b11111, jalE|balE, writereg2E);   //jal和bal指令的话需要写入31号寄存器
    mux2 #(32) wrmux3(aluoutE, pcE+8, jalE|jrE|jalrE|balE, aluout2E); //选择写入寄存器的值是alu计算的结果还是PC+8
    
	//mem stage
	flopenrc #(32) r1M(clk,rst,~stallM,flushM,srcb2E,writedataM);
	flopenrc #(32) r2M(clk,rst,~stallM,flushM,aluout2E,aluoutM);
	flopenrc #(5) r3M(clk,rst,~stallM,flushM,writereg2E,writeregM);
    flopenrc #(32) r4M(clk,rst,~stallM,flushM,pcE,pcM);
    flopenrc #(6) r5M(clk,rst,~stallM,flushM,opE,opM);
    flopenrc #(32) r6M(clk,rst,~stallM,flushM,cp0_outE,cp0_outM);
    flopenrc #(5) r7M(clk,rst,~stallM,flushM,rdE,rdM);
    flopenrc #(8) r8M(clk,rst,~stallM,flushM,{exceptE[7:3],overflow,exceptE[1:0]},exceptM);
    flopenrc #(1) r9M(clk,rst,~stallM,flushM,is_in_delayslotE,is_in_delayslotM);
    
    memory_select ms(pcM,opM,aluoutM,readdataM,writedataM,selM,final_readdataM,final_writedataM,adelM,adesM,bad_addrM);
    
    mux2 #(32) resmux(aluoutM, final_readdataM, memtoregM, resultM);   //将二选一操作提前到M阶段，方便数据前推
    
	exception exc(rst,exceptM,tlb_except2M,adelM,adesM,status_o,cause_o,excepttypeM,cp0weW);// 异常类型判断
	
	// cp0寄存器
	cp0_reg cp0(
		.clk(clk),
		.rst(rst),
		.we_i(cp0weM),    //M阶段写cp0
		.waddr_i(rdM),    
		.raddr_i(rdE),    //E阶段读cp0
		.data_i(cp0_outM),
		.int_i(ext_int),
		.excepttype_i(excepttypeM),
		.current_inst_addr_i(pcM),
		.is_in_delayslot_i(is_in_delayslotM),
		.bad_addr_i(bad_addrM),
		.data_o(cp0_inE),
		.count_o(count_o),
		.compare_o(compare_o),
		.status_o(status_o),
		.cause_o(cause_o),
		.epc_o(epc_o),
		.config_o(config_o),
		.prid_o(prid_o),
		.badvaddr(badvaddr),
		.timer_int_o(timer_int_o)
	);

	//writeback stage
	flopenrc #(32) r1W(clk,rst,~stallW,flushW,aluoutM,aluoutW);
	flopenrc #(32) r2W(clk,rst,~stallW,flushW,final_readdataM,readdataW);
	flopenrc #(5) r3W(clk,rst,~stallW,flushW,writeregM,writeregW);
	flopenrc #(32) r4W(clk,rst,~stallW,flushW,resultM,resultW);
	flopenrc #(32) r5W(clk,rst,~stallW,flushW,pcM,pcW);
	flopenrc #(1) r6W(clk,rst,~stallW,flushW,cp0weM,cp0weW);
//	mux2 #(32) resmux(aluoutW,readdataW,memtoregW,resultW);
endmodule
